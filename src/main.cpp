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
#include "downloadmodel.h"
#include "encodingmodel.h"
#include "fontsizemodel.h"
#include "searchenginemodel.h"
#include "settings.h"
#include "urlopenermodel.h"
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
    app.setApplicationVersion("0.9.0");
    
    qmlRegisterType<EncodingModel>("org.hildon.browser", 1, 0, "EncodingModel");
    qmlRegisterType<FontSizeModel>("org.hildon.browser", 1, 0, "FontSizeModel");
    qmlRegisterType<SelectionModel>("org.hildon.browser", 1, 0, "SelectionModel");

    qmlRegisterUncreatableType<BookmarksModel>("org.hildon.browser", 1, 0, "BookmarksModel", "");
    qmlRegisterUncreatableType<Download>("org.hildon.browser", 1, 0, "Download", "");
    qmlRegisterUncreatableType<DownloadModel>("org.hildon.browser", 1, 0, "DownloadModel", "");
    qmlRegisterUncreatableType<SearchEngineModel>("org.hildon.browser", 1, 0, "SearchEngineModel", "");
    qmlRegisterUncreatableType<UrlOpenerModel>("org.hildon.browser", 1, 0, "UrlOpenerModel", "");
    
    QSslConfiguration config = QSslConfiguration::defaultConfiguration();
    config.setProtocol(QSsl::TlsV1);
    QSslConfiguration::setDefaultConfiguration(config);
        
    Settings settings;
    Utils utils;
    VolumeKeys keys;

    UrlOpenerModel opener;
    opener.load();

    BookmarksModel bookmarks;
    bookmarks.load();

    DownloadModel downloads;
    downloads.load();

    SearchEngineModel searchEngines;
    searchEngines.load();

    QDeclarativeEngine engine;
    QDeclarativeContext *context = engine.rootContext();
    context->setContextProperty("urlopener", &opener);
    context->setContextProperty("bookmarks", &bookmarks);
    context->setContextProperty("downloads", &downloads);
    context->setContextProperty("searchEngines", &searchEngines);
    context->setContextProperty("qmlBrowserSettings", &settings);
    context->setContextProperty("qmlBrowserUtils", &utils);
    context->setContextProperty("volumeKeys", &keys);
    context->setContextProperty("BOOKMARKS_PATH", "/home/user/.config/QMLBrowser/bookmarks/");
    context->setContextProperty("HISTORY_PATH", "/home/user/.config/QMLBrowser/history");
    context->setContextProperty("VERSION_NUMBER", "0.9.0");

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
        foreach (const QDeclarativeError &error, component.errors()) {
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

    return app.exec();
}
