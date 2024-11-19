#ifndef EDITWINDOW_H
#define EDITWINDOW_H

#include <QMainWindow>

namespace Ui {
class EditWindow;
}

class EditWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit EditWindow(QWidget *parent = nullptr);
    ~EditWindow();
    void clear();
    void setText(const QString&);

private slots:
    void on_saveBtn_clicked();

private:
    Ui::EditWindow *ui;

signals:
    void SaveText(QString text);
};

#endif // EDITWINDOW_H
