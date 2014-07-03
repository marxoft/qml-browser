TEMPLATE = app
TARGET = qml-browser
QT += declarative xml

SOURCES += src/main.cpp \
    src/bookmarksmodel.cpp

HEADERS += src/bookmarksmodel.h

RESOURCES += src/resources.qrc

OTHER_FILES += src/*.qml

desktopfile.files = qml-browser.desktop
desktopfile.path = /usr/share/applications/hildon

target.path = /opt/qml-browser/bin

INSTALLS += target desktopfile
