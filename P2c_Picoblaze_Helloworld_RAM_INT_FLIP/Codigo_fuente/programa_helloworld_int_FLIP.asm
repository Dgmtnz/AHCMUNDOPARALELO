            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ; CIFRADOR CESAR CON VERIFICACION CRC
            ; Transmision RS-232, 115200bps, 8N1
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            	CONSTANT	rs232, FF
            	CONSTANT	crc_data, 40
            	CONSTANT	crc_reset, 41
            	NAMEREG		s1, txreg
            	NAMEREG		s2, rxreg
		NAMEREG		s3, contbit
		NAMEREG		s4, cont1
		NAMEREG		s5, cont2
		NAMEREG		s6, original
		NAMEREG		s7, crc1
		ADDRESS		00
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            	;Inicio del programa
            	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		DISABLE INTERRUPT
start:		CALL		recibe
		LOAD		S0,00
parte1:		INPUT		txreg,S0
		ADD		txreg,00
		JUMP Z		parte2
		OUTPUT		S0, 3E
		CALL		transmite
		INPUT		S0, 3E
		ADD		S0,01
		JUMP		parte1
parte2:		ENABLE INTERRUPT
bucle1:		LOAD 		S0,09
bucle2:		SUB		S0,01
		JUMP NZ		bucle2
		LOAD		S0,09
		JUMP		bucle2
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            	;Rutina de recepcion
            	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
recibe:		INPUT		rxreg, rs232
		AND		rxreg, 80
		JUMP		NZ, recibe
		CALL		wait_05bit
		LOAD		contbit,09
next_rx:	CALL		wait_1bit
		SR0		rxreg
		INPUT		s0, rs232
		AND		s0, 80
		OR		rxreg, s0
		SUB 		contbit, 01
		JUMP		NZ, next_rx
		RETURN
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            	;Rutina de transmision
            	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
transmite:	LOAD		s0, 00
		OUTPUT		s0, rs232
		CALL		wait_1bit
		LOAD 		contbit, 08
next_tx:	OUTPUT		txreg, rs232
		CALL		wait_1bit
		SR0		txreg
		SUB 		contbit, 01
		JUMP		NZ, next_tx
		LOAD		s0, FF
		OUTPUT		s0, rs232
		CALL		wait_1bit
		RETURN
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            	;Rutinas de espera
            	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wait_1bit:	LOAD 		cont1, 03  
espera2:	LOAD		cont2, 22
espera1:	SUB		cont2, 01
		JUMP		NZ, espera1
		SUB		cont1, 01
		JUMP		NZ, espera2
		RETURN
wait_05bit:	LOAD 		cont1, 03 
espera4:	LOAD		cont2, 10
espera3:	SUB		cont2, 01
		JUMP		NZ, espera3
		SUB		cont1, 01
		JUMP		NZ, espera4
		RETURN
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;Transmitir byte en s0 como hex (2 digitos)
		;Usa RAM[0x3F] para preservar s0
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tx_hex:		OUTPUT		s0, 3F
		LOAD		txreg, s0
		SR0		txreg
		SR0		txreg
		SR0		txreg
		SR0		txreg
		AND		txreg, 0F
		ADD		txreg, 30
		SUB		txreg, 3A
		JUMP		C, tn_num1
		ADD		txreg, 41
		JUMP		tn_out1
tn_num1:	ADD		txreg, 3A
tn_out1:	CALL		transmite
		INPUT		s0, 3F
		LOAD		txreg, s0
		AND		txreg, 0F
		ADD		txreg, 30
		SUB		txreg, 3A
		JUMP		C, tn_num2
		ADD		txreg, 41
		JUMP		tn_out2
tn_num2:	ADD		txreg, 3A
tn_out2:	CALL		transmite
		RETURN
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;Nueva linea
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tx_crlf:	LOAD		txreg, 0D
		CALL		transmite
		LOAD		txreg, 0A
		CALL		transmite
		RETURN
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        	; RUTINA DE INTERRUPCION
        	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
