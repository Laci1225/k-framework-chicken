    module CHICKEN-SYNTAX
        imports INT
        imports LIST

        syntax Token ::= "chicken" [token]
        syntax NL ::= ";" [token]
        syntax Chickens ::= Token Chickens | Token | ".Empty"
        syntax Line ::= Chickens NL
        syntax Program ::= Line | Program Line


    endmodule
