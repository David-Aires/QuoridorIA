

%déclaration de la carte
point(A):- member(A,[0,1,2,3,4,5,6,7,8]).
y(A):- point(A).
x(A):- point(A).
coor(X,Y):- x(X),y(Y).

%déclaration de la carte des barrières
pointB(A):- member(A,[0,1,2,3,4,5,6,7]).
coorB(X,Y,D):-D = 0 ,point(X),pointB(Y). 
coorB(X,Y,D):-D = 1 ,pointB(X),point(Y). 

%déclaration des couleurs
couleur(M):- member(M,["red","gold","darkgreen","blue"]).





%--------------------------------------------------------------------------------------------
%définition d'un pion
pion(X,Y,M) :- coor(X,Y),couleur(M).                                                        %
%fusion de testMap et testRepet
testMap(MAP):- testAll(MAP),testRepet(MAP).                                                 %
%test tout les pion de la LSj
testAll([]).                                                                                %
testAll([(X,Y,M)|S]):-pion(X,Y,M),testAll(S).                                               %
%test la non répétition des pions de la LSj
testRepet([]).                                                                              %
testRepet([(X,Y,P)|S]):- not(member((X,Y,_),S)), not(member((_,_,P),S)),testRepet(S).       %

%--------------------------------------------------------------------------------------------

%Renvoie vrai si le joueur peut encore poser des barrières.
nbColor(C,LSb):- couleur(C),count(C,LSb,Nb), Nb < 10.
%Version d'un count adapter au projet renvoie le nombre d'occurrence de H
count(_, [], 0).
count(Num, [(_,_,H,_)|T], X) :- dif(Num,H), count(Num, T, X).
count(Num, [(_,_,H,_)|T], X) :- Num = H, count(Num, T, X1), X is X1 + 1.
%définition des barres
barr(X,Y,C,D):-coorB(X,Y,D),couleur(C).
%inspection de la LSb
testAllBarr([]).                                                                               
testAllBarr([(X,Y,C,D)|S]):-coorB(X,Y,D),couleur(C),testAllBarr(S). 
%Empêche les barrières de faire des croix. 
isCross(Z,(X,_,_,D),(X1,Y1,_,_)):- D=0,member((X1,Y1,_,1),Z),member((X,Y1,_,1),Z).
isCross(Z,(X,Y,_,D),(X1,Y1,_,_)):- D=1,member((X,Y1,_,0),Z),member((X1,Y,_,0),Z).

%/////////////////////////////////////////////////////////////////////////////
%vérifie si une barrière ce trouve en bord de map -> correspond à une des conditions d'arret
isBorderUp(X,Y,D):-D=0,Y=8;D=1,X=8.
isBorderDown(X,Y,D):-D=0,Y=0;D=1,X=0.
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
moveLeft(Z,(X,Y,_,D),(XO,YO,_,DO)):-connectedUpLeft(Z,X,Y,X1,Y1,D,D1)->isLockedB(Z,(X1,Y1,_,D1),(XO,YO,_,DO)).
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
connectedRightDown(Z,X1,Y1,B,A,D,D1):-D=0,member((B,A,_,1),Z),A is Y1-1, B is X1+1,D1 is 1.
connectedUpLeft(Z,X1,Y1,B,A,D,D1):-D=1,member((B,Y1,_,0),Z), B is X1, A is Y1,D1 is 0.
connectedUpRight(Z,X1,Y1,B,A,D,D1):-D=1,(member((B,A,_,0),Z),B is X1), A is Y1+1,D1 is 0.
connectedDownLeft(Z,X1,Y1,B,A,D,D1):-D=1,member((B,A,_,0),Z), B is X1-1, A is Y1,D1 is 0.
connectedDownRight(Z,X1,Y1,B,A,D,D1):-D=1,member((X1,Y1,_,0),Z),B is X1, A is Y1,D1 is 0.
connectedRight(Z,X1,Y1,B,A,D,D1):-(member((B,Y1,_,D),Z),B is X1+1), A is Y1,D1 is 1.
connectedLeft(Z,X1,Y1,B,A,D,D1):-(member((B,Y1,_,D),Z),B is X1-1), A is Y1,D1 is 1.
%/////////////////////////////////////////////////////////////////////////////

%-----------------------------------------------------------------------------------------







