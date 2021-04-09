
y(A):- member(A,[0,1,2,3,4,5,6,7,8]).
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

isCross(Z,(X,Y,_,D),(X1,Y1,_,D1)):- D=0,member((X1,Y1,_,1),Z),member((B,Y1,_,1),Z).
isCross(Z,(X,Y,_,D),(X1,Y1,_,D1)):- D=1,member((B,Y1,_,0),Z),member((X1,A,_,0),Z).


isBlocked((X1,Y1),_,Ls2,(X2,_)):- not(X2 = X1),member((X1,Y1,_,_),Ls2).
isBlocked((X1,Y1),Ls1,_,(_,Y2)):- not(Y2 = Y1),member((X1,Y1,_,_),Ls1).
%/////////////////////////////////////////////////////////////////////////////
%vérifie si une barrière ce trouve en bord de map -> correspond à une des conditions d'arret
isBorderUp(X,Y,D):-D=0,Y=9;D=1,X=9.
isBorderDown(X,Y,D):-D=0,Y=1;D=1,X=9.
%/////////////////////////////////////////////////////////////////////////////

%/////////////////////////////////////////////////////////////////////////////
%prédicat de lancement de vérification des barrière 
%(Z= liste des barrières, (X=abscisses,Y=ordonée,_=couleurs,D=direction)=dernière barrière ajouté, (XO,YO,_,DO)=atome permettant de remonter les résultats)

isLocked(Z,(X,Y,_,D)):- isLocked1(Z,(X,Y,_,D),(X,Y,_,D)),isLocked2(Z,(X,Y,_,D),(X,Y,_,D)).
%/////////////////////////////////////////////////////////////////////////////

%/////////////////////////////////////////////////////////////////////////////
%prédicats de lancement de l'exploration des barrières en partent des 2 bouts
%(Z= liste des barrières, (X=abscisses,Y=ordonée,_=couleurs,D=direction)=dernière barrière ajouté, (XO,YO,_,DO)=atome permettant de remonter les résultats)
isLocked1(Z,(X,Y,_,D),(XO,YO,_,DO)):- (isBorderUp(X,Y,D));(D=0,moveUp(Z,(X,Y,_,D),(XO,YO,_,DO))).
isLocked1(Z,(X,Y,_,D),(XO,YO,_,DO)):- (isBorderUp(X,Y,D));(D=1,moveRight(Z,(X,Y,_,D),(XO,YO,_,DO))).
isLocked2(Z,(X,Y,_,D),(XO,YO,_,DO)):- (isBorderDown(X,Y,D));(D=1,moveLeft(Z,(X,Y,_,D),(XO,YO,_,DO))).
isLocked2(Z,(X,Y,_,D),(XO,YO,_,DO)):- (isBorderDown(X,Y,D));(D=0,moveDown(Z,(X,Y,_,D),(XO,YO,_,DO))).
%/////////////////////////////////////////////////////////////////////////////

%/////////////////////////////////////////////////////////////////////////////
%prédicats d'exploration des barrières recursif avec la conditions d'arret anti-boucle
%(Z= liste des barrières, (X=abscisses,Y=ordonée,_=couleurs,D=direction)=dernière barrière ajouté, (XO,YO,_,DO)=atome permettant de remonter les résultats)
isLockedA(Z,(X,Y,_,D),(XO,YO,_,DO)):- (isBorderUp(X,Y,D);(XO=X,YO=Y,DO=D));(D=0,moveUp(Z,(X,Y,_,D),(XO,YO,_,DO))).
isLockedA(Z,(X,Y,_,D),(XO,YO,_,DO)):- (isBorderUp(X,Y,D);(XO=X,YO=Y,DO=D));(D=1,moveRight(Z,(X,Y,_,D),(XO,YO,_,DO))).
isLockedB(Z,(X,Y,_,D),(XO,YO,_,DO)):- (isBorderDown(X,Y,D);(XO=X,YO=Y,DO=D));(D=1,moveLeft(Z,(X,Y,_,D),(XO,YO,_,DO))).
isLockedB(Z,(X,Y,_,D),(XO,YO,_,DO)):- (isBorderDown(X,Y,D);(XO=X,YO=Y,DO=D));(D=0,moveDown(Z,(X,Y,_,D),(XO,YO,_,DO))).
%/////////////////////////////////////////////////////////////////////////////

