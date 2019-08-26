Stack_Size      EQU     0x00000400

                AREA    STACK, NOINIT, READWRITE, ALIGN=3
Stack_Mem       SPACE   Stack_Size
__initial_sp


Heap_Size       EQU     0x00000C00

                AREA    HEAP, NOINIT, READWRITE, ALIGN=3
__heap_base
Heap_Mem        SPACE   Heap_Size
__heap_limit


; Vector Table Mapped to Address 0 at Reset

                PRESERVE8
                THUMB

                AREA    RESET, DATA, READONLY
                EXPORT  __Vectors

__Vectors       DCD     __initial_sp              ; Top of Stack(MSP)
                DCD     Reset_Handler             ; Reset Handler
                DCD     0				; NMI(Non-Maskable Interrupt)
                DCD     0				; HardFault
                DCD     0				; MemManage
                DCD     0				; bus fault
                DCD     0				; usage fault
                DCD     0				; reserved
                DCD     0				; reserved
                DCD     0				; reserved
                DCD     0				; reserved
                DCD     0				; SVC
                DCD     0				; debug
                DCD     0				; reserved
                DCD     0				; PendSV
                DCD     0				; systick

                ; External Interrupts
                DCD     external_int0_handler		; INT button up
                DCD     external_int1_handler		; INT button down
                DCD     external_int2_handler		; INT button left
                DCD     external_int3_handler		; INT button right
                DCD     external_int4_handler		; INT button center
                DCD     external_int5_handler		; uart interrupt
                DCD     0		; INT6
                DCD     0		; INT7
                DCD     0		; INT8
                DCD     0		; INT9
                DCD     0		; INT10
                DCD     0		; INT11
                DCD     0		; INT12
                DCD     0		; INT13
                DCD     0		; INT14
                DCD     0		; INT15

                AREA    |.text|, CODE, READONLY

; Reset Handler

Reset_Handler   PROC
                EXPORT  Reset_Handler
                ENTRY
				
				ldr r0, =0x40000000
				ldr r1, =0x55
				str r1, [r0]
				
				ldr r0, =0x10
Loop			subs r0, r0, #1
				bne Loop
				
				ldr r0, =0x40000000
				ldr r1, =0xAA
				str r1, [r0]				
				
                IMPORT  __main
                LDR     R0, =__main
                BX      R0                  ; Branch to __main
                ENDP

                ALIGN   4                   ; Align to a word boundary
					
Defualt_handler	PROC
				
				EXPORT external_int0_handler	[weak]
				EXPORT external_int1_handler	[weak]
				EXPORT external_int2_handler	[weak]
				EXPORT external_int3_handler	[weak]
				EXPORT external_int4_handler	[weak]
				EXPORT external_int5_handler	[weak]
external_int0_handler
external_int1_handler
external_int2_handler
external_int3_handler
external_int4_handler
external_int5_handler
				B		.
                ENDP
				
				ALIGN

; User Initial Stack & Heap

                IF      :DEF:__MICROLIB

                EXPORT  __initial_sp
                EXPORT  __heap_base
                EXPORT  __heap_limit

                ELSE

                IMPORT  __use_two_region_memory
                EXPORT  __user_initial_stackheap

__user_initial_stackheap PROC
                LDR     R0, =  Heap_Mem
                LDR     R1, =(Stack_Mem + Stack_Size)
                LDR     R2, = (Heap_Mem +  Heap_Size)
                LDR     R3, = Stack_Mem
                BX      LR
                ENDP

                ALIGN

                ENDIF

				END
