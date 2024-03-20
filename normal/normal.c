#include <locale.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

const int memoryAmount = 5000;
const char* folder = "normal/";
char str1[memoryAmount], str2[memoryAmount], result[memoryAmount];

// Функция для поиска пересечения символов в двух строках
void findIntersection(const char* str1, const char* str2, char* result) {
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
            freq[(int)str2[i]] = 0; // Убираем символ из пересечения (равно 0, значит что его дальше не булет)
        }
    }

    result[index] = '\0'; // Добавляем завершающий нуль-символ
}

// Функция для записи пересечения строк в файл
void writeIntersectionToFile(const char* input1, const char* input2, const char* output) {
    FILE* file1 = fopen(input1, "r");
    FILE* file2 = fopen(input2, "r");
    FILE* outputFile = fopen(output, "w");

    if (file1 == NULL || file2 == NULL || outputFile == NULL) {
        printf("Error opening the input/output files.\n");
        return;
    }
    fgets(str1, sizeof(str1), file1);
    fgets(str2, sizeof(str2), file2);

    fclose(file1);
    fclose(file2);

    str1[strcspn(str1, "\n")] = '\0';
    str2[strcspn(str2, "\n")] = '\0';

    findIntersection(str1, str2, result);

    fprintf(outputFile, "%s\n", result);

    fclose(outputFile);
}

char* joinStrings(const char* str1, const char* str2, const char* str3) {
    char* result = (char*)malloc(strlen(str1) + strlen(str2) + strlen(str3) + 1);
    strcpy(result, str1);
    strcat(result, str2);
    strcat(result, str3);
    return result;
}

int main() {
    writeIntersectionToFile("../tests/inputs/input1_1.txt", "../tests/inputs/input1_2.txt", joinStrings("../tests/outputs/", folder, "output1.txt"));
    writeIntersectionToFile("../tests/inputs/input2_1.txt", "../tests/inputs/input2_2.txt", joinStrings("../tests/outputs/", folder, "output2.txt"));
    writeIntersectionToFile("../tests/inputs/input3_1.txt", "../tests/inputs/input3_2.txt", joinStrings("../tests/outputs/", folder, "output3.txt"));
    writeIntersectionToFile("../tests/inputs/input4_1.txt", "../tests/inputs/input4_2.txt", joinStrings("../tests/outputs/", folder, "output4.txt"));
    writeIntersectionToFile("../tests/inputs/input5_1.txt", "../tests/inputs/input5_2.txt", joinStrings("../tests/outputs/", folder, "output5.txt"));
   return 0;
}