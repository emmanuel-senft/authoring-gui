#include "imagepainter.h"
#include <QPainter>
#include <QImage>
#include <QBuffer>

// https://www.nuomiphp.com/eplan/en/70207.html
// https://stackoverflow.com/questions/59470754/qt-quick-how-to-use-a-c-class-inheriting-from-qquickpainteditem-in-a-qml-int
ImagePainter::ImagePainter(QQuickItem* parent)
{
    img = QImage(":/res/background.jpeg");
    defaultImg = img;
    _parent = parent;
    m_ratio = 1;
}


void ImagePainter::paint(QPainter* painter)
{
    if(! img.loadFromData(QByteArray::fromBase64(m_bArray)))
        img = defaultImg;

    float imgW = img.width();
    float imgH = img.height();
    float pW = width();
    float pH = height();

    float r = pW/pH;
    float h = imgW/r;
    setRatio(pW/imgW);
    m_offset = imgH-h;
    QRectF target(0.0, 0, pW, pH);
    QRectF source(0.0, m_offset, imgW, h);
    painter->drawImage(target, img, source);
}
