TEMPLATE = app

QT += qml quick websockets

SOURCES += main.cpp \
    imagepainter.cpp

RESOURCES += qml.qrc


# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    fileio.hpp \
    imagepainter.h

DISTFILES += \
    res/gestures.json
