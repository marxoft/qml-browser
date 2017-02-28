/*
 * Copyright (C) 2014 Stuart Howarth <showarth@marxoft.co.uk>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms and conditions of the GNU General Public License,
 * version 3, as published by the Free Software Foundation.
 *
 * This program is distributed in the hope it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License
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

Download::Download(const QString &id, const QNetworkRequest &request, const QString &fileName, qint64 size,
                   qint64 received, QObject *parent) :
    QObject(parent),
    m_nam(0),
    m_reply(0),
    m_id(id),
    m_request(request),
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
        m_reply = 0;
    }
}

QString Download::id() const {
    return m_id;
}

QNetworkRequest Download::request() const {
    return m_request;
}

void Download::setRequest(const QNetworkRequest &r) {
    m_request = r;
    emit requestChanged();
}

QString Download::fileName() const {
    return m_fileName;
}

void Download::setFileName(const QString &f) {
    if (f != fileName()) {
        m_fileName = f;
        emit fileNameChanged();
    }
}

qint64 Download::size() const {
    return m_size;
}

void Download::setSize(qint64 s) {
    if (s != size()) {
        m_size = s;
        emit sizeChanged();
    }
}

qint64 Download::bytesReceived() const {
    return m_received;
}

void Download::setBytesReceived(qint64 r) {
    m_received = r;
}

int Download::progress() const {
    return m_progress;
}

void Download::setProgress(int p) {
    if (p != progress()) {
        m_progress = p;
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
    if (!isRunning()) {
        startDownload();
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
    m_file.setFileName(fileName() + TEMP_SUFFIX);

    if (!m_file.open(QIODevice::Append)) {
        m_error = FileError;
        m_errorString = m_file.errorString();
        emit finished(this);
        return;
    }

    m_error = NoError;
    m_errorString = QString();
    m_redirects = 0;

    if (!m_nam) {
        m_nam = new QNetworkAccessManager(this);
    }

    m_reply = m_nam->get(request());
    connect(m_reply, SIGNAL(metaDataChanged()), this, SLOT(onMetaDataChanged()));
    connect(m_reply, SIGNAL(readyRead()), this, SLOT(onReadyRead()));
    connect(m_reply, SIGNAL(finished()), this, SLOT(onReplyFinished()));
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

    m_file.setFileName(fileName() + TEMP_SUFFIX);

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
    
    QNetworkRequest r = request();
    r.setUrl(url);
    m_reply = m_nam->get(r);
    connect(m_reply, SIGNAL(metaDataChanged()), this, SLOT(onMetaDataChanged()));
    connect(m_reply, SIGNAL(readyRead()), this, SLOT(onReadyRead()));
    connect(m_reply, SIGNAL(finished()), this, SLOT(onReplyFinished()));
    emit runningChanged();
}

void Download::onMetaDataChanged() {
    if (m_reply) {
        qint64 size = m_reply->header(QNetworkRequest::ContentLengthHeader).toLongLong();

        if (size <= 0) {
            size = m_reply->rawHeader("Content-Length").toLongLong();
        }

        if (size > 0) {
            setSize(size);
        }
    }
}

void Download::onReadyRead() {
    if (m_reply) {
        m_received += m_reply->bytesAvailable();
        m_file.write(m_reply->readAll());

        if (m_size > 0) {
            setProgress(m_received * 100 / m_size);
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
        followRedirect(redirect);
    }
    else {
        int i = 1;
        QString oldFileName = fileName();
        QString newFileName = oldFileName;

        while ((QFile::exists(newFileName)) && (i < 100)) {
            const int lastDot = oldFileName.lastIndexOf('.');
            newFileName = QString("%1(%2)%3").arg(oldFileName.left(lastDot)).arg(i).arg(oldFileName.mid(lastDot));
            i++;
        }

        if (!m_file.rename(newFileName)) {
            m_error = FileError;
            m_errorString = m_file.errorString();
        }

        emit finished(this);
    }
}