%Vérifie si le pion traverse un mur.
casper(X,Y,X1,Y1,LSb):- X = X1 ,Y1 > Y,Y2 is Y1 - 1 ,member((X1,Y2,_,1),LSb).
casper(X,Y,X1,Y1,LSb):- X = X1 ,Y1 < Y ,member((X1,Y1,_,1),LSb).
casper(X,Y,X1,Y1,LSb):- Y = Y1 ,X1 > X,X2 is X1 - 1 ,member((X2,Y1,_,0),LSb).
casper(X,Y,X1,Y1,LSb):- Y = Y1 ,X1 < X ,member((X1,Y1,_,0),LSb).
%Première génération de point de déplacement possible 
arc((X,Y),(X1,Y),LSb):-coor(X,Y),X1 is X - 1 , coor(X1,Y),not(casper(X,Y,X1,Y,LSb)).
arc((X,Y),(X1,Y),LSb):-coor(X,Y),X1 is X + 1 , coor(X1,Y),not(casper(X,Y,X1,Y,LSb)).
arc((X,Y),(X,Y1),LSb):-coor(X,Y),Y1 is Y - 1 , coor(X,Y1),not(casper(X,Y,X,Y1,LSb)).
arc((X,Y),(X,Y1),LSb):-coor(X,Y),Y1 is Y + 1 , coor(X,Y1),not(casper(X,Y,X,Y1,LSb)).
%seconde génération en prenant en compte la possibilité de faire un saute-mouton
arc2(((X,Y),(X2,Y2)),LSj,LSb):-arc((X,Y),(X1,Y1),LSb),member((X1,Y1,_),LSj),coorplus((X,Y),(X1,Y1),(X2,Y2)),not(member((X2,Y2,_),LSj)).
arc2(((X,Y),(X1,Y1)),LSj,LSb):-arc((X,Y),(X1,Y1),LSb),not(member((X1,Y1,_),LSj)).
%Amplifie le déplacement. 
coorplus((X,Y),(X1,Y1),(X2,Y2)):- X = X1 , Y>Y1 , Y2 is Y1 -1 , X2 is X1.
coorplus((X,Y),(X1,Y1),(X2,Y2)):- X = X1 , Y<Y1 , Y2 is Y1 +1 , X2 is X1.
coorplus((X,Y),(X1,Y1),(X2,Y2)):- Y = Y1 , X>X1 , X2 is X1 -1 , Y2 is Y1.
coorplus((X,Y),(X1,Y1),(X2,Y2)):- Y = Y1 , X<X1 , X2 is X1 +1 , Y2 is Y1.
%Transforme le saute-mouton en diagonale s'il y a un mur derrière le pion.
arc3(((X,Y),(X2,Y2)),LSj,LSb):- arc2(((X,Y),(X2,Y2)),LSj,LSb),not(casper(X,Y,X2,Y2,LSb)).
arc3(((X,Y),(X3,Y3)),LSj,LSb):- arc2(((X,Y),(X2,Y2)),LSj,LSb),casper(X,Y,X2,Y2,LSb),diag((X,Y),(X2,Y2),(X3,Y3)).
%Génère une liste de déplacement selon arc3
listeTrajectoire(LS,X,Y,LSj,LSb):-findall((X2,Y2),arc3(((X,Y),(X2,Y2)),LSj,LSb),LS).
%Renvoie les coordonnées en triangle et atténuer de 1
trianglePos(A,B,A1,B1):- A1 is A + 1, B1 is B - 1.
trianglePos(A,B,A1,B1):- A1 is A + 1, B1 is B + 1.

triangleNeg(A,B,A1,B1):- A1 is A - 1, B1 is B - 1.
triangleNeg(A,B,A1,B1):- A1 is A - 1, B1 is B + 1.

%Choisis le bon triangle
diag((X,Y),(X1,Y1),(X2,Y2)):- X = X1 , Y1 > Y , triangleNeg(Y1,X1,Y2,X2).
diag((X,Y),(X1,Y1),(X2,Y2)):- X = X1 , Y1 < Y , trianglePos(Y1,X1,Y2,X2).

