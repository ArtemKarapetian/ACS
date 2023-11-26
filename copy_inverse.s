.include "macrolib.s"

.globl copy_inverse

.text 
# Функция, которая меняет порядок слов в тексте
copy_inverse:
	push (t0)
	push (t1)
	push (t2)
	push (t3)
	push (t4)
	push (t5)
	push (t6)
	
	# Загружаю в t0 и в t1 изначальную строку и отнимаю 1 элемент. 
	# Делаю так, потому что во внутренних циклах я увеличиваю индексы строк.
	mv	t0 a4
	add	t0 t0 a3
	addi	t0 t0 -1
	mv	t1 a4
	addi	t1 t1 -1
	# Выделяем память для выходной строки. Выходня строка будет храниться в t5
	li a7 9
    	mv a0 a3	# Размер блока памяти
   	ecall
   	# t4 - счётчик символов в текущем слове.
	li	t4 0
	mv	t5 a0
	# Аналогично другим строкам в этой подпрограмме уменьшаю индекс на один, так как увеличиваю его в процессе.
	addi	t5 t5 -1
	# Храню изначальный адрес выходной строки в t6
	mv	t6 a0
	
loop:
	# Если t0 и t1 совпадают, значит подпрограмма дошла до последнего символа (до самого начала)
	beq t1 t0 last_char
	# Иначе загружаем элемент из строки и делаем проверку на пробел.
	lb	t2 (t0)
	check_for_spacechar (t2, t3)
	# Если символ не пробел, то продолжаем считать символы в строке. Иначе, добавляем слово в выходную строку.
	bnez	t3 add_chars
	addi	t4 t4 1
	addi	t0 t0 -1
	b loop
# Добавляем (без инверсии) слово и потом добавляем пробел в конец.
add_chars:
	mv	s0 t0
	# Вызов макроса для добавления слова
	add_word (s0, t4, t5)
	# Обнуляем счетчик символов текущего слова
	li	t4 0
	# Сдвигаем индексы в строках на один и добавляем пробел (мы на этом шаге находимся на символе пробела,
	# ведь поэтому решили добавить целое слово)
	addi	t0 t0 -1
	addi	t5 t5 1
	sb	t2 (t5)
	# Повторяем
	b loop
	
# Отдельная проверка для последнего символа
last_char:
	addi	t0 t0 1
	check_for_spacechar (t2, t3)
	# Тут мы не меняли t2 и он остается самым первым символом входной строки, его и проверяем на пробельность
	beqz	t2 done_reversing

# Добавляем последнее слово, если требуется добавить
add_last_word:
	addi	t4 t4 1
	addi	t0 t0 -1
	mv	s0 t0
	add_word (s0, t4, t5)

# Ставим нулевой символ в конце и завершаем подпрограмму
done_reversing:
	addi	t5 t5 1
	sb	zero (t5)
	mv	a4 t6
	pop (t6)
	pop (t5)
	pop (t4)
	pop (t3)
	pop (t2)
	pop (t1)
	pop (t0)
	
	ret
