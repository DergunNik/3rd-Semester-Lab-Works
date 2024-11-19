#include "ciphermanager.h"
#include <iostream>

int CipherManager::EncryptCaesar()
{
    int s = rand_d(10);
    caesar_cipher(s);
    return s;
}

void CipherManager::DecryptCaesar(int shift)
{
    caesar_cipher(-shift);
}


void CipherManager::EncryptVigenere(const QString& key)
{
    vigenere_cipher(key.size(), key.toStdString().data());
}

void CipherManager::DecryptVigenere(QString& key)
{
    std::cout << key.size() <<' '<< key.toStdString() << '\n';
    QString _key;
    for (int i = 0; i < key.size(); ++i) {
        _key.append(QChar(char(128 - key.toStdString()[i])));
    }
    std::cout << _key.size() <<' '<< _key.toStdString()<< std::endl;
    vigenere_cipher(_key.size(), _key.toStdString().data());
}

int CipherManager::GetRand(int limit)
{
    return rand_d(limit);
}

int CipherManager::EncryptTransposition()
{
    int div = rand_d(10);
    auto t = std::array<int, 3>{4, 8, 16};
    div = t[div % 3];
    std::cout << div <<' '<< BUFFER_SIZE / div << std::endl;
    transposition_cipher(div, BUFFER_SIZE / div);
    return div;
}

void CipherManager::DecryptTransposition(int div)
{
    div = BUFFER_SIZE / div;
    std::cout << div <<' '<< BUFFER_SIZE / div << std::endl;
    transposition_cipher(div, BUFFER_SIZE / div);
}
