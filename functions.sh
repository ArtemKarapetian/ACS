#!/bin/bash

# функция, объявленная без слова function
counter_print() {
    # объявляю переменную-счетчик
    cnt=0

    # пока переменная меньше 100, буду итиреироваться. -le = less or equal
    while [ $cnt -le 100 ]
    do
        increment $cnt
        cnt=$?
    done
}

# Функция инкремента с одним аргументом и возвращением
function increment() {
    # объявляю переменную-счетчик
    local cnt=$1
    echo $cnt
    cnt=$[$cnt + 1]

    # если число делится на 10, то я вывожу надпись об этом. -eq = equal
    if [ $[$cnt % 10] -eq 0 ]
    then
        echo "Прошли очередные 10 на счётчике!"
    fi
    return $cnt
}

# Простой вызов функции, аналогичной while.sh
counter_print
