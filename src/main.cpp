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

#include "bookmarksmodel.h"
#include "cache.h"
#include <QApplication>
#include <QDeclarativeEngine>
#include <QDeclarativeContext>
#include <QDeclarativeComponent>
#include <qdeclarative.h>
#include <QDebug>

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setOrganizationName("QMLBrowser");
    app.setApplicationName("Browser");

    qmlRegisterUncreatableType<BookmarksModel>("org.hildon.browser", 1, 0, "BookmarksModel", "");

    Cache cache;
    cache.create();

    BookmarksModel bookmarks;
    bookmarks.setFileName("/home/user/.config/QMLBrowser/bookmarks.xml");

    QDeclarativeEngine engine;
    engine.rootContext()->setContextProperty("bookmarks", &bookmarks);

    QDeclarativeComponent component(&engine, QUrl("qrc:/main.qml"));
    component.create();

    if (component.isError()) {
        foreach (QDeclarativeError error, component.errors()) {
            qWarning() << error.toString();
        }

        return 0;
    }

    QObject::connect(&app, SIGNAL(aboutToQuit()), &cache, SLOT(clear()));

    return app.exec();
}
