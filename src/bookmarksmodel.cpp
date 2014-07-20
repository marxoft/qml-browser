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

#include "bookmarksmodel.h"
#include <QDomNodeList>
#include <QDir>
#include <QFile>
#include <QTextStream>
#include <QIcon>

BookmarksModel::BookmarksModel(QObject *parent) :
    QAbstractListModel(parent)
{
    QHash<int, QByteArray> roles;
    roles[TitleRole] = "title";
    roles[IconRole] = "icon";
    roles[UrlRole] = "url";
    this->setRoleNames(roles);
}

BookmarksModel::~BookmarksModel() {}

void BookmarksModel::setFileName(const QString &fileName) {
    if (fileName != this->fileName()) {
        m_fileName = fileName;
        emit fileNameChanged();
    }
}

int BookmarksModel::rowCount(const QModelIndex &parent) const {
    Q_UNUSED(parent)

    return m_document.documentElement().childNodes().size();
}

QVariant BookmarksModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid()) {
        return QVariant();
    }

    switch (role) {
    case Qt::DisplayRole:
        return QString("%1\n%2")
                .arg(m_document.documentElement().childNodes().at(index.row()).firstChildElement("title").text())
                .arg(m_document.documentElement().childNodes().at(index.row()).toElement().attribute("href"));
    case Qt::DecorationRole:
        return QIcon(m_document.documentElement().childNodes().at(index.row()).firstChildElement("icon").text());
    case Qt::TextAlignmentRole:
        return Qt::AlignLeft | Qt::AlignVCenter | Qt::ElideRight;
    case TitleRole:
        return m_document.documentElement().childNodes().at(index.row()).firstChildElement("title").text();
    case IconRole:
        return m_document.documentElement().childNodes().at(index.row()).firstChildElement("icon").text();
    case UrlRole:
        return m_document.documentElement().childNodes().at(index.row()).toElement().attribute("href");
    default:
        return QVariant();
    }
}

bool BookmarksModel::setData(const QModelIndex &index, const QVariant &value, int role) {
    if (!index.isValid()) {
        return false;
    }

    switch (role) {
    case TitleRole:
        m_document.documentElement().childNodes().at(index.row()).firstChildElement("title").firstChild().setNodeValue(value.toString());
        break;
    case IconRole:
        m_document.documentElement().childNodes().at(index.row()).firstChildElement("icon").firstChild().setNodeValue(value.toString());
        break;
    case UrlRole:
        m_document.documentElement().childNodes().at(index.row()).toElement().setAttribute("href", value.toString());
        break;
    default:
        return false;
    }

    emit dataChanged(index, index);
    return this->save();
}

bool BookmarksModel::addBookmark(const QString &title, const QString &icon, const QString &url) {
    QDomElement bookmark = m_document.createElement("bookmark");
    QDomElement titleElement = m_document.createElement("title");
    QDomText titleText = m_document.createTextNode(title);
    QDomElement iconElement = m_document.createElement("icon");
    QDomText iconText = m_document.createTextNode(icon);

    if ((bookmark.isNull()) || (titleElement.isNull()) || (iconElement.isNull())) {
        return false;
    }

    bookmark.setAttribute("href", url);
    titleElement.appendChild(titleText);
    bookmark.appendChild(titleElement);
    iconElement.appendChild(iconText);
    bookmark.appendChild(iconElement);

    this->beginInsertRows(QModelIndex(), this->rowCount(), this->rowCount());
    QDomNode newChild = m_document.documentElement().appendChild(bookmark);
    this->endInsertRows();

    if (!newChild.isNull()) {
        emit countChanged();
        return this->save();
    }

    return false;
}

bool BookmarksModel::removeBookmark(const QString &url) {
    for (int i = 0; i < m_document.documentElement().childNodes().size(); i++) {
        QDomNode bookmark = m_document.documentElement().childNodes().at(i);

        if (bookmark.toElement().attribute("href") == url) {
            this->beginRemoveRows(QModelIndex(), i, i);
            QDomNode removedChild = m_document.documentElement().removeChild(bookmark);
            this->endRemoveRows();

            if (!removedChild.isNull()) {
                emit countChanged();
                return this->save();
            }

            return false;
        }
    }

    return false;
}

bool BookmarksModel::removeBookmark(const QModelIndex &index) {
    return this->removeBookmark(index.row());
}

bool BookmarksModel::removeBookmark(int row) {
    Q_ASSERT((row >= 0) && (row < this->rowCount()));

    this->beginRemoveRows(QModelIndex(), row, row);
    QDomNode removedChild = m_document.documentElement().removeChild(m_document.documentElement().childNodes().at(row));
    this->endRemoveRows();

    if (!removedChild.isNull()) {
        emit countChanged();
        return this->save();
    }

    return false;
}

void BookmarksModel::load() {
    QDir().mkpath(this->fileName().left(this->fileName().lastIndexOf('/')));
    QFile file(this->fileName());

    if ((file.exists()) && (file.open(QIODevice::ReadOnly)) && (m_document.setContent(&file)) && (this->rowCount() > 0)) {
        emit countChanged();
    }
    else {
        QByteArray doc("<xbel version=\"1.0\"></xbel>");
        m_document.setContent(doc);
        this->save();
        emit countChanged();
    }
}

bool BookmarksModel::save() {
    QFile file(this->fileName());

    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        const int IndentSize = 4;
        QTextStream out(&file);
        m_document.save(out, IndentSize);
        return true;
    }

    return false;
}
