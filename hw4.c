#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>

#define BUFFER_SIZE 32

int main(int argc, char *argv[]) {
    if (argc != 3) {
        printf("Usage: %s <input_file> <output_file>\n", argv[0]);
        exit(-1);
    }

    char buffer[BUFFER_SIZE];
    int input_fd, output_fd;
    ssize_t bytes_read, bytes_written;

    input_fd = open(argv[1], O_RDONLY);
    if (input_fd == -1) {
        printf("Failed to open input file\n");
        exit(-1);
    }

    output_fd = open(argv[2], O_WRONLY | O_CREAT, 0666);
    if (output_fd == -1) {
        printf("Failed to open output file\n");
        close(input_fd);
        exit(-1);
    }

    do {
        bytes_read = read(input_fd, buffer, BUFFER_SIZE);
        if (bytes_read == -1) {
            perror("Failed to read from input file");
            close(input_fd);
            close(output_fd);
            exit(-1);
        }

        bytes_written = write(output_fd, buffer, bytes_read);
        if (bytes_written != bytes_read) {
            printf("Failed to write to output file\n");
            close(input_fd);
            close(output_fd);
            exit(-1);
        }
    } while (bytes_read > 0);

    if (bytes_read == -1) {
        perror("Failed to read from input file");
        close(input_fd);
        close(output_fd);
        exit(-1);
    }

    close(input_fd);
    close(output_fd);

    printf("File copied successfully.\n");

    return 0;
}
