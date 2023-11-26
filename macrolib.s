#
# Library of macros.
#

.macro print_int (%x)
	li a7, 1
	mv a0, %x
	ecall
.end_macro

# Ввод строки в буфер заданного размера с заменой перевода строки нулем
# %strbuf - адрес буфера
# %size - целая константа, ограничивающая размер вводимой строки
# %default – адрес строки, которая заполнится по умолчанию, если будет введена пустая строка
.macro str_get(%strbuf, %size, %default)
	# Получаем путь
	la      a0 %strbuf
	li      a1 %size
	li      a7 8
	ecall
	
	# Невовремя, но всё пушим
	push(t0)
	push(t1)
	push(t2)
	push(t3)
	
	# Удаляем перенос строки из пути
	li	t0 '\n'
	la	t1	%strbuf
	mv	t3 t1
# Идем по каждому символу пути к файлу, пока не найдем перенос строки
next:
	lb t2  (t1)
	beq t0 t2 replace
	addi t1 t1 1
	b next
# Заменяем перенос строки на нулевой символ и выходим
replace:
	beq t3 t1 default
	sb	zero (t1)
	b	done_reading_path
default: # Если на вход была дана пустая строка, то мы введем дефолт (не политический)
	la	a0 %default
done_reading_path:
	pop(t3)
	pop(t2)
	pop(t1)
	pop(t0)
.end_macro

# Чтение файла буфером %buf_size и макимальным количеством памяти, ограниченным %max_size.
.macro read_file (%buf_size, %max_size)
	push (t0)
	push (t1)
	push (t2)
	push (t3)
	push (t4)
	push (t5)

	allocate(%buf_size) 	# Выделяем память для буфера, будем использовать много раз
	mv 	a4 a0		# Сохранение адреса кучи в регистре
	mv 	t2 a0		# Сохранение изменяемого адреса кучи в регистре
	li	t3 %buf_size	# Сохранение константы для обработки
	li	t5 %max_size	# Сохранение максимального размера файла
	mv	a3 zero
	
read_loop:
	# Чтение информации из открытого файла
	read_addr_reg(s0, t2, %buf_size) # чтение для адреса блока из регистра
	# Проверка на корректное чтение
	beq	a0 s1 error	# Ошибка чтения
	mv   	t4 a0       	# Сохранение длины текста
	add 	a3, a3, t4		# Размер текста увеличивается на прочитанную порцию
	# При длине прочитанного текста меньшей, чем размер буфера,
	# необходимо завершить процесс.
	bge	a3 t5 end_loop
	bne	t4 t3 end_loop	
	# Иначе расширить буфер и повторить
	allocate(%buf_size)		# Результат здесь не нужен, но если нужно то...
	add	t2 t2 t4		# Адрес для чтения смещается на размер порции
	b	read_loop

end_loop:
	close (s0) 		# Закрываем программу
	mv	t0 a4		# Адрес буфера в куче
	add	t0 t0 a3	# Адрес последнего прочитанного символа
	addi	t0 t0 1		# Место для нуля
	sb	zero (t0)	# Ставим ноль и выходим
	b	done_reading
error:
	print_str ("Error happened")
	
done_reading:
	pop (t5)
	pop (t4)
	pop (t3)
	pop (t2)
	pop (t1)
	pop (t0)
.end_macro

.eqv READ_ONLY	0	# Открыть для чтения
.eqv WRITE_ONLY	1	# Открыть для записи
.macro open_a0(%opt)
    li   	a7 1024     	# Системный вызов открытия файла
    li   	a1 %opt        	# Открыть для чтения (флаг = 0)
    ecall             		# Дескриптор файла в a0 или -1)
.end_macro

# Выделение памяти size в a0
.macro allocate(%size)
    li a7, 9
    li a0, %size	# Размер блока памяти
    ecall
.end_macro

# Читаем из файла в нужный регистр нужноек кол-во символов
.macro read_addr_reg(%file_descriptor, %reg, %size)
    li   a7, 63       	# Системный вызов для чтения из файла
    mv   a0, %file_descriptor       # Дескриптор файла
    mv   a1, %reg   	# Адрес буфера для читаемого текста из регистра
    li   a2, %size 		# Размер читаемой порции
    ecall             	# Чтение
.end_macro

# Макрос, обворачивающий основной метод инверсирования последовательности слов в файле
.macro copy_inverse_macro (%arg, %size)
	# Использовал эту отчасти хитрую уловку, для того, чтобы не потерять arg и size, 
	# Сделано так, потому что по условию надо в макросе применять подпрограммы
	# (Предполагается, во временных переменных передавать аргументы не стоит)
	push (t0)
	push (t1)
	mv	t0 %arg
	mv	t1 %size
	push (a3)
	push (a4)
	mv	a4 t0
	mv	a3 t1
	jal copy_inverse
	mv	t0 a4
	pop (a4)
	pop (a3)
	mv	%arg t0
	pop (t1)
	pop (t0)
