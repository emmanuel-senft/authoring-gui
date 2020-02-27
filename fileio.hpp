#ifndef FILEIO_HPP
#define FILEIO_HPP
#include <QObject>
#include <QFile>
#include <QTextStream>
#include <QStandardPaths>
#include <QDir>
#include <QJsonDocument>
#include <QJsonValue>
#include <QJsonArray>
#include <QJsonObject>
#include <iostream>

using namespace std;
class FileIO : public QObject
{
    Q_OBJECT

public slots:
    bool write(const QString& source, const QString& data)
    {
        if (source.isEmpty())
            return false;

        QDir basepath = QDir(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation));

        QFile file(basepath.absoluteFilePath(source));
        if (!file.open(QFile::WriteOnly ))
            return false;

        QTextStream out(&file);
        out << data << "\n";
        file.close();
        return true;
    }
    QString read() {
          QString val;
          QFile file;
          file.setFileName("~/src/authoring-gui/res/gestures.json");
          file.open(QIODevice::ReadOnly | QIODevice::Text);
          val = file.readAll();
          file.close();
          return val;
       }

public:
    FileIO() {}
};

#endif // FILEIO_HPP
