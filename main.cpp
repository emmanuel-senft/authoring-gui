#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlComponent>
#include <QFont>

//#include <ros/ros.h>

#include "imagepainter.h"

#include "fileio.hpp"

QT_USE_NAMESPACE

int main(int argc, char *argv[])
{
    //ros::init(argc, argv,"authoringGui");

    FileIO fileio;
    QGuiApplication app(argc, argv);

    qmlRegisterType<ImagePainter>("ImagePainterQml", 1, 0, "ImagePainter");

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("fileio", &fileio);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    QFont fon("SourceSansPro", 12);
    app.setFont(fon);

    return app.exec();
}
