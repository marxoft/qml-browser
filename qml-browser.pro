TEMPLATE = app
TARGET = qml-browser
QT += declarative xml

SOURCES += src/main.cpp \
    src/bookmarksmodel.cpp \
    src/launcher.cpp \
    src/searchenginemodel.cpp \
    src/settings.cpp

HEADERS += src/bookmarksmodel.h \
    src/cache.h \
    src/launcher.h \
    src/searchenginemodel.h \
    src/settings.h

RESOURCES += src/resources.qrc

OTHER_FILES += src/*.qml

desktopfile.files = qml-browser.desktop
desktopfile.path = /usr/share/applications/hildon

searchengines.files = $$files(searchengines/*.*)
searchengines.path = /home/user/.config/QMLBrowser

target.path = /opt/qml-browser/bin

INSTALLS += target desktopfile searchengines
