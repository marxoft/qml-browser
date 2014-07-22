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

#include "searchenginemodel.h"
#include <QSettings>
#include <QDir>
#include <QIcon>

SearchEngineModel::SearchEngineModel(QObject *parent) :
    QAbstractListModel(parent)
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[IconRole] = "icon";
    roles[UrlRole] = "url";
    this->setRoleNames(roles);
}

SearchEngineModel::~SearchEngineModel() {}

void SearchEngineModel::setFileName(const QString &fileName) {
    if (fileName != this->fileName()) {
        m_fileName = fileName;
        emit fileNameChanged();
    }
}

int SearchEngineModel::rowCount(const QModelIndex &parent) const {
    Q_UNUSED(parent);

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

bool SearchEngineModel::setData(const QModelIndex &index, const QVariant &value, int role) {
    if (!index.isValid()) {
        return false;
    }

    switch (role) {
    case Qt::DisplayRole:
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

    QSettings settings(this->fileName(), QSettings::NativeFormat);
    settings.beginGroup(m_list.at(index.row()).name);
    settings.setValue("icon", m_list.at(index.row()).icon);
    settings.setValue("url", m_list.at(index.row()).url);
    settings.endGroup();
}

void SearchEngineModel::addSearchEngine(const QString &name, const QString &icon, const QString &url) {
    QSettings settings(this->fileName(), QSettings::NativeFormat);
    settings.beginGroup(name);
    settings.setValue("icon", icon);
    settings.setValue("url", url);
    settings.endGroup();
    this->load();
}

void SearchEngineModel::removeSearchEngine(const QString &name) {
    for (int i = 0; i < m_list.size(); i++) {
        if (m_list.at(i).name == name) {
            this->removeSearchEngine(i);
            return;
        }
    }
}

void SearchEngineModel::removeSearchEngine(const QModelIndex &index) {
    this->removeSearchEngine(index.row());
}

void SearchEngineModel::removeSearchEngine(int row) {
    if ((row >= 0) && (row < m_list.size())) {
        this->beginRemoveRows(QModelIndex(), row, row);
        QSettings(this->fileName(), QSettings::NativeFormat).remove(m_list.takeAt(row).name);
        this->endRemoveRows();
        emit countChanged();
    }
}

void SearchEngineModel::load() {
    QSettings settings(this->fileName(), QSettings::NativeFormat);
    QDir dir(this->fileName().left(this->fileName().lastIndexOf('/')));

    this->beginResetModel();
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

    this->endResetModel();
    emit countChanged();
}
