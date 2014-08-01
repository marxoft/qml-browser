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

#ifndef SEARCHENGINEMODEL_H
#define SEARCHENGINEMODEL_H

#include <QAbstractListModel>
#include <qdeclarative.h>

typedef struct {
    QString name;
    QString icon;
    QString url;
} SearchEngine;

class SearchEngineModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

    Q_ENUMS(Roles)

public:
    enum Roles {
        NameRole = Qt::DisplayRole,
        IconRole = Qt::UserRole + 1,
        UrlRole
    };

    explicit SearchEngineModel(QObject *parent = 0);
    ~SearchEngineModel();

    int rowCount(const QModelIndex &parent = QModelIndex()) const;

    Q_INVOKABLE QVariant data(const QModelIndex &index, int role) const;
    Q_INVOKABLE bool setData(const QModelIndex &index, const QVariant &value, int role);

    Q_INVOKABLE void addSearchEngine(const QString &name, const QString &icon, const QString &url);
    Q_INVOKABLE void removeSearchEngine(const QString &name);
    Q_INVOKABLE void removeSearchEngine(const QModelIndex &index);
    Q_INVOKABLE void removeSearchEngine(int row);

public slots:
    void load();

signals:
    void countChanged();

private:
    QString m_fileName;

    QList<SearchEngine> m_list;

    Q_DISABLE_COPY(SearchEngineModel)
};

QML_DECLARE_TYPE(SearchEngineModel)

#endif // SEARCHENGINEMODEL_H
