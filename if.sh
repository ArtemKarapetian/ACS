#!/bin/bash

# конструкция if then else fi с вложенной такой же конструкцией

# -n означает "не пуста ли переменная", а -а – это and (лог. И)
if [ -n "$1" -a -n "$2" ]
then
    if [ "$1" -eq "$2" ] # -eq очевидно отвечает за equal
    then
        echo "Входные параметры идентичны"
    else
        echo "Входные параметры отличаются"
    fi 
else
    echo "Недостаточно входных параметров. Должно было быть два"
fi 
