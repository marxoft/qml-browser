TEMPLATE = app
TARGET = qml-browser
QT += declarative xml network maemo5

HEADERS += \
    src/bookmarksmodel.h \
    src/cache.h \
    src/download.h \
    src/downloadmodel.h \
    src/encodingmodel.h \
    src/fontsizemodel.h \
    src/launcher.h \
    src/searchenginemodel.h \
    src/selectionmodel.h \
    src/settings.h \
    src/utils.h \
    src/volumekeys.h

SOURCES += \
    src/main.cpp \
    src/bookmarksmodel.cpp \
    src/download.cpp \
    src/downloadmodel.cpp \
    src/launcher.cpp \
    src/searchenginemodel.cpp \
    src/selectionmodel.cpp \
    src/settings.cpp \
    src/utils.cpp \
    src/volumekeys.cpp

target.path = /opt/qml-browser/bin

qml.files = $$files(src/qml/*.*)
qml.path = /opt/qml-browser/qml

desktopfile.files = qml-browser.desktop
desktopfile.path = /usr/share/applications/hildon

searchengines.files = $$files(searchengines/*.*)
searchengines.path = /home/user/.config/QMLBrowser

INSTALLS += target qml desktopfile searchengines
