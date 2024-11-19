#ifndef SAVEMANAGER_H
#define SAVEMANAGER_H

#include "ciphermanager.h"
#include "consts.h"
#include "popups.h"
#include <QCryptographicHash>
#include <QFile>
#include <QFileDialog>
#include <QMainWindow>
#include <QTextStream>
#include <string>
#include <iostream>

namespace Ui {
class SaveManager;
}

class SaveManager : public QMainWindow
{
    Q_OBJECT

    QString _text;
    QString _cipherInfo;
    void toTempFile();
    void deleteTempFiles();

public:
    explicit SaveManager(QWidget *parent = nullptr);
    ~SaveManager();

    void SetText(QString&& txt) {
        _text = txt;
    }

    QByteArray hashPassword(const QString &password);

private slots:
    void on_saveBtn_clicked();
    void on_fileBtn_clicked();

signals:
    void SaveData(QString, QByteArray, QString);

private:
    Ui::SaveManager *ui;

    QString caesarCall();
    QString visCall();
    QString transCall();
};

#endif // SAVEMANAGER_H
