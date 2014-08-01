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

#include "utils.h"
#include <QFileInfo>
#include <QFile>
#include <QDateTime>

Utils::Utils(QObject *parent) :
    QObject(parent)
{
}

Utils::~Utils() {}

QString Utils::fileSizeFromPath(const QString &filePath) {
    QFileInfo file(filePath);
    return Utils::fileSizeFromBytes(file.size());
}

QString Utils::fileSizeFromBytes(double bytes) {
    double kb = 1024;
    double mb = kb * 1024;
    double gb = mb * 1024;

    QString size;

    if (bytes > gb) {
        size = QString::number(bytes / gb, 'f', 2) + "GB";
    }
    else if (bytes > mb) {
        size = QString::number(bytes / mb, 'f', 2) + "MB";
    }
    else if (bytes > kb){
        size = QString::number(bytes / kb, 'f', 2) + "kB";
    }
    else {
        size = QString::number(bytes) + "B";
    }

    return size;
}

QString Utils::dateFromSecs(qint64 secs, bool showTime) {
    return Utils::dateFromMSecs(secs * 1000, showTime);
}

QString Utils::dateFromMSecs(qint64 msecs, bool showTime) {
    QString date;

    if (showTime) {
        date = QDateTime::fromMSecsSinceEpoch(msecs).toString("dd/MM/yyyy | HH:mm");
    }
    else {
        date = QDateTime::fromMSecsSinceEpoch(msecs).toString("dd/MM/yyyy");
    }

    return date;
}

QString Utils::localDateTimeFromString(const QString &dateTimeString, Qt::DateFormat format) {
    QDateTime dt = QDateTime::fromString(dateTimeString, format);

    if (!dt.isValid()) {
        dt = QDateTime::currentDateTimeUtc();
    }

    return dt.toLocalTime().toString("dd/MM/yyyy | HH:mm");
}

QString Utils::httpErrorString(int errorCode) {
    switch (errorCode) {
    case 400:
        return tr("Bad request");
    case 401:
        return tr("Request is unauthorised");
    case 403:
        return tr("Request is forbidden");
    case 404:
        return tr("Requested resource is unavailable");
    case 406:
        return tr("Requested resource is not accessible");
    case 422:
        return tr("Request cannot be processed");
    case 429:
        return tr("Request limit has been reached. Please try again later");
    case 500:
        return tr("Internal server error. Please try again later");
    case 503:
        return tr("Service unavailable. Please try again later");
    case 504:
        return tr("Request timed out. Please try again later");
    default:
        return tr("Unknown error. Please try again later");
    }
}

void Utils::log(const QString &filePath, const QByteArray &message) {
    QFile lf(filePath);

    if (lf.open(QIODevice::Append)) {
        lf.write(QDateTime::currentDateTime().toString().toUtf8() + ": " + message + "\n");
    }

    lf.close();
}

QString Utils::versionNumber() {
    return QString("0.5.0");
}
