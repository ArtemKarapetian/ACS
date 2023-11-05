.globl get_input
.globl print_output
.include "macrolib.s"
.text
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