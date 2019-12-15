// Anzahl der Knoten im Ring
#define N 5

// die Nachrichtentypen
mtype = {initiate, winner};

// die Kommunikationskanaele zw. den Knoten
chan pipes[N] = [2] of {mtype, byte}; 

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
      run node( pipes[i] , pipes[(i+1)%N] , permutation[i]+1 )
    }
  }
}
