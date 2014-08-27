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

#ifndef BOOKMARKSMODEL_H
#define BOOKMARKSMODEL_H

#include <QStandardItemModel>
#include <qdeclarative.h>

class BookmarksModel : public QStandardItemModel
{
    Q_OBJECT

    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

    Q_ENUMS(Roles)

public:
    enum Roles {
        TitleRole = Qt::UserRole + 1,
        FaviconRole,
        ThumbnailRole,
        UrlRole,
        TimeAddedRole,
        TimeVisitedRole,
        VisitCountRole
    };

    explicit BookmarksModel(QObject *parent = 0);
    ~BookmarksModel();

    Q_INVOKABLE QVariant data(const QModelIndex &index, int role) const;
    Q_INVOKABLE bool setData(const QModelIndex &index, const QVariant &value, int role);

    Q_INVOKABLE bool addBookmark(const QString &title, const QString &thumbnail, const QString &url, bool visited);
    Q_INVOKABLE bool removeBookmark(const QModelIndex &index);

    Q_INVOKABLE void urlVisited(const QString &url);

public slots:
    void load();
    bool save();

signals:
    void countChanged();
    
private:
    Q_DISABLE_COPY(BookmarksModel)
};

QML_DECLARE_TYPE(BookmarksModel)

#endif // BOOKMARKSMODEL_H
