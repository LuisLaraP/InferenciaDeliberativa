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
	expandirEntregas(ObjsEntrega, Entregas),
	expandirDesordenados(Desordenados, DecDesorden),
	objetosAgarrados(Base, Agarrados),
	(Agarrados == []
	;	writeln('El robot tiene los siguientes objetos en brazos:'),
		imprimirLista(Agarrados), nl
	),
	expandirDesordenados(Agarrados, DecAgarrados),
	concatena(DecDesorden, DecAgarrados, Reacomodos),
	fusionarObjetivos(Entregas, Reacomodos, DecBase),
	filtrar(decisionCumplida(Base), DecBase, Cumplidas),
	eliminarTodos(Cumplidas, DecBase, Decisiones),
	filtrarObjetivos(Decisiones, Base, Filtradas),
	writeln('Se tomaron las siguientes decisiones:'),
	imprimirLista(Filtradas), nl,
	buscar(objeto([decision], _, _, _), Base, objeto(_, A, P, R)),
	reemplazar(
		objeto([decision], A, P, R),
		objeto([decision], A, Filtradas, R),
		Base, Base2
	),
	buscar(objeto([diagnostico], _, _, _), Base2, objeto(_, Ad, Pd, Rd)),
	reemplazar(
		objeto([diagnostico], Ad, Pd, Rd),
		objeto([diagnostico], Ad, [], Rd),
		Base2, NuevaBase
	).

expandirEntregas([], []).
expandirEntregas([E | Es], [entregar(E) | Rs]) :-
	expandirEntregas(Es, Rs).

expandirDesordenados([], []).
expandirDesordenados([D | Ds], [reacomodar(D) | Rs]) :-
	expandirDesordenados(Ds, Rs).

fusionarObjetivos([], Reacomodos, Reacomodos).
fusionarObjetivos([entregar(O) | Es], Reacomodos, [entregar(O) | Rs]) :-
	fusionarObjetivos(Es, Reacomodos, Rsig),
	eliminar(reacomodar(O), Rsig, Rs).

filtrarObjetivos([], _, []).
filtrarObjetivos([O | _], Base, [O]) :-
	O =.. [_ , Arg],
	objetosAgarrados(Base, Ag),
	estaEn(Ag, Arg),
	writeln('Se realizará el primer objetivo por ahora.'), !.
filtrarObjetivos(Objetivos, _, Objetivos) :-
	length(Objetivos, Longitud),
	Longitud < 2, !.
filtrarObjetivos([O1, O2 | _], Base, Nuevos) :-
	O1 =.. [_, Arg1],
	O2 =.. [_, Arg2],
	ubicacionObjeto(Arg1, Base, U1),
	ubicacionObjeto(Arg2, Base, U2),
	(U1 == U2
	->	Nuevos = [O1, O2],
		writeln('Se realizarán los dos primeros objetivos por ahora.')
	;	Nuevos = [O1],
		writeln('Se realizará el primer objetivo por ahora.')
	).

objetosAgarrados(Base, Objetos) :-
	propiedadesObjeto(robot, Base, Props),
	buscar(brazo_derecho => _, Props, _ => Der),
	buscar(brazo_izquierdo => _, Props, _ => Izq),
	eliminar(nil, [Der, Izq], Objetos).

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

decisionCumplida(Base, entregar(Objeto)) :-
	propiedadesObjeto(creencia, Base, Creencia),
	buscar(inicio => _, Creencia, _ => Entregados),
	estaEn(Entregados, Objeto),
	write('El objetivo '),
	write(entregar(Objeto)),
	writeln(' ya se cumplió.').
decisionCumplida(Base, reacomodar(Objeto)) :-
	propiedadesObjetoHerencia(Objeto, Base, Props),
	buscar(estante => _, Props, _ => Estante),
	ubicacionObjeto(Objeto, Base, Estante),
	write('El objetivo '),
	write(entregar(Objeto)),
	writeln(' ya se cumplió.').