%/////////////////////////////////////////////////////////////////////////////
%prédicats de découvertes de barrières voisine en fonction de l'orientation de la barrière, permet aussi la recurcivité vers isLockedA ou isLockedB
%(Z= liste des barrières, (X=abscisses,Y=ordonée,_=couleurs,D=direction)=dernière barrière ajouté, (XO,YO,_,DO)=atome permettant de remonter les résultats)
moveUp(Z,(X,Y,_,D),(XO,YO,_,DO)):- connectedUp(Z,X,Y,X1,Y1,D,D1)->isLockedA(Z,(X1,Y1,_,D1),(XO,YO,_,DO)).
moveUp(Z,(X,Y,_,D),(XO,YO,_,DO)):-connectedRightUp(Z,X,Y,X1,Y1,D,D1)->isLockedA(Z,(X1,Y1,_,D1),(XO,YO,_,DO)).
moveUp(Z,(X,Y,_,D),(XO,YO,_,DO)):-connectedLeftUp(Z,X,Y,X1,Y1,D,D1)->isLockedB(Z,(X1,Y1,_,D1),(XO,YO,_,DO)).
moveDown(Z,(X,Y,_,D),(XO,YO,_,DO)):- connectedDown(Z,X,Y,X1,Y1,D,D1)->isLockedB(Z,(X1,Y1,_,D1),(XO,YO,_,DO)).
moveDown(Z,(X,Y,_,D),(XO,YO,_,DO)):-connectedRightDown(Z,X,Y,X1,Y1,D,D1)->isLockedA(Z,(X1,Y1,_,D1),(XO,YO,_,DO)).
moveDown(Z,(X,Y,_,D),(XO,YO,_,DO)):-connectedLeftDown(Z,X,Y,X1,Y1,D,D1)->isLockedB(Z,(X1,Y1,_,D1),(XO,YO,_,DO)).
moveLeft(Z,(X,Y,_,D),(XO,YO,_,DO)):- connectedLeft(Z,X,Y,X1,Y1,D,D1)->isLockedB(Z,(X1,Y1,_,D1),(XO,YO,_,DO)).
moveLeft(Z,(X,Y,_,D),(XO,YO,_,DO)):-connectedUpLeft(Z,X,Y,X1,Y1,D,D1)->isLockedA(Z,(X1,Y1,_,D1),(XO,YO,_,DO)).
moveLeft(Z,(X,Y,_,D),(XO,YO,_,DO)):-connectedDownLeft(Z,X,Y,X1,Y1,D,D1)->isLockedB(Z,(X1,Y1,_,D1),(XO,YO,_,DO)).
moveRight(Z,(X,Y,_,D),(XO,YO,_,DO)):- connectedRight(Z,X,Y,X1,Y1,D,D1)->isLockedA(Z,(X1,Y1,_,D1),(XO,YO,_,DO)).
moveRight(Z,(X,Y,_,D),(XO,YO,_,DO)):-connectedUpRight(Z,X,Y,X1,Y1,D,D1)->isLockedA(Z,(X1,Y1,_,D1),(XO,YO,_,DO)).
moveRight(Z,(X,Y,_,D),(XO,YO,_,DO)):-connectedDownRight(Z,X,Y,X1,Y1,D,D1)->isLockedB(Z,(X1,Y1,_,D1),(XO,YO,_,DO)).
%/////////////////////////////////////////////////////////////////////////////

