;------------------------------------- 
; Proyecto de Programacion II         |    
; Arquitectura de Computadoras        |
; Interprete de Comandos (Prompt)     |
; Alejandro Rojas Jara                |
; Fecha de entrega: 18/11/2013        |  
;-------------------------------------   

section .bss
buffer: resb 2048 ; Se utiliza un buffer de 2KB para la lectura

section .data
buflen: dw 2048 ; len del buffer

section .text
extern printf
extern file_Name
extern arg1
extern arg2

global copiar
copiar:

push ebp			
mov ebp, esp	

;--------------------------------------------------------------------------------
;Se crea un archivo nuevo si no existe, de otro modo se sobreescribe el existente|
;--------------------------------------------------------------------------------
open_newfile:
mov ebx, arg1
mov eax, 0x08 
mov ecx, 0x07  
xor edx, edx 
int 0x80 

test eax, eax ; Verifica eax
js exit 
push eax 

;------------------------------------------------------------------
; open(char *path, int flags, mode_t mode);                        |
; Utiliza el argumento guardado en file_Name para abrir un archivo.|
;------------------------------------------------------------------
open_oldfile:
mov ebx, arg2
mov eax, 0x05 ; llamada de sistema para funcion open
xor ecx, ecx ; ecx = 0 > archivo de solo lectura
xor edx, edx 
int 0x80 

test eax, eax ; Verifica eax
jns file_read ; Si no se activa la bandera de signo(positivo), se puede leer el archivo
jmp exit ;De otra manera sale.

;--------------------------------------------------------
;read(int fd, void *buf, size_t count);                  |
;Leemos el archivo utilizando el file descriptor en eax  |
;--------------------------------------------------------
file_read:
mov ebx, eax ; guardamos el FD en ebx
mov eax, 0x03 ; llamada de sistema para read
mov ecx, buffer ; Usamos el buffer de 2KB
mov edx, buflen ; Y su len
int 0x80

test eax, eax ; Revisa si hay errores / EOF (end of file)
jz file_out ; Cuando llega al EOF, imprime el contenido.
js exit ; Si la lectura falla, sale.

;-------------------------------------------------------------
; write(int fd, void *buf, size_t count);
;-------------------------------------------------------------
file_out:
mov edx, eax ; guardamos en edx la cantidad de bytes leidos por read.
mov eax, 0x04 ; llamada de sistema para write
pop ebx ; Usamos la salida standard 1.
mov ecx, buffer ; movemos el buffer al los argumentos
int 0x80

exit:
mov esp, ebp
pop ebp
ret