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
               <input> ListItem(1) ListItem(0) ListItem(2) </input>

           </state>
       </T>

    rule <k> CL:ChickenList => .K ...</k>
             <program> _ => convertToOps(CL) </program>

    syntax String ::= opToString(Op)  [function, total, hook(STRING.token2string)]

    syntax List ::= removeAt(List, Int) [function]
    rule removeAt(ListItem(_) REST, 0) => REST
    rule removeAt(ListItem(HEAD) TAIL, Ix) => ListItem(HEAD) removeAt(TAIL, Ix -Int 1)
            requires Ix >Int 0

    // LOAD from stack (source 0)
     rule <k> .K </k>
              <ip> I => I +Int 2 </ip>
              <program> OPS </program>
              <output> OUT => OUT +String "Load stack[" +String Int2String(Ix) +String "]" </output>
              <stack> ListItem(Ix:Int) REST => ListItem(getStackVal(REST, Ix)) removeAt(REST, Ix) </stack>
              requires I <Int size(OPS)
                    andBool getOp(OPS, I) ==K LOAD
                    andBool getOp(OPS, I +Int 1) ==K EXIT
             [priority(50)]

    // LOAD from input (source 1)
     rule <k> .K </k>
              <ip> I => I +Int 2 </ip>
              <program> OPS </program>
              <output> OUT => OUT +String "Input: " +String Int2String(getInt(INList, Ix)) </output>
              <stack> ListItem(Ix:Int) S => ListItem(getInt(INList, Ix)) S </stack>
              <input> INList </input>
              requires I <Int size(OPS)
                    andBool getOp(OPS, I) ==K LOAD
                    andBool getOp(OPS, I +Int 1) ==K CHICKEN
             [priority(50)]

     rule <k> .K </k>
          <ip> I => I +Int OFFSET </ip>
          <program> OPS </program>
          <stack> ListItem(OFFSET:Int) ListItem(CONDITION:Bool) REST => REST </stack>
       requires I <Int size(OPS)
            andBool getOp(OPS, I) ==K JUMP
            andBool CONDITION ==Bool true
       [priority(45)]


     rule <k> .K </k>
          <ip> I => I +Int 1 </ip>
          <program> OPS </program>
          <stack> ListItem(_) ListItem(CONDITION:Bool) REST => REST </stack>
       requires I <Int size(OPS)
            andBool getOp(OPS, I) ==K JUMP
            andBool CONDITION ==Bool false
       [priority(45)]


    //rule <k> .K </k>
    //     <ip> I => #if isTruthy(COND) #then I +Int OFFSET #else I +Int 1 #fi </ip>
    //     <program> OPS </program>
    //     <stack> ListItem(OFFSET:Int) ListItem(COND:StackVal) REST => REST </stack>
    //     requires I <Int size(OPS)
    //           andBool getOp(OPS, I) ==K JUMP
    //     [priority(45)]

    rule <k> .K </k>
             <ip> I => I +Int 1 </ip>
             <program> OPS </program>
             <stack> S => execute(getOp(OPS, I), S) </stack>
             <output> OUT => #if getOp(OPS, I) ==K CHAR
                                #then OUT +String chrChar(getInt(S, 0))
                                #else OUT #fi </output>
          requires I <Int size(OPS)
                  andBool getOp(OPS, I) =/=K LOAD
                  andBool getOp(OPS, I) =/=K JUMP
                 [priority(40)]







    syntax List ::= convertToOps(ChickenList) [function]
    rule convertToOps(.ChickenList) => .List
    rule convertToOps((C:Chickens ;) CL:ChickenList) => ListItem(chickensToOp(C)) convertToOps(CL)

    syntax List ::= updateAtIndex(List, Int, StackVal) [function]
    rule updateAtIndex(.List, _, _) => .List
    rule updateAtIndex(ListItem(_) REST, 0, V) => ListItem(V) REST
    rule updateAtIndex(ListItem(H) REST, I, V)
      => ListItem(H) updateAtIndex(REST, I -Int 1, V)
      requires I >Int 0

    syntax Op ::= getOp(List, Int) [function]
    syntax Int ::= getInt(List, Int) [function]

    rule getOp(L:List, I:Int) => {L[I]}:>Op
    rule getInt(L:List, I:Int) => {L[I]}:>Int

    syntax StackVal ::= Int | String
    syntax StackVal ::= getStackVal(List, Int) [function]
    rule getStackVal(ListItem(V:StackVal) _, 0) => V
    rule getStackVal(ListItem(_) TAIL, I) => getStackVal(TAIL, I -Int 1)
         requires I >Int 0

    syntax List ::= execute(Op, List) [function]
    rule execute(CHICKEN, S) => ListItem("chicken") S
    rule execute(PUSH N:Int, S) => ListItem(N) S
    rule execute(ADD, ListItem(A:Int) ListItem(B:Int) S) => ListItem(B +Int A) S
    rule execute(ADD, ListItem(A:String) ListItem(B:String) S) => ListItem(B +String A) S
    rule execute(SUB, ListItem(A:Int) ListItem(B:Int) S) => ListItem(B -Int A) S // A -Int B?
    rule execute(MUL, ListItem(A:Int) ListItem(B:Int) S) => ListItem(B *Int A) S
    rule execute(EQ, ListItem(A:Int) ListItem(B:Int) S) => ListItem(B ==Int A) S
    rule execute(STORE, ListItem(I:Int) ListItem(V:StackVal) REST)
              => updateAtIndex(REST, I, V)
              requires I >=Int 0 andBool I <Int size(REST)
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