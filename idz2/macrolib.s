#
# Library of macros.
#

# Печать содержимого регистра как целого
.macro print_double (%x)
	li a7, 3
	fmv.d fa0, %x
	ecall
.end_macro

# Ввод целого числа с консоли в регистр a0
.macro read_double_fa0
   li a7, 7
   ecall
.end_macro

# Ввод аргумента – рационального числа от -1 до 1
.macro read_arg(%x)
	push_double (f0)
	push (t0)
	push (a0)

read_right_arg:
	print_str ("Input rational number from -1 to 1: ")
	read_double_fa0	# Чтение числа
	
	# Загружаю в f0 значение 1 для проверки верхней границы введенного числа
	li t0 1
	fcvt.d.w f0 t0
	fle.d t0 fa0 f0
	beqz t0 retry # Если число больше 1, то повтор
	
	# Загружаю в f0 значение -1 для проверки нижней границы введенного числа
	li t0 -1
	fcvt.d.w f0 t0
	fge.d t0 fa0 f0
	beqz t0 retry # Если число меньше -1, то повтор
	
	b done_reading  # Выходим из программы, когда все успешно
retry:
	# Объявляем о неверности ввода и отправляемся в начало
	print_str ("The input number is incorrect. It must be -1 <= x <= 1")
	newline
	b read_right_arg
	
done_reading:
	fmv.d %x fa0	# В желаемый регистр переносим число и выходим из программы
	
	pop (a0)
	pop (t0)
	pop_double (f0)
.end_macro

.macro arcsin(%x)
.text
	push_double (f0)
	push_double (f1)
	push_double (f2)
	push_double (f3)
	push_double (f4)
	push_double (f5)
	push (t0)
	push (a0)
	
	# Проверяю на частные случаи
	arcsin_typical	(%x, a0)
	# Если аргумент является частным случаем, то быстро осуществляю выход из макроса
	bnez	a0 end_calculus

	# в f5 будет храниться 0.0 (float)
	li	t0 0
	fcvt.d.w	f5 t0
	
	# в f0 планируется хранить множитель к какой-то степени аргумента
	# в f1 планируется хранить необходимую степень аргумента
	li	t0 1
	fcvt.d.w	f0 t0
	fadd.d	f1 %x f5
	fadd.d	f2 %x f5 # хранение значение арксинуса на последнем шаге
	fadd.d	f3 %x f5 # хранение значения арксинуса на нынешнем шаге
	fadd.d	f4 %x f5 # промежуточный регистр f0 * f1 - необходимое слагаемое на каждой итерации
	b count_arcsin  # переходим к первой итерации
	
check_iter:
	# передаю в fs0 и fs1 значения из f2 и f3 соответственно, проверяю на то, насколько существенная разница
	fadd.d	fs0 f2 f5
	fadd.d	fs1 f3 f5
	li	a0 0 # этот аргумент будет показывать, есть или нет существенная разница
	is_significant_change (fs0, fs1, a0) # сама функция подсчета разницы
	# Если разница несуещственна, то заканчиваем подсчеты
	beqz	a0 end_calculus
	
count_arcsin:
	fadd.d	f2 f3 f5 # делаем предыдущую итерацию равной нынешней, чтобы потом сделать новую итерацию
	# увеличиваем степень аргумента в f4 на 2
	fmul.d	f4 f4 f1
	fmul.d  f4 f4 f1
	# пусть n = f0. Умножаем f4 на n 2 раза
	fmul.d  f4 f4 f0
	fmul.d  f4 f4 f0
	# Делим f0 на n + 1 и n + 2
	faddi (f0, t0, 1)
	fdiv.d	f4 f4 f0
	faddi (f0, t0, 1)
	fdiv.d	f4 f4 f0
	# в результате из f0 = 1/2 * 3/4 * ... * (n-2)/(n-1) * x^n / n 
	# мы получаем 1/2 * ... (n-2) / (n-1) *  n / (n+1) * x^(n+2) / (n+2) - новое слагаемое в степенном ряду
	fadd.d	f3 f3 f4 # добавляем к нынешней сумме текущее слагаемое
	fadd.d	%x f3 f5 # сразу обновляем ответ, так как все равно этот ответ будет ближе к истине, чем предыдущий
	b check_iter # осуществляем проверку на необходимость следующей итерации
	
end_calculus: # заканчиваем вычисление
	pop (a0)
	pop (t0)
	pop_double (f5)
	pop_double (f4)
	pop_double (f3)
	pop_double (f2)
	pop_double (f1)
	pop_double (f0)
