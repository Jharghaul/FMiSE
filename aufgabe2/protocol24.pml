// for 2.4a)
ltl t1 { []( !statusA || !(partyA == B) || !learned_nonceB ) };
// for 2.4b)
ltl t2 { []( !statusB || !(partyB == A) || !learned_nonceB ) };
// for 2.4c)
ltl t3 { []( !statusA || !statusB || partyA == B && partyB == A )};
