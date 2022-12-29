.data
memory: .skip 10000

.global _start
_start:
	movq 16(%rsp), %rsi

	#opens file for reading
	movq $2, %rax
	movq %rsi, %rdi
	movq $0, %rsi
	movq $0666, %rdx
	syscall

	#reads 5000 chars max, puts them in buffer
	movq %rax, %rdi
	movq $0, %rax
	movq $file_buffer, %rsi
	movq $5000, %rdx
	syscall

	#closes file
	movq $3, %rax
	syscall

	#r8 is stack pointer for brainfuck
	#r9 has the value for our little cutie pi memory of char
	movq $memory, %r8	
	movq $file_buffer, %r9
	
begin_interpret:

	movb (%r9), %bl
	incq %r9

	cmpb $43, %bl 	#+
	je plus
	cmpb $45, %bl 	#-
	je minus
	cmpb $62, %bl	#>
	je right
	cmpb $60, %bl	#<
	je left
	cmpb $46, %bl	#.
	je out
	cmpb $91, %bl	#[
	je start_loop
	cmpb $93, %bl	#]
	je end_loop
	cmpb $44, %bl
	je input

	cmpb $0, %bl
	je exit

	jmp begin_interpret
	

exit:
	movq $0, %rdi
	movq $60, %rax
	syscall 

plus:
	incb (%r8)

	jmp begin_interpret

minus:
	decb (%r8)

	jmp begin_interpret

right:
	incq %r8

	jmp begin_interpret

left:
	decq %r8

	jmp begin_interpret

out:	
	#output char in r8
	movq $1, %rax
	movq $1, %rdx	
	movq $1, %rdi
	movq %r8, %rsi
	syscall

	jmp begin_interpret

start_loop:	
	cmpb $0, (%r8)
	jne begin_interpret

loop_start_loop:
	movb (%r9), %bl
	incq %r9
	cmpb $93, %bl
	je 	begin_interpret
	jmp loop_start_loop

end_loop:
	cmpb $0, (%r8)
	je begin_interpret

loop_end_loop:
	decq %r9
	movb (%r9), %bl
	cmpb $91,%bl
	jne loop_end_loop
	incq %r9
	jmp begin_interpret

input:
	#reads 1 char max, puts them in (%r8)
	movq $0, %rdi
	movq $0, %rax
	movq %r8, %rsi
	movq $1, %rdx
	syscall

	jmp begin_interpret	

.bss
.lcomm file_buffer, 10000

