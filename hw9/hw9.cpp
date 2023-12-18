#include <pthread.h>
#include <semaphore.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <iostream>
#include <vector>


const int bufSize = 20;
// На маке не работают семафоры в полной степени, поэтому заместо get_value я считал процессы
int processes = 20;
int buf[bufSize];
// Счётчики, имитирующую работу стека, аналогично семинару
int front = 0;
int rear = 0;
int count = 0;
// Вектор всех сумматоров
std::vector<pthread_t> summators;

pthread_mutex_t mutex;
pthread_cond_t action;

// Функция для отладки, выводит количество элементов в буфере и его содержимое.
void printBuf() {
    std::cout << count << " | "; 
    for (int i = 0; i < bufSize; ++i) {
        std::cout << buf[i] << " ";
    }
    std::cout << std::endl;
}

// Функция генерации чисел.
void *numberGenerator(void *param) {
    int order = *static_cast<int*>(param);
    // Имитирую задержку и создаю число
    sleep(rand() % 7 + 1);
    int data = rand() % 20 + 1;
    // Лочу мьютехс, чтобы не было гонки за ресурсами.
    pthread_mutex_lock(&mutex);

    buf[rear] = data;
    rear = (rear + 1) % bufSize;
    count++;

    std::cout << "Generated number is on " << (bufSize + rear - 1) % bufSize << "place, and is made by generator " << order
              << ", and is equal to " << data << std::endl;
    // printBuf();
    pthread_mutex_unlock(&mutex);
    // Отнимаю процесс, когда уже сгенерировал число.
    --processes;
    // Сигнализирую о том, что можно склдывать числа.
    if (count >= 2) {
        pthread_cond_signal(&action);
    }

    return nullptr;
}

// Функция суммирования чисел
void *summator(void *param) {
    // Имитирую задержку и лочу мьютекс, чтобы не случилось использование вектора двумя потоками.
    sleep(3 + rand() % 4);
    pthread_mutex_lock(&mutex);
    // Считаю сумму двух чисел и записываю её в переднюю часть буфера.
    buf[rear] = buf[(bufSize + front - 1) % bufSize] + buf[front];
    // Я суммировал два числа, поэтому я сдвигаюсь на 2 вперёд.
    front += 2;
    front %= bufSize;
    // И я всего 1 число добавил, так что свдигаю хвост на 1 вперёд.
    rear += 1;
    rear %= bufSize;

    std::cout << "    Added number " << buf[(bufSize + front - 3) % bufSize] << " and " << buf[(bufSize + front - 2) % bufSize]
              << " and got " << buf[(bufSize + rear - 1) % bufSize] << std::endl;
    // printBuf();

    if (count > 0) {
        pthread_cond_signal(&action);
    }
    pthread_mutex_unlock(&mutex);
    return nullptr;
}

// Функция создания потока сумматора
void makeSummatorThread(std::vector<pthread_t> &threads) {
    // Сначала получаю общее кол-во потоков, чтобы присвоить ему номер.
    int threadNum = threads.size();
    pthread_t currentThread;
    // Запускаю новый поток с ее порядковым номером и добавляю его в вектор, чтобы потом заджоинить.
    pthread_create(&currentThread, nullptr, summator, static_cast<void*>(&threadNum));
    threads.emplace_back(currentThread);
}

// Функция проверки, можно ли суммировать числа
void *checker(void *param) {
    int result;

    // Пока есть числа в буфере или есть процессы, которые могут добавить числа.
    // Можно добавлять числа при условии, что их там не меньше 2.
    while (count >= 2 || processes > 0) {
        // Ждём, если мало чисел.
        while (count < 2) {
            pthread_cond_wait(&action, &mutex);
        }
        // 2 числа суммируем, возвращаем 1, по сути общее количество уменьшается на 1.
        --count;
        // Создаем поток.
        makeSummatorThread(summators);
    }
    // Когда осталось 0 процессов, но числа ещё есть, то суммируем их.
    makeSummatorThread(summators);
    pthread_mutex_unlock(&mutex);
    for (int i = 0; i < summators.size(); ++i) {
        pthread_join(summators[i], nullptr);
    }
    return nullptr;
}


int main() {
    srand(static_cast<uint>(time(nullptr)));

    // Создание мутекса и кондиционала.
    pthread_mutex_init(&mutex, nullptr);
    pthread_cond_init(&action, nullptr);

    // Сначала запускаю 20 потоков генераторов.
    pthread_t threadP[20];
    for (int i = 0; i < 20; ++i) {
        pthread_create(&threadP[i], nullptr, numberGenerator, static_cast<void*>(&i));
    }

    // Потом поток, который будет следить за всей ситуацией и складывать числа.
    pthread_t checkerNum;
    pthread_create(&checkerNum, nullptr, checker, nullptr);
    for (int i = 0; i < 20; ++i) {
        pthread_join(threadP[i], nullptr);
    }
    // Всё соединяю (иначе просто 0 выведет).
    pthread_join(checkerNum, nullptr);

    // Вывожу результат.
    std::cout << buf[(bufSize + rear - 1) % bufSize];
    return 0;
}
