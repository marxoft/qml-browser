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
#include "logger.h"
#include "utils.h"
#include <QSettings>
#include <QMaemo5InformationBox>

static const QString STORAGE_PATH("/home/user/.config/QMLBrowser/downloads");
static const int MAX_DOWNLOADS = 1;

DownloadModel::DownloadModel(QObject *parent) :
    QAbstractListModel(parent)
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[SizeRole] = "size";
    roles[BytesReceivedRole] = "bytesReceived";
    roles[ProgressRole] = "progress";
    roles[IsRunningRole] = "running";
    roles[ErrorRole] = "error";
    roles[ErrorStringRole] = "errorString";
    setRoleNames(roles);
}

DownloadModel::~DownloadModel() {
    save();
}

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

static QVariant networkRequestToVariant(const QNetworkRequest &request) {
    QVariantMap var;
    var["url"] = request.url();
    QVariantMap headers;
    
    foreach (const QByteArray &header, request.rawHeaderList()) {
        headers[QString::fromUtf8(header)] = request.rawHeader(header);
    }
    
    var["headers"] = headers;
    return var;
}

static QNetworkRequest variantToNetworkRequest(const QVariant &variant) {
    QVariantMap var = variant.toMap();
    QNetworkRequest request(var.value("url").toUrl());
    QMapIterator<QString, QVariant> iterator(var.value("headers").toMap());
    
    while (iterator.hasNext()) {
        iterator.next();
        request.setRawHeader(iterator.key().toUtf8(), iterator.value().toByteArray());
    }
    
    return request;
}

void DownloadModel::load() {
    QSettings settings(STORAGE_PATH, QSettings::IniFormat);
    const int count = settings.beginReadArray("downloads");

    for (int i = 0; i < count; i++) {
        settings.setArrayIndex(i);
        Download *download = new Download(settings.value("id").toString(),
                                          variantToNetworkRequest(settings.value("request")),
                                          settings.value("fileName").toString(),
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
    }
    
    settings.endArray();
    Logger::log(QString("DownloadModel::load(). %1 downloads loaded.").arg(rowCount()), Logger::MediumVerbosity);
    startNextDownload();
}

void DownloadModel::save() {
    QSettings settings(STORAGE_PATH, QSettings::IniFormat);
    settings.clear();
    settings.beginWriteArray("downloads");

    for (int i = 0; i < m_list.size(); i++) {
        const Download *download = m_list.at(i);
        settings.setArrayIndex(i);
        settings.setValue("id", download->id());
        settings.setValue("request", networkRequestToVariant(download->request()));
        settings.setValue("fileName", download->fileName());
        settings.setValue("size", download->size());
        settings.setValue("bytesReceived", download->bytesReceived());
    }
    
    settings.endArray();
    Logger::log(QString("DownloadModel::save(). %1 downloads saved.").arg(m_list.size()), Logger::MediumVerbosity);
}

void DownloadModel::addDownload(const QNetworkRequest &request, const QString &fileName) {
    Download *download = new Download(Utils::createId(), this);
    download->setRequest(request);
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
    save();
    startNextDownload();
}

void DownloadModel::removeDownload(Download *download) {
    const int row = m_list.indexOf(download);
    beginRemoveRows(QModelIndex(), row, row);
    m_list.removeAt(row);
    endRemoveRows();
    emit countChanged();
    download->deleteLater();
    save();
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
        QMaemo5InformationBox::information(0, tr("Downloading of '%1' completed")
                                           .arg(download->fileName().section('/', -1)));
        Logger::log("DownloadModel::onDownloadFinished(). Download completed: " + download->fileName(),
                    Logger::MediumVerbosity);
        removeDownload(download);
        break;
    default:
        QMaemo5InformationBox::information(0, tr("Downloading of '%1' failed.\nReason: %2")
                                           .arg(download->fileName().section('/', -1)).arg(download->errorString()),
                                           QMaemo5InformationBox::NoTimeout);
        Logger::log("DownloadModel::onDownloadFinished(). Download failed: " + download->errorString());
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