.end_macro

# Проверка на частный случаи: 1, 0, -1
.macro arcsin_typical (%arg, %change)
.data
	# Данные для частных случаев. Значения взяты из интернета
	arcsin_one:	.double 1.57079632679
	arcsin_neg_one: .double -1.57079632679
	arcsin_zero:	.double 0.0
.text
	push_double (f0)
	push (t0)
	push (t1)

# Проверка, что аргумент равен 1
check_for_one:	
	li	t0 1
	fcvt.d.w	f0 t0 # Загружаем в f0 1
	feq.d	t1 f0 %arg
	beqz	t1 check_for_neg_one # Если аргумент не равен 1, то идем к следующей проверке
	# Присваиваем значение частного случая, обновляем аргумент-индикатор частного случая на 1 и переходим к концу
	fld	%arg arcsin_one t0
	li	%change 1
	b	end

# Проверка, что аргумент равен -1
check_for_neg_one:
	li	t0 -1
	fcvt.d.w	f0 t0 # Загружаем в f0 -1
	feq.d	t1 f0 %arg
	beqz	t1 check_for_zero # Если аргумент не равен -1, то идем к следующей проверке
	# Присваиваем значение частного случая, обновляем аргумент-индикатор частного случая на 1 и переходим к концу
	fld	%arg arcsin_neg_one t0
	li	%change 1
	b	end

# Проверка, что аргумент равен 0
check_for_zero:
	li	t0 0
	fcvt.d.w	f0 t0 # Загружаем в f0 0
	feq.d	t1 f0 %arg
	beqz	t1 end_no_typical # Если аргумент не равен 0, то идем к концу, обновляя индикатор изменения на 0 (изменений нет)
	# Присваиваем значение частного случая, обновляем аргумент-индикатор частного случая на 1 и переходим к концу
	fld	%arg arcsin_zero t0 
	li	%change 1
	b	end
	
end_no_typical:
	li %change 0
	
end:	pop (t1)
	pop (t0)
	pop_double (f0)
.end_macro

.macro is_significant_change (%first, %second, %answer)
.data
	# Данные для 1.0 float и для очень близкого к 1 числу, нужного для сравнения
	small_number:	.double 1.000001
	one_double:	.double 1.0
.text
	push_double (f0)
	push_double (f1)
	push (t0)
	push (t1)
	
	fld	f1 one_double t1 # Загружаем значение 1 из памяти
	fdiv.d	f0 %first %second # Присваиваем f0 соотношение первого и второго числа
	flt.d	t0 f0 f1
	beqz	t0 right_numbers_check # Если соотношение верное (первое число больше второго), то сразу переходим к сравнению
not_right_numbers_check:
	fdiv.d	f0 %second %first # Переворачиваем число, если второе число больше первого
right_numbers_check:
	fld	f1 small_number t1
	fge.d 	t0 f0 f1 # сравниваем соотношение с очень близким к 1 числу
end:
	add	%answer t0 zero # Возвращаем результат сравнения
	pop (t1)
	pop (t0)
	pop_double (f1)
	pop_double (f0)
.end_macro

# Макрос для конвертации радиан в градусы (для красоты :) ) 
# (угол в градусах) = (угол в радианах) / (табличное значение для 90 градусов (он же равен арксин(1)) * 90 градусов
.macro convert_to_degree (%arg)
.data
	# Значение арксинуса для 1
	arcsin_one: .double 1.57079632679
.text
	push_double (f0)
	push (t0)
	
	# Загружаем из данных табличное значение арксинуса и выполняем первое действие формулы
	fld	f0 arcsin_one t0
	fdiv.d	%arg %arg f0
	# Загружаем 90 градусов в float регистр и выполняем второе действие формулы
	li	t0 90
	fcvt.d.w	f0 t0
	fmul.d	%arg %arg f0
	
	pop (t0)
	pop_double (f0)
.end_macro

# аналог addi но для float чисел
.macro faddi (%fx, %x, %t)
	addi %x %x %t
	fcvt.d.w %fx %x
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

# Сохранение заданного регистра со значением double на стеке
.macro push_double(%x)
	addi	sp, sp, -8
	fsd	%x, (sp)
.end_macro

# Выталкивание значения с вершины стека в регистр
.macro pop(%x)
	lw	%x, (sp)
	addi	sp, sp, 4
.end_macro

# Выталкивание значения double с вершины стека в регистр
.macro pop_double(%x)
	fld	%x, (sp)
	addi	sp, sp, 8
.end_macro
