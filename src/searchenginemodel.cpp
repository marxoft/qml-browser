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

#include "searchenginemodel.h"
#include <QSettings>
#include <QDir>
#include <QIcon>

static const QString FILE_NAME("/home/user/.config/QMLBrowser/searchengines.conf");

SearchEngineModel::SearchEngineModel(QObject *parent) :
    QAbstractListModel(parent)
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[IconRole] = "icon";
    roles[UrlRole] = "url";
    setRoleNames(roles);
}

SearchEngineModel::~SearchEngineModel() {}

int SearchEngineModel::rowCount(const QModelIndex &) const {
    return m_list.size();
}

QVariant SearchEngineModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid()) {
        return QVariant();
    }

    switch (role) {
    case Qt::DisplayRole:
        return m_list.at(index.row()).name;
    case Qt::DecorationRole:
        return QIcon(m_list.at(index.row()).icon);
    case IconRole:
        return m_list.at(index.row()).icon;
    case UrlRole:
        return m_list.at(index.row()).url;
    default:
        return QVariant();
    }
}

QVariant SearchEngineModel::data(int row, int role) const {
    return data(index(row), role);
}

bool SearchEngineModel::setData(const QModelIndex &index, const QVariant &value, int role) {
    if (!index.isValid()) {
        return false;
    }

    switch (role) {
    case IconRole:
        m_list[index.row()].icon = value.toString();
        break;
    case UrlRole:
        m_list[index.row()].url = value.toString();
        break;
    default:
        return false;
    }

    emit dataChanged(index, index);

    QSettings settings(FILE_NAME, QSettings::NativeFormat);
    settings.beginGroup(m_list.at(index.row()).name);
    settings.setValue("icon", m_list.at(index.row()).icon);
    settings.setValue("url", m_list.at(index.row()).url);
    settings.endGroup();

    return true;
}

bool SearchEngineModel::setData(int row, const QVariant &value, int role) {
    return setData(index(row), value, role);
}

void SearchEngineModel::addSearchEngine(const QString &name, const QString &icon, const QString &url) {
    QSettings settings(FILE_NAME, QSettings::NativeFormat);
    settings.beginGroup(name);
    settings.setValue("icon", icon);
    settings.setValue("url", url);
    settings.endGroup();
    load();
}

void SearchEngineModel::removeSearchEngine(const QString &name) {
    for (int i = 0; i < m_list.size(); i++) {
        if (m_list.at(i).name == name) {
            removeSearchEngine(i);
            return;
        }
    }
}

void SearchEngineModel::removeSearchEngine(int row) {
    if ((row >= 0) && (row < m_list.size())) {
        beginRemoveRows(QModelIndex(), row, row);
        QSettings(FILE_NAME, QSettings::NativeFormat).remove(m_list.takeAt(row).name);
        endRemoveRows();
        emit countChanged();
    }
}

void SearchEngineModel::load() {
    QSettings settings(FILE_NAME, QSettings::NativeFormat);
    QDir dir(FILE_NAME.left(FILE_NAME.lastIndexOf('/')));

    beginResetModel();
    m_list.clear();

    QStringList groups = settings.childGroups();
    groups.sort();

    foreach (QString group, groups) {
        settings.beginGroup(group);

        QString icon = settings.value("icon").toString();

        if (!icon.isEmpty()) {
            icon = dir.absoluteFilePath(icon);
        }

        if ((icon.isEmpty()) || (!dir.exists(icon))) {
            icon = "/usr/share/icons/hicolor/48x48/hildon/general_web.png";
        }

        SearchEngine se;
        se.name = group;
        se.icon = icon;
        se.url = settings.value("url").toString();
        m_list.append(se);

        settings.endGroup();
    }

    SearchEngine se;
    se.name = tr("Add search engine");
    se.icon = "/usr/share/icons/hicolor/48x48/hildon/general_add.png";
    m_list.append(se);

    endResetModel();
    emit countChanged();
}
