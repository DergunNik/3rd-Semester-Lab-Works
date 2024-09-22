 ; $7950 HY     |
 ; $7951 LY     | X 
 ; $7952 HX  |   *  
 ; $7953 LX  |      Y
 ; $7954 (LX *
 ; $7955    LY)
 ; $7956 (HX *     +
 ; $7957    HY)    +
 ; $7958 (HX *
 ; $7959    LY)
 ; $795A (LX *
 ; $795B    HY)
 ; $795C (LX * HY) +
 ; $795D +     +
 ; $795E (HX * LY) -


 org $8000
 stx $7950
 sty $7952

 ; LX * LY 
 ldaa $7951
 ldab $7953
 mul
 std $7954

 ; HX * HY 
 ldaa $7950
 ldab $7952
 mul
 std $7956

 ; HX * LY 
 ldaa $7951
 ldab $7952
 mul
 std $7958

 ; LX * HY 
 ldaa $7950
 ldab $7953
 mul
 std $795a

 ; LX * HY + HX * LY 
 ; L(LX * HY) + L(HX * LY)
 ldab $795b
 clra
 std $795d
 ldab $7959
 addd $795d
 std $795d
 ; H(LX * HY) + H(HX * LY) + H(L(LX * HY) + L(HX * LY))
 ldaa $7958
 ldab $795a
 aba
 tab
 ldaa #0
 adca #0
 xgdx
 ldab $795d
 abx
 stx $795c
 
 ; (HX * HY) + !L(LX * HY + HX * LY)
 ; L(HX * HY) + L(!L(LX * HY + HX * LY))
 ldab $795d
 clra
 std $795f
 ldab $7957
 addd $795f
 std $795f
 ; H(HX * HY) + H(!L(LX * HY + HX * LY)) + H(L(HX * HY) + L(!L(LX * HY + HX * LY)))
 ldaa $7956
 ldab $795 
 aba
 tab
 ldaa #0
 adca #0
 xgdx
 ldab $795f
 abx
 stx $795c
 
 ; X * Y
 stx $7950
 ldab $795e
 stab $7952
 ldab $7955
 stab $7953