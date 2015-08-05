/*
 * Copyright (C) 2015 Stuart Howarth <showarth@marxoft.co.uk>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "downloadmodel.h"
#include "utils.h"
#include <QSettings>
#include <QMaemo5InformationBox>
#include <QDateTime>
#include <QDebug>

static const QString FILE_NAME("/home/user/.config/QMLBrowser/downloads");
static const int MAX_DOWNLOADS = 1;

DownloadModel::DownloadModel(QObject *parent) :
    QAbstractListModel(parent)
{
    QHash<int, QByteArray> roles;
    roles[Qt::DisplayRole] = "display";
    roles[NameRole] = "name";
    roles[SizeRole] = "size";
    roles[BytesReceivedRole] = "bytesReceived";
    roles[ProgressRole] = "progress";
    roles[IsRunningRole] = "running";
    roles[ErrorRole] = "error";
    roles[ErrorStringRole] = "errorString";
    setRoleNames(roles);
}

DownloadModel::~DownloadModel() {}

int DownloadModel::activeDownloads() const {
    return m_activeList.size();
}

int DownloadModel::rowCount(const QModelIndex &) const {
    return m_list.size();
}

QVariant DownloadModel::data(const QModelIndex &index, int role) const {
    Download *download = get(index.row());

    if (!download) {
        return QVariant();
    }

    switch (role) {
    case FileNameRole:
        return download->fileName();
    case NameRole:
        return download->fileName().section('/', -1);
    case SizeRole:
        return download->size();
    case BytesReceivedRole:
        return download->bytesReceived();
    case ProgressRole:
        return download->progress();
    case IsRunningRole:
        return download->isRunning();
    case ErrorRole:
        return download->error();
    case ErrorStringRole:
        return download->errorString();
    default:
        return QVariant();
    }
}

QVariant DownloadModel::data(int row, int role) const {
    return data(index(row), role);
}

Download* DownloadModel::get(int row) const {
    if ((row >= 0) && (row < m_list.size())) {
        return m_list.at(row);
    }

    return 0;
}

void DownloadModel::load() {
    QSettings settings(FILE_NAME, QSettings::NativeFormat);

    foreach (QString group, settings.childGroups()) {
        settings.beginGroup(group);
        QUrl url(settings.value("url").toUrl());
        QString fileName(settings.value("fileName").toString());

        if ((url.isValid()) && (!fileName.isEmpty())) {
            Download *download = new Download(group,
                                              url,
                                              settings.value("headers").toMap(),
                                              fileName,
                                              settings.value("size").toLongLong(),
                                              settings.value("bytesReceived").toLongLong(),
                                              this);

            connect(download, SIGNAL(queued(Download*)), this, SLOT(onDownloadQueued(Download*)));
            connect(download, SIGNAL(started(Download*)), this, SLOT(onDownloadStarted(Download*)));
            connect(download, SIGNAL(paused(Download*)), this, SLOT(onDownloadPaused(Download*)));
            connect(download, SIGNAL(canceled(Download*)), this, SLOT(onDownloadCanceled(Download*)));
            connect(download, SIGNAL(finished(Download*)), this, SLOT(onDownloadFinished(Download*)));
            connect(download, SIGNAL(fileNameChanged()), this, SLOT(onDownloadDataChanged()));
            connect(download, SIGNAL(sizeChanged()), this, SLOT(onDownloadDataChanged()));
            connect(download, SIGNAL(progressChanged()), this, SLOT(onDownloadDataChanged()));
            connect(download, SIGNAL(runningChanged()), this, SLOT(onDownloadDataChanged()));
            beginInsertRows(QModelIndex(), m_list.size(), m_list.size());
            m_list.append(download);
            endInsertRows();
            emit countChanged();
            qDebug() << "Download added:" << url.toString() << fileName;
        }
        else {
            qDebug() << "Cannot add download" << url.toString() << fileName;
        }

        settings.endGroup();
    }

    startNextDownload();
}

void DownloadModel::save() {
    QSettings settings(FILE_NAME, QSettings::NativeFormat);
    settings.clear();

    foreach (Download *download, m_list) {
        settings.beginGroup(download->id());
        settings.setValue("url", download->url());
        settings.setValue("headers", download->headers());
        settings.setValue("fileName", download->fileName());
        settings.setValue("size", download->size());
        settings.setValue("bytesReceived", download->bytesReceived());
        settings.endGroup();
    }
}

void DownloadModel::addDownload(const QUrl &url, const QVariantMap &headers, const QString &fileName) {
    qsrand(QDateTime::currentMSecsSinceEpoch());
    Download *download = new Download(QString::number(qrand()), this);
    download->setUrl(url);
    download->setHeaders(headers);
    download->setFileName(fileName);
    connect(download, SIGNAL(queued(Download*)), this, SLOT(onDownloadQueued(Download*)));
    connect(download, SIGNAL(started(Download*)), this, SLOT(onDownloadStarted(Download*)));
    connect(download, SIGNAL(paused(Download*)), this, SLOT(onDownloadPaused(Download*)));
    connect(download, SIGNAL(canceled(Download*)), this, SLOT(onDownloadCanceled(Download*)));
    connect(download, SIGNAL(finished(Download*)), this, SLOT(onDownloadFinished(Download*)));
    connect(download, SIGNAL(fileNameChanged()), this, SLOT(onDownloadDataChanged()));
    connect(download, SIGNAL(sizeChanged()), this, SLOT(onDownloadDataChanged()));
    connect(download, SIGNAL(progressChanged()), this, SLOT(onDownloadDataChanged()));
    connect(download, SIGNAL(runningChanged()), this, SLOT(onDownloadDataChanged()));
    beginInsertRows(QModelIndex(), m_list.size(), m_list.size());
    m_list.append(download);
    endInsertRows();
    emit countChanged();
    QMaemo5InformationBox::information(0, tr("Download '%1' added").arg(fileName.section('/', -1)));
    qDebug() << "Download added:" << url.toString() << fileName;
    startNextDownload();
}

void DownloadModel::removeDownload(Download *download) {
    const int row = m_list.indexOf(download);
    beginRemoveRows(QModelIndex(), row, row);
    m_list.removeAt(row);
    endRemoveRows();
    emit countChanged();
    qDebug() << "Download removed:" << download->url().toString() << download->fileName();
    download->deleteLater();
}

void DownloadModel::startNextDownload() {
    if (m_activeList.size() < MAX_DOWNLOADS) {
        foreach (Download *download, m_list) {
            if ((!download->isRunning()) && (download->error() == Download::NoError)) {
                download->queue();
                return;
            }
        }
    }
}

void DownloadModel::onDownloadQueued(Download *download) {
    if (m_activeList.size() < MAX_DOWNLOADS) {
        download->start();
    }
}

void DownloadModel::onDownloadStarted(Download *download) {
    const int row = m_list.indexOf(download);
    emit dataChanged(index(row, 0), index(row, 2));
    m_activeList.append(download);
    emit activeDownloadsChanged();
}

void DownloadModel::onDownloadPaused(Download *download) {
    const int row = m_list.indexOf(download);
    emit dataChanged(index(row, 0), index(row, 2));
    m_activeList.removeOne(download);
    emit activeDownloadsChanged();
    startNextDownload();
}

void DownloadModel::onDownloadCanceled(Download *download) {
    m_activeList.removeOne(download);
    emit activeDownloadsChanged();
    removeDownload(download);
    startNextDownload();
}

void DownloadModel::onDownloadFinished(Download *download) {
    m_activeList.removeOne(download);
    emit activeDownloadsChanged();

    switch (download->error()) {
    case Download::NoError:
        QMaemo5InformationBox::information(0, tr("Downloading of '%1' completed").arg(download->fileName().section('/', -1)));
        qDebug() << "Download completed:" << download->url().toString() << download->errorString();
        removeDownload(download);
        break;
    default:
        QMaemo5InformationBox::information(0, tr("Downloading of '%1' failed.\nReason: %2").arg(download->fileName().section('/', -1)).arg(download->errorString()),
                                           QMaemo5InformationBox::NoTimeout);
        qDebug() << "Download failed:" << download->url().toString() << download->errorString();
        break;
    }

    startNextDownload();
}

void DownloadModel::onDownloadDataChanged() {
    if (Download *download = qobject_cast<Download*>(sender())) {
        const int row = m_list.indexOf(download);
        emit dataChanged(index(row, 0), index(row, 2));
    }
}
