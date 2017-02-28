TEMPLATE = app
TARGET = qml-browser
QT += declarative network maemo5

HEADERS += \
    src/bookmarksmodel.h \
    src/download.h \
    src/downloadmodel.h \
    src/encodingmodel.h \
    src/fontsizemodel.h \
    src/logger.h \
    src/searchenginemodel.h \
    src/selectionmodel.h \
    src/settings.h \
    src/urlopenermodel.h \
    src/utils.h \
    src/volumekeys.h

SOURCES += \
    src/main.cpp \
    src/bookmarksmodel.cpp \
    src/download.cpp \
    src/downloadmodel.cpp \
    src/logger.cpp \
    src/searchenginemodel.cpp \
    src/selectionmodel.cpp \
    src/settings.cpp \
    src/urlopenermodel.cpp \
    src/utils.cpp \
    src/volumekeys.cpp

qml.files = \
    src/qml/AboutDialog.qml \
    src/qml/BookmarkDelegate.qml \
    src/qml/BookmarksWindow.qml \
    src/qml/BrowserWindow.qml \
    src/qml/DownloadDelegate.qml \
    src/qml/DownloadsDialog.qml \
    src/qml/EditBookmarkDialog.qml \
    src/qml/FullscreenIndicator.qml \
    src/qml/HistoryDelegate.qml \
    src/qml/HistoryWindow.qml \
    src/qml/ListSelectorButton.qml \
    src/qml/main.qml \
    src/qml/main_browser.qml \
    src/qml/NewBookmarkDialog.qml \
    src/qml/NewSearchEngineDialog.qml \
    src/qml/SaveFileDialog.qml \
    src/qml/SettingsDialog.qml \
    src/qml/UrlInputField.qml \
    src/qml/UrlOpenerDelegate.qml \
    src/qml/UrlOpenerDialog.qml \
    src/qml/UrlOpenersDialog.qml \
    src/qml/ViewSourceWindow.qml

qml.path = /opt/qml-browser/qml

desktopfile.files = desktop/qml-browser.desktop
desktopfile.path = /usr/share/applications/hildon

searchengines.files = $$files(searchengines/*.*)
searchengines.path = /home/user/.config/QMLBrowser

target.path = /opt/qml-browser/bin

INSTALLS += \
    qml \
    desktopfile \
    searchengines \
    target
