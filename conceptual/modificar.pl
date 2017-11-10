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
% modificar.pl
% Contiene los comandos que sirven para modificar la información de la base de conocimiento.
% =============================================================================
%:- op(800, xfx, '=>').

% Modificar el nombre de una clase. Falla si se repite el nombre
modificar_nombre_clase(_, NuevoNom, Base, Base) :- \+unico(NuevoNom, Base).
modificar_nombre_clase(AntiguoNom, NuevoNom, Base, NuevaBase) :- unico(NuevoNom, Base), mnc(AntiguoNom, NuevoNom, Base, NB), mrs(AntiguoNom, NuevoNom, NB, NuevaBase).

% Modificar el nombre de un objeto.
modificar_nombre_objeto(AntiguoNom, NuevoNom, Base, NuevaBase) :- mno(AntiguoNom, NuevoNom, Base, NB), mrs(AntiguoNom, NuevoNom, NB, NuevaBase).

% Modificar propiedad de una clase u objeto.
modificar_propiedad(Entidad, Propiedad, NuevoValor, Base, NuevaBase) :- mp(Entidad, Propiedad, NuevoValor, Base, NuevaBase).

%Modificar proiedad con valor especifico de una clase u objeto.
modificar_propiedad(Entidad, Propiedad, ViejoValor, NuevoValor, Base, NuevaBase) :- mp(Entidad, Propiedad, ViejoValor, NuevoValor, Base, NuevaBase).

% Modifica relacion de una clase u objeto.
modificar_relacion(Entidad, Relacion, NuevoValor, Base, NuevaBase) :- mr(Entidad, Relacion, NuevoValor, Base, NuevaBase).

% Modifica relacion con un valor especifico de una calse u objeto.
modificar_relacion(Entidad, Relacion, ViejoValor, NuevoValor, Base, NuevaBase) :- mr(Entidad, Relacion, ViejoValor, NuevoValor, Base, NuevaBase).

% Niega una propiedad de una clase u objeto.
negar_propiedad(Entidad, Propiedad, Base, NuevaBase) :- np(Entidad, Propiedad, _, Base, NuevaBase).

% Niega una propiedad de una clase u objeto.
negar_propiedad(Entidad, Propiedad, Valor, Base, NuevaBase) :- np(Entidad, Propiedad, Valor, Base, NuevaBase).

% Nieha una propiedad de una clase u objeto.
negar_relacion(Entidad, Relacion, Base, NuevaBase) :- nr(Entidad, Relacion, _, Base, NuevaBase).

% Nieha una propiedad de una clase u objeto.
negar_relacion(Entidad, Relacion, Valor, Base, NuevaBase) :- nr(Entidad, Relacion, Valor, Base, NuevaBase).


% Auxiliar: Verifica que el elemento no esté en la lista
unico(_, []).

unico(Nom, [clase(Nom, _, _, _) | _]):-
	!, fail.

unico(Nom, [_ | T]) :-
	unico(Nom, T).
      
% Auxiliar: Modificar el nombre de una clase en los campos: Nombre de la clase, padre de una clase o clase de un objeto.
mnc(_, _, [], []).

mnc(AntiguoNom, NuevoNom, [clase(AntiguoNom, M, P, R) | T], [clase(NuevoNom, M, P, R) | TN]) :-
	mnc(AntiguoNom, NuevoNom, T, TN).

mnc(AntiguoNom, NuevoNom, [clase(N, AntiguoNom, P, R) | T], [clase(N, NuevoNom, P, R) | TN]) :-
	mnc(AntiguoNom, NuevoNom, T, TN).

mnc(AntiguoNom, NuevoNom, [objeto(N, AntiguoNom, P, R) | T], [clase(N, NuevoNom, P, R) | TN]) :-
	mnc(AntiguoNom, NuevoNom, T, TN).

mnc(AntiguoNom, NuevoNom, [H|T], [H|NT]) :-
	mnc(AntiguoNom, NuevoNom, T, NT).

% Auxiliar: Modificar el nombre de un objeto.
mno(_, _, [], []).

mno(AntiguoNom, NuevoNom, [objeto(ID, Cl, Pr, Re) | T], [objeto(NID, Cl, Pr, Re) | NT]) :-
	mno(AntiguoNom, NuevoNom, T, NT), mod_lista(AntiguoNom, NuevoNom, ID, NID).

mno(AntiguoNom, NuevoNom, [H | T], [H | NT]) :- 
	mno(AntiguoNom, NuevoNom, T, NT).

% Auxiliar: Modificar el nombre de un objeto o clase en una relacion.
mrs(_, _, [], []).

mrs(Relacion, NuevaRelacion, [clase(N, M, P, R) | T], [clase(N, M, P, NR) | NT]) :-
	mod_lista_valor(_, Relacion, NuevaRelacion, R, NR), mrs(Relacion, NuevaRelacion, T, NT).

mrs(Relacion, NuevaRelacion, [objeto(N, M, P, R) | T], [objeto(N, M, P, NR) | NT]) :-
	mod_lista_valor(_, Relacion, NuevaRelacion, R, NR), mrs(Relacion, NuevaRelacion, T, NT).

% Auxiliar: Modicar una propiedad de una clase u objeto.
mp(_, _, _, _, [], []).

mp(Nombre, Propiedad, Valor, NuevoValor, [clase(Nombre, M, P, R) | T], [clase(Nombre, M, NP, R) | T]) :-
	mod_lista_valor(Propiedad, Valor, NuevoValor, P, NP).

mp(Nombre, Propiedad, Valor, NuevoValor, [objeto(N, M, P, R) | T], [objeto(N, M, NP, R) | T]) :-
	member(Nombre, N), mod_lista_valor(Propiedad, Valor, NuevoValor, P, NP).