.end_macro

# Получаем путь на вход. Макрос обворачивает подпрограмму.
.macro print_in_console_macro (%arg)
	# Использовал эту отчасти хитрую уловку, для того, чтобы не потерять arg и size, 
	# Сделано так, потому что по условию надо в макросе применять подпрограммы
	# (Предполагается, во временных переменных передавать аргументы не стоит)
	push (t0)
	mv	t0 %arg
	push (s4)
	mv	s4 t0
	# Прыгаем в подпрограмму
	jal print_in_console
	pop (s4)
	pop (t0)
.end_macro

# Получаем путь на вход. Макрос обворачивает подпрограмму.
.macro get_input_macro (%dest, %size)
	# Использовал эту отчасти хитрую уловку, для того, чтобы не потерять arg и size, 
	# Сделано так, потому что по условию надо в макросе применять подпрограммы
	# (Предполагается, во временных переменных передавать аргументы не стоит)
	push (t0)
	push (t1)
	push (a3)
	push (a4)
	
	# Прыгаем в подпрограмму
	jal get_input
	mv	t0 a3
	mv	t1 a4
	pop (a4)
	pop (a3)
	mv	%dest t1
	mv	%size t0
	pop (t1)
	pop (t0)
	
.end_macro

# Запись в файл. Макрос обворачивает подпрограмму.
.macro print_output_macro (%file_text, %size)
	# Использовал эту отчасти хитрую уловку, для того, чтобы не потерять arg и size, 
	# Сделано так, потому что по условию надо в макросе применять подпрограммы
	# (Предполагается, во временных переменных передавать аргументы не стоит)
	push (t0)
	push (t1)
	mv	t0 %file_text
	mv	t1 %size
	push (s4)
	push (s3)
	mv	s4 t0
	mv	s3 t1
	# Прыгаем в подпрограмму
	jal	print_output
	pop (s3)
	pop (s4)
	pop (t1)
	pop (t0)
.end_macro

# Проверка на то, что символ является пустым/проблельным/переносом строки и другим разделителем слова.
# Современные системы типа Word тоже считают не отделенные пробелом слова (но отделенные запятыми) за одно слово,
# Так что и тут чисто разделение по пробелам
.macro check_for_spacechar (%arg, %indicator)
	push (t0)
	li	t0 32 # до 32 символа в ASCII только пустые/служебные символы
	ble	%arg t0 space
	li	t0 127 # это код еще одного пустого символа
	beq	%arg t0 space
	li	%indicator 0
	b done
space:
	li %indicator 1 # Индикатор равен 1 означает, что это пробельный символ
done:
	pop (t0)
.end_macro

# Добавление size символов из регистра begin в регистр dest. Предполагается, что это есть целое слово
.macro add_word (%begin, %size, %dest)
	push (t0)
	push (t1)
	
	# Загружаем счетчик в t1 и уменьшаем, пока он не станет равным нулю. Значит, загрузим всё слово
	mv	t1 %size
inner_loop:
	beqz	t1 done
	# Двигаем счетчик и адреса строк на 1.
	addi	t1 t1 -1
	addi	%begin %begin 1
	addi	%dest %dest 1
	# Загружаем и выгружаем из входной в выходную строку
	lb	t0 (%begin)
	sb	t0 (%dest)
	b inner_loop
done:
	# Начальную строку переставляем на свое обычное место, но слово выходное оставляем на последнем символе.
	# Так как один из элементов неизменяем и не стоит менять указатель на него, а второй является заполняемым.
	sub	%begin %begin %size
	pop (t1)
	pop (t0)
.end_macro

.macro write_file (%descriptor, %address, %length)
# Запись информации в открытый файл
	li   a7 64       		# Системный вызов для записи в файл
	mv   a0 %descriptor 		# Дескриптор файла
	mv   a1 %address 		# Адрес буфера записываемого текста
	mv   a2 %length    		# Размер записываемой порции из регистра
	ecall             		# Запись в файл
.end_macro

# Закрытие файла
.macro close(%file_descriptor)
    li   a7, 57       # Системный вызов закрытия файла
    mv   a0, %file_descriptor  # Дескриптор файла
    ecall             # Закрытие файла
.end_macro

# Функция main, просто заменены все подпрограммы на макросы
.macro main_function_macro
	push (s2)
	push (s3)
	push (s4)
	push (s7)
	li	s7 -1
	get_input_macro (a4, a3)
	beq	s7 a0 done
	copy_inverse_macro (a4, a3)
	mv	s4 a4
	mv	s3 a3
	print_in_console_macro (a4)
	print_output_macro (a4, a3)
done:
	pop (s7)
	pop (s4)
	pop (s3)
	pop (s2)
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
