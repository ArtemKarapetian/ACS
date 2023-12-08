#include <iostream>
#include <iomanip>
#include <limits>
#include <ctime>
#include <pthread.h>
#include "random_task.cpp"

// const unsigned long long arrSize = 10000000;
const unsigned long long arrSize = 500000000;
// const unsigned long long arrSize = 750000000;
// const unsigned long long arrSize = 2000000000;
double *A, *B;
const int threadNumber = 4; 

void* func(void* param) {
    unsigned long long shift = arrSize / threadNumber;
    int p = (*(unsigned long long*)param) * shift;
    double*current_multi = new double;
    *current_multi = 0;
    for(unsigned long long i = p ; i < p + shift; i++) {
        *current_multi += A[i] * B[i];
    }
    return (void*)current_multi;
}

void fill_arrays(double* A, double* B) {
    if (!A || !B) {
        return;
    }
    for (unsigned long long i = 0; i < arrSize; ++i) {
        A[i] = i + 1;
        B[i] = arrSize - i;
    }
}

unsigned long count_time(double *A, double *B) {
    unsigned long long result = 0;
    fill_arrays(A, B);
    
    pthread_t thread[threadNumber];
    unsigned long long number[threadNumber];
    
    clock_t start_time =  clock();
    
    for (int i=0 ; i<threadNumber ; i++) {
        number[i]=i;
        pthread_create(&thread[i], nullptr, func, (void*)(number+i)) ;
    }

    clock_t thread_started_time = clock();
    
    unsigned long long *scalar_multiplication;
    for (int i = 0 ; i < threadNumber; i++) {
        pthread_join(thread[i],(void **)&scalar_multiplication);
        result += *scalar_multiplication;
        delete scalar_multiplication;
    }

    clock_t end_time = clock();

    std::cout << std::setprecision(20) << result << "\n" ;

    return end_time - start_time;
}

int main() {
    random_task();

    A = new double[arrSize];
    B = new double[arrSize];
    if(!A || !B) {
        std::cout << "Incorrect size of vector = " << arrSize << "\n";
        return 1;
    }
    unsigned int time = count_time(A, B);

    std::cout << "Time of compiling = " << time << "\n";

    delete[] A;
    delete[] B;
    return 0;
}

// 1
// Time of compiling = 27134
// Time of compiling = 1542311
// Time of compiling = 57182887
// 2
// Time of compiling = 32010
// Time of compiling = 1752474
// Time of compiling = 61775282
// 4
// Time of compiling = 60201
// Time of compiling = 3931827
// Time of compiling = 69229290
// 8
// Time of compiling = 48635
// Time of compiling = 3829483
// Time of compiling = 74865973
// 1000
// Time of compiling = 117450
// Time of compiling = 4064534
// Time of compiling = 95578642