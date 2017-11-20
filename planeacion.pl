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
	nodoInicial(Base, Inicio),
	writeln('Nodo inicial'),
	writeln(Inicio),
	busquedaPlan([], [Inicio], Objetivos, Base, Plan),
	writeln('Plan encontrado:'),
	imprimirLista(Plan),
	filtrar(objetoSeLlama(diagnostico), Base, Objetos),
	agregarPropiedadObjetos(Objetos, parar, Base, NuevaBase).

% Algoritmo de búsqueda -------------------------------------------------------

busquedaPlan(_, _, [], _, []).
busquedaPlan(Blancos, Grises, Objetivos, Base, Plan) :-
	maximaRecompensa(Grises, Objetivos, Base, Maximo, _),
	eliminar(Maximo, Grises, Grises2),
	agregar(Maximo, Blancos, Blancos2),
	extensionClase(acciones_robot, Base, Acciones),
	expandirNodo(Maximo, Acciones, Base, Sucesores),
	concatena(Grises2, Sucesores, Grises3),
	objetivosCumplidos(Maximo, Objetivos, Base, Cumplidos),
	(Cumplidos == []
	->	NBlancos = Blancos2,
		NGrises = Grises3,
		NObjetivos = Objetivos,
		PlanActual = []
	;	eliminarTodos(Cumplidos, Objetivos, NObjetivos),
		NBlancos = [],
		Maximo = nodo(_, PlanActual, S),
		NGrises = [nodo(S, [], S)]
	),
	busquedaPlan(NBlancos, NGrises, NObjetivos, Base, SigPlan),
	concatena(PlanActual, SigPlan, Plan).

expandirNodo(_, [], _, []).
expandirNodo(Nodo, [[A] | As], Base, Sucesores) :-
	funcionSucesor(A, Nodo, Base, SucA),
	expandirNodo(Nodo, As, Base, SucAs),
	concatena(SucA, SucAs, Sucesores).

maximaRecompensa([G], Objetivos, Base, G, Recompensa) :-
	recompensa(G, Objetivos, Base, Recompensa).
maximaRecompensa([G | Gs], Objetivos, Base, Maximo, Recompensa) :-
	maximaRecompensa(Gs, Objetivos, Base, SigMax, SigRec),
	recompensa(G, Objetivos, Base, Actual),
	(Actual > SigRec
	-> Maximo = G, Recompensa = Actual
	; Maximo = SigMax, Recompensa = SigRec
	).

objetivosCumplidos(_, [], _, []).
objetivosCumplidos(nodo(P, A, H), [O | Os], Base, Cumplidos) :-
	objetivosCumplidos(nodo(P, A, H), Os, Base, Sig),
	(funcionObjetivo(H, O, Base)
	->	agregar(O, Sig, Cumplidos)
	;	Cumplidos = Sig
	).

% Definición ------------------------------------------------------------------

nodoInicial(Base, nodo(Inicio, [], Inicio)) :-
	propiedadesObjeto(robot, Base, Robot),
	propiedadesObjeto(creencia, Base, Creencia),
	concatena(Robot, Creencia, E1),
	agregar(buscado => nil, E1, Inicio).

funcionSucesor(agarrar, nodo(I, A, Estado), _, Sucesores) :-
	buscar(buscado => _, Estado, _ => Objeto),
	Objeto \== nil, !,
	expandirAgarrar([Objeto], Acciones),
	calcularSucesores(nodo(I, A, Estado), Acciones, Sucesores).
funcionSucesor(agarrar, _, _, []).

funcionSucesor(buscar, nodo(I, A, Estado), _, Sucesores) :-
	buscar(buscado => _, Estado, _ => nil), !,
	buscar(posicion => _, Estado, _ => Posicion),
	buscar(Posicion => _, Estado, _ => Objetos),
	expandirBuscar(Objetos, Acciones),
	calcularSucesores(nodo(I, A, Estado), Acciones, Sucesores).
funcionSucesor(buscar, _, _, []).

funcionSucesor(colocar, nodo(I, A, Estado), _, Sucesores) :-
	buscar(brazo_derecho => _, Estado, _ => Der),
	buscar(brazo_izquierdo => _, Estado, _ => Izq),
	expandirColocar([Der, Izq], Acciones),
	calcularSucesores(nodo(I, A, Estado), Acciones, Sucesores).

