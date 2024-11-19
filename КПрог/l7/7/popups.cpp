#include "popups.h"

void showErrorPopup(const QString &message) {
    QMessageBox::critical(nullptr, "Error", message);
}

void showInfoPopup(const QString &message) {
    QMessageBox::information(nullptr, "Info", message);
}
