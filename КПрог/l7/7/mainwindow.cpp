#include "mainwindow.h"
#include "./ui_mainwindow.h"

StartWindow::StartWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);
}

StartWindow::~StartWindow()
{
    delete ui;
}

void StartWindow::on_openBtn_clicked()
{
    emit OpenF();
}


void StartWindow::on_createBtn_clicked()
{
    emit CreateF();
}


void StartWindow::on_pSaveBtn_clicked()
{
    QString filename = QFileDialog::getSaveFileName(this, "Save file", "", "Text Files (*.txt);;All Files (*)");
    if (!filename.isEmpty()) {
        emit SavePasswords(filename);
    }
}


void StartWindow::on_pushButton_2_clicked()
{
    QString filename = QFileDialog::getOpenFileName(this, "Open file", "", "Text Files (*.txt);;All Files (*)");
    if (!filename.isEmpty()) {
        emit LoadPasswords(filename);
    }
}
