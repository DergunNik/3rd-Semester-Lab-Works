#include "windowsmanager.h"


void WindowsManager::delFile(QString name) {
    _passwords.erase(name);

    QFile file(name);
    if (file.exists()) {
        if (!file.remove()) {
            showErrorPopup("Error deleting file!");
            return;
        }
    } else {
        showErrorPopup("File does not exist!");
        return;
    }

    showInfoPopup("File deleted!");
}


WindowsManager::WindowsManager()
{
    connect(&_start_menu, &StartWindow::OpenF, this, &WindowsManager::OpenCall);
    connect(&_start_menu, &StartWindow::CreateF, this, &WindowsManager::CreateCall);
    connect(&_edit_w, &EditWindow::SaveText, this, &WindowsManager::SaveCall);
    connect(&_save_m, &SaveManager::SaveData, this, &WindowsManager::FinishCall);
    connect(&_open_m, &OpenManager::Check, this, &WindowsManager::CheckPassword);
    connect(&_start_menu, &StartWindow::SavePasswords, this, &WindowsManager::SavePasswords);
    connect(&_start_menu, &StartWindow::LoadPasswords, this, &WindowsManager::LoadPasswords);
}

void WindowsManager::start()
{
    _start_menu.show();
}

void WindowsManager::OpenCall()
{
    _start_menu.hide();
    _open_m.show();
}

void WindowsManager::CreateCall()
{
    _start_menu.hide();
    _edit_w.clear();
    _edit_w.show();
}

void WindowsManager::SaveCall(QString text)
{
    _edit_w.hide();
    _save_m.SetText(std::move(text));
    _save_m.show();
}

void WindowsManager::FinishCall(QString name, QByteArray hash, QString info)
{
    _passwords[name] = fileInfo{hash, info, BASE_ATTEMPTS_NUM};
    _save_m.hide();
    _start_menu.show();
}

void WindowsManager::CheckPassword(QString name, QString password)
{
    if (_passwords.count(name)) {
        if (_save_m.hashPassword(password) == _passwords[name].hash) {
            _passwords[name].attempts = BASE_ATTEMPTS_NUM;
            AccessAllowed(name, true);
        } else {
            _passwords[name].attempts -= 1;
            if (_passwords[name].attempts < 1) {
                delFile(name);
                _open_m.AccessDenied(0);
            } else {
                _open_m.AccessDenied(_passwords[name].attempts);
            }
        }
    } else {
        AccessAllowed(name, false);
    }
}

void WindowsManager::AccessAllowed(const QString& name, bool isNameFound)
{
    if (isNameFound) {
        showInfoPopup("Access is allowed!");
    } else {
        showInfoPopup("There is no info about this file!");
    }
    QString decryptedText = decrypt(name);
    _open_m.hide();
    _open_m.clear();
    _edit_w.setText(decryptedText);
    _edit_w.show();
}

QString WindowsManager::decrypt(const QString& name)
{
    auto text = readRaw(name);
    if (!_passwords.count(name)) {
        return text;
    }

    QFile in_file(TEMP_IN_FILE_NAME);
    in_file.open(QIODevice::WriteOnly | QIODevice::Text);
    QTextStream out(&in_file);
    out << text;
    in_file.close();

    auto info = _passwords[name].info;
    int shift, textSize, div = -1;
    std::string key;
    switch (char(info.toStdString().at(0))) {
    case 'c':
        shift = int(info.toStdString().at(1));
        CipherManager::DecryptCaesar(shift);
        break;
    case 'v':
        info.erase(info.begin());
        CipherManager::DecryptVigenere(info);
        break;
    case 't':
        info.remove(0, 1);
        shift = info.indexOf('|');
        textSize = info.left(shift).toInt();
        div = info.mid(shift + 1).toInt();
        CipherManager::DecryptTransposition(div);
        break;
    }

    QFile out_file(TEMP_OUT_FILE_NAME);
    out_file.open(QIODevice::ReadOnly | QIODevice::Text);
    QTextStream in(&out_file);
    if (div != -1) {
        text = in.read(textSize);
    } else {
        text = in.readAll();
    }

    in_file.remove();
    out_file.remove();
    std::cout << text.toStdString() << std::endl;
    std::cout.flush();
    return text;
}

QString WindowsManager::readRaw(const QString& name)
{
    QString text;

    QFile file(name);
    if (file.exists()) {
        if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            QTextStream in(&file);
            text = in.readAll();
            file.close();
        } else {
            showErrorPopup("Error opening file for reading!");
            return QString();
        }
    } else {
        showErrorPopup("File does not exist!");
        return QString();
    }

    return text;
}

void WindowsManager::SavePasswords(QString filename) {
    QFile file(filename);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream out(&file);
        for (const auto& [key, value] : _passwords) {
            out << key << "\n"
                << value.hash.toHex() << "\n"
                << value.info << "\n"
                << value.attempts << "\n";
        }
        file.close();
    } else {
        qWarning() << "Password saving error";
    }
}

void WindowsManager::LoadPasswords(QString filename) {
    QFile file(filename);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&file);
        while (!in.atEnd()) {
            QString key = in.readLine();
            QByteArray hash = QByteArray::fromHex(in.readLine().toUtf8());
            QString info = in.readLine();
            int attempts = in.readLine().toInt();

            _passwords[key] = {hash, info, attempts};
        }
        file.close();
    } else {
        qWarning() << "Password file error";
    }
}
