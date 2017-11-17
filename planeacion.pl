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
	propiedadesObjeto(decision, Base, Objetivos),
	writeln('Los objetivos del plan son:'),
	imprimirLista(Objetivos),
	estadoInicial(Base, Inicio),
	writeln('Estado inicial'),
	writeln(Inicio),
	busquedaPlan([], [nodo(nil, nil, Inicio)], Objetivos, Base, Plan),
	writeln('Plan encontrado:'),
	imprimirLista(Plan),
	filtrar(objetoSeLlama(diagnostico), Base, Objetos),
	agregarPropiedadObjetos(Objetos, parar, Base, NuevaBase).

% Algoritmo de búsqueda -------------------------------------------------------

busquedaPlan(_, _, [], _, []).
%busquedaPlan(Blancos, Grises, Objetivos, Base, Plan).

expandirEstado(_, [], _, []).
expandirEstado(Estado, [[A] | As], Base, Sucesores) :-
	funcionSucesor(A, Estado, Base, SucA),
	expandirEstado(Estado, As, Base, SucAs),
	concatena(SucA, SucAs, Sucesores).

% Definición ------------------------------------------------------------------

estadoInicial(Base, Inicio) :-
	propiedadesObjeto(robot, Base, Robot),
	propiedadesObjeto(creencia, Base, Creencia),
	concatena(Robot, Creencia, E1),
	agregar(buscado => nil, E1, Inicio).

funcionSucesor(agarrar, Estado, _, Sucesores) :-
	buscar(buscado => _, Estado, _ => Objeto),
	Objeto \== nil, !,
	expandirAgarrar([Objeto], Acciones),
	calcularSucesores(Estado, Acciones, Sucesores).
funcionSucesor(agarrar, _, _, []).

funcionSucesor(buscar, Estado, _, Sucesores) :-
	buscar(buscado => _, Estado, _ => nil), !,
	buscar(posicion => _, Estado, _ => Posicion),
	buscar(Posicion => _, Estado, _ => Objetos),
	expandirBuscar(Objetos, Acciones),
	calcularSucesores(Estado, Acciones, Sucesores).
funcionSucesor(buscar, _, _, []).

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

funcionObjetivo(Estado, entregar(Objeto), _) :-
	buscar(inicio => _, Estado, _ => ObjsInicio),
	estaEn(ObjsInicio, Objeto).
funcionObjetivo(Estado, reacomodar(Objeto), Base) :-
	propiedadesObjetoHerencia(Objeto, Base, Props),
	buscar(estante => _, Props, _ => Estante),
	buscar(Estante => _, Estado, _ => ObjsEstante),
	estaEn(ObjsEstante, Objeto).

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
calcularSucesores(Estado, [agarrar(O) | As], [nodo(Estado, agarrar(O), S) | Rs]) :-
	buscar(brazo_derecho => _, Estado, _ => nil), !,
	buscar(posicion => _, Estado, _ => Posicion),
	buscar(Posicion => _, Estado, _ => Objetos),
	eliminar(O, Objetos, NObjetos),
	reemplazar(Posicion => Objetos, Posicion => NObjetos, Estado, E2),
	reemplazar(brazo_derecho => nil, brazo_derecho => O, E2, E3),
	reemplazar(buscado => _, buscado => nil, E3, S),
	calcularSucesores(Estado, As, Rs).
calcularSucesores(Estado, [agarrar(O) | As], [nodo(Estado, agarrar(O), S) | Rs]) :-
	buscar(brazo_izquierdo => _, Estado, _ => nil), !,
	buscar(posicion => _, Estado, _ => Posicion),
	buscar(Posicion => _, Estado, _ => Objetos),
	eliminar(O, Objetos, NObjetos),
	reemplazar(Posicion => Objetos, Posicion => NObjetos, Estado, E2),
	reemplazar(brazo_izquierdo => nil, brazo_izquierdo => O, E2, E3),
	reemplazar(buscado => _, buscado => nil, E3, S),
	calcularSucesores(Estado, As, Rs).
calcularSucesores(Estado, [agarrar(_) | As], Rs) :-
	calcularSucesores(Estado, As, Rs).
calcularSucesores(Estado, [buscar(O) | As], [nodo(Estado, buscar(O), S) | Rs]) :-
	reemplazar(buscado => _, buscado => O, Estado, S),
	calcularSucesores(Estado, As, Rs).
calcularSucesores(Estado, [colocar(O) | As], [nodo(Estado, colocar(O), S) | Rs]) :-
	buscar(_ => O, Estado, Brazo => _),
	(Brazo == brazo_derecho; Brazo == brazo_izquierdo),
	reemplazar(Brazo => O, Brazo => nil, Estado, E2),
	buscar(posicion => _, Estado, _ => Posicion),
	buscar(Posicion => _, Estado, _ => Objetos),
	agregar(O, Objetos, NObjetos),
	reemplazar(Posicion => Objetos, Posicion => NObjetos, E2, E3),
	reemplazar(buscado => _, buscado => nil, E3, S),
	calcularSucesores(Estado, As, Rs).
