.include "macrolib.s"
.globl main
.globl get_arcsine

.text
main:
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
