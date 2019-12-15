// Anzahl der Knoten im Ring
#define N 6

// Winner Node number
byte wnr;

// Checks whether a random node i can terminate sometimes
byte ran;

// Ghostvariable checks whether the i-node terminates
byte ghost[N];

// If a i-node is winner, then meWin[i] = true
bool meWin[N];

byte wNode[N];

active proctype verification(){
  // selects random index to check
  select(ran : 0 .. N-1);

  // Checks: if a node is marked as winner, then its nodeNr should be wnr
  assert(!meWin[ran] || ran == wnr-1)
}

// Checks whether all nodes have the same winnerNode (N-1) after termination
ltl t1 {<>(wNode[ran] == N)}

// Checks whether all nodes terminate sometimes
ltl t0 {<>(ghost[ran]==1)}
