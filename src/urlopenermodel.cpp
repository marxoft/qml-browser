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

#include "urlopenermodel.h"
#include "logger.h"
#include <QProcess>
#include <QRegExp>
#include <QSettings>

static const QString STORAGE_PATH("/home/user/.config/QMLBrowser/urlopeners");

UrlOpenerModel::UrlOpenerModel(QObject *parent) :
    SelectionModel(parent)
{
}

UrlOpenerModel::~UrlOpenerModel() {
    save();
}

void UrlOpenerModel::append(const QString &regExp, const QVariant &command) {
    const int i = match(0, NameRole, regExp);

    if (i == -1) {
        SelectionModel::append(regExp, command);
    }
    else {
        setData(i, command, ValueRole);
    }
}

void UrlOpenerModel::insert(int row, const QString &regExp, const QVariant &command) {
    const int i = match(0, NameRole, regExp);

    if (i == -1) {
        SelectionModel::insert(row, regExp, command);
    }
    else {
        setData(i, command, ValueRole);
    }
}

void UrlOpenerModel::load() {
    clear();
    QSettings settings(STORAGE_PATH, QSettings::IniFormat);
    const int size = settings.beginReadArray("urlopeners");

    for (int i = 0; i < size; i++) {
        settings.setArrayIndex(i);
        const QString regExp = settings.value("regExp").toString();
        const QString command = settings.value("command").toString();

        if ((!regExp.isEmpty()) && (!command.isEmpty())) {
            append(regExp, command);
            Logger::log(QString("UrlOpenerModel::load(). Opener added. RegExp: %2, Command: %3")
                               .arg(regExp).arg(command), Logger::MediumVerbosity);
        }
        else {
            Logger::log(QString("UrlOpenerModel::load(). Cannot add opener. RegExp: %2, Command: %3")
                               .arg(regExp).arg(command));
        }
    }

    settings.endArray();
}

void UrlOpenerModel::save() {
    QSettings settings(STORAGE_PATH, QSettings::IniFormat);
    settings.beginWriteArray("urlopeners");
    
    for (int i = 0; i < rowCount(); i++) {        
        settings.setArrayIndex(i);
        settings.setValue("regExp", data(i, NameRole));
        settings.setValue("command", data(i, ValueRole));
    }

    settings.endArray();
}

bool UrlOpenerModel::open(const QString &url) {
    for (int i = 0; i < rowCount(); i++) {
        const QRegExp re = QRegExp(data(i, NameRole).toString());
        
        if (re.indexIn(url) == 0) {
            const QString command = data(i, ValueRole).toString().replace("%u", url);
            Logger::log(QString("UrlOpenerModel::open(). URL: %1, Command: %2").arg(url).arg(command),
                        Logger::MediumVerbosity);
            
            return QProcess::startDetached(command);
        }
    }
    
    Logger::log("UrlOpener::open(). No opener found for URL: " + url, Logger::MediumVerbosity);
    return false;
}
