.include "macrolib.s"

.text
	# Передаю на вход строку, возвращаемого значения нет, только передача строки
	print_str ("Hello. It's 5 variant of homework 2. The author is Karapetian Artem.\n")
	
	# Получение аргумента арксинуса от -1 до 1
	jal get_input
    	
    	# Получение значения арксинуса в радианах в fa2
    	jal get_arcsine
    	
    	# Получение конвертации из радиан в градусы в fa3
    	jal get_degree_from_radians
    	
    	# Красивый вывод результата
    	jal print_output
    	
    	# Этот макрос осуществляет выход из программы
	exit

get_arcsine:
	li	t0 0
    	fcvt.d.w f5 t0
    	fadd.d fa2 fa1 f5
    	# Передаю на вход регистр float, результат возвращается в передаваемый регистр 
    	arcsin (fa2)
    	ret
   
get_degree_from_radians:
	li	t0 0
    	fcvt.d.w f5 t0
	fadd.d fa3 fa2 f5
    	# Передаю на вход регистр float, результат возвращается в передаваемый регистр 
    	convert_to_degree (fa3)
    	ret
get_input:	
	# Макрос, без входных-выходных данных, печатающий новую линию
	newline
	# Передаю на вход строку, возвращаемого значения нет, только передача строки
	print_str ("This program takes a rational number between -1 and 1 and gives and arcsine of it")
	newline
	# Передаю на вход регистр (а1), в котором буду хранить аргумент степенного ряда. Возвращается упомянутый регистр со значением
	read_arg (fa1)	# Чтение размера массива
	# Передаю на вход строку, возвращаемого значения нет, только передача строки
	print_str ("The input argument is ")  # Вывод размера массива
	# Передаю на вход регистр, возвращаемого значения нет и ничего не меняется, только вывод значения в регистре на экран
	print_double (fa1)
    	newline
    	ret
    	
print_output:
	print_str ("arcsin(") # Передаю на вход строку аналогично прошлым вызовам print_str
    	print_double (fa1) # Передаю на вход регистр аналогично прошлым вызовам print_double
    	print_str (") = ") # Передаю на вход строку аналогично прошлым вызовам print_str
    	print_double (fa2) # Передаю на вход регистр аналогично прошлым вызовам print_double
    	print_str (" radians or ") # Передаю на вход строку аналогично прошлым вызовам print_str
    	print_double (fa3) # Передаю на вход регистр аналогично прошлым вызовам print_double
    	print_str (" degrees") # Передаю на вход строку аналогично прошлым вызовам print_str
    	ret