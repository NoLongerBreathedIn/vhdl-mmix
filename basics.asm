	;; Expects ALUY to contain any extra bits to or into rX.
gen_trap:
	MVO ALUZ rX
	SET ALUS OR
	SET SRS rXX
	MVO SDR ALUX
	SET SRS rYY
	MVO SDR rY
	SET SRS rZZ
	MVO SDR rZ
	SET SRS rWW
	MVO SDR IP
	SET SRS rBB
	SET GRS 0xFF
	MVO SDR GDR
	SET SRS rJ
	MVO GDR SDR
	POP
dytrap:
	BUN 1 DYTRP
	POP
	SET SRS rQ
	MVO ALUY SDR
	SET SRS rK
	MVO ALUZ SDR
	CLO SDR
	SET ALUS AND
	MVO ALUY ALUX
	CLO ALUZ
	SET ALUZ.3 0xFF
	MVO ALUY ALUX
	PGO gen_trap
	SET SRS rTT
	MVO IP SDR
	PGO fetch
cause_r:
	BIF 1 rKr
	POP
	AST rQr
	PGO dytrap
cause_w:
	BIF 1 rKw
	POP
	AST rQw
	PGO dytrap
cause_x:
	BIF 1 rKx
	POP
	AST rQx
	PGO dytrap
cause_n:
	BIF 1 rKn
	POP
	AST rQn
	PGO dytrap
cause_k:
	BIF 1 rKk
	POP
	AST rQk
	PGO dytrap
cause_b:
	BIF 1 rKb
	POP
	AST rQb
	PGO dytrap
cause_s:
	AST rQs
	PGO dytrap
cause_p:
	BIF 1 rKp
	POP
	AST rQp
	PGO dytrap
	
	;; Input in u19 and ALUY (assumed equal). Output in TCKR.
determine_pte_key:
	MVW PTW Vnf
	BIF 1 PTPW
	PGO cause_p
	BIF 1 PTPR
	PGO cause_p
	CLO ALUZ
	MVB ALUZ.7 Vs
	SET ALUS SR
	MVO ALUY ALUX
	SET ALUS SL
	MVO ALUY ALUX
	MVW PTW u19.l
	MVW ALUZ.l PTN
	SET ALUS OR
	MVO TCKR ALUX
	POP
	;; Same as lookup_check_ptp, except doesn't shift right,
	;; and leaves in ALUY.
lookup_check_pt:
	MVO ALUY ALUX
	SET ALUZ.7 13
	SET ALUS SL
	MVO ALUY ALUX
	MVW ALUZ.l u20.l
	SET ALUS OR
	MVO MAR ALUX
	AST MEMRDD
	MVW ALUZ.l u21.l
	SET ALUS SUB
	CLO ALUY
	BIF -1 MEMNF
	MVW ALUY.l MDR.l
	MVO ALUY ALUX
	BIF 1 ALUZR
	PGO cause_p
	MVO ALUY MDR
	POP
	;; Put 10 bits in u20.l (wyde). Put upper bits shifted right in ALUX.
	;; Reads PTP, checks n is correct, puts it (shifted right) in ALUX.
	;; Expects n in u21.l (wyde).
lookup_check_ptp:
	PGO lookup_check_pt
	CLO ALUZ
	BIF 1 ALUN
	PGO cause_p
	SET ALUZ.7 13
	SET ALUS SRU
	POP
	
	;; Input in u19. Output in TCVR.
