#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/fcntl.h>
#include <sys/stat.h>


const int memory_amount = 5000;
const char* folder = "two_pipes_unnamed/";

// Функция для поиска пересечения символов в двух строках
char *findIntersection(const char* str1, const char* str2, char* result) {
    int freq[256] = {0}; // Массив для подсчета частоты встречаемости символов

    // Подсчёт частоты встречаемости символов в str1
    for (int i = 0; str1[i] != '\0'; i++) {
        freq[(int)str1[i]]++;
    }

    // Поиск пересечения символов в str2
    int index = 0;
    for (int i = 0; str2[i] != '\0'; i++) {
        if (freq[(int)str2[i]] > 0) {
            result[index++] = str2[i];
            freq[(int)str2[i]] = 0; // Убираем символ из пересечения (равно 0, значит что его дальше не будет)
        }
    }
    result[index] = '\0'; // Добавляем завершающий нуль-символ
}

char *read_message(const char *path) {
    int input = open(path, O_RDONLY);
    if (input < 0) {
        printf("Error opening the input file 1.\n");
        exit(-1);
    }
    int read_b = 0;

    char message[memory_amount + 4], str[memory_amount];

    read_b = read(input, str, sizeof(str));
    str[read_b] = '\0';
    snprintf(message, sizeof(message), "%d %s", read_b, str);
    close(input);
    return message;
}

void read_and_write_result(const char *path, int pipe_fd) {
   int output = open(path, O_WRONLY | O_CREAT | O_TRUNC, 0666);
    if (output == -1) {
        printf("Error opening the output file.\n");
        exit(-1);
    }

    char result[memory_amount] = {0};

    read(pipe_fd, result, memory_amount);
    write(output, result, strlen(result));

    close(output);
}
void writeIntersectionToFile(const char* input1, const char* input2, const char* output) {
    int fd1, fd2;
    pid_t pid;

    if (mkfifo("pipe1", 0666) == -1 || mkfifo("pipe2", 0666) == -1) {
        fprintf(stderr, "FIFO creation failed.\n");
        exit(-1);
    }
    
    pid = fork();

    if (pid < 0) {
        printf("Can\'t fork child\n");
        exit(-1);
    } else if (pid == 0) { // Child
        fd1 = open("pipe1", O_WRONLY);
        
        if (fd1 == -1) {
            fprintf(stderr, "Error opening the FIFO.\n");
            exit(1);
        }

        char double_str[memory_amount * 2 + 9];

        char str1[memory_amount], str2[memory_amount];
        sprintf(str1, "%s", read_message(input1));
        sprintf(str2, "%s", read_message(input2));
        snprintf(double_str, sizeof(double_str), "%s%s", str1, str2);

        write(fd1, double_str, strlen(double_str));
        close(fd1);

        exit(0);
    } else {
        pid = fork();

        if (pid < 0) {
            printf("Can\'t fork child\n");
            exit(-1);
        } else if (pid == 0) { // Child 2
            fd1 = open("pipe1", O_RDONLY);
            fd2 = open("pipe2", O_WRONLY);

            char double_str[memory_amount * 2 + 9] = {0};
            char result[memory_amount] = {0};

            read(fd1, double_str, sizeof(double_str));
            int bytes1, bytes2;
            char str1[memory_amount] = {0}, str2[memory_amount] = {0};

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

            write(fd2, result, strlen(result));
            close(fd2);

            exit(0);
        } else { // Parent
            fd2 = open("pipe2", O_RDONLY);

            if (fd2 == -1) {
                fprintf(stderr, "Error opening the FIFO.\n");
                exit(1);
            }

            read_and_write_result(output, fd2);
            close(fd2);
        }
    }

    unlink("pipe1");
    unlink("pipe2");
    unlink("pipe3");
}

int main(int argc, char *argv[]) {
    if (argc != 4) {
        fprintf(stderr, "Usage: %s input_file output_file\n", argv[0]);
        exit(1);
    }

    const char *input1 = argv[1];
    const char *input2 = argv[2];
    const char *output = argv[3];

    writeIntersectionToFile(input1, input2, output);
    return 0;
}