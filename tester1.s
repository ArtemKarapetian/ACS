.include "macrolib.s"

#.globl main

.text
#main:
	# Тест на подпрограммы с разными входами
	print_str("Try to enter anything non-existent. It should print a message about a mistake.\n")
	jal main_function
	
	print_str("\nNow enter input_2.txt. This test tests for not changing order for 1 word")
	newline
	print_str("The input is \"abcdefghijklmnopqrstuvwxyz12345678900\"")
	newline
	jal main_function
	newline
	print_str("The answer must be \"abcdefghijklmnopqrstuvwxyz12345678900\"")
	newline
	
	
	print_str("\nNow enter input_3.txt. Three words must be in reversed order")
	newline
	print_str("The input is \"Hello, my heroes\"")
	newline
	jal main_function
	newline
	print_str("The answer must be \"heroes. my Hello,\"")
	newline
	
	print_str("\nNow enter input_4.txt. The same as previous but with newlines and escessive spacebars")
	newline
	print_str("The input is \"Hello, my beautiful and superb heroes\"")
	newline
	jal main_function
	newline
	print_str("The answer must be \"Heroes. superb and beautiful my Hello,\" with inversed newlines and spacebars")
	newline
	
	newline
	print_str("Try to enter anything existent or just hit enter. Then, try to give path to a non-existent file for output.")
	print_str("It should print a message about a mistake.\n")
	jal main_function
	
	exit