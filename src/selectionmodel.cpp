/*
 * Copyright (C) 2016 Stuart Howarth <showarth@marxoft.co.uk>
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

#include "selectionmodel.h"

SelectionModel::SelectionModel(QObject *parent) :
    QAbstractListModel(parent)
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[ValueRole] = "value";
    setRoleNames(roles);
}

int SelectionModel::rowCount(const QModelIndex &) const {
    return m_items.size();
}

QVariant SelectionModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid()) {
        return QVariant();
    }
    
    switch (role) {
    case NameRole:
        return m_items.at(index.row()).first;
    case ValueRole:
        return m_items.at(index.row()).second;
    default:
        return QVariant();
    }
}

QMap<int, QVariant> SelectionModel::itemData(const QModelIndex &index) const {
    QMap<int, QVariant> map;
    map[NameRole] = data(index, NameRole);
    map[ValueRole] = data(index, ValueRole);
    
    return map;
}

bool SelectionModel::setData(const QModelIndex &index, const QVariant &value, int role) {
    if (!index.isValid()) {
        return false;
    }
    
    switch (role) {
    case NameRole:
        m_items[index.row()].first = value.toString();
        break;
    case ValueRole:
        m_items[index.row()].second = value;
        break;
    default:
        return false;
    }
    
    switch (index.column()) {
    case 0:
        emit dataChanged(index, index.sibling(index.row(), 1));
        break;
    default:
        emit dataChanged(index.sibling(index.row(), 0), index);
        break;
    }
    
    return true;
}

bool SelectionModel::setItemData(const QModelIndex &index, const QMap<int, QVariant> &roles) {
    if (roles.isEmpty()) {
        return false;
    }
    
    QMapIterator<int, QVariant> iterator(roles);
    
    while (iterator.hasNext()) {
        iterator.next();
        
        if (!setData(index, iterator.value(), iterator.key())) {
            return false;
        }
    }
    
    return true;
}

QVariant SelectionModel::data(int row, int role) const {
    return data(index(row), role);
}

QVariantMap SelectionModel::itemData(int row) const {
    QVariantMap map;
    map[QString::number(NameRole)] = data(row, NameRole);
    map[QString::number(ValueRole)] = data(row, ValueRole);
    
    return map;
}

bool SelectionModel::setData(int row, const QVariant &value, int role) {
    return setData(index(row), value, role);
}

bool SelectionModel::setItemData(int row, const QVariantMap &roles) {
    if (roles.isEmpty()) {
        return false;
    }
    
    QMapIterator<QString, QVariant> iterator(roles);
    
    while (iterator.hasNext()) {
        iterator.next();
        
        if (!setData(row, iterator.value(), iterator.key().toInt())) {
            return false;
        }
    }
    
    return true;
}

QModelIndexList SelectionModel::match(const QModelIndex &start, int role, const QVariant &value, int hits,
                                      Qt::MatchFlags flags) const {
    return QAbstractListModel::match(start, role, value, hits, flags);
}

int SelectionModel::match(int start, int role, const QVariant &value, int flags) const {
    const QModelIndexList idxs = match(index(start), role, value, 1, Qt::MatchFlags(flags));
    return idxs.isEmpty() ? -1 : idxs.first().row();
}

void SelectionModel::append(const QString &name, const QVariant &value) {
    beginInsertRows(QModelIndex(), m_items.size(), m_items.size());
    m_items << QPair<QString, QVariant>(name, value);
    endInsertRows();
    emit countChanged(rowCount());
}

void SelectionModel::insert(int row, const QString &name, const QVariant &value) {
    if ((row < 0) || (row >= m_items.size())) {
        append(name, value);
    }
    else {
        beginInsertRows(QModelIndex(), row, row);
        m_items.insert(row, QPair<QString, QVariant>(name, value));
        endInsertRows();
        emit countChanged(rowCount());
    }
}

bool SelectionModel::remove(int row) {
    if ((row >= 0) && (row < m_items.size())) {
        beginRemoveRows(QModelIndex(), row, row);
        m_items.removeAt(row);
        endRemoveRows();
        emit countChanged(rowCount());
        
        return true;
    }
    
    return false;
}

void SelectionModel::clear() {
    if (!m_items.isEmpty()) {
        beginResetModel();
        m_items.clear();
        endResetModel();
        emit countChanged(0);
    }
}
