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

#ifndef DOWNLOADMODEL_H
#define DOWNLOADMODEL_H

#include "download.h"
#include <QAbstractListModel>
#include <qdeclarative.h>

class DownloadModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(int activeDownloads READ activeDownloads NOTIFY activeDownloadsChanged)

    Q_ENUMS(Roles)

public:
    enum Roles {
        FileNameRole = Qt::UserRole + 1,
        NameRole,
        SizeRole,
        BytesReceivedRole,
        ProgressRole,
        IsRunningRole,
        ErrorRole,
        ErrorStringRole
    };

    explicit DownloadModel(QObject *parent = 0);
    ~DownloadModel();

    int activeDownloads() const;

    int rowCount(const QModelIndex &parent = QModelIndex()) const;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    Q_INVOKABLE QVariant data(int row, int role = Qt::DisplayRole) const;

    Q_INVOKABLE Download* get(int row) const;

public Q_SLOTS:
    void load();
    void save();

    void addDownload(const QUrl &url, const QVariantMap &headers, const QString &fileName);

private Q_SLOTS:
    void onDownloadQueued(Download *download);
    void onDownloadStarted(Download *download);
    void onDownloadPaused(Download *download);
    void onDownloadCanceled(Download *download);
    void onDownloadFinished(Download *download);

    void onDownloadDataChanged();

private:
    void removeDownload(Download *download);
    void startNextDownload();
    
Q_SIGNALS:
    void countChanged();
    void activeDownloadsChanged();
    
private:
    QList<Download*> m_list;
    QList<Download*> m_activeList;

    Q_DISABLE_COPY(DownloadModel)
};

QML_DECLARE_TYPE(DownloadModel)

#endif // DOWNLOADMODEL_H