mp(Nombre, Propiedad, Valor, NuevaPropiedad, [E | T], [E | NT]) :-
	mp(Nombre, Propiedad, Valor, NuevaPropiedad, T, NT).

mp(_, _, _, [], []).

mp(Nombre, Propiedad, NuevoValor, [clase(Nombre, M, P, R) | T], [clase(Nombre, M, NP, R) | T]) :-
	mod_lista(Propiedad, NuevoValor, P, NP).

mp(Nombre, Propiedad, NuevoValor, [objeto(N, M, P, R) | T], [objeto(N, M, NP, R) | T]) :-
	member(Nombre, N), mod_lista(Propiedad, NuevoValor, P, NP).

mp(Nombre, Propiedad, NuevaPropiedad, [E | T], [E | NT]) :-
	mp(Nombre, Propiedad, NuevaPropiedad, T, NT).

% Auxiliar: Modifiar una relacion.
mr(_, _, _, _, [], []).

mr(Nombre, Relacion, Valor, NuevoValor, [clase(Nombre, M, P, R) | T], [clase(Nombre, M, P, NR) | T]) :-
	mod_lista_valor(Relacion, Valor, NuevoValor, R, NR).

mr(Nombre, Relacion, Valor, NuevoValor, [objeto(N, M, P, R) | T], [objeto(N, M, P, NR) | T]) :-
	member(Nombre, N), mod_lista_valor(Relacion, Valor, NuevoValor, R, NR).

mr(Nombre, Relacion, Valor, NuevoValor, [R | T], [R | NT]) :-
	mr(Nombre, Relacion, Valor, NuevoValor, T, NT).

mr(_, _, _, [], []).

mr(Nombre, Relacion, NuevoValor, [clase(Nombre, M, P, R) | T], [clase(Nombre, M, P, NR) | T]) :-
	mod_lista(Relacion, NuevoValor, R, NR).

mr(Nombre, Relacion, NuevoValor, [objeto(N, M, P, R) | T], [objeto(N, M, P, NR) | T]) :-
	member(Nombre, N), mod_lista(Relacion, NuevoValor, R, NR).

mr(Nombre, Relacion, NuevoValor, [R | T], [R | NT]) :-
	mr(Nombre, Relacion, NuevoValor, T, NT).


% Auxiliar: Modifica una lista de propiedades.

mod_lista_valor(N, V, NV, L, LR) :-
	modifica_lista_valor(N, V, NV, L,  T), list_to_set(T, LR).
	
modifica_lista_valor(_, _, _, [], []).

modifica_lista_valor(Nombre, Valor, NuevoValor, [Nombre=>Valor | T], [Nombre=>NuevoValor | T]).

modifica_lista_valor(Nombre, Valor, NuevoValor, [not(Nombre=>Valor) | T], [not(Nombre=>NuevoValor) | T]).

modifica_lista_valor(Nombre, Valor, NuevoValor, [P | T], [P | NT]) :-
	modifica_lista_valor(Nombre, Valor, NuevoValor, T, NT).


mod_lista(V, NV, L, LR) :-
	modifica_lista(V, NV, L,  T), list_to_set(T, LR).

modifica_lista(_, _, [], []).

modifica_lista(Nombre, NuevoValor, [Nombre=>_| T], [Nombre=>NuevoValor | T]).

modifica_lista(Nombre, NuevoValor, [not(Nombre=>_) | T], [not(Nombre=>NuevoValor) | T]).

modifica_lista(Nombre, NuevoValor, [Nombre | T], [NuevoValor | T]).

modifica_lista(Nombre, NuevoValor, [not(Nombre) | T], [not(NuevoValor) | T]).

modifica_lista(Nombre, NuevoValor, [P | T], [P | NT]) :-
	modifica_lista(Nombre, NuevoValor, T, NT).

% Auxiliar: Niga la propiedad de la entidad indicadada.

np(_, _, _, [], []).

np(Entidad, Propiedad, Valor, [clase(Entidad, M, P, R) | T], [clase(Entidad, M, NP, R) | T]) :-
	neg_lista(Propiedad, Valor, P, NP).

np(Entidad, Propiedad, Valor, [objeto(N, M, P, R) | T], [objeto(N, M, NP, R) | T]) :-
	member(Entidad, N), neg_lista(Propiedad, Valor, P, NP).

np(Entidad, Propiedad, Valor, [E | T], [E | NT]) :-
	np(Entidad, Propiedad, Valor, T, NT).

% Auxiliar: Niega la relación de la entidad indicada.

nr(_, _, _, [], []).

nr(Entidad, Relacion, Valor, [clase(Entidad, M, N, R) | T], [clase(Entidad, M, N, NR) | T]) :-
	neg_lista(Relacion, Valor, R, NR).

nr(Entidad, Relacion, Valor, [objeto(N, M, N, R) | T], [objeto(N, M, N, NR) | T] ) :-
	member(Entidad, N), neg_lista(Relacion, Valor, R, NR).

nr(Entidad, Relacion, Valor, [E | T], [E | NT]) :-
	nr(Entidad, Valor, Relacion, T, NT).

% Auxiliar: Niega la propiedad o relacion indicada en la lista.

neg_lista(_, _, [], []).

neg_lista(Nombre, Valor, [Nombre=>Valor | T], [not(Nombre=>Valor) | T]).

neg_lista(Nombre, Valor, [not(Nombre=>Valor) | T], [Nombre=>Valor | T]).

neg_lista(Nombre, _, [Nombre | T], [not(Nombre) | T]).

neg_lista(Nombre, _, [not(Nombre) | T], [Nombre | T]).

neg_lista(Nombre, Valor, [H | T], [H | NT]) :-
	neg_lista(Nombre, Valor, T, NT).
