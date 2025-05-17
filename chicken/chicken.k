requires "syntax.k"
requires "types.k"
requires "domains.md"

module CHICKEN
    imports CHICKEN-SYNTAX
    imports CHICKEN-TYPES
    imports STRING-BUFFER
    imports K-EQUAL
    imports BOOL
    imports LIST
    imports INT

    configuration <T>
           <k> $PGM:ChickenList </k>
           <state>
               <ip> 0 </ip>
               <stack> .List </stack>
               <output> "" </output>
               <running> true </running>
               <program> .List </program>
               <input> .List </input>

           </state>
       </T>

    rule <k> CL:ChickenList => .K ...</k>
             <program> _ => convertToOps(CL) </program>

    rule <k> .K </k>
             <ip> I => I +Int 1 </ip>
             <program> OPS </program>
              <stack> S => execute(getOp(OPS, I), S) </stack>
             <output> OUT => #if getOp(OPS, I) ==K CHAR
                                #then OUT +String chrChar(getInt(S, 0))
                                #else OUT #fi </output>
          requires I <Int size(OPS)
                 [priority(40)]


    rule <k> .K </k>
             <ip> I => I +Int 2 </ip>
             <program> OPS </program>
             <stack> ListItem(INDEX:Int) STACK => ListItem({STACK[INDEX]}:>Int) STACK </stack>
          requires I +Int 1 <Int size(OPS)
                   andBool getOp(OPS, I) ==K LOAD
                   andBool getOp(OPS, I +Int 1) ==K PUSH 0
                   andBool INDEX >=Int 0
                   andBool INDEX <Int size(STACK)
                 [priority(50)]


        // LOAD from input (source 1)
        rule <k> .K </k>
                 <ip> I => I +Int 2 </ip>
                 <program> OPS </program>
                 <input> ListItem(IN:Int) REST => REST </input>
                 <output> OUT => OUT +String "Input: " +String Int2String(IN) </output>
                 <stack> S => ListItem(IN) S </stack>
                requires I +Int 1 <Int size(OPS)
                       andBool getOp(OPS, I) ==K LOAD
                       andBool getOp(OPS, I +Int 1) ==K PUSH 1
                [priority(50)]


    syntax List ::= convertToOps(ChickenList) [function]
    rule convertToOps(.ChickenList) => .List
    rule convertToOps((C:Chickens ;) CL:ChickenList) => ListItem(chickensToOp(C)) convertToOps(CL)

    syntax List ::= updateAtIndex(List, Int, Int) [function]
    rule updateAtIndex(.List, _, _) => .List
    rule updateAtIndex(ListItem(_) REST, 0, V) => ListItem(V) REST
    rule updateAtIndex(ListItem(H) REST, I, V)
      => ListItem(H) updateAtIndex(REST, I -Int 1, V)
      requires I >Int 0

    syntax Op ::= getOp(List, Int) [function]
    syntax Int ::= getInt(List, Int) [function]

    rule getOp(L:List, I:Int) => {L[I]}:>Op
    rule getInt(L:List, I:Int) => {L[I]}:>Int

    syntax List ::= execute(Op, List) [function]
    rule execute(PUSH_ONE, S) => ListItem("chicken") S
    rule execute(PUSH N:Int, S) => ListItem(N) S
    rule execute(ADD, ListItem(A:Int) ListItem(B:Int) S) => ListItem(A +Int B) S
    rule execute(SUB, ListItem(A:Int) ListItem(B:Int) S) => ListItem(A -Int B) S // B -Int A?
    rule execute(MUL, ListItem(A:Int) ListItem(B:Int) S) => ListItem(A *Int B) S
    rule execute(EQ, ListItem(A:Int) ListItem(B:Int) S) => ListItem(A ==Int B) S
    rule execute(LOAD, S) =>  S [owise]
    rule execute(STORE, ListItem(I:Int) ListItem(V:Int) REST)
      => updateAtIndex(REST, I, V)
      requires I >=Int 0 andBool I <Int size(REST)
    rule execute(JUMP, S) => S
    rule execute(CHAR, ListItem(A:Int) S) => ListItem(chrChar(A)) S


    rule <k> .K </k>
             <ip> I </ip>
             <program> OPS </program>
             <running> true => false </running>
             <output> OUT => OUT +String "Program finished" </output>
          requires I >=Int size(OPS)


    syntax Int ::= countChickens(Chickens) [function]
    rule countChickens(.Empty) => 0
    rule countChickens(chicken C:Chickens) => 1 +Int countChickens(C)
    rule countChickens(chicken) => 1

    syntax Op ::= chickensToOp(Chickens) [function]
    rule chickensToOp(C:Chickens) => intToOp(countChickens(C))

endmodule