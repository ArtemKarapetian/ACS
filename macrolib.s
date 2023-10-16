#
# Example library of macros.
#

# Печать содержимого регистра как целого
.macro print_int (%x)
	li a7, 1
	mv a0, %x
	ecall
.end_macro

.macro print_imm_int (%x)
    li a7, 1
    li a0, %x
    ecall
.end_macro

# Вывод size элементов массива
.macro print_array(%array, %size)
	# Вставляем все регистры, которые хотим использовать, в стек
	push (t0)
	push (t1)
	push (t2)
	
	li t0 0 	# t0 выступает в роли счётчика
	la t1 %array 	# t1 - сам массив, который мы выводим
loop_print:
	addi t0 t0 1 	# Обновляем счётчик
	lw t2 (t1) 	# Загрузка элемента массива и его вывод
	print_int(t2)
	print_str(" ")
	addi t1 t1 4	# Обновляем регистр с массивом
	bne t0 %size loop_print # Смотрим, не заканчиваем ли обход
	
	# Достаём все зарезервированные в начале элементы из стека
	pop (t2)
	pop (t1)
	pop (t0)
.end_macro

# Ввод целого числа с консоли в регистр a0
.macro read_int_a0
   li a7, 5
   ecall
.end_macro

# Ввод размера массива – целого числа от 1 до 10
.macro read_size(%x)
	push (t0)
	push (a0)

read_right_size:
	print_str ("Input array size from 1 to 100: ")
	read_int_a0	# Чтение числа
	blez a0 retry	# Если число меньше или равно 0, то повтор
	li t0 100
	bgt a0 t0 retry # Если число больше 100, то повтор
	b done_reading  # Выходим из программы
retry:
	print_str ("The read size is incorrect. Write one more time.")
	newline
	b read_right_size # Объявляем о неверности ввода и отправляемсы в начало
done_reading:
	mv %x a0	# В эелаемый регистр переносим число и выходим из программы
	pop (a0)
	pop (t0)
.end_macro

# Ввод целого числа с консоли в указанный регистр,
# исключая регистр a0
.macro read_int(%x)
   push	(a0)
   li a7, 5
   ecall
   mv %x, a0
   pop	(a0)
.end_macro

# Ввод size элементов массива
.macro read_array(%array, %size)
	# Вставляем все регистры, которые хотим использовать, в стек
	push (t0)
	push (t1)
	push (a0)

	li t0 0 	# t0 выступает в роли счётчика
	la t1 %array 	# t1 - сам массив, который мы заполянем
loop:
	addi t0 t0 1    # Обновляем счётчик
	print_str ("Enter number ")
	print_int (t0)
	print_str(": ")
	read_int_a0     # Вводим число
	sw a0 (t1)      # Сохраняем в массив
	addi t1 t1 4    # Обновляем регистр с массивом
	bne t0 %size loop  # Повтор цикла при необходимости
	
	# Достаём все зарезервированные в начале элементы из стека
	pop (a0)
	pop (t1)
	pop (t0)
.end_macro

   .macro print_str (%x)
   .data
str:
   .asciz %x
   .text
   push (a0)
   li a7, 4
   la a0, str
   ecall
   pop	(a0)
   .end_macro

   .macro print_char(%x)
   li a7, 11
   li a0, %x
   ecall
   .end_macro

   .macro newline
   print_char('\n')
   .end_macro

# Копирование size элементов массива А в массив B
.macro copy_array(%A, %B, %size)
	# Вставляем все регистры, которые хотим использовать, в стек
	push(t0)
	push(t1)
	push(t2)
	push(t3)
	
	la t0 %A # Загружаем массивы в t0 и t1, а размер – в t2
	la t1 %B
	mv t2 %size
loop:
	# Сохраняем в t3 элемент из первого массива и загружаем во второй
	lw t3 (t0)
	sw t3 (t1)
	addi t2 t2 -1	# Уменьшаем счётчик оставшихся элементов для копирования
	addi t0 t0 4	# Передвигаемся к следующему элементу массива 
	addi t1 t1 4
	bnez t2 loop	# Если t2 = 0, то не осталось элементов для копирования, выходим из цикла
	
	# Достаём все зарезервированные в начале элементы из стека
	pop(t3)
	pop(t2)
	pop(t1)
	pop(t0)
.end_macro

# Сортировка x элементов массива
.macro sort(%array, %size)
	# Вставляем все регистры, которые хотим использовать, в стек
	push (t0)
	push (t1)
	push (t2)
	push (t3)
	push (t4)
	push (t5)
	push (t6)
	
	la t0 %array	# Загружаем в t0 массив, а в t1 – его размер
	mv t1 %size
	addi t2 zero -1	# Чтобы счётчик правильно сработал, отнимаю 1 от 0, и начинаю отсчёт
	
loop_sort:
	addi t2 t2 1	# Увеличиваем счётчик и смотрим не равен ли он размеру (тогда заканчиваем цикл)
	beq t1 t2 end_sort
	mv t3 t2	# Загружаю в t3 второй счётчик для внутреннего цикла
	mv t4 t0	# Загружаем в t4 адрес нынешнего элемента массива
	lw t5 (t0)	# Загружаем элемент массива, с которым хотим сравнить следующие элементы массива
inner_loop:
	addi t3 t3 1	# Увеличиваем внутренний счётчик и переносим адрес массива на следующий элемент
	addi t4 t4 4
	beq t1 t3 loop_end # Заканчиваем цикл, если достигли конца массива
	lw t6 (t4)	# Загружаем элемент, на который указывает t4
	ble t6 t5 swap	# Делаем swap элементов, если нынешний элемент внутреннего цикла меньше исходного
	b inner_loop	# Повторяем цикл
	
swap:
	sw t5 (t4)	# Сохрянем элементы по нужным адресам
	sw t6 (t0)
	mv t5 t6	# Обновляем элемент, по которому будем сравнивать
	b inner_loop
	
loop_end:
	addi t0 t0 4	# Передвигаемся к следующему элементу массива и повторяем цикл
	b loop_sort

	# Достаём все зарезервированные в начале элементы из стека
end_sort:
	pop (t6)
	pop (t5)
	pop (t4)
	pop (t3)
	pop (t2)
	pop (t1)
	pop (t0)
.end_macro



# Завершение программы
.macro exit
    li a7, 10
    ecall
.end_macro

# Сохранение заданного регистра на стеке
.macro push(%x)
	addi	sp, sp, -4
	sw	%x, (sp)
.end_macro

# Выталкивание значения с вершины стека в регистр
.macro pop(%x)
	lw	%x, (sp)
	addi	sp, sp, 4
.end_macro
