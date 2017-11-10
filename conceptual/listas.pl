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
% listas.pl
% Predicados para realizar operaciones sobre listas.
% =============================================================================

% Agrega el elemento dado al final de la lista.
%	Arg. 1 - Elemento a agregar a la lista.
%	Arg. 2 - Lista que se modificará.
%	Arg. 3 - Lista resultado
agregar(Elemento, [], [Elemento]).
agregar(Elemento, [C | R], [C | R2]) :-
	agregar(Elemento, R, R2).

% Busca la primera coincidencia de un patrón en la lista dada.
%	Arg. 1 - Patrón a buscar.
%	Arg. 2 - Lista en la cual buscar.
%	Arg. 3 - Coincidencia encontrada.
buscar(_, [], _) :- fail.
buscar(Patron, [Patron | _], Patron) :- !.
buscar(Patron, [_ | R], Resultado) :-
	buscar(Patron, R, Resultado).

% Esta regla es cierta si el elemento dado se encuentra dentro de la lista. De
% otra manera, es falso.
%	Arg. 1 - Elemento a buscar.
%	Arg. 2 - Lista en la cual buscar.
estaEn([], _) :- fail.
estaEn([Elemento | _], Elemento) :- !.
estaEn([_ | R], Elemento) :-
	estaEn(R, Elemento).

% Elimina todas las ocurrencias del elemento dado en la lista.
%	Arg. 1 - Elemento a eliminar.
%	Arg. 2 - Lista a modificar.
%	Arg. 3 - Lista resultado.
eliminar(_, [], []).
eliminar(Elemento, [Elemento | R], R2) :-
	eliminar(Elemento, R, R2), !.
eliminar(Elemento, [C | R], [C | R2]) :-
	eliminar(Elemento, R, R2).

% Elimina todas las ocurrencias de todos los elementos de la lista de entrada.
%	Arg. 1 - Lista de elementos a eliminar.
% 	Arg. 2 - Lista a modificar.
%	Arg. 3 - Lista resultado.
eliminarTodos([], Lista, Lista).
eliminarTodos([C | R], Lista, NuevaLista) :-
	eliminar(C, Lista, Lista2),
	eliminarTodos(R, Lista2, NuevaLista).

% Devuelve todos los elementos de la lista dada para los cuales la condición
% es verdadera.
%	Arg. 1 - Condición. Debe ser un predicado cuyo último argumento es la
%		variable a probar. Este último argumento debe omitirse.
%	Arg. 2 - Lista a filtrar.
%	Arg. 3 - Lista resultado.
filtrar(Condicion, Lista, Resultado) :-
	filtrar(Condicion, Lista, [], Resultado).
filtrar(_, [], Filtrada, Filtrada) :- !.
filtrar(Condicion, [C | R], Filtrada, Resultado) :-
	call(Condicion, C),
	agregar(C, Filtrada, Res),
	filtrar(Condicion, R, Res, Resultado), !.
filtrar(Condicion, [_ | R], Filtrada, Resultado) :-
	Res = Filtrada,
	filtrar(Condicion, R, Res, Resultado), !.

% Muestra la lista dada en pantalla. Cada elemento se imprime en una línea porobjetoSeLlama(hola, objeto([hola], adios, [], [])).
% separado.
%	Arg. 1 - Lista a imprimir.
imprimirLista(Lista) :-
	paraCada(Lista, writeln).

% Llama a una función para cada miembro de la lista proporcionada. Este
% predicado es verdadero si la función dada es verdadera para todos los
% elementos de la lista. Si la función resulta falsa para alguno de los
% elementos de la lista, se dejan sin recorrer los elementos restantes, y este
% predicado resulta falso.
%	Arg. 1 - Lista.
%	Arg. 2 - Función a ejecutar. Debe ser el nombre de un predicado de aridad 1.
paraCada([], _).
paraCada([C | R], Funcion) :-
	call(Funcion, C),
	paraCada(R, Funcion).

% Reemplaza todas las ocurrencias de un elemento por uno nuevo.
%	Arg. 1 - Elemento a reemplazar.
%	Arg. 2 - Elemento nuevo.
%	Arg. 3 - Lista a modificar.
%	Arg. 4 - Lista resultado.
reemplazar(_, _, [], []).
reemplazar(Original, Nuevo, [Original | R], [Nuevo | NuevaCola]) :-
	reemplazar(Original, Nuevo, R, NuevaCola), !.
reemplazar(Original, Nuevo, [C | R], [C | NuevaCola]) :-
	reemplazar(Original, Nuevo, R, NuevaCola), !.	

%concatena dos listas
concatena([],L,L).
concatena([H|L1],L2,[H|L3]):- concatena(L1,L2,L3).

revisaDefaultsProps([],[]).

revisaDefaultsProps([not(X)|T],[not(X)|R]) :-
	eliminar(X,T,C),
	revisaDefaultsProps(C,R),!.

revisaDefaultsProps([X=>Y|T],[X=>Y|R]) :-
	eliminarTodos([not(X=>Y),X=>_],T,C),
	revisaDefaultsProps(C,R),!.

revisaDefaultsProps([not(X=>Y)|T],[not(X=>Y)|R]) :-
	eliminar(X=>Y,T,C),
	revisaDefaultsProps(C,R),!.

revisaDefaultsProps([X|T],[X|R]) :-
	eliminar(not(X),T,C),
	revisaDefaultsProps(C,R),!.

revisaDefaultsRels([],[]).

revisaDefaultsRels([not(X)|T],[not(X)|R]) :-
	eliminar(X,T,C),
	revisaDefaultsRels(C,R),!.

revisaDefaultsRels([X=>Y|T],[X=>Y|R]) :-
	eliminar(not(X=>Y),T,C),
	revisaDefaultsRels(C,R),!.

revisaDefaultsRels([not(X=>Y)|T],[not(X=>Y)|R]) :-
	eliminar(X=>Y,T,C),
	revisaDefaultsRels(C,R),!.

revisaDefaultsRels([X|T],[X|R]) :-
	eliminar(not(X),T,C),
	revisaDefaultsRels(C,R),!.

% Elimina de la primera lista todos los elementos que aparecen en la segunda.
% Actúa como una resta de lista.
%	Arg. 1 - Lista a modificar.
%	Arg. 2 - Lista a restar.
%	Arg. 3 - Lista resultado.
restar([], _, []).
restar([L1 | L1s], L2, [L1 | Temp]) :-
	\+ estaEn(L2, L1), !,
	restar(L1s, L2, Temp).
restar([_ | L1s], L2, Resta) :-
	restar(L1s, L2, Resta).
