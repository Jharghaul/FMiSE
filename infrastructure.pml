// Anzahl der Knoten im Ring
#define N 5

// die Nachrichtentypen
mtype = {initiate, winner};

// die Kommunikationskanaele zw. den Knoten
chan pipes[N] = [2] of {mtype, byte}; 

// Winner Node number
byte wnr;

// Checks whether a random node i can terminate sometimes
byte ran;

// Ghostvariable checks whether the i-node terminates
byte ghost[N];

proctype node(chan left; chan right; byte nodeNr)  {
   // wird auf wahr gesetzt, falls dieser Knoten als Koordinator gewaehlt wird
   bool mewinner   = false;
   // enthält am Ende die Knotennummer (nodeNr) des gewaehlten Koordinators
   byte winnerNode = 0;
   mtype msg;
   byte nr;
   //TODO: Implementierung des Algorithmus
   left ! initiate,nodeNr;
   
   receive:
   pipes[nodeNr] ? msg,nr;
   if
    :: msg == winner -> 
      atomic{
        mewinner = false; winnerNode = nr; 
        left ! winner,winnerNode; 
        goto finish 
      }
    :: else ->
      if
        :: nr < nodeNr -> goto receive
        :: nr > nodeNr -> atomic{ left ! msg,nr ; goto receive } // Sends received message to left node and continues receiving message from right node
        :: else ->  atomic {
                      mewinner = true; winnerNode = nodeNr; // Finds out the winner
                      wnr = nodeNr ; // Assigns wnr by number of current node (nodeNr)
                      left ! winner,nodeNr; goto finish // Sends message of winner to left node and finishs then
                    }
      fi   
   fi
   
   finish:
   if
    :: nodeNr == winnerNode -> pipes[nodeNr] ? _,_
    :: else
   fi
   // Prints to console the finished node
   //atomic {printf("finished node %d\n with winner = %d \n", nodeNr,winnerNode)}

   // nodeNr-node terminates -> ghost[nodeNr] is assigned by 1 
   ghost[nodeNr] = 1;

   // Checks: if a node is marked as winner (mewinner), then its nodeNr assigns to winnerNode
   assert( !mewinner || winnerNode == nodeNr);

   // Checks whether all nodes have the same winnerNode
   assert( winnerNode == wnr);
}


init {
  // the permutation of nodes
  byte permutation[N];
  bool used[N];
  byte count = 0;
  byte index;
  printf("Zu implementieren")
  // Strategy: Each loop a index is randomly took out. After that loop is these index removed from avaible elements for next loop
  //           Repeats till permutation is filled (count == N)
  do
    :: count < N -> 
        select(index : 1 .. N-count);
        byte tmp = 0;
        do
          :: 1 <= index -> 
            if
              :: !used[tmp] -> index--;tmp++
              :: else -> tmp++
            fi
          :: else -> used[tmp-1] = true; permutation[count] = tmp-1; break
        od
        count++     
    :: else -> break
  od

  // print the permutation
  /*int l;
  for(l: 0 .. N-1){
    printf("%d : node %d",l,permutation[l])
  }*/

  // runs all processes node 
  atomic{
    byte i;
    for(i: 0 .. N-1){
      run node( pipes[permutation[(N+i-1)%N]] , pipes[permutation[(N+i+1)%N]] , permutation[i] )
    }
  }

  // selects random index to check
  select(ran : 0 .. N-1)
}

ltl t {<>(ghost[ran]==1)}