diag((X,Y),(X1,Y1),(X2,Y2)):- Y = Y1 , X1 > X , triangleNeg(X1,Y1,X2,Y2).
diag((X,Y),(X1,Y1),(X2,Y2)):- Y = Y1 , X1 < X , trianglePos(X1,Y1,X2,Y2).
%Centralise tous les tests en 1 prédicat.
aprouved(LSj,LSb,(X,Y,Cl),(X1,Y1,Or)):-pion(X,Y,Cl),barr(X1,Y1,Cl,Or),testMap(LSj),member((X,Y,Cl),LSj),testAllBarr(LSb),nbColor(Cl,LSb),not(member((X1,Y1,_,Or),LSb)),append(LSb,[(X1,Y1,Cl,Or)],LSbb),not(isLocked(LSbb,(X1,Y1,_,Or))).
aprouved(LSj,LSb,(X,Y,Cl),(X1,Y1)):-pion(X,Y,Cl),not(barr(X1,Y1,Cl,5)),testMap(LSj),member((X,Y,Cl),LSj),arc3(((X,Y),(X1,Y1)),LSj,LSb),pion(X1,Y1,Cl),win((X1,Y1,Cl)).
%Inspecte la victoire d'un pion.
win((X,Y,Cl)):-distance(Cl,X,Y,Sc),Sc < 8.
win((X,Y,Cl)):-distance(Cl,X,Y,Sc),Sc = 8,write("Victoire du pion : "),writeln(Cl).

%--------------fonction d'évaluation---------------------

%objectif : calculer la différence de  score entre les joueur
% verifier la distance entre le joueur et l'arrivé 
% 0 = début 
% 8 = arrivé
% ro = 5,0 -> vise le _,8 : haut -> bas
% ja = 0,5 -> vise le 8,_ : gauche -> droite
% ve = 8,5 -> vise le _,0 : droite -> gauche
% bl = 5,8 -> vise le 0,_ : bas -> haut

distance(Cl,_,Y,Sc):-couleur(Cl), Cl = "red", Sc is Y. 
distance(Cl,X,_,Sc):-couleur(Cl), Cl = "gold", Sc is X. 
distance(Cl,X,_,Sc):-couleur(Cl), Cl = "darkgreen", Sc is 8 - X.
distance(Cl,_,Y,Sc):-couleur(Cl), Cl = "blue", Sc is 8 - Y. 


%--------------------------------------------------------------------------------deplacement IA-------------------------------------------------------------------------------------------
%Appelle la fonction assit sans garder la liste 
moveIA(LSj,LSb,Cl,MX,MY,C):-assist(LSj,LSb,Cl,MX,MY,_,C).
%renvoie les coordonées de arc3 si l'une d'entre elles est victorieuse
assist(LSj,LSb,Cl,MX,MY,_,1):-member((X,Y,Cl),LSj),listeTrajectoire(LSf,X,Y,LSj,LSb),chercheur2(LSf,Cl,MX,MY,_).
%Lance la procédure path avec une première génération de coordonnées 
assist(LSj,LSb,Cl,MX,MY,L,C):-member((X,Y,Cl),LSj),listeTrajectoire(LSf,X,Y,LSj,LSb),findall(LSO,starter(LSf,LSO,LSb,LSj),LStt),path(LStt,LSb,LSj,MX,MY,Cl,L),length(L,C).

%Renvoie la liste victorieuse et sont premier tuple, si chercheur trouve une bonne liste 
%Utilise le prédicat Rome pour générer toutes les suites de chemin possible et remerge ensemble avec le prédicat fusion, et recommence jusqu'a trouver un chemin
path([],[],[],_,_,_,_).
path(LSt,_,_,MX,MY,Cl,L):-chercheur(LSt,Cl,MX,MY,L),coor(MX,MY),!.
path(LSt,LSb,LSj,MX,MY,Cl,L):-findall(LSO,rome(LSt,LSO,LSb,LSj),ROAD),fusion(ROAD,B),path(B,LSb,LSj,MX,MY,Cl,L).
%version courte du chercheur pour le premier assist
chercheur2(L,Cl,X,Y,_):-member((X,Y),L),distance(Cl,X,Y,Sc),Sc = 8,!.
%Regarde si la dernière coordonnée = 8 pour validé le chercheur. 
chercheur(LS,Cl,VX,VY,L):-member(L,LS),member((X,Y),L),distance(Cl,X,Y,Sc),Sc = 8,premier1(L,(VX,VY)),!.

