#ifndef OPENMANAGER_H
#define OPENMANAGER_H

#include <QMainWindow>
#include <QFileDialog>
#include "popups.h"

namespace Ui {
class OpenManager;
}

class OpenManager : public QMainWindow
{
    Q_OBJECT

    QPair<bool, bool> _ans;

public:
    explicit OpenManager(QWidget *parent = nullptr);
    ~OpenManager();
    void AccessDenied(int left);
    void clear();

private slots:
    void on_fileBtn_clicked();
    void on_decryptBtn_clicked();

private:
    Ui::OpenManager *ui;

signals:
    void Check(QString, QString);
};

#endif // OPENMANAGER_H
