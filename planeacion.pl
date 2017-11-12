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

% Módulo de planeación.
%	Arg. 1 - Base de entrada.
%	Arg. 2 - Base de salida.
planeacion(Base, NuevaBase) :-
	estadoInicial(Base, Inicio),
	write("Estado inicial: "),
	writeln(Inicio),
	extensionClase(acciones_robot, Base, Acciones),
	expandirEstado(Inicio, Acciones, Base, Suc),
	write("Sucesores: "),
	writeln(Suc),
	filtrar(objetoSeLlama(diagnostico), Base, Objetos),
	agregarPropiedadObjetos(Objetos, parar, Base, NuevaBase).

% Algoritmo de búsqueda -------------------------------------------------------

expandirEstado(_, [], _, []).
expandirEstado(Estado, [[A] | As], Base, Sucesores) :-
	funcionSucesor(A, Estado, Base, SucA),
	expandirEstado(Estado, As, Base, SucAs),
	concatena(SucA, SucAs, Sucesores).

% Definición ------------------------------------------------------------------

estadoInicial(Base, Inicio) :-
	propiedadesObjeto(robot, Base, Inicio).

funcionSucesor(agarrar, Estado, _, Sucesores) :-
	buscar(posicion => _, Estado, _ => Posicion),
	(buscar(Posicion => _, Estado, _ => Objetos)
	-> expandirAgarrar(Objetos, Acciones),
	   calcularSucesores(Estado, Acciones, Sucesores)
	; Sucesores = []
	).

funcionSucesor(buscar, Estado, Base, Sucesores) :-
	buscar(posicion => _, Estado, _ => Posicion),
	propiedadesObjeto(creencia, Base, Creencia),
	buscar(Posicion => _, Creencia, _ => Objetos),
	expandirBuscar(Objetos, Acciones),
	calcularSucesores(Estado, Acciones, Sucesores).

funcionSucesor(colocar, Estado, _, Sucesores) :-
	buscar(brazo_derecho => _, Estado, _ => Der),
	buscar(brazo_izquierdo => _, Estado, _ => Izq),
	expandirColocar([Der, Izq], Acciones),
	calcularSucesores(Estado, Acciones, Sucesores).

funcionSucesor(mover, Estado, Base, Sucesores) :-
	buscar(posicion => _, Estado, _ => Posicion),
	extensionClase(ubicaciones, Base, U),
	filtrar(\==([Posicion]), U, Ubicaciones),
	expandirMover(Posicion, Ubicaciones, Acciones),
	calcularSucesores(Estado, Acciones, Sucesores).

% Utilidades ------------------------------------------------------------------

expandirAgarrar([], []).
expandirAgarrar([O | Os], [agarrar(O) | Rs]):-
	expandirAgarrar(Os, Rs).

expandirBuscar([], []).
expandirBuscar([O | Os], [buscar(O) | Rs]) :-
	expandirBuscar(Os, Rs).

expandirColocar([], []).
expandirColocar([nil | Os], Rs) :- !,
	expandirColocar(Os, Rs).
expandirColocar([O | Os], [colocar(O) | Rs]) :-
	expandirColocar(Os, Rs).

expandirMover(_, [], []).
expandirMover(Posicion, [[U] | Us], [mover(Posicion, U) | Rs]) :-
	expandirMover(Posicion, Us, Rs).

calcularSucesores(_, [], []).
calcularSucesores(Estado, [agarrar(O) | As], [[agarrar(O), S] | Rs]) :-
	buscar(brazo_derecho => _, Estado, _ => nil), !,
	reemplazar(brazo_derecho => nil, brazo_derecho => O, Estado, E2),
	eliminar(_ => [_|_], E2, S),
	calcularSucesores(Estado, As, Rs).
calcularSucesores(Estado, [agarrar(O) | As], [[agarrar(O), S] | Rs]) :-
	buscar(brazo_izquierdo => _, Estado, _ => nil), !,
	reemplazar(brazo_izquierdo => nil, brazo_derecho => O, Estado, E2),
	eliminar(_ => [_|_], E2, S),
	calcularSucesores(Estado, As, Rs).
calcularSucesores(Estado, [agarrar(_) | As], Rs) :-
	calcularSucesores(Estado, As, Rs).
calcularSucesores(Estado, [buscar(O) | As], [[buscar(O), S] | Rs]) :-
	buscar(posicion => _, Estado, _ => Posicion),
	agregar(Posicion => [O], Estado, S),
	calcularSucesores(Estado, As, Rs).
calcularSucesores(Estado, [colocar(O) | As], [[colocar(O), S] | Rs]) :-
	buscar(_ => O, Estado, Brazo => _),
	reemplazar(Brazo => O, Brazo => nil, Estado, E2),
	eliminar(_ => [_|_], E2, S),
	calcularSucesores(Estado, As, Rs).
calcularSucesores(Estado, [mover(I, F) | As], [[mover(I, F), S] | Rs]) :-
	reemplazar(posicion => _, posicion => F, Estado, E2),
	eliminar(_ => [_|_], E2, S),
	calcularSucesores(Estado, As, Rs).
