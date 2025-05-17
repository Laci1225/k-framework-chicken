module CHICKEN-SYNTAX
    syntax Token ::= "chicken" [token]
    syntax Chickens ::= Token Chickens | Token | ".Empty"
    syntax Line ::= Chickens ";"
    syntax ChickenList ::= List{Line, ""}
endmodule