%génére la première liste 
starter(LSI,LSO,LSb,LSj):-member((X,Y),LSI),arc3(((X,Y),(X1,Y1)),LSj,LSb),append([(X,Y)],[(X1,Y1)],LSO).
%Génère la suite des  sous-listes. 
follower(LSI,LSO,LSb,LSj):-last(LSI,(X,Y)),arc3(((X,Y),(X1,Y1)),LSj,LSb),append(LSI,[(X1,Y1)],LSO).
%Récupère toutes les sous-listes
rome(LSI,LSO,LSb,LSj):-member(LSIi,LSI),findall(LSOo,follower(LSIi,LSOo,LSb,LSj),LSO).
%merge les listes
fusion(LSO,LSI):-findall(Y,(member(T,LSO),member(Y,T)),LSI).

%Va chercher le premier élément d'une liste.
premier1([X|_],X).

%--------------------------------------------------------------------------------------Placement MUR IA-------------------------------------------------------------------------------------------------------------------------

%@requires : LSj = liste des Joueurs, LSb = Liste des Barrières , Cl = couleur du pion concerné , X et Y les coor interroger 
%@return   : vrai ou faux -> vrai si il y a un mur devant 
rectiligne(LSb,Cl,X,Y):-couleur(Cl), Cl = "red"       ,plusGrand(Y,NewY),member((X,NewY,_,1),LSb). %je vise la ligne haut (bleu)
rectiligne(LSb,Cl,X,Y):-couleur(Cl), Cl = "gold"      ,plusGrand(X,NewX),member((NewX,Y,_,0),LSb). %je vise la ligne droite (jaune)
rectiligne(LSb,Cl,X,Y):-couleur(Cl), Cl = "blue"      ,plusPetit(Y,NewY),member((X,NewY,_,1),LSb). %je vise la ligne basse (rouge)
rectiligne(LSb,Cl,X,Y):-couleur(Cl), Cl = "darkgreen" ,plusPetit(X,NewX),member((NewX,Y,_,0),LSb). %je vise la ligne gauche (vert)

plusGrand(A,B):-member(B,[0,1,2,3,4,5,6,7,8]), B > A.
plusPetit(A,B):-member(B,[0,1,2,3,4,5,6,7,8]), B < A.

%Utilise placeMur pour générer les listes de mur et utilise the_worst pour choisir la bonne liste
choixMur(LSj,LSb,Cible,Cl,R):-findall(LSA,placeMur(LSj,LSb,Cible,Cl,LSA),LSbigB),the_worst(LSj,LSbigB,Cible,R).
%Génère une série de listes de mur 
placeMur(LSj,LSb,Cible,Cl,LSA):-member((X,Y,Cible),LSj),arcMur((X,Y),(X1,Y1)),member(Or,[0,1]),not(member((X1,Y1,_,Or),LSb)),append([(X1,Y1,Cl,Or)],LSb,LSA).%,  moveIA(LSj,LSb,Cl,MX,MY,C).


%Choisis la liste de murs la plus désavantageuse pour la cible 
the_worst(LSj,LSb,Cible,R):-member(LS,LSb),member((X,Y,Cible),LSj),rectiligne(LS,Cible,X,Y),return(LS,R).
the_worst(LSj,LSb,Cible,_):-member(LS,LSb),member((X,Y,Cible),LSj),not(rectiligne(LS,Cible,X,Y)),the_worst(LSj,LSb,Cible,_).

return(T,T).
%génére les séries de coor pour les murs similaire a arc1
arcMur((X,Y),(X,Y)).
arcMur((X,Y),(X1,Y)):- X1 is X +1.
arcMur((X,Y),(X,Y1)):- Y1 is Y +1.
%-----------------------------------------------------------------------------------------CHOIX IA--------------------------------------------------------------------------------

%calcule la différence de score entre 2 Joeur
difference((X,Y,Cl),(X1,Y1,Cl1),Diff):- distance(Cl,X,Y,D),distance(Cl1,X1,Y1,D1), Diff is D - D1.
%renvoie toutes les differences par rapport aux autres joueurs : allDifference([(4,5,"ro"),(4,2,"bl"),(4,5,"ja"),(6,6,"ve")],"ro",Sc,Cl). 
allDifference(Lsj,ClIa,Sc,Clcible):-member((X,Y,ClIa),Lsj),member((X1,Y1,Clcible),Lsj),not(ClIa = Clcible),difference((X,Y,ClIa),(X1,Y1,Clcible),Sc).

