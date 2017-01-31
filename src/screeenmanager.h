#ifndef SCREEENMANAGER_H
#define SCREEENMANAGER_H

#include <QObject>
#include <QWindow>

class ScreeenManager : public QObject
{
    Q_OBJECT
public:
    explicit ScreeenManager(QObject *parent = 0);

    Q_INVOKABLE int screenCount() const;

    Q_INVOKABLE void setScreen(QWindow * window, int screen);
};

#endif // SCREEENMANAGER_H
