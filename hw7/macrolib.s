# Вручную посчитанные значения для вывода 16 чисел
.eqv	DIGLAB_0 0x3f
.eqv	DIGLAB_1 0x06
.eqv	DIGLAB_2 0x5b
.eqv	DIGLAB_3 0x4f
.eqv	DIGLAB_4 0x66
.eqv	DIGLAB_5 0x6d
.eqv	DIGLAB_6 0x7d
.eqv	DIGLAB_7 0x07
.eqv	DIGLAB_8 0x7f
.eqv	DIGLAB_9 0x6f
.eqv	DIGLAB_A 0x77
.eqv	DIGLAB_B 0x7c
.eqv	DIGLAB_C 0x39
.eqv	DIGLAB_D 0x5e
.eqv	DIGLAB_E 0x79
.eqv	DIGLAB_F 0x71

# Пуш всех чисел в стек для удобного их нахождения
# Чтобы получить код нужного числа, нужно к начальному адресу добавить -4 * число (-4 - спуск вниз на 4 байта)
.macro push_numbers %stack_begin
	addi	%stack_begin sp 0
	addi	sp, sp, -68
	sw	t0, (sp)
	addi	sp, sp 68
	
	li	t0 DIGLAB_0
	push (t0)
	li	t0 DIGLAB_1
	push (t0)
	li	t0 DIGLAB_2
	push (t0)
	li	t0 DIGLAB_3
	push (t0)
	li	t0 DIGLAB_4
	push (t0)
	li	t0 DIGLAB_5
	push (t0)
	li	t0 DIGLAB_6
	push (t0)
	li	t0 DIGLAB_7
	push (t0)
	li	t0 DIGLAB_8
	push (t0)
	li	t0 DIGLAB_9
	push (t0)
	li	t0 DIGLAB_A
	push (t0)
	li	t0 DIGLAB_B
	push (t0)
	li	t0 DIGLAB_C
	push (t0)
	li	t0 DIGLAB_D
	push (t0)
	li	t0 DIGLAB_E
	push (t0)
	li	t0 DIGLAB_F
	push (t0)
	lw	t0, (sp)
.end_macro

# Просто возвращаения указателя на стек на изначальное значение
.macro pop_numbers
	addi	sp, sp, 68
.end_macro

# Получение положительного остатка от деления на 16. Если число больше 16 или меньше 0, то это фиксируется
.macro get_hex (%num, %indicator_not_hex)
	
	push (t0)
	li	t0 16
	
	# Проверка, больше ли 16 число или меньше ли 0
	bltz	%num lower_than_zero
	bge	%num t0 bigger_than_sixteen
	# Если число уже хорошее, то просто выходим из программы
	b	done

	# Так или иначе, если число не из диапозона [0, 15] то загружаем
	# номер символа точки в регистр индикатора
lower_than_zero:
	li %indicator_not_hex 0x80
adding_loop: # Цикл, увеличивающий число на 16 пока оно не станет положительным
	bgez	%num done
	add	%num %num t0
	b adding_loop
	
	# Загружаем номер точки в регистр индикатора
bigger_than_sixteen:
	li %indicator_not_hex 0x80
subtracting_loop: # Цикл, уменьшающий число на 16 пока оно не станет меньше 16
	blt	%num t0 done
	sub	%num %num t0
	b subtracting_loop

# Выход
done:
	pop (t0)
.end_macro

# Сканирование кнопки цифровой клавиатуры в а0
.macro scan_kbd_a0
	push (t0)
	push (t1)
	push (t2)
	push (t3)
	
	# Загрузка всех значений на 0 и загрузка адреса MMIO
	li	t0 0
	li	t1 0
	lui	t2 0xffff0
	li	t3 0
	li	a0 0
	

	li      t0 1                # первый ряд
        sb      t0 0x12(t2)         # сканируем
        lb      t0 0x14(t2)	    # получаем значение
        or      t1 t1 t0            # добавляем биты в общий результат
        li      t0 2                # второй ряд
        sb      t0 0x12(t2)
        lb      t0 0x14(t2)
        or      t1 t1 t0
        li      t0 4                # третий ряд
        sb      t0 0x12(t2)
        lb      t0 0x14(t2)
        or      t1 t1 t0
        li      t0 8                # четвёртый ряд
        sb      t0 0x12(t2)
        lb      t0 0x14(t2)
        or      t1 t1 t0
        
        # делаем шрифт туда-обратно, чтобы число в t1 наверняка выглядело как 0x000000xx
        slli	t1 t1 24
        srli	t1 t1 24
        
        # Последовательная проверка, какое число лежит в а0
        li	t0 0
        beq	t1 t0 dot
        li	t0 0x11
        beq	t1 t0 done_scanning
        addi	a0 a0 1
        li	t0 0x21
        beq	t1 t0 done_scanning
        addi	a0 a0 1
        li	t0 0x41
        beq	t1 t0 done_scanning
        addi	a0 a0 1  
        li	t0 0x81
        beq	t1 t0 done_scanning
        addi	a0 a0 1
        li	t0 0x12
        beq	t1 t0 done_scanning
        addi	a0 a0 1
        li	t0 0x22
        beq	t1 t0 done_scanning
        addi	a0 a0 1
        li	t0 0x42
        beq	t1 t0 done_scanning
        addi	a0 a0 1  
        li	t0 0x82
        beq	t1 t0 done_scanning
        addi	a0 a0 1
        li	t0 0x14
        beq	t1 t0 done_scanning
        addi	a0 a0 1
        li	t0 0x24
        beq	t1 t0 done_scanning
        addi	a0 a0 1
        li	t0 0x44
        beq	t1 t0 done_scanning
        addi	a0 a0 1  
        li	t0 0x84
        beq	t1 t0 done_scanning
        addi	a0 a0 1
        li	t0 0x18
        beq	t1 t0 done_scanning
        addi	a0 a0 1
        li	t0 0x28
        beq	t1 t0 done_scanning
        addi	a0 a0 1
        li	t0 0x48
        beq	t1 t0 done_scanning
        addi	a0 a0 1
        b	done_scanning
       
# Если сейчас не введено никакое число, то загрузим в а0 номер точки
dot:
	addi	a0 a0 0x80
done_scanning: # выход
	pop (t3)
	pop (t2)
	pop (t1)
	pop (t0)
.end_macro

# Получение номера для вывода результата 
.macro	get_diglab_num (%arg, %stack)
	push (t0)
	push (t1)
	push (t2)
	
	# Все 16 чисел хранятся в стеке, чтобы получить нужное число, надо
	# загрузить значение по адресу (начало стека - 4*число)
	mv	t0 %arg
	addi	t0 t0 1
	li	t1 -4
	mul	t0 t0 t1
	add	t2 %stack t0
	lw	%arg (t2)
	
	pop (t2)
	pop (t1)
	pop (t0)
.end_macro


# Сохранение заданного регистра на стеке
.macro push(%x)
	addi	sp, sp, -4
	sw	%x, (sp)
.end_macro

# Выталкивание значения с вершины стека в регистр
.macro pop(%x)
	lw	%x, (sp)
	addi	sp, sp, 4
.end_macro
