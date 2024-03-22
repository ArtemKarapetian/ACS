#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/fcntl.h>
#include <sys/stat.h>
#include <sys/ipc.h>
#include <sys/msg.h>

const int memory_amount = 5000;
const int buf_size = 30; // поскольку по условию задания я все равно не могу генерировать более 256 символов, то сделаю буффер очень маленьким.
char double_str[memory_amount * 2 + 8] = {0};

struct message {
    long mtype;
    char mtext[buf_size];
};

char *findIntersection(char* str1, char* str2) {
    int freq[256] = {0};
    char *result = (char *)malloc(memory_amount);

    for (int i = 0; str1[i] != '\0'; i++) {
        freq[(int)str1[i]]++;
    }

    int index = 0;
    for (int i = 0; str2[i] != '\0'; i++) {
        if (freq[(int)str2[i]] > 0) {
            result[index++] = str2[i];
            freq[(int)str2[i]] = 0;
        }
    }
    result[index] = '\0';

    return result;
}

int main() {
    int fd1 = msgget(ftok(".", 'F'), 0666 | IPC_CREAT);
    if (fd1 == -1) {
        fprintf(stderr, "Error creating the stack.\n");
        exit(1);
    }

    struct message msg;
    msg.mtype = 1;
    int read_b = 0;
    char buffer[buf_size];
    char* temp = double_str;

    while ((read_b = msgrcv(fd1, &msg, sizeof(msg.mtext), 1, 0)) > 0) {
        memcpy(temp, msg.mtext, strlen(msg.mtext));
        temp += read_b;
        if (read_b < buf_size) {
            if (read_b == -1) {
                printf("Error in reading data\n");
                exit(-1);
            }
            msgctl(fd1, IPC_RMID, NULL);
            break;
        }
    }

    int bytes1, bytes2;
    char str1[memory_amount] = {0}, str2[memory_amount] = {0};

    temp = double_str;
    char bytes_str[4];

    sscanf(temp, "%d", &bytes1);
    sprintf(bytes_str, "%d", bytes1);
    temp += strlen(bytes_str) + 1;

    memcpy(str1, temp, bytes1);
    str1[bytes1] = '\0';
    temp += bytes1;

    sscanf(temp, "%d", &bytes2);
    sprintf(bytes_str, "%d", bytes2);
    temp += strlen(bytes_str) + 1;

    memcpy(str2, temp, bytes2);
    str2[bytes2] = '\0';

    char *result = findIntersection(str1, str2);
    int fd2 = msgget(ftok(".", 'P'), 0666 | IPC_CREAT);
    if (fd2 == -1) {
        fprintf(stderr, "Error creating the stack.\n");
        exit(1);
    }

    int result_len = strlen(result);
    int offset = 0;
    msg.mtype = 2;

    while (offset < result_len) {
        int write_size = result_len - offset < buf_size ? result_len - offset : buf_size;
        memcpy(msg.mtext, result + offset, write_size);
        if (msgsnd(fd2, &msg, write_size, 0) < 0) {
            printf("Error sending the message\n");
            exit(-1);
        }
        offset += write_size;
    }

    return 0;
}