funcionSucesor(mover, nodo(I, A, Estado), Base, Sucesores) :-
	buscar(posicion => _, Estado, _ => Posicion),
	extensionClase(ubicaciones, Base, U),
	filtrar(\==([Posicion]), U, Ubicaciones),
	expandirMover(Posicion, Ubicaciones, Acciones),
	calcularSucesores(nodo(I, A, Estado), Acciones, Sucesores).

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
calcularSucesores(nodo(I, A, Estado), [agarrar(O) | As], [nodo(I, A2, S) | Rs]) :-
	buscar(brazo_derecho => _, Estado, _ => nil), !,
	buscar(posicion => _, Estado, _ => Posicion),
	buscar(Posicion => _, Estado, _ => Objetos),
	eliminar(O, Objetos, NObjetos),
	reemplazar(Posicion => Objetos, Posicion => NObjetos, Estado, E2),
	reemplazar(brazo_derecho => nil, brazo_derecho => O, E2, E3),
	reemplazar(buscado => _, buscado => nil, E3, S),
	agregar(agarrar(O), A, A2),
	calcularSucesores(nodo(I, A, Estado), As, Rs).
calcularSucesores(nodo(I, A, Estado), [agarrar(O) | As], [nodo(I, A2, S) | Rs]) :-
	buscar(brazo_izquierdo => _, Estado, _ => nil), !,
	buscar(posicion => _, Estado, _ => Posicion),
	buscar(Posicion => _, Estado, _ => Objetos),
	eliminar(O, Objetos, NObjetos),
	reemplazar(Posicion => Objetos, Posicion => NObjetos, Estado, E2),
	reemplazar(brazo_izquierdo => nil, brazo_izquierdo => O, E2, E3),
	reemplazar(buscado => _, buscado => nil, E3, S),
	agregar(agarrar(O), A, A2),
	calcularSucesores(nodo(I, A, Estado), As, Rs).
calcularSucesores(nodo(I, A, Estado), [agarrar(_) | As], Rs) :-
	calcularSucesores(nodo(I, A, Estado), As, Rs).
calcularSucesores(nodo(I, A, Estado), [buscar(O) | As], [nodo(I, A2, S) | Rs]) :-
	reemplazar(buscado => _, buscado => O, Estado, S),
	agregar(buscar(O), A, A2),
	calcularSucesores(nodo(I, A, Estado), As, Rs).
calcularSucesores(nodo(I, A, Estado), [colocar(O) | As], [nodo(I, A2, S) | Rs]) :-
	buscar(_ => O, Estado, Brazo => _),
	(Brazo == brazo_derecho; Brazo == brazo_izquierdo),
	reemplazar(Brazo => O, Brazo => nil, Estado, E2),
	buscar(posicion => _, Estado, _ => Posicion),
	buscar(Posicion => _, Estado, _ => Objetos),
	agregar(O, Objetos, NObjetos),
	reemplazar(Posicion => Objetos, Posicion => NObjetos, E2, E3),
	reemplazar(buscado => _, buscado => nil, E3, S),
	agregar(colocar(O), A, A2),
	calcularSucesores(nodo(I, A, Estado), As, Rs).
calcularSucesores(nodo(I, A, Estado), [mover(Inicio, Fin) | As], [nodo(I, A2, S) | Rs]) :-
	reemplazar(posicion => _, posicion => Fin, Estado, E3),
	reemplazar(buscado => _, buscado => nil, E3, S),
	agregar(mover(Inicio, Fin), A, A2),
	calcularSucesores(nodo(I, A, Estado), As, Rs).

costoCamino([], _, 0).
costoCamino([C | Cs], Base, Costo) :-
	costoCamino(Cs, Base, Costo2),
	costoAccion(C, Base, Costo1),
	Costo is Costo1 + Costo2.

costoAccion(nil, _, 0).
costoAccion(Accion, Base, Costo) :-
	Accion =.. [Nombre | Args],
	buscar(objeto([Nombre], acciones_robot, _, _), Base, objeto(_, _, Props, _)),
	buscar(costo => _, Props, _ => Costos),
	agregar(Costo, Args, PatronCosto),
	buscar(PatronCosto, Costos, _), !.
costoAccion(Accion, Base, Costo) :-
	Accion =.. [Nombre | Args],
	buscar(objeto([Nombre], acciones_robot, _, _), Base, objeto(_, _, Props, _)),
	buscar(costo => _, Props, _ => Costos),
	invertir(Args, Args2),
	agregar(Costo, Args2, PatronCosto),
	buscar(PatronCosto, Costos, _).

recompensa(nodo(_, [], _), _, _, 0).
recompensa(nodo(_, Acciones, _), Objetivos, Base, Recompensa) :-
	invertir(Acciones, [Ultima, Penultima | AccionesInv]), !,
	recompensaAccion(Ultima, AccionesInv, Objetivos, Base, RecBase),
	Ultima =.. [NomUlt | _],
	Penultima =.. [NomPen | _],
	(NomUlt == NomPen
	->	Recompensa is RecBase / 2
	;	Recompensa is RecBase
	).
recompensa(nodo(_, Acciones, _), Objetivos, Base, Recompensa) :-
	invertir(Acciones, [Ultima | AccionesInv]),
	recompensaAccion(Ultima, AccionesInv, Objetivos, Base, Recompensa).

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
