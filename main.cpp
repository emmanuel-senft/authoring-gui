#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlComponent>
#include <QFont>

#include <ros/ros.h>

#include "fileio.hpp"

int main(int argc, char *argv[])
{
    ros::init(argc, argv,"pickGui");

    FileIO fileio;
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("fileio", &fileio);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    QFont fon("SourceSansPro", 12);
    app.setFont(fon);

    return app.exec();
}
