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

#ifndef CACHE_H
#define CACHE_H

#include <QObject>
#include <QDir>

class Cache : public QObject
{
    Q_OBJECT

public:
    explicit Cache(QObject *parent = 0) :
        QObject(parent)
    {
    }

public slots:
    inline bool create() {
        return QDir().mkpath("/home/user/.config/QMLBrowser/.cache/");
    }

    inline void clear() {
        QDir dir("/home/user/.config/QMLBrowser/.cache/");

        foreach (QString fileName, dir.entryList(QStringList("*.jpg"), QDir::Files)) {
            dir.remove(dir.absoluteFilePath(fileName));
        }
    }

private:
    Q_DISABLE_COPY(Cache)
};

#endif // CACHE_H
