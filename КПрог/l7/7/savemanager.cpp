#include "savemanager.h"
#include "ui_savemanager.h"

void SaveManager::toTempFile()
{
    QFile file(TEMP_IN_FILE_NAME);
    file.open(QIODevice::WriteOnly | QIODevice::Text);
    QTextStream out(&file);
    out << _text;
    file.close();
}

void SaveManager::deleteTempFiles()
{
    QFile file1(TEMP_IN_FILE_NAME);
    file1.remove();
    QFile file2(TEMP_OUT_FILE_NAME);
    file2.remove();
}

SaveManager::SaveManager(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::SaveManager)
{
    ui->setupUi(this);
}

SaveManager::~SaveManager()
{
    delete ui;
}

QByteArray SaveManager::hashPassword(const QString &password) {
    QCryptographicHash hash(QCryptographicHash::Sha256);
    hash.addData(password.toUtf8());
    return hash.result();
}

void SaveManager::on_saveBtn_clicked()
{
    if (ui->nameE->text().isEmpty() || ui->passE->text().isEmpty()) {
        showErrorPopup("Name and password cannot be empty!");
        return;
    }

    QString encryptedText;
    if (ui->caesar->isChecked()) {
        encryptedText = caesarCall();
    } else if (ui->trans->isChecked()) {
        encryptedText = transCall();
    } else {
        encryptedText = visCall();
    }

    QString fileName = ui->nameE->text();
    QFile file(fileName);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        showErrorPopup("Error opening file for writing!");
        return;
    }

    QTextStream out(&file);
    out << encryptedText;
    file.close();

    showInfoPopup("File saved successfully!");

    QByteArray hashedPassword = hashPassword(ui->passE->text());
    emit SaveData(ui->nameE->text(), hashedPassword, _cipherInfo);
}

QString SaveManager::caesarCall()
{
    toTempFile();
    int shift = CipherManager::EncryptCaesar();
    _cipherInfo = "c" + QString(1, char(shift));
    QFile file(TEMP_OUT_FILE_NAME);
    file.open(QIODevice::ReadOnly | QIODevice::Text);
    QTextStream in(&file);
    QString ret = in.readAll();
    file.close();
    deleteTempFiles();
    return ret;
}

QString SaveManager::visCall()
{
    toTempFile();
    QString key;
    for (int i = 0; i < KEY_SIZE - 1 + CipherManager::GetRand(KEY_SIZE); ++i) {
        key.append(char(CipherManager::GetRand(7) + 1));
    }
    CipherManager::EncryptVigenere(key);
    _cipherInfo = "v" + key;
    QFile file(TEMP_OUT_FILE_NAME);
    file.open(QIODevice::ReadOnly | QIODevice::Text);
    QTextStream in(&file);
    QString ret = in.readAll();
    file.close();
    deleteTempFiles();
    return ret;
}

QString SaveManager::transCall()
{
    toTempFile();
    int div = CipherManager::EncryptTransposition();
    _cipherInfo = "t" + QString::number(_text.size()) + "|" + QString::number(div);
    QFile file(TEMP_OUT_FILE_NAME);
    file.open(QIODevice::ReadOnly | QIODevice::Text);
    QTextStream in(&file);
    QString ret = in.readAll();
    file.close();
    deleteTempFiles();
    return ret;
}

void SaveManager::on_fileBtn_clicked()
{
    QString fileName = QFileDialog::getSaveFileName(this, "Save File", "", "All Files (*);;Text Files (*.txt)");
    if (!fileName.isEmpty()) {
        ui->nameE->setText(fileName);
    }
}
