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
	expandirEstado(Inicio, [[mover]], Base, Suc),
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

funcionSucesor(mover, Estado, Base, Sucesores) :-
	buscar(posicion => _, Estado, _ => Posicion),
	extensionClase(ubicaciones, Base, U),
	filtrar(\==([Posicion]), U, Ubicaciones),
	expandirMover(Posicion, Ubicaciones, Acciones),
	calcularSucesores(Estado, Acciones, Sucesores).

% Utilidades ------------------------------------------------------------------

expandirMover(_, [], []).
expandirMover(Posicion, [[U] | Us], [mover(Posicion, U) | Rs]) :-
	expandirMover(Posicion, Us, Rs).

calcularSucesores(_, [], []).
calcularSucesores(Estado, [mover(I, F) | As], [[mover(I, F), S] | Rs]) :-
	reemplazar(posicion => _, posicion => F, Estado, S),
	calcularSucesores(Estado, As, Rs).
