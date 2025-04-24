module CHICKEN-SYNTAX
    imports INT

    syntax Token ::= "chicken" [token]
    syntax Chickens ::= Token Chickens | Token | ".Empty"
    syntax Line ::= Chickens
    syntax Program ::= Line
endmodule
