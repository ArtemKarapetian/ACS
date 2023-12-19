#include <vector>
#include <iostream>
#include <fstream>

// Вывод сообщения на экран и в файл
void print(std::ofstream& outputStream, std::string outputMessage) {
    outputStream << outputMessage << std::endl;
    std::cout << outputMessage << std::endl;
}

// Функция для вывода сада в консоль
void printGarden(const std::vector<std::vector<char> >& garden, std::ofstream& outputStream) {
    // Банальный проход цикла в цикле
    for (int i = 0; i < garden.size(); ++i) {
        for (int j = 0; j < garden[0].size(); ++j) {
            outputStream << garden[i][j] << " ";
            std::cout << garden[i][j] << " ";
        }
        outputStream << std::endl;
        std::cout << std::endl;
    }
    outputStream << std::endl;
    std::cout << std::endl;
}

// Функция для чтения чисел для размеров сада
void readDimensions(std::size_t& n, std::size_t& m) {
    std::cout << "Введите размеры сада (n, m) через пробел: ";
    int N, M;
    // Обработка ошибок
    while (!(std::cin >> N) || N <= 0 || !(std::cin >> M) || M <= 0) {
        std::cout << "Ошибка ввода. Пожалуйста, введите целочисленные положительные значения для n и m: ";
        std::cin.clear();
        std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
    }
    std::cin.clear();
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
    n = N;
    m = M;
}

// Функция для чтения чисел для скоростей
void readSpeed(int& speed1, int& speed2) {
    std::cout << "Введи скорость1 и скорость2 (speed1, speed2) через пробел: ";
    while (!(std::cin >> speed1 >> speed2) || speed1 <= 0 || speed2 <= 0) {
        std::cout << "Ошибка ввода. Пожалуйста, введите целочисленные положительные значения: ";
        std::cin.clear();
        std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
    }
    std::cin.clear();
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
}

// Чтение одного числа
int readNumber() {
    int number;
    std::cout << "Введите число 0 или 1: ";
    while (!(std::cin >> number) || (number != 0 && number != 1)) {
        std::cout << "Ошибка ввода. Пожалуйста, введите число 0 или 1: ";
        std::cin.clear();
        std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
    }
    return number;
}