interrup:	DISABLE 	INTERRUPT
		CALL 		recibe
		LOAD		original, rxreg
		CALL		tx_crlf
		; "IN:" + char + " (" + hex + ")"
		LOAD		txreg, 49
		CALL		transmite
		LOAD		txreg, 4E
		CALL		transmite
		LOAD		txreg, 3A
		CALL		transmite
		LOAD		txreg, original
		CALL		transmite
		LOAD		txreg, 20
		CALL		transmite
		LOAD		txreg, 28
		CALL		transmite
		LOAD		s0, original
		CALL		tx_hex
		LOAD		txreg, 29
		CALL		transmite
		CALL		tx_crlf
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		; Validar: solo letras (A-Z, a-z) y digitos (0-9)
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		LOAD		s0, original
		SUB		s0, 30
		JUMP		C, no_alfa
		LOAD		s0, original
		SUB		s0, 3A
		JUMP		C, si_alfa
		LOAD		s0, original
		SUB		s0, 41
		JUMP		C, no_alfa
		LOAD		s0, original
		SUB		s0, 5B
		JUMP		C, si_alfa
		LOAD		s0, original
		SUB		s0, 61
		JUMP		C, no_alfa
		LOAD		s0, original
		SUB		s0, 7B
		JUMP		C, si_alfa
no_alfa:	LOAD		txreg, 45
		CALL		transmite
		LOAD		txreg, 52
		CALL		transmite
		LOAD		txreg, 52
		CALL		transmite
		LOAD		txreg, 21
		CALL		transmite
		CALL		tx_crlf
		JUMP		fin
si_alfa:
		; CRC del original
		LOAD		s0, 00
		OUTPUT		s0, crc_reset
		OUTPUT		original, crc_data
		INPUT		crc1, crc_data
		; "C1:" + hex
		LOAD		txreg, 43
		CALL		transmite
		LOAD		txreg, 31
		CALL		transmite
		LOAD		txreg, 3A
		CALL		transmite
		LOAD		s0, crc1
		CALL		tx_hex
		CALL		tx_crlf
		; CESAR +3
		LOAD		rxreg, original
		CESAR		rxreg, 03
		; "+3:" + char + " (" + hex + ")"
		LOAD		txreg, 2B
		CALL		transmite
		LOAD		txreg, 33
		CALL		transmite
		LOAD		txreg, 3A
		CALL		transmite
		LOAD		txreg, rxreg
		CALL		transmite
		LOAD		txreg, 20
		CALL		transmite
		LOAD		txreg, 28
		CALL		transmite
		LOAD		s0, rxreg
		CALL		tx_hex
		LOAD		txreg, 29
		CALL		transmite
		CALL		tx_crlf
		; CRC del cifrado
		LOAD		s0, 00
		OUTPUT		s0, crc_reset
		OUTPUT		rxreg, crc_data
		; "CE:" + hex
		LOAD		txreg, 43
		CALL		transmite
		LOAD		txreg, 45
		CALL		transmite
		LOAD		txreg, 3A
		CALL		transmite
		INPUT		s0, crc_data
		CALL		tx_hex
		CALL		tx_crlf
		; CESARINV -3
		CESARINV	rxreg, 03
		; "-3:" + char + " (" + hex + ")"
		LOAD		txreg, 2D
		CALL		transmite
		LOAD		txreg, 33
		CALL		transmite
		LOAD		txreg, 3A
		CALL		transmite
		LOAD		txreg, rxreg
		CALL		transmite
		LOAD		txreg, 20
		CALL		transmite
		LOAD		txreg, 28
		CALL		transmite
		LOAD		s0, rxreg
		CALL		tx_hex
		LOAD		txreg, 29
		CALL		transmite
		CALL		tx_crlf
		; CRC del descifrado
		LOAD		s0, 00
		OUTPUT		s0, crc_reset
		OUTPUT		rxreg, crc_data
		; "C2:" + hex
		LOAD		txreg, 43
		CALL		transmite
		LOAD		txreg, 32
		CALL		transmite
		LOAD		txreg, 3A
		CALL		transmite
		INPUT		s0, crc_data
		LOAD		original, s0
		CALL		tx_hex
		CALL		tx_crlf
		; Verificar CRC1 vs CRC2
		LOAD		s0, original
		SUB		s0, crc1
		JUMP		NZ, fail
		LOAD		txreg, 4F
		CALL		transmite
		LOAD		txreg, 4B
		CALL		transmite
		LOAD		txreg, 21
		CALL		transmite
		JUMP		fin
fail:		LOAD		txreg, 45
		CALL		transmite
		LOAD		txreg, 52
		CALL		transmite
		LOAD		txreg, 52
		CALL		transmite
fin:		CALL		tx_crlf
		LOAD		txreg, 2D
		CALL		transmite
		LOAD		txreg, 2D
		CALL		transmite
		LOAD		txreg, 2D
		CALL		transmite
		CALL		tx_crlf
		RETURNI		ENABLE
		ADDRESS		FF
		JUMP		interrup

