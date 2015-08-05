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

    QVariant data(const QModelIndex &index, int role) const;
    Q_INVOKABLE QVariant data(int row, int role) const;
    bool setData(const QModelIndex &index, const QVariant &value, int role);
    Q_INVOKABLE bool setData(int row, const QVariant &value, int role);

    Q_INVOKABLE void addSearchEngine(const QString &name, const QString &icon, const QString &url);
    Q_INVOKABLE void removeSearchEngine(const QString &name);
    Q_INVOKABLE void removeSearchEngine(int row);

public Q_SLOTS:
    void load();

Q_SIGNALS:
    void countChanged();

private:
    QString m_fileName;

    QList<SearchEngine> m_list;

    Q_DISABLE_COPY(SearchEngineModel)
};

QML_DECLARE_TYPE(SearchEngineModel)

#endif // SEARCHENGINEMODEL_H
