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

# Ввод целого числа с консоли в регистр a0
.macro read_int_a0
   li a7, 5
   ecall
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

# Чтение строки размера a0
.macro read_str
.data
	enter_text:	.asciz "Enter the string you want to copy. It length must be less or equal to 100 or it won't work out.\n"
.text
	push (a0)	# Пушу на стек, чтоб не потерять адрес
	la	a0 enter_text	# Вывожу спомогательное сообщение для ввода
	li	a7 4
	ecall
	pop (a0)
	li	a7 8	# Читаю саму строку
	ecall
	
.end_macro

# Вывод строки, просто сокращение обычного системного вызова
.macro print_str (%x)
.data 
str: .asciz %x
.text
   push (a0)
   li a7, 4
   la a0, str
   ecall
   pop	(a0)
.end_macro

# Вызов строки, адрес которой находится в а0
.macro print_str_a0
   li a7 4
   ecall
.end_macro

# Макрос для копирования строки. Аналогично языку С принимает 2 параметра
.macro strcpy (%a, %b)
	push (t0)
	push (t1)
	push (t2)

	# Загружаем адреса строк в t0 и t1. t2 будем использовать для хранения символа
	mv	t0 %a
	mv	t1 %b

loop:
	lb	t2 0(t0)	# Грузим текущий символ с t0
	sb	t2 0(t1)	# Загружаем в t1
	beqz	t2 fin	# Если символ нулевой, то заканчиваем программу
	
	addi	t0 t0 1	# Переносим адреса на следующий символ строк
	addi	t1 t1 1
	b loop
	
fin:
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
