.include "macrolib.s"

# Эта программа выполняет то, что нужно на 8 баллов
.text
	lui	a1 0xffff0    # MMIO address high half
	push_numbers (a2)
	
	# Счетчик. Будем увеличивать на 3. Значение счетчика будет выводиться на экран
	li	t2 0
	li	t3 145
	
	jal print_numbers

	pop_numbers
	
	li	a7 10
	ecall

# Необходимая подпрограмма
print_numbers:
	push (t0)
	push (t1)
	push (t2)
	push (t3)
	push (t4)
	push (t5)	

loop:
	mv	a0 t2
	get_hex (a0, t1) # Получаю значение от 0 до 15 из а0,
	# а также в t1 хранится 0x80 (точка), если значение больше 15 или меньше 0
	
	# Получаем выражение, которое покажет нам нужное число. Берем выражение из стека
	# Чтобы получить число, надо загрузить значение по адресу (стек - 4 * число)
	li	t0 -4
	addi	a0 a0 1
	mul	a0 a0 t0
	add	a3 a2 a0
	lw	a0 (a3)
	add	a0 a0 t1
	# Загружаю в t0 0x10, чтобы произвести сравнение и выводить сначала в одно окно, потом в другое.
	li	t0 0x10
	beq	t0 t5 print_left

print_right:
	sb	a0 0x11(a1)
	li	t5 0x10
	b	check_loop

print_left:
	sb	a0 0x10(a1)
	li	t5 0x11

check_loop:
	# Увеличение счетчика и повторение цикла
	addi	t2 t2 3
	blt	t2 t3 loop
	
	pop (t4)
	pop (t3)
	pop (t2)
	pop (t1)
	pop (t0)
	ret
