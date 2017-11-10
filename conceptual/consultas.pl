% =============================================================================
% Universidad Nacional Autónoma de México
% Inteligencia Artificial
%
% Proyecto 1 - Representación del conocimiento
%
% Luis Alejandro Lara Patiño
% Roberto Monroy Argumedo
% Alejandro Ehecatl Morales Huitrón
%
% consultas.pl
% Predicados para consultas.
% =============================================================================


% Predicados para la extensión de una clase-----------------------------------

% Obtiene objetos de una clase, declarados directamente.
%	Arg. 1 - La clase en cuestión.
%	Arg. 2 - La base de conocimiento.
%	Arg. 3 - Los objetos de la clase, declarados directamente
obClase(_,[],[]).
obClase(Clase,[objeto(X,Clase,_,_)|N],[X|T]):-
	obClase(Clase,N,T),!.
obClase(Clase,[_|T1],L):-
	obClase(Clase,T1,L).

% Lista de subclases de una clase
%	Arg. 1 - La clase en cuestión.
%	Arg. 2 - La base de conocimiento.
%	Arg. 3 - Lista de sus subclases
subclases(_,[],[]).
subclases(Clase,[clase(N,Clase,_,_)|T],[N|C]):-
	subclases(Clase,T,C),!.
subclases(Clase,[_|T],L):-
	subclases(Clase,T,L).

% Lista de subclases de una clase bajo la relacion de herencia
todasSubclases(Clase,KB,P):-
	subclases(Clase,KB,S),
	intermedia(S,KB,P).

intermedia([],_,[]).
intermedia([H|T],KB,[H|P]):-
	todasSubclases(H,KB,P1),
	intermedia(T,KB,P2),
	concatena(P1,P2,P).

extensionClase(Clase,KB,E):-
	obClase(Clase,KB,O),
	todasSubclases(Clase,KB,S),
	auxiliarExtensionClase(S,KB,A),
	concatena(O,A,E).

auxiliarExtensionClase([],_,[]).
auxiliarExtensionClase([H|T],KB,R):-
	obClase(H,KB,O),
	auxiliarExtensionClase(T,KB,P),
	concatena(O,P,R).
	

% Clases a las que pertenece un objeto-----------------------------

% Devuelve el camino de ancestros hasta la raíz (top)
clasesObjeto(objeto(_,Clase,_,_),KB,R):-
	buscar(clase(Clase,_,_,_),KB,Linea),
	buscaAncestros(Linea,KB,R).

buscaAncestros(clase(top,_,_,_),_,[top]).
buscaAncestros(clase(Clase,Ancestro,_,_),KB,[Clase|R]):-
	buscar(clase(Ancestro,_,_,_),KB,B),!,
	buscaAncestros(B,KB,R).
	

% Lista de propiedades de un objeto--------------------------

propiedadesObjeto(Objeto,KB,Props):-
	filtrar(objetoSeLlama(Objeto),KB,[Ob]),
	propiedadesObjeto(Ob,Props).

propiedadesObjeto(objeto(_,_,Props,_),Props).

claseDeUnObjeto(objeto(_,Clase,_,_),Clase).

propiedadesObjetoHerencia(Objeto,KB,Resultado):-
	filtrar(objetoSeLlama(Objeto),KB,[Ob]),
	propiedadesObjeto(Objeto,KB,Props),
	claseDeUnObjeto(Ob,ClaseOb),
	propiedadesClaseHerencia(ClaseOb,KB,Lis),
	concatena(Props,Lis,Lis2),
	revisaDefaultsProps(Lis2,Resultado).
	

% Lista de propiedades de una clase-----------------------

propiedadesClase(Clase,KB,Props):-
	buscar(clase(Clase,_,_,_),KB,Cl),
	propiedadesClase(Cl,Props).

propiedadesClase(clase(_,_,Props,_),Props).

propiedadesClaseLista([],_,[]).
propiedadesClaseLista([H|T],KB,Salida):-
	propiedadesClase(H,KB,Props),
	propiedadesClaseLista(T,KB,S),
	concatena(Props,S,Salida),!.
	

propiedadesClaseHerencia(Clase,KB,Resultado):-
	buscar(clase(Clase,_,_,_),KB,Cl),
	buscaAncestros(Cl,KB,Anc),
	propiedadesClaseLista(Anc,KB,ListaProps),
	revisaDefaultsProps(ListaProps,Resultado).

