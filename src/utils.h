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

#ifndef UTILS_H
#define UTILS_H

#include <QObject>
#include <QString>

class Utils : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString versionNumber READ versionNumber CONSTANT)

public:
    explicit Utils(QObject *parent = 0);
    ~Utils();

    Q_INVOKABLE static QString fileSizeFromPath(const QString &filePath);
    Q_INVOKABLE static QString fileSizeFromBytes(double bytes);
    Q_INVOKABLE static QString dateFromSecs(qint64 secs, bool showTime = true);
    Q_INVOKABLE static QString dateFromMSecs(qint64 msecs, bool showTime = true);
    Q_INVOKABLE static QString localDateTimeFromString(const QString &dateTimeString, Qt::DateFormat = Qt::ISODate);
    Q_INVOKABLE static QString httpErrorString(int errorCode);
    Q_INVOKABLE static void log(const QString &filePath, const QByteArray &message);
    Q_INVOKABLE static QString versionNumber();
};

#endif // UTILS_H
