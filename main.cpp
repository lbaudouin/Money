#include <QtGui/QGuiApplication>
#include "qtquick2applicationviewer.h"

#include "sqlmanip.h"
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    SqlManip sql;

    QtQuick2ApplicationViewer viewer;

    viewer.rootContext()->setContextProperty("sql",&sql);

    viewer.setMainQmlFile(QStringLiteral("qml/Money/main.qml"));

    viewer.show();
    //viewer.showExpanded();

    return app.exec();
}
