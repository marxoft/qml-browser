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

#include "bookmarksmodel.h"
#include <QXmlStreamReader>
#include <QXmlStreamWriter>
#include <QDir>
#include <QFile>
#include <QStandardItem>
#include <QDateTime>
#include <QDebug>

static const QString FILE_NAME("/home/user/.config/QMLBrowser/bookmarks/bookmarks.xml");
static const QString THUMBNAILS_DIR("/home/user/.config/QMLBrowser/bookmarks/");
static const QString ALT_FILE_NAME("/home/user/.bookmarks/MyBookmarks.xml");
static const QString ALT_THUMBNAILS_DIR("/home/user/.bookmarks/thumbnails/");

BookmarksModel::BookmarksModel(QObject *parent) :
    QStandardItemModel(parent)
{
    QHash<int, QByteArray> roles;
    roles[TitleRole] = "title";
    roles[FaviconRole] = "favicon";
    roles[ThumbnailRole] = "thumbnail";
    roles[UrlRole] = "url";
    roles[TimeAddedRole] = "timeAdded";
    roles[TimeVisitedRole] = "timeVisited";
    roles[VisitCountRole] = "visitCount";
    setRoleNames(roles);
    setSortRole(VisitCountRole);
}

BookmarksModel::~BookmarksModel() {}

QVariant BookmarksModel::data(const QModelIndex &index, int role) const {
    return QStandardItemModel::data(index, role);
}

QVariant BookmarksModel::data(int row, int role) const {
    return data(index(row, 0), role);
}

bool BookmarksModel::setData(const QModelIndex &index, const QVariant &value, int role) {
    if (QStandardItemModel::setData(index, value, role)) {
        if (role == sortRole()) {
            sort(0, Qt::DescendingOrder);
        }

        return true;
    }

    return false;
}

bool BookmarksModel::setData(int row, const QVariant &value, int role) {
    return setData(index(row, 0), value, role);
}

bool BookmarksModel::addBookmark(const QString &title, const QString &thumbnail, const QString &url, bool visited) {
    QStandardItem *item = new QStandardItem(QIcon(thumbnail), QString("%1\n%2").arg(title).arg(url));
    item->setData(title, TitleRole);
    item->setData(thumbnail, ThumbnailRole);
    item->setData(url, UrlRole);
    item->setData(QDateTime::currentMSecsSinceEpoch() / 1000, TimeAddedRole);
    
    if (visited) {
        item->setData(item->data(TimeAddedRole), TimeVisitedRole);
        item->setData(1, VisitCountRole);
    }
    
    appendRow(item);
    sort(0, Qt::DescendingOrder);

    emit countChanged();
    
    return true;
}

bool BookmarksModel::removeBookmark(int row) {
    QString thumbnail = data(row, ThumbnailRole).toString();

    if (removeRows(row, 1)) {
        emit countChanged();

        if (thumbnail.startsWith(THUMBNAILS_DIR)) {
            // Delete the thumbnail if it belongs to QML Browser
            QFile::remove(thumbnail);
        }

        return true;
    }

    return false;
}

void BookmarksModel::urlVisited(const QString &url) {
    for (int i = 0; i < rowCount(); i++) {
        const QModelIndex idx = index(i, 0);

        if (data(idx, UrlRole) == url) {
            setData(idx, data(idx, VisitCountRole).toInt() + 1, VisitCountRole);
            setData(idx, QDateTime::currentMSecsSinceEpoch() / 1000, TimeVisitedRole);
            return;
        }
    }
}

