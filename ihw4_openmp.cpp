#include <fstream>
#include <iostream>
#include <pthread.h>
#include <unistd.h>
#include <vector>
#include "Helper.h"

// Стрим для вывода
std::ofstream output;
int numOfStep = 0;
// Отслеживатель заполненности сада (если один садовник отработа => сад заполнен)
bool oneGardeneredEnded = false;
// Константы, показывающие, чем занят квадрат
const char EMPTY = '-';
const char POND_OR_ROCK = 'o';
const char FIRST_GARDENER = 'F';
const char SECOND_GARDENER = 'S';

// Структура для передачи параметров в поток садовника
struct Gardener {
    // След после работы садовника
    char trace;
    // Передаю указатель на вектор, чтобы оба садовника могли менять один сад
    std::vector<std::vector<char> > *garden;
    // Все данные для создания пути садовника и со скоростью
    std::pair<int, int> startPos, endPos, step, rotate;
    int speed;
};

// Функция для инициализации сада с прудами или камнями
void initializeGarden(std::vector<std::vector<char> >& garden, std::size_t m, std::size_t n) {
    int maxPondsOrRocks = std::rand() % (m * n / 5) + (m * n / 10);
    for (int i = 0; i < maxPondsOrRocks; ++i) {
        int row = rand() % m;
        int col = rand() % n;
        if (garden[row][col] == POND_OR_ROCK) {
            --i;
            continue;
        }
        garden[row][col] = POND_OR_ROCK; // 1 - пруд или камень
    }
}

// Функция, представляющая работу садовника
void gardenerWork(Gardener& gardener) {
    // Сохранение в переменные всех данных о садоводе. 
    // Формально это не требуется, но нежели обращаться к структуре каждый раз, можно просто сохранить переменные
    char trace = gardener.trace;
    std::vector<std::vector<char> > &garden = *(gardener.garden);
    std::pair<int, int> startPos = gardener.startPos;
    std::pair<int, int> endPos = gardener.endPos;
    std::pair<int, int> step = gardener.step;
    std::pair<int, int> rotate = gardener.rotate;
    int speed = gardener.speed;

    // Инициализирую начальную позицию
    std::pair<int, int> pos = startPos;
    while (true) {

        // Имитация времени обработки квадрата
        usleep(speed * 1000);

        if (oneGardeneredEnded) {
            break;
        }

        // Проверка, свободен ли квадрат для обработки
        #pragma omp critical
        {
            if (garden[pos.first][pos.second] == EMPTY) {
            garden[pos.first][pos.second] = trace; // Значение 2 и 3 обозначают садовников
            }
            // Вывод текущей позиции после обработки земли и разлочивание мьютекса
            print(output, "Шаг " + std::to_string(++numOfStep) + ": садовник " + trace + " обрабатывает квадрат [" 
            + std::to_string(pos.first + 1) + ", " + std::to_string(pos.second + 1) + "]");
            printGarden(garden, output);
        }

        // Если садовник дошел до своей последней позиции, то обход заканчивается
        if (pos == endPos) {
            break;
        }

        // Делаю следующий шаг и по необходимости делаю поворот
        pos.first += step.first;
        pos.second += step.second;
        if (pos.first == -1 || pos.first == garden.size() 
        || pos.second == -1 || pos.second == garden[0].size()) {
            pos.first -= step.first;
            pos.second -= step.second;
            pos.first += rotate.first;
            pos.second += rotate.second;
            step.first *= -1;
            step.second *= -1;
        }
    }

    // Меняю общую переменную, означающую конец обработки на true
    oneGardeneredEnded = true;
}

// Функция обработки сада двумя садовниками
void twoGardenerFiller() {
    // Даю рандомный сид для рандома (чтобы рандом был хоть какого-то непостоянного качества)
    srand(time(nullptr));

    // Ввод числа для идентификации, хочется ли ввести вручную или невручную
    std::cout << "Введите 0, если хотите ввести размеры сада и скорости садовников вручную,"
    << " или 1, если хотите считать их из файла: ";
    int number = readNumber();

    // Ввод размеров и скорости
    std::size_t n, m;
    int speed1, speed2;
    if (number) {
        // Из файла
        std::string filename;
        std::cout << "Заранее уже заготовлены input1.txt, input2.txt и input3.txt."
        << " Введите имя файла: ";
        std::cin >> filename;
        std::ifstream input(filename);
        if (!(input >> n >> m >> speed1 >> speed2)) {
            std::cout << "Ошибка чтения файла. Завершение программы.\n";
        }
    } else {
        // Вручную
        readDimensions(n, m);
        readSpeed(speed1, speed2);
    }

    // Ввод выходящего файла
    std::string outputFilename;
    std::cout << "Введите имя файла для вывода: ";
    std::cin >> outputFilename;
    output.open(outputFilename);

    // Создание пустого сада и заполнение его прудами и камнями
    std::vector<std::vector<char> > garden(n, std::vector<char>(m, EMPTY));
    initializeGarden(garden, n, m);

    // Вывод изначального сада
    print(output, "Сад до работы садовников: ");
    printGarden(garden, output);

    // Параметры для первого садовника (идет слева направо)
    std::pair<int, int> endPos1 = n % 2 ? std::pair<int, int>{n - 1, m - 1} : std::pair<int, int>{n - 1, 0};
    Gardener gardener1 = {FIRST_GARDENER, &garden, {0, 0}, endPos1, {0, 1}, {1, 0}, speed1};

    // Параметры для второго садовника (идет снизу вверх)
    std::pair<int, int> endPos2 = m % 2 ? std::pair<int, int>{0, 0} : std::pair<int, int>{n - 1, 0};
    Gardener gardener2 = {SECOND_GARDENER, &garden, {n - 1, m - 1}, endPos2, {-1, 0}, {0, -1}, speed2};

    #pragma omp parallel
    {
        #pragma omp sections
        {
            #pragma omp section
            {
                gardenerWork(gardener1);
            }
            #pragma omp section
            {
                gardenerWork(gardener2);
            }
        }
    }
    
    print(output, "Сад после работы садовников: ");
    printGarden(garden, output);
}

int main() {
    std::cout << "Программа для моделирования работы двух садовников в саду с прудами и камнями.\n"
    << "Первый садовник обозначен буковй F (first), второй – S (second).\n Пруд или камень - o, пустой квадрат - -.\n";

    twoGardenerFiller();

    return 0;
}
