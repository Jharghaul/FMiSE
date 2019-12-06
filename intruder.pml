active proctype Intruder() {
  mtype msg, key, cnt1, cnt2, cnt3, cnt4, r;
  mtype c_msg,c_key, c_cnt1, c_cnt2, c_cnt3, c_cnt4;
  mtype receipt;
  do
    :: internet ? (msg, r, key, cnt1, cnt2, cnt3, cnt4) ->
       if // Merken oder Verwerfen der empfangenen Nachricht
         :: c_msg = msg; c_key = key; c_cnt1 = cnt1; c_cnt2 = cnt2; c_cnt3 = cnt3; c_cnt4 = cnt4
         :: skip;
       fi;
    :: // Wiederspielen einer empfangenen Nachricht oder Senden einer neuen Nachricht
       if // wähle Nachrichtentyp
         :: msg = msg3
         :: msg = msg4
         :: msg = msg5
       fi;
       if // Auswahl eines Empfängers (hier: Beate oder Ingo)
         :: receipt = A;
         :: receipt = B;
         :: receipt = S;
       fi;
       if 
       ::// Neue Nachricht zusammenstellen. Auswahl des Inhaltes für die erste Inhaltskomponente der Nachricht
            if // Auswahl eines Schlüssels
              :: key = KIS;
              :: key = K_NONE;
              fi;
            if // Auswahl der Inhaltskomponente
              :: cnt1 = A
              :: cnt1 = B
              :: cnt1 = I
              :: cnt1 = S
              :: cnt1 = NI
              :: cnt1 = NI_MINUS_1
              fi;
            cnt2 = 0; cnt3 = 0; cnt4 = 0            
       :: // Wiederspielen der zuvor abgefangenen Nachricht
          key   = c_key;
          cnt1  = c_cnt1;
          cnt2  = c_cnt2;
          cnt3  = c_cnt3;
          cnt4  = c_cnt4
      fi;      
      internet ! msg,receipt,key,cnt1,cnt2,cnt3,cnt4;
  od
}