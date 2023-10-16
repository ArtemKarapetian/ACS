.include "macrolib.s"

.data
	# Массивы А и B
	.align 2 
	A: .space 400
	.align 2
	B: .space 400

.text
main:
	print_str ("Hello. It's 28 variant of homework 1. The author is Karapetian Artem.\n")
	newline
	print_str ("This program takes array A and turns it into array B which is non-decreasing sorted version of A")
	newline
	read_size (a1)	# Чтение размера массива
	print_str ("The input size is ")  # Вывод размера массива
	print_int (a1)
    	newline
    	read_array (A, a1) # Ввод всех элементов массива
    	print_str ("You wrote this array:\n") # Вывод всех элементов массива
    	print_array (A, a1)
	copy_array (A, B, a1) # Копирование массива А в массив B
	sort (B, a1) # Сортируем в неубывающем порядке
	newline
	print_str  ("Array in non decreasing order:\n") # Вывод отсортированного массива
	print_array (B, a1)
	newline
	exit
