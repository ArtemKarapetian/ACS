#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>

int sender_pid;
int current_bit;
int received_num = 0;

void negative_handler(int signum) {
    if (signum == SIGUSR2) {
        received_num *= -1;
    }
}

void bit_handler(int signum) {
    if (signum == SIGUSR1) {
        current_bit = 0;
        return;
    }
    if (signum == SIGUSR2) {
        current_bit = 1;
        return;
    }
}

void sig_handler(int signum) {
    signal(SIGUSR1, negative_handler);
    signal(SIGUSR2, negative_handler);
    kill(sender_pid, SIGUSR1);
    pause();

    printf("Полученное число: %d\n", received_num);
    exit(0);
}

int main() {
    printf("PID приёмника: %d\n", getpid());

    printf("Введите PID передатчика: ");
    scanf("%d", &sender_pid);

    signal(SIGUSR1, bit_handler);
    signal(SIGUSR2, bit_handler);
    signal(SIGTERM, sig_handler);

    int multiplier = 1;
    while (1) {
        pause();
        received_num += current_bit * multiplier;
        multiplier <<= 1;
        kill(sender_pid, SIGUSR1);
    }

    return 0;
}
