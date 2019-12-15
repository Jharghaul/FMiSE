mtype = { msg1, msg2, msg3, msg4, msg5, // Nachrichten"nummern"
          KAS, KBS, KIS, // symmetrische Schlüssel für Kommunikation mit Server
                                    // nur dem Server und dem entsprechenden Partner bekannt, 
                                    // d.h. KAS kennen nur Alice und Server, KBS nur Bob und Server etc.
          KAB,KAB_OLD,KAI,KBI,  // modellieren die erzeugten Sitzungsschluessel (session keys)
          KAB_A_KBS,           // modelliert die verschluesselte Nachricht {KAB, A}_KBS 
          KAB_OLD_A_KBS,        // modelliert die verschluesselte Nachricht {KAB)OLDKAB_OLD, A}_KBS, 
                               // kann nur von jemandem/einer gelesen werden die KBS kennt
          K_NONE,              // "Schlüssel" für unverschlüsselte Kommunikation
          NA, NB, NB_MINUS_1, NI, NI_MINUS_1  // Noncen NA kennt initial nur A, NB kennt initial nur B, NB_MINUS_1 die Nonce NB - 1
          A, B, I, S, NONE        // Identifikationsnummern der Kommunikationspartner: A=Alice, B=Bob, I=Intruder, S=Server          
        }

        
//  { msgId, to, key, content1, content2, content3, content4 }
chan internet = [0] of {mtype, mtype, mtype, mtype, mtype, mtype, mtype}


// Ghostvariablen zur Spezifikation
bool statusA, statusB;
mtype partyA, partyB;


active proctype Server() {
    mtype sender, receiver;
    mtype nonceSender;
    mtype sessionKey;
    mtype key;
    mtype content = 0;
    internet?msg1, S, K_NONE, sender, receiver, nonceSender, _ ->
      atomic{
          // "Schluesselerzeugung"
         sender == A && receiver == B; sessionKey = KAB; key = KAS; content = KAB_A_KBS;
         // sende Schluessel          
         internet!msg2, sender, key, receiver, nonceSender, sessionKey, content
      }
    terminate:
    printf("terminate");   
}


active proctype Alice() {
    mtype encryptedMsg;
    mtype sessionKey;
    mtype noncePartner;
   
    statusA = false;

    // wähle Kommunikationspartner
    partyA = B;
    
    // Anfrage an Server nach Sitzungsschluessel (session key)
    internet!msg1,S,K_NONE,A,partyA,NA,0;
    // warte auf Nachricht mit Sitzungsschluessel (session key)
    internet?msg2,A,KAS,eval(partyA),NA,sessionKey,encryptedMsg;
    // sende B verschluesselte Nachricht
    internet!msg3,partyA,K_NONE,encryptedMsg, 0, 0, 0;
    // warte auf Antwort von B
    internet?msg4,A,eval(sessionKey),noncePartner, _, _, _;
    // sende Bobs modifizierte Nonce
    // Beachte, dass die mtypes absteigend durchnummeriert werden, daher:
    // NB_MINUS_1 == NB - 1 und NI_MINUS_1 == NI - 1
    internet!msg5,partyA,sessionKey, noncePartner - 1, 0, 0, 0; 
    
    statusA = true
}


active proctype Bob() {
  printf("implementiere Bob");
  // TODO: Implementiere Bob
  statusB = false;
  mtype encryptedMsg;
  mtype sessionKey;

  // Bob receives encrypted message
  internet ? msg3,B,K_NONE,encryptedMsg,_,_,_ -> 
    atomic{
      if
        :: encryptedMsg == KAB_A_KBS -> sessionKey = KAB; partyB = A
        :: encryptedMsg == KAB_OLD_A_KBS -> sessionKey = KAB_OLD; partyB = A
      fi
      // Bob sends his nonce to the sender
      internet ! msg4,partyB,sessionKey,NB,0,0,0;
    }
  internet ? msg5,B,sessionKey,NB_MINUS_1,_,_,_;

  statusB = true
}
