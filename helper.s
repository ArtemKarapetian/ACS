.globl get_input
.globl print_output
.globl print_in_console

.include "macrolib.s"

.eqv    NAME_SIZE 256	# Размер буфера для имени файла
.eqv    TEXT_SIZE 512	# Размер буфера для текста
.eqv	MAX_SIZE 10240  # Максимальный размер для текста 

.data
input_file:	.space NAME_SIZE
default_input_file:	.asciz "input.txt"
output_file:	.space NAME_SIZE
default_output_file:	.asciz "output.txt"

.text
# Получение пути к файлу
get_input:	
	newline
	print_str("Enter a path to the input file. The default one would be \"input.txt\".\n")
	# Получаем путь. Если будет пустой ввод, то вернется default
	str_get(input_file, NAME_SIZE, default_input_file)
	
	# Открываем файл в а0
	open_a0 (READ_ONLY)
	
	# Делаем проверку на ошибку
	li	t0 -1
	beq	a0 t0 error_input
	mv	s0 a0	# Сохранения дескриптора
	
	# Если всё хорошо, то сохраняем результат
	read_file (TEXT_SIZE, MAX_SIZE)
	
	ret
	
# Вывод строки в консоль
print_in_console:
	push (t0)
	push (t1)
	push (t2)
	
	# Выделяем память для входной строки - ответа на вопрос о необходимости вывода.
	# Можно было использовать readchar, но она крашится с диалоговым окном RARS при пустом вводе (у меня, по крайней мере)
	li	a0 2
	li	a7 9
	ecall
	
	# Две опции ответа
	li	t0 'Y'
	li	t1 'N'
	
	# Задаём необходимый вопрос и читаем строку
	print_str ("Do you wanna know the results of inversing the program? Answer must be Y or N.\n")
	li	a1 2
	li	a7 8
	ecall
	
	# Если пользователь с первого раза все ответил верно, то мы его поздравляем и печатаем/не печатаем и выходим
	lb	t2 (a0)
	beq	t0 t2 done_and_print
	beq	t1 t2 done
	
# Если пользователь ввёл неверно, то будет вводить, пока не сделает это правильно
wrong_char_loop:
	print_str ("Try again. You should write 'Y' or 'N'.\n")
	li	a7 8
	ecall

	# аналогичная проверка
	lb	t2 (a0)
	beq	t0 t2 done_and_print
	beq	t1 t2 done
	b	wrong_char_loop

# Вывод строки при положительном ответе
done_and_print:
	newline	
	mv	a0 s4
	li	a7 4
	ecall
	newline
# Выход из подпрограммы
done:
	pop (t2)
	pop (t1)
	pop (t0)
	ret

# Вывод в файл
print_output:
	push (a0)
	push (s0)
	push (t0)
	# Сохранение прочитанного файла в другом файле
	print_str ("\nEnter path to the output file. The default one would be \"output.txt\".\n")
	str_get(output_file, NAME_SIZE, default_output_file) # Ввод имени файла с консоли эмулятора
	open_a0(WRITE_ONLY)
	
	li	t0 -1
	beq	a0 t0 error_output	# Ошибка открытия файла
	mv   	s0 a0       	# Сохранение дескриптора файла
	# Сам макрос вывода в файл
	write_file (s0, s4, s3)
	
	# Закрываем файл
	close (s0)
	pop (t0)
	pop (s0)
	pop (a0)
	ret
   
# Отлов ошибок
error_input:
	print_str("Mistake in writing paths happened.")
	ret

error_output:
	print_str("Mistake in writing paths happened.")
	pop (t0)
	pop (s0)
	pop (a0)
	ret

