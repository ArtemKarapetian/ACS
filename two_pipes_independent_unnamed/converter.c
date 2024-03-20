#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/fcntl.h>
#include <sys/stat.h>

int     fd1, fd2;
char *pipe_name_one = "pipe1";
char *pipe_name_two = "pipe2";
const int memoryAmount = 5000;
char double_str[memoryAmount * 2 + 8] = {0}, result[memoryAmount] = {0};

void findIntersection(char* str1, char* str2, char* result) {
    int freq[256] = {0};

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
}

int main() {
    int fd1 = open(pipe_name_one, O_RDONLY);
    if (fd1 == -1) {
        fprintf(stderr, "Error opening the FIFO.\n");
        exit(1);
    }

    read(fd1, double_str, sizeof(double_str));
    int bytes1, bytes2;
    char str1[memoryAmount] = {0}, str2[memoryAmount] = {0};

    char* temp = double_str;
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

    close(fd1);

    findIntersection(str1, str2, result);

    int fd2 = open(pipe_name_two, O_WRONLY);
    if (fd2 == -1) {
        fprintf(stderr, "Error opening the FIFO.\n");
        exit(1);
    }

    write(fd2, result, strlen(result));
    close(fd2);

    return 0;
}
