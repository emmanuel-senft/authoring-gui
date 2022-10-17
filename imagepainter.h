#ifndef IMAGEPAINTER_H
#define IMAGEPAINTER_H
#include <QQuickPaintedItem>
#include <QtWebSockets/QWebSocket>
#include <QImage>

class ImagePainter : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(float ratio READ ratio WRITE setRatio NOTIFY ratioChanged)
    Q_PROPERTY(int offset READ offset WRITE setOffset NOTIFY offsetChanged)
    Q_PROPERTY(QByteArray bArray READ bArray WRITE setBArray NOTIFY bArrayChanged)
private:
    QImage img;
    QImage defaultImg;
    QQuickItem* _parent;
    QString color;
    float m_ratio;
    int m_offset;
    QByteArray m_bArray;
public:
    ImagePainter(QQuickItem* parent = 0);

    void paint(QPainter* painter);

    void setRatio(const float &a){
        if (a != m_ratio) {
            m_ratio = a;
            emit ratioChanged();
        }
    }
    void setOffset(const int &a){
        if (a != m_offset) {
            m_offset = a;
            emit offsetChanged();
        }
    }
    void setBArray(const QByteArray &a){
        if (a != m_bArray) {
            m_bArray = a;
            emit bArrayChanged();
        }
    }

    float ratio() const {
        return m_ratio;
    }
    int offset() const {
        return m_offset;
    }
    QByteArray bArray() const {
        return m_bArray;
    }

signals:
    void ratioChanged();
    void offsetChanged();
    void bArrayChanged();
};

#endif // IMAGEPAINTER_H
/*
class imagePainter : public QQuickPaintedItem
{
    Q_OBJECT
private:
    QWebSocket m_webSocket;
public:
    imagePainter(QQuickItem* parent = 0){
        QObject::connect(&m_webSocket, &QWebSocket::connected, this, &imagePainter::onConnected);
        m_webSocket.open(QUrl("ws://192.168.0.160:49154"));
    }
    ~imagePainter(){ };
    //! [onConnected]
    void onConnected()
    {
        connect(&m_webSocket, &QWebSocket::textMessageReceived,
                this, &imagePainter::onTextMessageReceived);
        //m_webSocket.sendTextMessage(QStringLiteral("Hello, world!"));
    }
    //! [onConnected]

    //! [onTextMessageReceived]
    void onTextMessageReceived(QString message)
    {
        qDebug() << "Message received:" << message;
        m_webSocket.close();
    }
    void paint(QPainter *painter) override;
};
*/
