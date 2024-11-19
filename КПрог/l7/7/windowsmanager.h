#ifndef WINDOWSMANAGER_H
#define WINDOWSMANAGER_H

#include "consts.h"
#include "editwindow.h"
#include "mainwindow.h"
#include "openmanager.h"
#include "popups.h"
#include "savemanager.h"
#include <QByteArray>
#include <QCryptographicHash>
#include <QFile>
#include <QMap>
#include <QString>
#include <QDebug>
#include <unordered_map>
#include <string>
#include <iostream>

struct fileInfo {
    QByteArray hash;
    QString info;
    int attempts = BASE_ATTEMPTS_NUM;
};

class WindowsManager : public QObject
{
    Q_OBJECT

    StartWindow _start_menu;
    EditWindow _edit_w;
    OpenManager _open_m;
    SaveManager _save_m;
    std::unordered_map<QString, fileInfo> _passwords;
    void delFile(QString);
    void AccessAllowed(const QString&, bool);
    QString decrypt(const QString&);
    QString readRaw(const QString&);

public:
    WindowsManager();
    void start();

public slots:
    void OpenCall();
    void CreateCall();
    void SaveCall(QString text);
    void FinishCall(QString, QByteArray, QString);
    void CheckPassword(QString, QString);
    void SavePasswords(QString filename);
    void LoadPasswords(QString filename);
};

#endif // WINDOWSMANAGER_H
