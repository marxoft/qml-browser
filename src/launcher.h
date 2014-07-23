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

#ifndef LAUNCHER_H
#define LAUNCHER_H

#include <QObject>
#include <QRegExp>

typedef struct {
    QString name;
    QRegExp regExp;
    QString command;
} Handler;

class Launcher : public QObject
{
    Q_OBJECT

public:
    explicit Launcher(QObject *parent = 0);
    ~Launcher();

    Q_INVOKABLE void loadHandlers();

    Q_INVOKABLE void addHandler(const QString &name, const QString &regExp, const QString &command);

    Q_INVOKABLE QString handler(const QString &url) const;

    Q_INVOKABLE bool canLaunch(const QString &url) const;

public slots:
    bool launch(const QString &url);

private:
    QList<Handler> m_handlers;

    Q_DISABLE_COPY(Launcher)
};

#endif // LAUNCHER_H
