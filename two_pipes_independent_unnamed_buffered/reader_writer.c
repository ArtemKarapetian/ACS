#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/fcntl.h>
#include <sys/stat.h>

int  fd1, fd2;
char *pipe_name_one = "pipe1";
char *pipe_name_two = "pipe2";
const int memory_amount = 5000;
const int buf_size = 30; // поскольку по условию задания я все равно не могу генерировать более 256 символов, то сделаю буффер очень маленьким.
char double_str[memory_amount * 2 + 8] = {0}, result[memory_amount] = {0};

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

void read_and_write_result(const char *filename, int pipe_fd) {
   int output = open(filename, O_WRONLY | O_CREAT | O_TRUNC, 0666);
    if (output == -1) {
        printf("Error opening the output file.\n");
        exit(-1);
    }

    char buffer[buf_size];
    int bytes_read = 0;
    while ((bytes_read = read(pipe_fd, buffer, buf_size)) > 0) {
        write(output, buffer, bytes_read);
    }
    if (bytes_read < 0) {
        printf("Error reading from pipe.\n");
        exit(-1);
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

    if (access(pipe_name_one, F_OK) != -1) {
        unlink(pipe_name_one);
    }
    if (access(pipe_name_two, F_OK) != -1) {
        unlink(pipe_name_two);
    }

    if (mkfifo(pipe_name_one, 0666) == -1 || mkfifo(pipe_name_two, 0666) == -1) {
        fprintf(stderr, "FIFO creation failed.\n");
        exit(1);
    }

    int fd1 = open(pipe_name_one, O_WRONLY);
    if (fd1 == -1) {
        fprintf(stderr, "Error opening the FIFO.\n");
        exit(1);
    }

    char str1[memory_amount], str2[memory_amount];
    sprintf(str1, "%s", read_message(input1, fd1));
    sprintf(str2, "%s", read_message(input2, fd1));
    snprintf(double_str, sizeof(double_str), "%s%s", str1, str2);

    int double_str_len = strlen(double_str);
    int bytes_written = 0;
    while (bytes_written < double_str_len) {
        int remaining_bytes = double_str_len - bytes_written;
        int write_size = remaining_bytes < buf_size ? remaining_bytes : buf_size;
        write(fd1, double_str + bytes_written, write_size);
        bytes_written += write_size;
    }
    close(fd1);


    int fd2 = open(pipe_name_two, O_RDONLY);
    if (fd2 < 0) {
        printf("Can\'t open FIFO for writting\n");
        exit(-1);
    }

    read_and_write_result(output, fd2);

    close(fd2);

    unlink(pipe_name_one);
    unlink(pipe_name_two);

    return 0;
}