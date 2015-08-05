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

    QVariant data(const QModelIndex &index, int role) const;
    Q_INVOKABLE QVariant data(int row, int role) const;
    bool setData(const QModelIndex &index, const QVariant &value, int role);
    Q_INVOKABLE bool setData(int row, const QVariant &value, int role);

    Q_INVOKABLE bool addBookmark(const QString &title, const QString &thumbnail, const QString &url, bool visited);
    Q_INVOKABLE bool removeBookmark(int row);

    Q_INVOKABLE void urlVisited(const QString &url);

public Q_SLOTS:
    void load();
    bool save();

Q_SIGNALS:
    void countChanged();
    
private:
    Q_DISABLE_COPY(BookmarksModel)
};

QML_DECLARE_TYPE(BookmarksModel)

#endif // BOOKMARKSMODEL_H