%/////////////////////////////////////////////////////////////////////////////
%prédicats qui vérifie si une barrières voisine existe en fonction de l'orientation et fais remonter les coordonnée de cette barrière
%(Z= liste des barrières, X1=abscisses,Y1=ordonée,B=nouvelle abscisses,A=nouvelle ordonées,D=direction,D1=nouvelle direction)
connectedUp(Z,X1,Y1,B,A,D,D1):-(member((X1,A,_,D),Z),A is Y1+1), B is X1,D1 is 0.
connectedDown(Z,X1,Y1,B,A,D,D1):-(member((X1,A,_,D),Z),A is Y1-1), B is X1,D1 is 0.
connectedLeftUp(Z,X1,Y1,B,A,D,D1):-D=0,member((X1,Y1,_,1),Z), B is X1, A is Y1,D1 is 1.
connectedRightUp(Z,X1,Y1,B,A,D,D1):-D=0,member((B,Y1,_,1),Z),A is Y1, B is X1+1,D1 is 1.
connectedLeftDown(Z,X1,Y1,B,A,D,D1):-D=0,member((B,Y1,_,1),Z), B is X1-1, A is Y1,D1 is 1.
connectedRightDown(Z,X1,Y1,B,A,D,D1):-D=0,member((X1,Y1,_,1),Z),A is Y1, B is X1,D1 is 1.
connectedUpLeft(Z,X1,Y1,B,A,D,D1):-D=1,member((B,Y1,_,0),Z), B is X1-1, A is Y1,D1 is 0.
connectedUpRight(Z,X1,Y1,B,A,D,D1):-D=1,(member((B,Y1,_,0),Z),B is X1), A is Y1,D1 is 0.
connectedDownLeft(Z,X1,Y1,B,A,D,D1):-D=1,member((X1,A,_,0),Z), B is X1, A is Y1-1,D1 is 0.
connectedDownRight(Z,X1,Y1,B,A,D,D1):-D=1,member((X1,Y1,_,0),Z),B is X1, A is X1,D1 is 0.
connectedRight(Z,X1,Y1,B,A,D,D1):-(member((B,Y1,_,D),Z),B is X1+1), A is Y1,D1 is 1.
connectedLeft(Z,X1,Y1,B,A,D,D1):-(member((B,Y1,_,D),Z),B is X1-1), A is Y1,D1 is 1.
%/////////////////////////////////////////////////////////////////////////////

%-----------------------------------------------------------------------------------------

deuxieme([_,_,T],T).
renvoie(R,R).
genListe(T,[T,T,T]).



%isLocked([(1,1,"ro",0),(1,2,"ro",0),(1,3,"ro",0),(1,4,"ro",0),(1,5,"bl",0),(1,7,"bl",0),(2,7,"ve",0),(2,8,"je",0),(2,9,"bl",0)],[(2,7,"ro",1)],(1,6,"bl",0)). 
%isLocked([(1,1,R,0),(1,2,R,0),(1,3,R,0),(1,5,R,0),(1,6,R,0),(1,7,R,0),(1,8,R,0),(1,9,R,0)],[],(1,4,R,0)).
%isBlocked((1,1),[(1,1,"ro",0)],[(2,2,"ro",1)],(1,1)). 

%20 ?- string_to_list("7",U).
%U = [55].
%atom_string('4',U).

%step1 créer un sous ensemble 
%depuis "[(0,0,blue,0),(0,1,blue,0)]"" sortir -> [(0,0,'bl'),(0,1,'bl')]
%ignorer les [] et detecter les ()


%suprimme les occurences
supprime(X,[X|L],L).
supprime(X,[Y|L],[Y|R]):- supprime(X,L,R).

%supprime les [ 91 et ] 93 
converteur(Str,Finale):-string_to_list(Str,LS),supprime(91,LS,LS2),supprime(93,LS2,LS3),separateur(LS3,Finale).

%sépare les liste en fonction des () pour créer d'autres sous listes 
%40 = ( 41 = )
%append([[40]],[[8]],U).  
%U = [[40], [8]].
%separateur([],_).
%separateur([L|Ls],Ensemble):-L = 40 ,append([],[L],Tp),separateur(Ls,Ensemble)



%barr
%joueur



point(X,Y):- member(X,[0,1,2,3,4,5,6,7,8]),member(Y,[0,1,2,3,4,5,6,7,8]).

