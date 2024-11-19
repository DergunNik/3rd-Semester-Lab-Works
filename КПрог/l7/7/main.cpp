#include "mainwindow.h"
#include "windowsmanager.h"

#include <QApplication>


int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    WindowsManager w;
    w.start();
    return a.exec();
}
