.include "macrolib.s"

.text
	lui	a1 0xffff0    # MMIO address high half
	push_numbers (a2)
	
	# Загружаю в t0 16, в t1 - 0 и в t2 - 20 (будет выполнено 20 повторений, это счетчик)
	# В a7 загружаю 32, это для sleep
	li	t0 0x80
	li	t1 0
	li	t2 20
	li	a7 32

loop:
	# Секундный сон
	li	a0 1000
	ecall

	# Получаю значение из цифровой клавиатуры
	scan_kbd_a0
	beq	a0 t0 print
	# Получение нужного номера для вывода из стека. Число в а0, адрес стека - в а2
	get_diglab_num (a0, a2)
print:
	# Вывод на экран
	sb	a0 0x10(a1)
	
	# Повторение цикла
	addi	t1 t1 1
	ble	t1 t2 loop
	
end:	
	pop_numbers
	
	li	a7 10
	ecall
