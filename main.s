.include "macrolib.s"

#.globl main
.globl main_function

.text
#main:
	jal main_function
end_of_program:
	exit

main_function:
	push (s2)
	push (s3)
	push (s4)
	push (s6)
	push (s7)
	# Загружаем в память информацию о возвращаемом регистре
	mv	s6 ra
	# И загружаем -1, это как код ошибки
	li	s7 -1
	jal get_input
	# Получили строку на вход, делаем проверку на ошибку
	beq	s7 a0 return
	# Все хорошо, поэтоум инверсируем строку
	jal copy_inverse
	mv	s4 a4
	mv	s3 a3
	# Выводим в консоль/файл
	jal print_in_console
    	jal print_output
return:
	# Возвращаем все на места 
	mv	ra s6
	pop (s7)
	pop (s6)
	pop (s4)
	pop (s3)
	pop (s2)
	ret