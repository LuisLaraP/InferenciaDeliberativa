% =============================================================================
% Universidad Nacional Autónoma de México
% Posgrado en Ciencia e Ingeniería de la Computación
%
% Inteligencia Artificial
% Proyecto 2 - Inferencia deliberativa
%
% Luis Alejandro Lara Patiño
% Roberto Monroy Argumedo
% Alejandro Ehecatl Morales Huitrón
% =============================================================================

:- op(800, xfx, '=>').

% Módulo de toma de decisiones.
%	Arg. 1 - Base de entrada.
%	Arg. 2 - Base de salida.
decision(Base, NuevaBase) :-
	propiedadesObjeto(orden, Base, ObjsEntrega),
	writeln('El cliente ordenó los siguientes objetos:'),
	imprimirLista(ObjsEntrega), nl,
	objetosDesordenados(Base, Desordenados),
	writeln('Los siguientes objetos están desordenados:'),
	imprimirLista(Desordenados), nl,
	expandirEntregas(ObjsEntrega, Decisiones),
	writeln('Se tomaron las siguientes decisiones:'),
	imprimirLista(Decisiones), nl,
	buscar(objeto([decision], _, _, _), Base, objeto(_, A, P, R)),
	reemplazar(
		objeto([decision], A, P, R),
		objeto([decision], A, Decisiones, R),
		Base, NuevaBase
	).

expandirEntregas([], []).
expandirEntregas([E | Es], [entregar(E) | Rs]) :-
	expandirEntregas(Es, Rs).

objetosDesordenados(Base, Objetos) :-
	propiedadesObjeto(creencia, Base, Creencia),
	concatenarUbicaciones(Creencia, Todos),
	filtrar(ubicacionIncorrecta(Base), Todos, Objetos).

concatenarUbicaciones([], []).
concatenarUbicaciones([inicio => _ | Us], R) :-
	concatenarUbicaciones(Us, R), !.
concatenarUbicaciones([_ => Objetos | Us], R) :-
	concatenarUbicaciones(Us, Rsig),
	concatena(Objetos, Rsig, R).

ubicacionIncorrecta(Base, Objeto) :-
	propiedadesObjetoHerencia(Objeto, Base, Props),
	buscar(estante => _, Props, _ => Estante),
	\+ ubicacionObjeto(Objeto, Base, Estante).
