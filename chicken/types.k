requires "syntax.k"

module CHICKEN-TYPES
  imports INT
  syntax Op ::= "PUSH_ONE" | "ADD" | "SUB" | "MUL" | "EQ"
                  | "LOAD" | "STORE" | "JUMP" | "CHAR" | PushInt
  syntax PushInt ::= "PUSH" Int
  //syntax String ::= chrChar(Int) [function, hook(STRING.chr)]


  syntax Op ::= intToOp(Int) [function]
  rule intToOp(1) => PUSH_ONE
  rule intToOp(2) => ADD
  rule intToOp(3) => SUB
  rule intToOp(4) => MUL
  rule intToOp(5) => EQ
  rule intToOp(6) => LOAD
  rule intToOp(7) => STORE
  rule intToOp(8) => JUMP
  rule intToOp(9) => CHAR
  rule intToOp(N:Int) => PUSH (N -Int 10) requires N >=Int 10

endmodule
