#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>

int receiver_pid;

void signal_handler(int signum) {
    if (signum == SIGUSR1) {
        return;
    }
}

int main() {
    printf("PID передатчика: %d\n", getpid());

    printf("Введите PID приёмника: ");
    scanf("%d", &receiver_pid);

    signal(SIGUSR1, signal_handler);

    printf("Введите целое число: ");
    int number = 0;
    int flag = 1;
    scanf("%d", &number);
    if (number < 0) {
        number *= -1;
        flag = 0;
    }

    while (number > 0) {
        if (number & 1) {
            kill(receiver_pid, SIGUSR2);
        } else {
            kill(receiver_pid, SIGUSR1);
        }
        number >>= 1;
        pause();
    }
    kill(receiver_pid, SIGTERM);
    pause();
    if (flag) {
        kill(receiver_pid, SIGUSR1);
    } else {
        kill(receiver_pid, SIGUSR2);
    }
    return 0;
}
