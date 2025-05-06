requires "syntax.k"
requires "types.k"

module CHICKEN
    imports CHICKEN-SYNTAX
    imports CHICKEN-TYPES
    imports INT
    imports BOOL
    imports LIST

    configuration <T>
         <k> $PGM:Program </k>
         <stack> .List </stack>
         <pc> 0 </pc>
    </T>

     rule <k> P:Program L:Line => P ~> L ... </k>
     rule <k> C:Chickens ; => chickensToOp(C) ... </k>
          <pc> PC => PC +Int 1 </pc>



    rule <k> PUSH_ONE => .K ... </k>
         <stack> S => ListItem(1) S </stack>

    rule <k> PUSH N => .K ... </k>
         <stack> S => ListItem(N) S </stack>

    rule <k> ADD => .K ... </k>
         <stack> ListItem(A:Int) ListItem(B:Int) S => ListItem(A +Int B) S </stack>

    rule <k> SUB => .K ... </k>
         <stack> ListItem(A:Int) ListItem(B:Int) S => ListItem(A -Int B) S </stack>

    rule <k> MUL => .K ... </k>
         <stack> ListItem(A:Int) ListItem(B:Int) S => ListItem(A *Int B) S </stack>

        rule <k> CHAR => .K ... </k>
             <stack> ListItem(A:Int) S => ListItem(chrChar(A)) S </stack>

    syntax Int ::= countChickens(Chickens) [function]
    rule countChickens(.Empty) => 0
    rule countChickens(chicken C:Chickens) => 1 +Int countChickens(C)
    rule countChickens(chicken) => 1

    syntax Op ::= chickensToOp(Chickens) [function]
    rule chickensToOp(C:Chickens) => intToOp(countChickens(C))

endmodule