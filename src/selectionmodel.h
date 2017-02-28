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

#ifndef SELECTIONMODEL_H
#define SELECTIONMODEL_H

#include <QAbstractListModel>

class SelectionModel : public QAbstractListModel
{
    Q_OBJECT
    
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    
    Q_ENUMS(Roles)
        
public:
    enum Roles {
        NameRole = Qt::UserRole + 1,
        ValueRole = Qt::UserRole
    };
    
    explicit SelectionModel(QObject *parent = 0);
    
    virtual int rowCount(const QModelIndex &parent = QModelIndex()) const;
    
    QVariant data(const QModelIndex &index, int role = NameRole) const;
    QMap<int, QVariant> itemData(const QModelIndex &index) const;
    bool setData(const QModelIndex &index, const QVariant &value, int role);
    bool setItemData(const QModelIndex &index, const QMap<int, QVariant> &roles);
    
    Q_INVOKABLE virtual QVariant data(int row, int role) const;
    Q_INVOKABLE virtual QVariantMap itemData(int row) const;
    Q_INVOKABLE virtual bool setData(int row, const QVariant &value, int role);
    Q_INVOKABLE virtual bool setItemData(int row, const QVariantMap &roles);
    
    QModelIndexList match(const QModelIndex &start, int role, const QVariant &value, int hits = 1,
                          Qt::MatchFlags flags = Qt::MatchFlags(Qt::MatchExactly | Qt::MatchWrap)) const;
    Q_INVOKABLE virtual int match(int start, int role, const QVariant &value,
                                  int flags = Qt::MatchFlags(Qt::MatchExactly | Qt::MatchWrap)) const;
    
    Q_INVOKABLE virtual void append(const QString &name, const QVariant &value);
    Q_INVOKABLE virtual void insert(int row, const QString &name, const QVariant &value);
    Q_INVOKABLE virtual bool remove(int row);

public Q_SLOTS:
    void clear();
    
Q_SIGNALS:
    void countChanged(int count);
    
protected:
    QList< QPair<QString, QVariant> > m_items;
};

#endif // SELECTIONMODEL_H
