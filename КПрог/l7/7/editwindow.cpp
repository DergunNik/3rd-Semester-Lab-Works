#include "editwindow.h"
#include "ui_editwindow.h"

EditWindow::EditWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::EditWindow)
{
    ui->setupUi(this);
}

EditWindow::~EditWindow()
{
    delete ui;
}

void EditWindow::clear()
{
    ui->textEdit->clear();
}

void EditWindow::setText(const QString& txt)
{
    ui->textEdit->setText(txt);
}

void EditWindow::on_saveBtn_clicked()
{
    emit SaveText(ui->textEdit->toPlainText());
}

