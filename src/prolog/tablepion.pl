
y(A):- member(A,[1,2,3,4,5,6,7,8,9]).
x(A):- y(A).
coor(X,Y):- x(X),y(Y).

coorB(X,Y,D):-D = 0 , X < 9 , X > 0, Y < 10 , Y > 0.
coorB(X,Y,D):-D = 1 , X < 10, X > 0, Y < 9 ,  Y > 0.

verticalBarriere(X,Y):- barriere(X),y(Y).
horizontaleBarriere(X,Y):- x(X),barriere(Y).

couleur(M):- member(M,["ro","ja","ve","bl"]).

%--------------------------------------------------------------------------------------------

pion(X,Y,M) :- coor(X,Y),couleur(M).                                                        %

testMap(MAP):- testAll(MAP),testRepet(MAP).                                                 %

testAll([]).                                                                                %
testAll([(X,Y,M)|S]):-pion(X,Y,M),testAll(S).                                               %

testRepet([]).                                                                              %
testRepet([(X,Y,P)|S]):- not(member((X,Y,_),S)), not(member((_,_,P),S)),testRepet(S).       %

%--------------------------------------------------------------------------------------------


nbColor(C,HR,VR):- couleur(C),count(C,HR,Nb1),count(C,VR,Nb2), (Nb1 + Nb2) < 6.

count(_, [], 0).
count(Num, [(_,_,H,_)|T], X) :- dif(Num,H), count(Num, T, X).
count(Num, [(_,_,H,_)|T], X) :- Num = H, count(Num, T, X1), X is X1 + 1.

barr(X,Y,C,D):-coorB(X,Y,D),couleur(C).

testAllBarr([]).                                                                               
testAllBarr([(X,Y,C,D)|S]):-coorB(X,Y,D),couleur(C),testAllBarr(S). 

isBlocked((X1,Y1),_,Ls2,(X2,_)):- not(X2 = X1),member((X1,Y1,_,_),Ls2).
isBlocked((X1,Y1),Ls1,_,(_,Y2)):- not(Y2 = Y1),member((X1,Y1,_,_),Ls1).

isBorderUp(X,Y,D):-D=0,Y=9;D=1,X=9.
isBorderDown(X,Y,D):-D=0,Y=1;D=1,X=9.
isLocked(Z,Z1,(X,Y,C,D)):- isLocked1(Z,Z1,(X,Y,_,D),(X,Y,_,D)),isLocked2(Z,Z1,(X,Y,_,D),(X,Y,_,D)),barr(X,Y,C,D).
isLocked1(Z,Z1,(X,Y,_,D),(XO,YO,_,DO)):- (isBorderUp(X,Y,D));(D=0,moveUp(Z,Z1,(X,Y,_,D),(XO,YO,_,DO))).
isLocked1(Z,Z1,(X,Y,_,D),(XO,YO,_,DO)):- (isBorderUp(X,Y,D));(D=1,moveRight(Z,Z1,(X,Y,_,D),(XO,YO,_,DO))).
isLocked2(Z,Z1,(X,Y,_,D),(XO,YO,_,DO)):- (isBorderDown(X,Y,D));(D=1,moveLeft(Z,Z1,(X,Y,_,D),(XO,YO,_,DO))).
isLocked2(Z,Z1,(X,Y,_,D),(XO,YO,_,DO)):- (isBorderDown(X,Y,D));(D=0,moveDown(Z,Z1,(X,Y,_,D),(XO,YO,_,DO))).
isLockedA(Z,Z1,(X,Y,_,D),(XO,YO,_,DO)):- (isBorderUp(X,Y,D);(XO=X,YO=Y,DO=D));(D=0,moveUp(Z,Z1,(X,Y,_,D),(XO,YO,_,DO))).
isLockedA(Z,Z1,(X,Y,_,D),(XO,YO,_,DO)):- (isBorderUp(X,Y,D);(XO=X,YO=Y,DO=D));(D=1,moveRight(Z,Z1,(X,Y,_,D),(XO,YO,_,DO))).
isLockedB(Z,Z1,(X,Y,_,D),(XO,YO,_,DO)):- (isBorderDown(X,Y,D);(XO=X,YO=Y,DO=D));(D=1,moveLeft(Z,Z1,(X,Y,_,D),(XO,YO,_,DO))).
isLockedB(Z,Z1,(X,Y,_,D),(XO,YO,_,DO)):- (isBorderDown(X,Y,D);(XO=X,YO=Y,DO=D));(D=0,moveDown(Z,Z1,(X,Y,_,D),(XO,YO,_,DO))).
moveUp(Z,Z1,(X,Y,_,D),(XO,YO,_,DO)):- connectedUp(Z,Z1,X,Y,X1,Y1,D,D1)->isLockedA(Z,Z1,(X1,Y1,_,D1),(XO,YO,_,DO)).
moveUp(Z,Z1,(X,Y,_,D),(XO,YO,_,DO)):- connectedRightUp(Z,Z1,X,Y,X1,Y1,D,D1)->isLockedA(Z,Z1,(X1,Y1,_,D1),(XO,YO,_,DO)).
moveUp(Z,Z1,(X,Y,_,D),(XO,YO,_,DO)):- connectedLeftUp(Z,Z1,X,Y,X1,Y1,D,D1)->isLockedB(Z,Z1,(X1,Y1,_,D1),(XO,YO,_,DO)).
moveDown(Z,Z1,(X,Y,_,D),(XO,YO,_,DO)):- connectedDown(Z,Z1,X,Y,X1,Y1,D,D1)->isLockedB(Z,Z1,(X1,Y1,_,D1),(XO,YO,_,DO)).
moveDown(Z,Z1,(X,Y,_,D),(XO,YO,_,DO)):-connectedRightDown(Z,Z1,X,Y,X1,Y1,D,D1)->isLockedA(Z,Z1,(X1,Y1,_,D1),(XO,YO,_,DO)).
moveDown(Z,Z1,(X,Y,_,D),(XO,YO,_,DO)):-connectedLeftDown(Z,Z1,X,Y,X1,Y1,D,D1)->isLockedB(Z,Z1,(X1,Y1,_,D1),(XO,YO,_,DO)).
moveLeft(Z,Z1,(X,Y,_,D),(XO,YO,_,DO)):- connectedLeft(Z,Z1,X,Y,X1,Y1,D,D1)->isLockedB(Z,Z1,(X1,Y1,_,D1),(XO,YO,_,DO)).
moveLeft(Z,Z1,(X,Y,_,D),(XO,YO,_,DO)):-connectedUpLeft(Z,Z1,X,Y,X1,Y1,D,D1)->isLockedA(Z,Z1,(X1,Y1,_,D1),(XO,YO,_,DO)).
moveLeft(Z,Z1,(X,Y,_,D),(XO,YO,_,DO)):-connectedDownLeft(Z,Z1,X,Y,X1,Y1,D,D1)->isLockedB(Z,Z1,(X1,Y1,_,D1),(XO,YO,_,DO)).
moveRight(Z,Z1,(X,Y,_,D),(XO,YO,_,DO)):- connectedRight(Z,Z1,X,Y,X1,Y1,D,D1)->isLockedA(Z,Z1,(X1,Y1,_,D1),(XO,YO,_,DO)).
moveRight(Z,Z1,(X,Y,_,D),(XO,YO,_,DO)):-connectedUpRight(Z,Z1,X,Y,X1,Y1,D,D1)->isLockedA(Z,Z1,(X1,Y1,_,D1),(XO,YO,_,DO)).
moveRight(Z,Z1,(X,Y,_,D),(XO,YO,_,DO)):-connectedDownRight(Z,Z1,X,Y,X1,Y1,D,D1)->isLockedB(Z,Z1,(X1,Y1,_,D1),(XO,YO,_,DO)).


