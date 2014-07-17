; squence_leds.asm
; This program will sequences the leds on all the output GPIOs of the PIC12F629
; Copyright EJ Devices 2014 (http://www.ejdevices.com)
; 



	list	p=12F629
	radix	dec
	include	"p12f629.inc"

; Use all the PGIO pins by disabling the reset pin and using the internal oscillator
	__CONFIG	_MCLRE_OFF & _CP_OFF & _WDT_OFF & _INTRC_OSC_NOCLKOUT 

	
; globals
_delayA		equ	26h
_delayB		equ	27h
_delayC		equ	28h

; GPIO bits	
GP0		equ	0	;GP0  output to LED
GP1	 	equ	1	;GP1
GP2		equ	2	;GP2
GP3		equ	3	;GP3
GP4		equ	4	;GP4
GP5		equ	5	;GP5
		

; Start the program at offset 0
Start	org	0x0000		

		
SetUp	
    bcf     STATUS, RP0	;bank 0
    clrf 	GPIO       	;Clear GPIO of junk
	movlw   0x07
    movwf   CMCON       ;comparator off =111
    bsf     STATUS, RP0 ;Bank 1
    movlw	b'00001000'	;Set GP0,1,2,4,5 as output, note that for the PIC12F629 GP3 is input only
	movwf	TRISIO
		
    movlw	b'10000110'	;Turn off T0CKI, prescale for TMR0 = 1:128
	movwf	OPTION_REG


    ;calibrating the internal oscillator
	call	0x3ff		;get the calibration value
	movwf	OSCCAL		;calibrate oscillator
	bcf     STATUS, RP0	;bank 0

    ; intialise delay register files
    clrf    _delayA
    clrf    _delayB
    clrf    _delayC

	; sequence the LED's turning them off and on with a delay in between
LED
	bsf     GPIO,GP0		;turn on LED1
	call    Delay
	bcf     GPIO,GP0		;turn off LED1
    bsf     GPIO,GP1        ;turn on LED2
	call    Delay
    bcf     GPIO,GP1		;turn off LED2
    bsf     GPIO,GP2        ;turn on LED3
	call    Delay
    bcf     GPIO,GP2		;turn off LED3
    bsf     GPIO,GP4        ;turn on LED4
	call    Delay
    bcf     GPIO,GP4		;turn off LED4
    bsf     GPIO,GP5        ;turn on LED5
	call    Delay
    bcf     GPIO,GP5        ;turn off LED5
    bsf     GPIO,GP4        ;turn on LED4
	call    Delay
    bcf     GPIO,GP4        ;turn off LED4
    bsf     GPIO,GP2        ;turn on LED3
	call    Delay
    bcf     GPIO,GP2        ;turn off LED3
    bsf     GPIO,GP1        ;turn on LED2
	call    Delay
    bcf     GPIO,GP1        ;turn off LED2
	goto    LED

	
	
	;delay a period
Delay
    movlw   01h
	movwf   _delayC
Delay_loop
	decfsz  _delayA, 1
	goto    Delay_loop
	decfsz  _delayB, 1
	goto    Delay_loop
	decfsz  _delayC, 1
	goto    Delay_loop
	return
		
	

		
    ; internal oscillator calibration
    ; A good PIC programmer will ignore this instruction and not program the device with it
    ; The PIC12F629 comes preprogrammed with the oscillator calibration value at address 0x3FF
    ; This value should not be overwritten. 
    ; The return value of 0x20 is nominal and will vary depending on the device
	org     0x3ff
	retlw	0x20
		
    ; all assembly files end with 'end' to tell the compiler that the end of the file has been reached
	end
		

	
	