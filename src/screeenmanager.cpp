#include "screeenmanager.h"
#include <QGuiApplication>
#include <QDebug>

ScreeenManager::ScreeenManager(QObject *parent) :
    QObject(parent)
{
}

int ScreeenManager::screenCount() const {
    return QGuiApplication::screens().count();
}

void ScreeenManager::setScreen(QWindow *window, int screen) {
    if(screen >= 0 && screen < QGuiApplication::screens().count()) {
        window->setScreen(QGuiApplication::screens().at(screen));
        window->showFullScreen();
    }
}
