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

// If a i-node is winner, then meWin[i] = true
bool meWin[N];

byte wNode[N];

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
    :: msg == winner -> 
      atomic{
        mewinner = false; winnerNode = nr; meWin[nodeNr] = false; 
        wNode[nodeNr-1] = winnerNode; // wNode of Current node holds now winnernode number 
        left ! winner,winnerNode; 
        goto finish 
      }
    :: else ->
      if
        :: nr < nodeNr -> goto receive
        :: nr > nodeNr -> atomic{ left ! msg,nr ; goto receive } // Sends received message to left node and continues receiving message from right node
        :: else ->  atomic {
                      mewinner = true; winnerNode = nodeNr; meWin[nodeNr-1] = true; wNode[nodeNr-1] = winnerNode; // Finds out the winner
                      wnr = nodeNr ; // Assigns wnr by number of current node (nodeNr)
                      left ! winner,nodeNr; goto finish // Sends message of winner to left node and finishs then
                    }
      fi   
   fi
   
   finish:
   if
    :: nodeNr == winnerNode -> right ? _,_
    :: else
   fi
   // Prints to console the finished node
   //atomic {printf("finished node %d\n with winner = %d \n", nodeNr,winnerNode)}

   // nodeNr-node terminates -> ghost[nodeNr] is assigned to 1 
   ghost[nodeNr-1] = 1;

   // Checks: if a node is marked as winner (mewinner), then its nodeNr assigns to winnerNode
   //assert( !mewinner || winnerNode == nodeNr);

   // Checks whether all nodes have the same winnerNode
   //assert( winnerNode == wnr);
}
