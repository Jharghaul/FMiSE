// Anzahl der Knoten im Ring
#define N 5

// die Nachrichtentypen
mtype = {initiate, winner};

// die Kommunikationskanaele zw. den Knoten
chan pipes[N] = [2] of {mtype, byte}; 

// Ghostvariable checks whether the i-node terminates
//int ghost[N];
//int tung;
// Winner Node number
int wnr;

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
   //ghost[nodeNr] = 1;

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
  // Strategy: Each loop a index is randomly took out. After that loop is these index removed from avaible elements for next loop
  //           Repeats till permutation is filled (count == N)
  do
    :: count < N -> 
        select(index : 0 .. N-1-count);
        int tmp = 0;
        do
          :: 0 <= index -> 
            if
              :: !used[tmp] -> index--;tmp++
              :: else -> tmp++
            fi
          :: else -> used[tmp-1] = true; permutation[count] = tmp-1; break
        od
        count++     
    :: else -> break
  od

  // runs all processes node 
  atomic{
    int i;
    for(i: 0 .. N-1){
      run node( pipes[permutation[(N+i-1)%N]] , pipes[permutation[(N+i+1)%N]] , permutation[i] )
    }
  }
}

// Checks whether a random node i can terminate sometimes
//select(tung: 0..N-1)
//ltl t {<>(ghost[tung]==1)}
