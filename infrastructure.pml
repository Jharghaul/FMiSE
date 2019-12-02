// Anzahl der Knoten im Ring
#define N 3

// die Nachrichtentypen
mtype = {initiate, winner};

// die Kommunikationskanaele zw. den Knoten
chan pipes[N] = [2] of {mtype, byte}; 

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
   right ? msg,nr;
   if
    :: msg == winner -> mewinner = false; winnerNode = nr; left ! winner,winnerNode; goto finish 
    :: else ->
      if
        :: nr < nodeNr -> goto receive
        :: nr > nodeNr -> left ! msg,nr ; goto receive // Sends received message to left node and continues receiving message from right node
        :: else ->  mewinner = true; winnerNode = nodeNr; // Finds out the winner
                    wnr = nodeNr ; // Assigns wnr by number of current node (nodeNr)
                    left ! winner,nodeNr; goto finish // Sends message of winner to left node and finishes then
      fi   
   fi
   
   finish:

   // Prints to console the finished node
   printf("finished node %d", nodeNr);

   // nodeNr-node terminates -> ghost[nodeNr] is assigned by 1 
   ghost[nodeNr] = 1;

   // Checks: if a node is marked as winner (mewinner), then its nodeNr assigns to winnerNode
   assert( !mewinner || winnerNode == nodeNr);

   // Checks whether all nodes have the same winnerNode
   assert( winnerNode == wnr);
}


init {
  // the permutation of nodes
  int permutation[N];

  bool used[N];
  int count = 0;
  int index;
  printf("Zu implementieren")
  // Strategy: Each loop a index in range [0,N-1] is took out. 
  //           If these index is already avaible in permutation, then tries again. Otherwise saves these index in permutation[count].
  //           Repeats till permutation is filled (count == N)
  do
    :: count < N -> 
      { 
        again:
        select(index : 0..N-1);
        if
          :: !used[index] -> used[index] = true; permutation[count] = index; count++
          :: else -> goto again
        fi
      }   
    :: else -> break
  od

  // runs all processes node 
  for(int i: 0..N-1){
    run node( pipes[permutation[(i-1)%N]] , pipes[permutation[(i+1)%N]] , permutation[i] )
  }
}

// Ghostvariable checks whether the i-node terminates
int ghost[N];
int i;
// Winner Node number
int wnr;

// Checks whether a random node i can terminate sometimes
select(i: 0..N-1)
ltl t {<>(ghost[i]==1)}
