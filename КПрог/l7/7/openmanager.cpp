#include "openmanager.h"
#include "ui_openmanager.h"

OpenManager::OpenManager(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::OpenManager)
{
    ui->setupUi(this);
}

OpenManager::~OpenManager()
{
    delete ui;
}

void OpenManager::AccessDenied(int left)
{
    if (left > 0) {
        showInfoPopup("There are " + QString::number(left) + " attempts left!");
    } else {
        ui->nameE->setText("");
    }
    ui->passE->setText("");
}

void OpenManager::clear()
{
    ui->nameE->setText("");
    ui->passE->setText("");
}

void OpenManager::on_fileBtn_clicked()
{
    QString fileName = QFileDialog::getOpenFileName(this, "Open File", "", "All Files (*)");
    if (!fileName.isEmpty()) {
        ui->nameE->setText(fileName);
    }
}


void OpenManager::on_decryptBtn_clicked()
{
    if (ui->nameE->text().isEmpty() || ui->passE->text().isEmpty()) {
        showErrorPopup("Name and password cannot be empty!");
        return;
    }

    emit Check(ui->nameE->text(), ui->passE->text());
}

