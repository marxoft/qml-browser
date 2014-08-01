/*
 * Copyright (C) 2014 Stuart Howarth <showarth@marxoft.co.uk>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms and conditions of the GNU Lesser General Public License,
 * version 3, as published by the Free Software Foundation.
 *
 * This program is distributed in the hope it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for
 * more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
 */

#include "download.h"
#include <QNetworkAccessManager>

static const int MAX_REDIRECTS = 8;
static const QString TEMP_SUFFIX(".qbdownload");

Download::Download(const QString &id, QObject *parent) :
    QObject(parent),
    m_nam(0),
    m_reply(0),
    m_id(id),
    m_size(0),
    m_received(0),
    m_progress(0),
    m_error(NoError)
{
}

Download::Download(const QString &id, const QUrl &url, const QVariantMap &headers, const QString &fileName, qint64 size, qint64 received, QObject *parent) :
    QObject(parent),
    m_nam(0),
    m_reply(0),
    m_id(id),
    m_url(url),
    m_headers(headers),
    m_fileName(fileName),
    m_size(size),
    m_received(received),
    m_progress((size > 0) && (received > 0) ? received * 100 / size : 0),
    m_error(NoError)
{
}

Download::~Download() {
    if (m_reply) {
        delete m_reply;
    }
}

QString Download::id() const {
    return m_id;
}

QUrl Download::url() const {
    return m_url;
}

void Download::setUrl(const QUrl &url) {
    if (url != this->url()) {
        m_url = url;
        emit urlChanged();
    }
}

QVariantMap Download::headers() const {
    return m_headers;
}

void Download::setHeaders(const QVariantMap &headers) {
    m_headers = headers;
    emit headersChanged();
}

QString Download::fileName() const {
    return m_fileName;
}

void Download::setFileName(const QString &fileName) {
    if (fileName != this->fileName()) {
        m_fileName = fileName;
        emit fileNameChanged();
    }
}

qint64 Download::size() const {
    return m_size;
}

void Download::setSize(qint64 size) {
    if (size != this->size()) {
        m_size = size;
        emit sizeChanged();
    }
}

qint64 Download::bytesReceived() const {
    return m_received;
}

void Download::setBytesReceived(qint64 received) {
    m_received = received;
}

int Download::progress() const {
    return m_progress;
}

void Download::setProgress(int progress) {
    if (progress != this->progress()) {
        m_progress = progress;
        emit progressChanged();
    }
}

bool Download::isRunning() const {
    return (m_reply) && (m_reply->isRunning());
}

Download::Error Download::error() const {
    return m_error;
}

QString Download::errorString() const {
    return m_errorString;
}

void Download::queue() {
    m_error = Download::NoError;
    m_errorString = QString();
    emit queued(this);
}

void Download::start() {
    if (!this->isRunning()) {
        this->startDownload();
    }
}

void Download::pause() {
    if (m_reply) {
        m_reply->abort();
    }

    emit paused(this);
}

void Download::cancel() {
    if (m_reply) {
        m_reply->abort();
    }

    if (m_file.exists()) {
        m_file.remove();
    }

    emit canceled(this);
}

void Download::startDownload() {
    m_file.setFileName(this->fileName() + TEMP_SUFFIX);

    if (!m_file.open(QIODevice::Append)) {
        m_error = FileError;
        m_errorString = m_file.errorString();
        emit finished(this);
        return;
    }

    m_error = NoError;
    m_errorString = QString();
    m_redirects = 0;
    QNetworkRequest request(this->url());

    QMapIterator<QString, QVariant> iterator(this->headers());

    while (iterator.hasNext()) {
        iterator.next();
        request.setRawHeader(iterator.key().toUtf8(), iterator.value().toByteArray());
    }

    if (!m_nam) {
        m_nam = new QNetworkAccessManager(this);
    }

    m_reply = m_nam->get(request);
    this->connect(m_reply, SIGNAL(metaDataChanged()), this, SLOT(onMetaDataChanged()));
    this->connect(m_reply, SIGNAL(readyRead()), this, SLOT(onReadyRead()));
    this->connect(m_reply, SIGNAL(finished()), this, SLOT(onReplyFinished()));
    emit runningChanged();
    emit started(this);
}

void Download::followRedirect(const QUrl &url) {
    m_redirects++;

    if (m_redirects > MAX_REDIRECTS) {
        m_error = ContentNotFoundError;
        m_errorString = tr("Maximum redirects reached");
        emit finished(this);
        return;
    }

    m_file.setFileName(this->fileName() + TEMP_SUFFIX);

    if (!m_file.open(QIODevice::Append)) {
        m_error = FileError;
        m_errorString = m_file.errorString();
        emit finished(this);
        return;
    }

    m_error = NoError;
    m_errorString = QString();

    if (!m_nam) {
        m_nam = new QNetworkAccessManager(this);
    }

    m_reply = m_nam->get(QNetworkRequest(url));
    this->connect(m_reply, SIGNAL(metaDataChanged()), this, SLOT(onMetaDataChanged()));
    this->connect(m_reply, SIGNAL(readyRead()), this, SLOT(onReadyRead()));
    this->connect(m_reply, SIGNAL(finished()), this, SLOT(onReplyFinished()));
    emit runningChanged();
}

void Download::onMetaDataChanged() {
    if (m_reply) {
        qint64 size = m_reply->header(QNetworkRequest::ContentLengthHeader).toLongLong();

        if (size <= 0) {
            size = m_reply->rawHeader("Content-Length").toLongLong();
        }

        if (size > 0) {
            this->setSize(size);
        }
    }
}

void Download::onReadyRead() {
    if (m_reply) {
        m_received += m_reply->bytesAvailable();
        m_file.write(m_reply->readAll());

        if (m_size > 0) {
            this->setProgress(m_received * 100 / m_size);
        }
    }
}

void Download::onReplyFinished() {
    if (!m_reply) {
        return;
    }

    m_file.close();

    switch (m_reply->error()) {
    case QNetworkReply::OperationCanceledError:
        m_error = NoError;
        m_errorString = QString();
        m_reply->deleteLater();
        m_reply = 0;
        emit runningChanged();
        return;
    default:
        m_error = Error(m_reply->error());
        m_errorString = m_reply->errorString();
        break;
    }

    QUrl redirect = m_reply->attribute(QNetworkRequest::RedirectionTargetAttribute).toUrl();

    if (redirect.isEmpty()) {
        redirect = m_reply->header(QNetworkRequest::LocationHeader).toUrl();
    }

    m_reply->deleteLater();
    m_reply = 0;
    emit runningChanged();

    if (!redirect.isEmpty()) {
        this->followRedirect(redirect);
    }
    else {
        int i = 1;
        QString fileName = this->fileName();

        while ((QFile::exists(fileName)) && (i < 100)) {
            const int lastDot = this->fileName().lastIndexOf('.');
            fileName = QString("%1(%2)%3").arg(this->fileName().left(lastDot)).arg(i).arg(this->fileName().mid(lastDot));
            i++;
        }

        if (!m_file.rename(fileName)) {
            m_error = FileError;
            m_errorString = m_file.errorString();
        }

        emit finished(this);
    }
}
