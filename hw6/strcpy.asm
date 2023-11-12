.globl strcpy
strcpy:
	# Пушим на стек используемые регистры
	addi	sp, sp, -4
	sw	t0, (sp)
	addi	sp, sp, -4
	sw	t1, (sp)
	addi	sp, sp, -4
	sw	t2, (sp)	

	# Загружаем в переменные адреса строк, в t2 храним текущий символ
	mv	t0 a2
	mv	t1 a3
loop:
	# Загружаем символ из t0 и вгружаем его в t1
	lb	t2 0(t0)
	sb	t2 0(t1)
	beqz	t2 fin # Если символ нулевой, то переходим к концу копирования
	
	# Переносим адреса строк на следующий символ
	addi	t0 t0 1
	addi	t1 t1 1
	b loop
fin:
	# Возвращаем со стека использованные регистры
	lw	t2, (sp)
	addi	sp, sp, 4
	lw	t1, (sp)
	addi	sp, sp, 4
	lw	t0, (sp)
	addi	sp, sp, 4
	ret
