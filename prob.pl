% ev(E) :- trust(N), belief(N, E).
belief(N, E) :- trust(N).

0.8::belief(a, ev(e1)). 
0.8::trust(a).

query(belief(a, ev(e1))).
% query(ev(e1)).