%verifie si tu traverses un mur
gaspar(X,Y,X1,Y1,LSb):- X = X1 ,Y1 > Y,Y2 is Y1 - 1 ,member((X1,Y2,_,0),LSb).
gaspar(X,Y,X1,Y1,LSb):- X = X1 ,Y1 < Y ,member((X1,Y1,_,0),LSb).
gaspar(X,Y,X1,Y1,LSb):- Y = Y1 ,X1 > X,X2 is X1 - 1 ,member((X2,Y1,_,1),LSb).
gaspar(X,Y,X1,Y1,LSb):- Y = Y1 ,X1 < X ,member((X1,Y1,_,1),LSb).

arc((X,Y),(X1,Y),LSb):-point(X,Y),X1 is X - 1 , point(X1,Y),not(gaspar(X,Y,X1,Y,LSb)).
arc((X,Y),(X1,Y),LSb):-point(X,Y),X1 is X + 1 , point(X1,Y),not(gaspar(X,Y,X1,Y,LSb)).
arc((X,Y),(X,Y1),LSb):-point(X,Y),Y1 is Y - 1 , point(X,Y1),not(gaspar(X,Y,X,Y1,LSb)).
arc((X,Y),(X,Y1),LSb):-point(X,Y),Y1 is Y + 1 , point(X,Y1),not(gaspar(X,Y,X,Y1,LSb)).

arc2(((X,Y),(X2,Y2)),LSj,LSb):-arc((X,Y),(X1,Y1),LSb),testMap(LSj),member((X1,Y1,_),LSj),coorplus((X,Y),(X1,Y1),(X2,Y2)).
arc2(((X,Y),(X1,Y1)),LSj,LSb):-arc((X,Y),(X1,Y1),LSb),testMap(LSj),not(member((X1,Y1,_),LSj)).

coorplus((X,Y),(X1,Y1),(X2,Y2)):- X = X1 , Y>Y1 , Y2 is Y1 -1 , X2 is X1.
coorplus((X,Y),(X1,Y1),(X2,Y2)):- X = X1 , Y<Y1 , Y2 is Y1 +1 , X2 is X1.
coorplus((X,Y),(X1,Y1),(X2,Y2)):- Y = Y1 , X>X1 , X2 is X1 -1 , Y2 is Y1.
coorplus((X,Y),(X1,Y1),(X2,Y2)):- Y = Y1 , X<X1 , X2 is X1 +1 , Y2 is Y1.

arc3(((X,Y),(X2,Y2)),LSj,LSb):- arc2(((X,Y),(X2,Y2)),LSj,LSb),not(gaspar(X,Y,X2,Y2,LSb)).
arc3(((X,Y),(X3,Y3)),LSj,LSb):- arc2(((X,Y),(X2,Y2)),LSj,LSb),gaspar(X,Y,X2,Y2,LSb),diag((X,Y),(X2,Y2),(X3,Y3)).

trianglePos(A,B,A1,B1):- A1 is A + 1, B1 is B - 1.
trianglePos(A,B,A1,B1):- A1 is A + 1, B1 is B + 1.

triangleNeg(A,B,A1,B1):- A1 is A - 1, B1 is B - 1.
triangleNeg(A,B,A1,B1):- A1 is A - 1, B1 is B + 1.


diag((X,Y),(X1,Y1),(X2,Y2)):- X = X1 , Y1 > Y , triangleNeg(Y1,X1,Y2,X2).
diag((X,Y),(X1,Y1),(X2,Y2)):- X = X1 , Y1 < Y , trianglePos(Y1,X1,Y2,X2).

diag((X,Y),(X1,Y1),(X2,Y2)):- Y = Y1 , X1 > X , triangleNeg(X1,Y1,X2,Y2).
diag((X,Y),(X1,Y1),(X2,Y2)):- Y = Y1 , X1 < X , trianglePos(X1,Y1,X2,Y2).
%
aprouved(LSj,LSb,(X,Y,Cl),(X1,Y1,Or)):-writeln('barr').
aprouved(LSj,LSb,(X,Y,Cl),(X1,Y1)):-pion(X,Y,Cl),member((X,Y,Cl),LSj),arc3(((X,Y),(X1,Y1)),LSj,LSb),pion(X1,Y1,Cl).