% Lista de relaciones de un objeto---------------------

relacionesObjeto(Objeto,KB,Rels):-
	filtrar(objetoSeLlama(Objeto),KB,[Ob]),
	relacionesObjeto(Ob,Rels).

relacionesObjeto(objeto(_,_,_,Rels),Rels).

relacionesObjetoHerencia(Objeto,KB,Resultado):-
	filtrar(objetoSeLlama(Objeto),KB,[Ob]),
	relacionesObjeto(Objeto,KB,Rels),
	claseDeUnObjeto(Ob,ClaseOb),
	relacionesClaseHerencia(ClaseOb,KB,Lis),
	concatena(Rels,Lis,Lis2),
	revisaDefaultsRels(Lis2,Resultado).

% Lista de relaciones de una clase

relacionesClase(Clase,KB,Rels):-
	buscar(clase(Clase,_,_,_),KB,Cl),
	relacionesClase(Cl,Rels).

relacionesClase(clase(_,_,_,Rels),Rels).

relacionesClaseLista([],_,[]).
relacionesClaseLista([H|T],KB,Salida):-
	relacionesClase(H,KB,Rels),
	relacionesClaseLista(T,KB,S),
	concatena(Rels,S,Salida),!.
	

relacionesClaseHerencia(Clase,KB,Resultado):-
	buscar(clase(Clase,_,_,_),KB,Cl),
	buscaAncestros(Cl,KB,Anc),
	relacionesClaseLista(Anc,KB,ListaRels),
	revisaDefaultsRels(ListaRels,Resultado).
	
% Extension de una propiedad---------------------------------------------

listPropAux(_,_,[],[]).
listPropAux(Prop,Nom,[Prop|T],[Nom:si|R]) :-
	listPropAux(Prop,Nom,T,R),!.
listPropAux(Prop,Nom,[not(Prop)|T],[Nom:no|R]) :-
	listPropAux(Prop,Nom,T,R),!.
listPropAux(Prop,Nom,[Prop=>X|T],[Nom:X|R]) :-
	listPropAux(Prop,Nom,T,R),!.
listPropAux(Prop,Nom,[not(Prop=>X)|T],[not(Nom:X)|R]) :-
	listPropAux(Prop,Nom,T,R),!.
listPropAux(Prop,Nom,[_|T],R) :-
	listPropAux(Prop,Nom,T,R),!.


limpiaL([],[]).
limpiaL([[X]|T],[X|L]) :-
	limpiaL(T,L),!.
limpiaL([[]|T],L) :-
	limpiaL(T,L),!.
limpiaL([X|T],[X|L]) :-
	limpiaL(T,L).


extensionPropiedad(_,_,[],[]).
extensionPropiedad(Prop,KB,[objeto(Nom,_,_,_)|TB],[V|LR]) :-
	propiedadesObjetoHerencia(Nom,KB,R),
	listPropAux(Prop,Nom,R,V),
	extensionPropiedad(Prop,KB,TB,LR),!.
extensionPropiedad(Prop,KB,[_|TB],LR) :-
			extensionPropiedad(Prop,KB,TB,LR).

			   
eProp(Prop,KB,R) :-
	extensionPropiedad(Prop,KB,KB,Prev),
	limpiaL(Prev,R).

% Extensión de una relación--------------------------------------------

listRelAux(_,_,[],[]).
listRelAux(Rel,Nom,[Rel=>X|T],[Nom:X|R]) :-
	listRelAux(Rel,Nom,T,R),!.
listRelAux(Rel,Nom,[not(Rel=>X)|T],[not(Nom:X)|R]) :-
	listRelAux(Rel,Nom,T,R),!.
listRelAux(Rel,Nom,[_|T],R) :-
	listRelAux(Rel,Nom,T,R),!.


extensionRelacion(_,_,[],[]).
extensionRelacion(Rel,KB,[objeto(Nom,_,_,_)|TB],[V|LR]) :-
	relacionesObjetoHerencia(Nom,KB,R),
	listRelAux(Rel,Nom,R,V),
	extensionRelacion(Rel,KB,TB,LR),!.
extensionRelacion(Rel,KB,[_|TB],LR) :-
			extensionRelacion(Rel,KB,TB,LR).

			   
eRel(Rel,KB,R) :-
	extensionRelacion(Rel,KB,KB,Prev),
	limpiaL(Prev,R).
