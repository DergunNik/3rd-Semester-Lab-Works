#ifndef CIPHERMANAGER_H
#define CIPHERMANAGER_H

#include "consts.h"
#include <QDebug>
#include <QString>
#include <string>

extern "C" void caesar_cipher(int shift);
extern "C" int rand_d(int limit);
extern "C" void vigenere_cipher(int size, const char* key);
extern "C" void vigenere_decipher(int size, const char* key);
extern "C" void transposition_cipher(int div1, int div2);

class CipherManager
{
public:
    static int EncryptCaesar();
    static void DecryptCaesar(int shift);
    static void EncryptVigenere(const QString& key);
    static void DecryptVigenere(QString& key);
    static int GetRand(int limit);
    static int EncryptTransposition();
    static void DecryptTransposition(int div);
};

#endif // CIPHERMANAGER_H
