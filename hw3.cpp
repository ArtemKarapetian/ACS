#include <unistd.h>
#include <stdio.h>
#include <iostream>
#include <climits>

unsigned long long get_nice_number() {
    unsigned long long number;
    while (true) {
        try
        {
            std::cin >> number;
            if (number > 0) {
                return number;
            } else {
                std::cout << "Вы ввели отрицательное число";
            }
        }
        catch(const std::exception& e)
        {
            std::cout << "Вы ввели вообще не число";
        }
    }
}

unsigned long long factorial(unsigned long long number) {
    unsigned long long answer = 1;
    for (unsigned long long i = 1; i < number; ++i) {
        if (UINT64_MAX / i < answer) {
            std::cout << "Произошло переполнение, возвращаю значение.";
            return answer;
        }
        answer *= i;
    }
    return answer;
}

unsigned long long fibonacci(unsigned long long number) {
    if (number <= 2) {
        return 1;
    }
    unsigned long long answer = 0;
    unsigned long long number1 = 1;
    unsigned long long number2 = 0;
    for (unsigned long long i = 1; i < number; ++i) {
        if (i != 1 && UINT64_MAX - number1 - number2 < answer) {
            std::cout << "Произошло переполнение во время вычисления фибонначи, возвращаю значение.";
            return answer;
        }
        answer = number1 + number2;
        number2 = number1;
        number1 = answer;
    }
    return answer;
}

int main() {
    unsigned long long n = get_nice_number();

    pid_t pid, ppid, chpid;
    chpid = fork();
    pid  = getpid();
    ppid = getppid();

    if(chpid <= -1) {
        printf("Произошла ошибка с fork\n");
    } else if (chpid == 0) {
        printf("Я ребенок\n");
        printf("Мой pid = %d, Мой родитель = %d\n",
               (int)pid, (int)ppid);
        printf("Вот Факториал для %llu: %llu\n", n, factorial(n));
    } else {
        printf("Я родитель\n");
        printf("Мой pid = %d, Мой родитель %d, Мой ребенок %d\n",
               (int)pid, (int)ppid, (int)chpid);
        printf("Вот число Фибоначчи для %llu: %llu\n", n, fibonacci(n));
    }
    
    if (chpid > 0) {
        int status;
        wait(&status);
        printf("Дочерний процесс завершился\n");
    }

    chpid = fork();
    if(chpid <= -1) {
        printf("Произошла ошибка с fork\n");
    } else if (chpid == 0) {
        printf("Я ребенок еще раз!\n");
        printf("Содержимое текущего каталога:\n");
        execl("/bin/ls", "ls");
    }
    return 0;
}