determine_pte:
	MVO ALUY u19
	CLO ALUZ
	SET ALUZ.0 0xE0
	SET ALUS ANDN
	MVO ALUY ALUX
	CLO ALUZ
	MVB ALUZ.7 Vs
	SET ALUS SR
	MVO B210W ALUX
	MVB CND u19.0
	CLO ALUY
	BIF 7 CND1
	BIF 3 CND2
	MVB ALUY.7 Vb1
	SET ALUZ.7 0
	BUN 9 FALS
	MVB ALUY.7 Vb2
	MVB ALUZ.7 Vb1
	BUN 6 FALS
	BIF 3 CND2
	MVB ALUY.7 Vb3
	MVB ALUZ.7 Vb2
	BUN 2 FALS
	MVB ALUY.7 Vb4
	MVB ALUZ.7 Vb3
	SET ALUS SUB
	MVB GRS ALUY.7
	MVO ALUY ALUX
	BUN 1 ALUN
	PGO cause_p
	CLT ALUY.h
	CLO ALUZ
	MVB ALUZ.7 GRS
	MVT ALUY.l Vr
	SET ALUS ADD
	MVO u20 ALUX
	MVW PTW Vnf
	MVW u21.l PTN
	MVB CND ALUY.7
	MVW ALUY.l B210A
	BIF 8 ALUZR 		; to the MVW ALUY.l B210B
	BIF 4 CND4
	BUN 2 CND5
	BIF 2 CND6
	BIF 1 CND7
	PGO cause_p
	MVO ALUY u20
	SET ALUZ.7 4
	BUN 37 FALS		; to the MVW u20.l B210A
	MVW ALUY.l B210B
	BIF 6 ALUZR		; to the MVW ALUY.l B210C
	BIF 2 CND4
	BIF 1 CND5
	PGO cause_p
	MVO ALUY u20
	SET ALUZ.7 3
	BUN 31 FALS		; to the MVW u20.l B210B
	MVW ALUY.l B210C
	BIF 8 ALUZR     	; to the MVW ALUY.l B210D
	BIF 4 CND4
	BIF 3 CND5
	BUN 1 CND6
	BIF 1 CND7
	PGO cause_p
	MVO ALUY u20
	SET ALUZ.7 2
	BUN 23 FALS 		; to the MVW u20.l B210C
	MVW ALUY.l B210D
	BIF 7 ALUZR		; to the MVW ALUY.l B210E
	BIF 3 CND4
	BIF 2 CND5
	BIF 1 CND6
	PGO cause_p
	MVO ALUY u20
	SET ALUZ.7 1
	BUN 16 FALS		; to the MVW u20.l B210D
	MVW ALUY.l B210E
	BIF 5 ALUZR
	BIF 4 CND4
	BIF 3 CND5
	BIF 2 CND6
	BIF 1 CND7
	PGO cause_p
	MVO ALUY u20
	SET ALUZ.7 0
	BUN 8 FALS 		; to the MVW u20.l B210E
	MVW u20.l B210A
	PGO lookup_check_ptp
	MVW u20.l B210B
	PGO lookup_check_ptp
	MVW u20.l B210C
	PGO lookup_check_ptp
	MVW u20.l B210D
	PGO lookup_check_ptp
	MVW u20.l B210E
	PGO lookup_check_pt
	MVB ALUY.0 ALUY.7
	CLO ALUZ
	MVB ALUZ.7 Vs
	SET ALUS SRU
	MVO ALUY ALUX
	SET ALUS SL
	MVO ALUY ALUX
	SET ALUZ.7 5
	MVO ALUY ALUX
	SET ALUZ.7 5
	SET ALUS SRU
	MVB CND ALUX.0
	SET ALUZ.7 15
	MVO ALUY ALUX
	CLW ALUY.h
	MVB ALUZ.7 CND
	SET ALUS OR
	MVO TCVR ALUY
	POP
	;; Input in u19 and ALUY (assumed equal). Output in TCVR.
determine_pte_x:
	PGO determine_pte_key
	BUN 2 TCIKK
	AST TCIR
	POP
	MVW PTW Vnf
	BIF 3 PTPX
	SET rX.0 3
	MVO rY u19
	PGO dytrap
	PGO determine_pte
	AST TCIW
	POP
determine_pte_rw:
	PGO determine_pte_key
	BUN 2 TCDKK
	AST TCDR
	POP
	MVW PTW Vnf
	BIF 3 PTPX
	SET rX.0 3
	MVO rY u19
	PGO dytrap
	PGO determine_pte
	AST TCDW
	POP