connectedUp(Z,_,X1,Y1,B,A,D,D1):-(member((X1,A,_,D),Z),A is Y1+1), B is X1,D1 is 0.
connectedDown(Z,_,X1,Y1,B,A,D,D1):-(member((X1,A,_,D),Z),A is Y1-1), B is X1,D1 is 0.
connectedLeftUp(_,Z1,X1,Y1,B,A,D,D1):-D=0,member((X1,Y1,_,1),Z1), B is X1, A is Y1,D1 is 1.
connectedRightUp(_,Z1,X1,Y1,B,A,D,D1):-D=0,member((B,Y1,_,1),Z1),A is Y1, B is X1+1,D1 is 1.
connectedLeftDown(_,Z1,X1,Y1,B,A,D,D1):-D=0,member((B,Y1,_,1),Z1), B is X1-1, A is Y1,D1 is 1.
connectedRightDown(_,Z1,X1,Y1,B,A,D,D1):-D=0,member((X1,Y1,_,1),Z1),A is Y1, B is X1,D1 is 1.
connectedUpLeft(Z,_,X1,Y1,B,A,D,D1):-D=1,member((B,Y1,_,0),Z), B is X1-1, A is Y1,D1 is 0.
connectedUpRight(Z,_,X1,Y1,B,A,D,D1):-D=1,(member((B,Y1,_,0),Z),B is X1), A is Y1,D1 is 0.
connectedDownLeft(Z,_,X1,Y1,B,A,D,D1):-D=1,member((X1,A,_,0),Z), B is X1, A is Y1-1,D1 is 0.
connectedDownRight(Z,_,X1,Y1,B,A,D,D1):-D=1,member((X1,Y1,_,0),Z),B is X1, A is X1,D1 is 0.
connectedRight(_,Z1,X1,Y1,B,A,D,D1):-(member((B,Y1,_,D),Z1),B is X1+1), A is Y1,D1 is 1.
connectedLeft(_,Z1,X1,Y1,B,A,D,D1):-(member((B,Y1,_,D),Z1),B is X1-1), A is Y1,D1 is 1.







%isLocked([(1,1,"ro",0),(1,2,"ro",0),(1,3,"ro",0),(1,4,"ro",0),(1,5,"bl",0),(1,7,"bl",0),(2,7,"ve",0),(2,8,"je",0),(2,9,"bl",0)],[(2,7,"ro",1)],(1,6,"bl",0)). 
%isLocked([(1,1,R,0),(1,2,R,0),(1,3,R,0),(1,5,R,0),(1,6,R,0),(1,7,R,0),(1,8,R,0),(1,9,R,0)],[],(1,4,R,0)).
%isBlocked((1,1),[(1,1,"ro",0)],[(2,2,"ro",1)],(1,1)). 

