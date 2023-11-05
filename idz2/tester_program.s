# Тестовая программа, все значения взяты из интернета (встроенный в яндекс калькулятор)
#.globl main
.data
	# Для сравнения я использую переменную, равную 1.05, а также две строки для вывода в зав-ти от случая
	one_point_zero_five:	.double 1.05
	normal_diff:	.asciz "The difference is less than 1.05. It's allright!\n"
	not_normal_diff:	.asciz "The difference is more than 1.05. It's not allright((\n"
	
	# Тесты и ответы к тестам. Ответы к тестам взяты из яндекса (просто вводите "arcsin(x)" в яндекс)
	test_1:	.double 1
	test_1_answer:	.double 1.57079632679
	
	test_2:	.double 0.234234
	test_2_answer:	.double 0.23643057347
	
	test_3:	.double 0
	test_3_answer:	.double 0.0
	
	test_4:	.double -0.6
	test_4_answer:	.double -0.64350110879
	
	test_5:	.double -0.9994
	test_5_answer:	.double -1.53615357836
	
	test_6:	.double 0.4
	test_6_answer:	.double 0.41151684606

.text
#main:
	# В fa4 кладу 1.05, чтобы дальше с ней сравнивать
	fld	fa4 one_point_zero_five t0
	
	# Запускаю первый тест, аналогично все остальные. В конце каждого теста проверяю на разницу
	fld	fa1 test_1 t0
	jal	get_arcsine
	fld	fa3 test_1_answer t0
	jal	is_difference_big
	
	fld	fa1 test_2 t0
	jal	get_arcsine
	fld	fa3 test_2_answer t0
	jal	is_difference_big
	
	fld	fa1 test_3 t0
	jal	get_arcsine
	fld	fa3 test_3_answer t0
	jal	is_difference_big
	
	fld	fa1 test_4 t0
	jal	get_arcsine
	fld	fa3 test_4_answer t0
	jal	is_difference_big
	
	fld	fa1 test_5 t0
	jal	get_arcsine
	fld	fa3 test_5_answer t0
	jal	is_difference_big
	
	fld	fa1 test_6 t0
	jal	get_arcsine
	fld	fa3 test_6_answer t0
	jal	is_difference_big
	
	# Выход из программы (библиотеку макросов не подключал)
	li	a7 10
	ecall

# Проверка на разницу
is_difference_big:
	# Отдельная проверка на равенство. На случай, когда аргументы равны 0, или когда действительно равны
	feq.d	t0 fa2 fa3
	bnez	t0 normal # Если аргументы равны, то, конечно, программа сработала правильно
	fdiv.d	f0 fa2 fa3 # Присваиваем f0 соотношение первого и второго числа
	flt.d	t0 f0 fa4
	beqz	t0 not_normal # Переход к выводу строки о неверном тесте в случае разницы более, чем 1.05
	fdiv.d	f0 fa3 fa2 # Присваиваем f0 соотношение второго и первого числа (на случай, если первое больше второго)
	flt.d	t0 f0 fa4
	beqz	t0 not_normal # Переход к выводу строки о неверном тесте в случае разницы более, чем 1.05

normal: # Вывод строки о том, что разница между арксинусами маленькая
	li	a7 4
	la	a0 normal_diff
	ecall
	ret # Возвращение из подпрограммы
	
not_normal: # Вывод строки о том, что разница между арксинусами большая
	li	a7 4
	la	a0 not_normal_diff
	ecall
	ret # Возвращение из подпрограммы