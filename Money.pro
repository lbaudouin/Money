# Add more folders to ship with the application, here
folder_01.source = qml/Money
folder_01.target = qml
DEPLOYMENTFOLDERS = folder_01

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp \
    sqlmanip.cpp

# Installation path
# target.path =

# Please do not modify the following two lines. Required for deployment.
include(qtquick2applicationviewer/qtquick2applicationviewer.pri)
qtcAddDeployment()

HEADERS += \
    sqlmanip.h

exists( connection_params.h ){
    HEADERS += connection_params.h
    DEFINES += USE_DB_CONFIG
}

QT += sql


DEFINES +=  QT_SQL_MYSQL

OTHER_FILES += qml/Money/qchart/*

RESOURCES += \
    images.qrc
