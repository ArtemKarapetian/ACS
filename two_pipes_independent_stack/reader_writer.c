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
char double_str[memory_amount * 2 + 8] = {0}, result[memory_amount] = {0};

struct message {
    long mtype;
    char mtext[buf_size];
};

char *read_message(const char *path, int fd) {
    int input = open(path, O_RDONLY);
    if (input < 0) {
        printf("Error opening the input file 1.\n");
        exit(-1);
    }
    int read_b = 0;

    char message[memory_amount + 4], str[memory_amount] = {0};

    char buf[buf_size];
    int length = 0;
    while ((read_b = read(input, buf, sizeof(buf))) > 0) {
        memcpy(str + length, buf, read_b);
        length += read_b;
    }
    str[length] = '\0';
    snprintf(message, sizeof(message), "%d %s", length, str);
    close(input);
    return message;
}

void read_and_write_result(const char *filename, int fd) {
   int output = open(filename, O_WRONLY | O_CREAT | O_TRUNC, 0666);
    if (output == -1) {
        printf("Error opening the output file.\n");
        exit(-1);
    }

    struct message msg;
    msg.mtype = 2;
    int read_b = 0, write_b = 0;
    sleep(1);
    while ((read_b = msgrcv(fd, &msg, buf_size, 2, 0)) > 0) {
        if (read_b < 0) {
            printf("Error reading from the stack.\n");
            exit(-1);
        }
        write_b = write(output, msg.mtext, read_b);
        if (write_b < 0) {
            printf("Error writing to file.\n");
            exit(-1);
        }
        if (read_b < buf_size) {
            msgctl(fd, IPC_RMID, NULL);
            if (read_b < 0) {
                printf("Error writing to file.\n");
                exit(-1);
            }
            break;
        }
    }

    close(output);
}

int main(int argc, char *argv[]) {
    if (argc != 4) {
        fprintf(stderr, "Usage: %s input_file output_file\n", argv[0]);
        exit(1);
    }

    const char *input1 = argv[1];
    const char *input2 = argv[2];
    const char *output = argv[3];

    int fd1 = msgget(ftok(".", 'F'), 0666 | IPC_CREAT);
    if (fd1 == -1) {
        fprintf(stderr, "Error creating the stack.\n");
        exit(1);
    }

    char str1[memory_amount], str2[memory_amount];
    sprintf(str1, "%s", read_message(input1, fd1));
    sprintf(str2, "%s", read_message(input2, fd1));
    snprintf(double_str, sizeof(double_str), "%s%s", str1, str2);

    struct message msg;
    msg.mtype = 1;
    int double_str_len = strlen(double_str);
    int write_b = 0;
    while (write_b < double_str_len) {
        int remaining_bytes = double_str_len - write_b;
        int write_size = remaining_bytes < buf_size ? remaining_bytes : buf_size;
        memcpy(msg.mtext, double_str + write_b, write_size);
        if (msgsnd(fd1, &msg, write_size, 0) < 0) {
            printf("Error sending the message\n");
            exit(-1);
        }
        write_b += write_size;
    }

    int fd2 = msgget(ftok(".", 'P'), 0666 | IPC_CREAT);
    if (fd2 == -1) {
        fprintf(stderr, "Error creating the stack.\n");
        exit(1);
    }

    read_and_write_result(output, fd2);

    return 0;
}