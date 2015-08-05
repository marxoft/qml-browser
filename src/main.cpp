/*
 * Copyright (C) 2015 Stuart Howarth <showarth@marxoft.co.uk>
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

#include "bookmarksmodel.h"
#include "cache.h"
#include "downloadmodel.h"
#include "encodingmodel.h"
#include "fontsizemodel.h"
#include "launcher.h"
#include "searchenginemodel.h"
#include "settings.h"
#include "utils.h"
#include "volumekeys.h"
#include <QWidget>
#include <QApplication>
#include <QDeclarativeEngine>
#include <QDeclarativeContext>
#include <QDeclarativeComponent>
#include <qdeclarative.h>
#include <QSsl>
#include <QSslConfiguration>
#include <QDebug>

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setOrganizationName("QMLBrowser");
    app.setApplicationName("QML Browser");
    
    qmlRegisterType<EncodingModel>("org.hildon.browser", 1, 0, "EncodingModel");
    qmlRegisterType<FontSizeModel>("org.hildon.browser", 1, 0, "FontSizeModel");

    qmlRegisterUncreatableType<BookmarksModel>("org.hildon.browser", 1, 0, "BookmarksModel", "");
    qmlRegisterUncreatableType<Download>("org.hildon.browser", 1, 0, "Download", "");
    qmlRegisterUncreatableType<DownloadModel>("org.hildon.browser", 1, 0, "DownloadModel", "");
    qmlRegisterUncreatableType<SearchEngineModel>("org.hildon.browser", 1, 0, "SearchEngineModel", "");
    
    QSslConfiguration config = QSslConfiguration::defaultConfiguration();
    config.setProtocol(QSsl::TlsV1);
    QSslConfiguration::setDefaultConfiguration(config);

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

    QDeclarativeComponent component(&engine, QUrl::fromLocalFile(QString("/opt/qml-browser/qml/%1.qml")
                                                                        .arg(url.isEmpty() ? "main" : "main_browser")));
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
        
        if (!fullScreen) {
            fullScreen = settings.openBrowserWindowsInFullScreen();
        }
        
        if (fullScreen) {
            if (QWidget *w = qobject_cast<QWidget*>(obj)) {
                w->showFullScreen();
            }
        }
    }

    QObject::connect(&app, SIGNAL(aboutToQuit()), &cache, SLOT(clear()));
    QObject::connect(&app, SIGNAL(aboutToQuit()), &bookmarks, SLOT(save()));
    QObject::connect(&app, SIGNAL(aboutToQuit()), &downloads, SLOT(save()));

    return app.exec();
}
