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

#include <QAbstractListModel>
#include <QDomDocument>
#include <qdeclarative.h>

class BookmarksModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(int count
               READ rowCount
               NOTIFY countChanged)
    Q_PROPERTY(QString fileName
               READ fileName
               WRITE setFileName
               NOTIFY fileNameChanged)

    Q_ENUMS(Roles)

public:
    enum Roles {
        TitleRole = Qt::UserRole + 1,
        IconRole,
        UrlRole
    };

    explicit BookmarksModel(QObject *parent = 0);
    ~BookmarksModel();

    inline QString fileName() const { return m_fileName; }
    void setFileName(const QString &fileName);

    int rowCount(const QModelIndex &parent = QModelIndex()) const;

    Q_INVOKABLE QVariant data(const QModelIndex &index, int role) const;
    Q_INVOKABLE bool setData(const QModelIndex &index, const QVariant &value, int role);

    Q_INVOKABLE bool addBookmark(const QString &title, const QString &icon, const QString &url);
    Q_INVOKABLE bool removeBookmark(const QString &url);
    Q_INVOKABLE bool removeBookmark(const QModelIndex &index);
    Q_INVOKABLE bool removeBookmark(int row);

public slots:
    void load();
    bool save();

signals:
    void countChanged();
    void fileNameChanged();
    
private:
    QString m_fileName;
    QDomDocument m_document;

    Q_DISABLE_COPY(BookmarksModel)
};

QML_DECLARE_TYPE(BookmarksModel)

#endif // BOOKMARKSMODEL_H
