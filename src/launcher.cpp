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

#include "launcher.h"
#include <QSettings>
#include <QProcess>
#include <QDebug>

static const QString FILE_NAME("/home/user/.config/QMLBrowser/urlhandlers.conf");

Launcher::Launcher(QObject *parent) :
    QObject(parent)
{
}

Launcher::~Launcher() {}

void Launcher::loadHandlers() {
    m_handlers.clear();
    QSettings settings(FILE_NAME, QSettings::NativeFormat);

    foreach (QString group, settings.childGroups()) {
        settings.beginGroup(group);
        QRegExp re(settings.value("regExp").toString());
        QString command(settings.value("command").toString());

        if ((re.isValid()) && (!command.isEmpty())) {
            Handler handler;
            handler.name = group;
            handler.regExp = re;
            handler.command = command;
            m_handlers.append(handler);
            qDebug() << "Handler added" << group << re.pattern() << command;
        }
        else {
            qDebug() << "Cannot add handler" << group << re.pattern() << command;
        }

        settings.endGroup();
    }
}

bool Launcher::addHandler(const QString &name, const QString &regExp, const QString &command) {
    QRegExp re(regExp);

    if ((re.isValid()) && (!command.isEmpty())) {
        Handler handler;
        handler.name = name;
        handler.regExp = re;
        handler.command = command;
        m_handlers.append(handler);

        QSettings settings(FILE_NAME, QSettings::NativeFormat);
        settings.beginGroup(name);
        settings.setValue("regExp", regExp);
        settings.setValue("command", command);
        settings.endGroup();
        qDebug() << "Handler added" << name << re.pattern() << command;
        return true;
    }

    qDebug() << "Cannot add handler" << name << re.pattern() << command;
    return false;
}

QString Launcher::handler(const QString &url) const {
    foreach (Handler handler, m_handlers) {
        if (handler.regExp.indexIn(url) == 0) {
            return handler.name;
        }
    }

    return QString();
}

bool Launcher::canLaunch(const QString &url) const {
    return !handler(url).isEmpty();
}

bool Launcher::launch(const QString &url) {
    foreach (Handler handler, m_handlers) {
        if (handler.regExp.indexIn(url) == 0) {
            QString command = QString(handler.command).replace("%URL%", url);
            qDebug() << "Launching" << url << "with command" << command;
            QProcess *process = new QProcess(this);
            connect(process, SIGNAL(finished(int, QProcess::ExitStatus)), process, SLOT(deleteLater()));
            process->start(command);
            return true;
        }
    }

    return false;
}