allbarr(LSb,Cl,C):-couleur(Cl),count(Cl,LSb,C).
%génère les déplacements des IA et renvoie le score avec la couleur
allMove(LSj,LSb,C,Cl):-couleur(Cl),moveIA(LSj,LSb,Cl,_,_,C).

%si ennemi est a 2 move de la victoire -> mur
%si ennemi a 2 move d'avance -> mur 

%ancienne IA 
%iA(LSj,LSb,Cl,(X1,Y1,Cl1,Or)):-moveIA(LSj,LSb,Cl,_,_,C),allMove(LSj,LSb,C1,Cible),not(Cl = Cible),C2 is C1 - 1,C < C2 ,choixMur(LSj,LSb,Cible,Cl,R),
%member((X,Y,Cl),LSj),premier1(R,(X1,Y1,Cl1,Or)),aprouved(LSj,LSb,(X,Y,Cl),(X1,Y1,Or)),writeln("1"). %2 move d'avance

%iA(LSj,LSb,Cl,(X1,Y1,Cl1,Or)):-allMove(LSj,LSb,C1,Cible),not(Cl = Cible),C1 < 3,choixMur(LSj,LSb,Cible,Cl,R),
%member((X,Y,Cl),LSj),premier1(R,(X1,Y1,Cl1,Or)),aprouved(LSj,LSb,(X,Y,Cl),(X1,Y1,Or)),writeln("2").%2 move de la victoire

%iA(LSj,LSb,Cl,(X,Y,Cl)):-moveIA(LSj,LSb,Cl,X,Y,_),member((X1,Y1,Cl),LSj),aprouved(LSj,LSb,(X1,Y1,Cl),(X,Y)).

%Génère le score de touts les pions et demande a decissionIA pour la réponse
iA(LSj,LSb,Cl,T):-findall((C,Cl1),allMove(LSj,LSb,C,Cl1),LSr),decissionIA(LSj,LSb,LSr,Cl,T).

%test si le choix le plus logique est de possé un mur si oui demande a decisionMurale ou le mettre
decissionIA(LSj,LSb,LSr,Cl,(X,Y,Cl,D)):-nbColor(Cl,LSb),member((Sc,Cl),LSr),plusCourt(LSr,Sc,_),findall(N,plusCourt(LSr,Sc,N),K),decisionMurale(LSj,LSb,K,Cl,(X,Y,D)),!.
%simple mouvement si on ne met de pas de barr
decissionIA(LSj,LSb,_,Cl,(X,Y,Cl)):-moveIA(LSj,LSb,Cl,X,Y,_),!.
%test le score de l'adversaire 
plusCourt(LSr,SC,Cible):-member((P,Cible),LSr),SC-1 > P.
%cible la barrière en fonction du mouvement du pion cible 
decisionMurale(LSj,LSb,LSr,Cl,(X2,Y2,Or)):-member(CiblePoten,LSr),member((X,Y,CiblePoten),LSj),moveIA(LSj,LSb,CiblePoten,X1,Y1,_),
incre(X,Y,X1,Y1,X2,Y2),orien(X,Y,X1,Y1,Or),member((MX,MY,Cl),LSj),sousaprouved(LSj,LSb,(MX,MY,Cl),(X2,Y2,Or)),!.
% recommence 2 fois le prédicat approuved pour test les barrière entierement 
sousaprouved(LSj,LSb,(MX,MY,Cl),(X2,Y2,Or)):-aprouved(LSj,LSb,(MX,MY,Cl),(X2,Y2,Or)),addorien(X2,Y2,Or,X3,Y3),append(LSb,[(X2,Y2,Cl,Or)],Superlsb),aprouved(LSj,Superlsb,(MX,MY,Cl),(X3,Y3,Or)).
addorien(X,Y,Or,X1,Y):-Or = 0,X1 is X + 1.
addorien(X,Y,Or,X,Y1):-Or = 1,Y1 is Y + 1.



orien(X,_,X1,_,1):- X = X1.
orien(_,Y,_,Y1,0):- Y = Y1.

incre(X,Y,X1,_,X1,Y):-X1 < X.
incre(X,Y,_,Y1,X,Y1):- Y1 < Y.
incre(X,Y,X1,_,X,Y):- X < X1.
incre(X,Y,_,Y1,X,Y):- Y < Y1.