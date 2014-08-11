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
#include "downloadmodel.h"
#include "launcher.h"
#include "searchenginemodel.h"
#include "settings.h"
#include "utils.h"
#include "volumekeys.h"
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
    app.setApplicationName("QML Browser");

    qmlRegisterUncreatableType<BookmarksModel>("org.hildon.browser", 1, 0, "BookmarksModel", "");
    qmlRegisterUncreatableType<Download>("org.hildon.browser", 1, 0, "Download", "");
    qmlRegisterUncreatableType<DownloadModel>("org.hildon.browser", 1, 0, "DownloadModel", "");
    qmlRegisterUncreatableType<SearchEngineModel>("org.hildon.browser", 1, 0, "SearchEngineModel", "");

    Settings settings;
    Utils utils;
    VolumeKeys keys;

    Cache cache;
    cache.create();

    Launcher launcher;
    launcher.loadHandlers();

    BookmarksModel bookmarks;
    bookmarks.load();

    DownloadModel downloads;
    downloads.load();

    SearchEngineModel searchEngines;
    searchEngines.load();

    QDeclarativeEngine engine;
    engine.rootContext()->setContextProperty("launcher", &launcher);
    engine.rootContext()->setContextProperty("bookmarks", &bookmarks);
    engine.rootContext()->setContextProperty("downloads", &downloads);
    engine.rootContext()->setContextProperty("searchEngines", &searchEngines);
    engine.rootContext()->setContextProperty("qmlBrowserSettings", &settings);
    engine.rootContext()->setContextProperty("qmlBrowserUtils", &utils);
    engine.rootContext()->setContextProperty("volumeKeys", &keys);

    QString url;
    bool fullScreen = false;
    QStringList args = app.arguments();

    if (args.size() > 1) {
        args.removeFirst();

        foreach (QString arg, args) {
            arg = arg.toLower();

            if (arg.startsWith("--url=")) {
                url = arg.section("--url=", -1);
            }
            else if (arg.startsWith("--full_screen")) {
                fullScreen = true;
            }
        }
    }

    QDeclarativeComponent component(&engine, QUrl::fromLocalFile(QString("/opt/qml-browser/qml/%1.qml").arg(url.isEmpty() ? "main" : "main_browser")));
    QObject *obj = component.create();

    if (component.isError()) {
        foreach (QDeclarativeError error, component.errors()) {
            qWarning() << error.toString();
        }

        if (obj) {
            delete obj;
        }

        return 0;
    }

    if (!url.isEmpty()) {
        obj->setProperty("url", url);
        obj->setProperty("fullScreen", (fullScreen) || (settings.openBrowserWindowsInFullScreen()));
    }

    QObject::connect(&app, SIGNAL(aboutToQuit()), &cache, SLOT(clear()));
    QObject::connect(&app, SIGNAL(aboutToQuit()), &downloads, SLOT(save()));

    return app.exec();
}