void BookmarksModel::load() {
    if (!QDir().mkpath(FILE_NAME.left(FILE_NAME.lastIndexOf("/")))) {
        qDebug() << "Cannot create path for bookmarks";
        return;
    }

    QFile file(FILE_NAME);
    bool alt = false;

    if (!file.exists()) {
        // Load MicroB bookmarks
        file.setFileName(ALT_FILE_NAME);
        alt = true;
    }

    if ((file.exists()) && (file.open(QIODevice::ReadOnly))) {
        QXmlStreamReader reader(&file);

        while (!reader.atEnd()) {
            reader.readNextStartElement();

            if (reader.name() == "bookmark") {
                QString url = reader.attributes().value("href").toString();
                QString favicon = reader.attributes().value("favicon").toString();
                QString thumbnail = reader.attributes().value("thumbnail").toString();
                QString title = tr("Unknown title");
                int timeAdded = 0;
                int timeVisited = 0;
                int visitCount = 0;
                bool bookmarkDeleted = false;

                reader.readNextStartElement();

                while ((!reader.atEnd()) && (reader.name() != "bookmark")) {
                    if (reader.name() == "title") {
                        title = reader.readElementText();
                    }
                    else if (reader.name() == "time_added") {
                        timeAdded = reader.readElementText().toInt();
                    }
                    else if (reader.name() == "time_visited") {
                        timeVisited = reader.readElementText().toInt();
                    }
                    else if (reader.name() == "visit_count") {
                        visitCount = reader.readElementText().toInt();
                    }
                    else if (reader.name() == "deleted") {
                        bookmarkDeleted = (reader.readElementText() == "1");
                    }

                    reader.readNextStartElement();
                }

                if (!bookmarkDeleted) {
                    QStandardItem *item = new QStandardItem;
                    item->setText(QString("%1\n%2").arg(title).arg(url));
                    item->setData(url, UrlRole);
                    item->setData(title, TitleRole);
                    item->setData(timeAdded, TimeAddedRole);
                    item->setData(timeVisited, TimeVisitedRole);
                    item->setData(visitCount, VisitCountRole);

                    if (!favicon.isEmpty()) {
                        item->setData(((alt) && (!favicon.startsWith("/")) ? ALT_THUMBNAILS_DIR : "") + favicon, FaviconRole);
                    }

                    if (!thumbnail.isEmpty()) {
                        item->setIcon(QIcon(((alt) && (!thumbnail.startsWith("/")) ? ALT_THUMBNAILS_DIR : "") + thumbnail));
                        item->setData(((alt) && (!thumbnail.startsWith("/")) ? ALT_THUMBNAILS_DIR : "") + thumbnail, ThumbnailRole);
                    }

                    appendRow(item);
                }
            }
        }

        sort(0, Qt::DescendingOrder);
        emit countChanged();
    }
    else {
        qDebug() << "Cannot load bookmarks:" << file.errorString();
    }
}

bool BookmarksModel::save() {
    if (!QDir().mkpath(FILE_NAME.left(FILE_NAME.lastIndexOf("/")))) {
        qDebug() << "Cannot create path for bookmarks";
        return false;
    }

    QFile file(FILE_NAME);

    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QXmlStreamWriter writer(&file);
        writer.setAutoFormatting(true);
        writer.writeStartDocument();
        writer.writeStartElement("xbel");
        writer.writeAttribute("version", "1.0");
        writer.writeTextElement("title", "QML Browser bookmarks");
        writer.writeStartElement("info");
        writer.writeStartElement("metadata");
        writer.writeTextElement("default_folder", "no");
        writer.writeEndElement(); // metadata
        writer.writeEndElement(); // info

        for (int i = 0; i < rowCount(); i++) {
            const QModelIndex idx = index(i, 0);
            writer.writeStartElement("bookmark");
            writer.writeAttribute("href", data(idx, UrlRole).toString());
            writer.writeAttribute("favicon", data(idx, FaviconRole).toString());
            writer.writeAttribute("thumbnail", data(idx, ThumbnailRole).toString());
            writer.writeTextElement("title", data(idx, TitleRole).toString());
            writer.writeStartElement("info");
            writer.writeStartElement("metadata");
            writer.writeTextElement("time_added", data(idx, TimeAddedRole).toString());
            writer.writeTextElement("time_visited", data(idx, TimeVisitedRole).toString());
            writer.writeTextElement("visit_count", data(idx, VisitCountRole).toString());
            writer.writeEndElement(); // metadata
            writer.writeEndElement(); // info
            writer.writeEndElement(); // bookmark
        }

        writer.writeEndElement(); // xbel
        writer.writeEndDocument();
        file.close();
        return true;
    }

    qDebug() << "Cannot save bookmarks:" << file.errorString();

    return false;
}