calcularSucesores(Estado, [mover(I, F) | As], [nodo(Estado, mover(I, F), S) | Rs]) :-
	reemplazar(posicion => _, posicion => F, Estado, E3),
	reemplazar(buscado => _, buscado => nil, E3, S),
	calcularSucesores(Estado, As, Rs).

generarCamino(nodo(nil, nil, Inicio), _, [nodo(nil, nil, Inicio)]).
generarCamino(nodo(Padre, Accion, Hijo), Blancos, Camino) :-
	filtrar(nodoTieneHijo(Padre), Blancos, [Antecesor|_]),
	generarCamino(Antecesor, Blancos, Cs),
	agregar(nodo(Padre, Accion, Hijo), Cs, Camino).

igualdadEstados([], _).
igualdadEstados([E1 | E1s], E2) :-
	filtrar(igualdadElementos(E1), E2, [E1]),
	igualdadEstados(E1s, E2).

igualdadElementos(N => E1, N => E2) :-
	is_list(E1),
	is_list(E2), !,
	sonIguales(E1, E2).
igualdadElementos(N => X, N => X).

nodoTieneHijo(Hijo, nodo(_, _, Nodo)) :-
	igualdadEstados(Hijo, Nodo).

costoNodo(nodo(_, Accion, _), Base, Costo) :-
	Accion =.. [Nombre | Args],
	buscar(objeto([Nombre], acciones_robot, _, _), Base, objeto(_, _, Props, _)),
	buscar(costo => _, Props, _ => Costos),
	agregar(Costo, Args, PatronCosto),
	buscar(PatronCosto, Costos, _), !.
costoNodo(nodo(_, Accion, _), Base, Costo) :-
	Accion =.. [Nombre | Args],
	buscar(objeto([Nombre], acciones_robot, _, _), Base, objeto(_, _, Props, _)),
	buscar(costo => _, Props, _ => Costos),
	invertir(Args, Args2),
	agregar(Costo, Args2, PatronCosto),
	buscar(PatronCosto, Costos, _).

recompensa(Nodo, Blancos, Objetivos, Base, Recompensa) :-
	generarCamino(Nodo, Blancos, Camino),
	recompensaCamino(Camino, Objetivos, [], Base, Recompensa).

recompensaCamino([], _, _, _, 0).
recompensaCamino([nodo(_, nil, _) | Cs], Objetivos, AccReal, Base, Recompensa) :-
	recompensaCamino(Cs, Objetivos, AccReal, Base, Recompensa).
recompensaCamino([nodo(_, Accion, _) | Cs], Objetivos, AccReal, Base, Recompensa) :-
	recompensaAccion(Accion, AccReal, Objetivos, Base, RecAccion),
	agregar(Accion, AccReal, Realizadas),
	recompensaCamino(Cs, Objetivos, Realizadas, Base, RecResto),
	Recompensa is RecAccion + RecResto.

recompensaAccion(Accion, ListaAcciones, _, _, 0) :-
	estaEn(ListaAcciones, Accion), !.
recompensaAccion(Accion, _, Objetivos, Base, Recompensa) :-
	Accion =.. [Nombre | _],
	buscar(objeto([Nombre], acciones_robot, _, _), Base, objeto(_, _, Props, _)),
	buscar(recompensa => _, Props, _ => RecBase),
	factorRecompensa(Accion, Objetivos, Base, 1, Factor),
	Recompensa is RecBase * Factor.

factorRecompensa(_, [], _, _, 0).
factorRecompensa(mover(I, D), [entregar(Obj) | Os], Base, Cuenta, Factor) :-
	ubicacionObjeto(Obj, Base, Ubicacion),
	(D == inicio; D == Ubicacion), !,
	Cuenta2 is Cuenta + 1,
	factorRecompensa(mover(I, D), Os, Base, Cuenta2, F2),
	Factor is F2 + 1 / Cuenta.
factorRecompensa(mover(I, D), [reacomodar(Obj) | Os], Base, Cuenta, Factor) :-
	ubicacionObjeto(Obj, Base, Ubicacion),
	propiedadesObjetoHerencia(Obj, Base, Props),
	buscar(estante => _, Props, _ => Estante),
	(D == Estante; D == Ubicacion), !,
	Cuenta2 is Cuenta + 1,
	factorRecompensa(mover(I, D), Os, Base, Cuenta2, F2),
	Factor is F2 + 1 / Cuenta.
factorRecompensa(Accion, [O | Os], Base, Cuenta, Factor) :-
	O =.. [_, Arg | _],
	Accion =.. [_ | ArgAccion],
	estaEn(ArgAccion, Arg), !,
	Cuenta2 is Cuenta + 1,
	factorRecompensa(Accion, Os, Base, Cuenta2, F2),
	Factor is F2 + 1 / Cuenta.
factorRecompensa(Accion, [_ | Os], Base, Cuenta, Factor) :-
	Cuenta2 is Cuenta + 1,
	factorRecompensa(Accion, Os, Base, Cuenta2, Factor).
