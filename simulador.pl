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

simulador(Base, Base) :-
	\+ accionPendiente(Base), !.
simulador(Base, NuevaBase) :-
	write('Diagnóstico '),
	writeln('=========================================================='),
	diagnostico(Base, BaseA),
	write('Toma de decisión '),
	writeln('====================================================='),
	decision(BaseA, BaseB),
	write('Planeación '),
	writeln('==========================================================='),
	planeacion(BaseB, BaseC),
	write('Ejecutando plan '),
	writeln('======================================================'),
	ejecutarPlan(BaseC, BasePlan, Costo),
	write('El costo de las acciones realizadas fue: '),
	writeln(Costo),
	simulador(BasePlan, NuevaBase).

% Este predicado es verdadero si el robot aún tiene acciones pendientes por
% realizar.
accionPendiente(Base) :-
	buscar(objeto([agenda], _, _, _), Base, objeto(_, _, [], _)),
	\+ propiedadesObjeto(diagnostico, Base, []), !,
	fail.
accionPendiente(_).

% Ejecuta las acciones contenidas en la agenda del robot, hasta que éstas se
% agoten o bien, hasta que ocurra un error.
ejecutarPlan(Base, Base, 0) :-
	\+ accionPendiente(Base), !.
ejecutarPlan(Base, NuevaBase, Costo) :-
	buscar(objeto([agenda], _, _, _), Base, objeto(_, P, [Acc | Resto], R)),
	write(Acc),
	write("\t\t..."),
	ejecutarAccion(Acc, Base, BaseAccion, CostoAccion),
	reemplazar(
		objeto([agenda], P, [Acc | Resto], R),
		objeto([agenda], P, Resto, R),
		BaseAccion, BaseR),
	ejecutarPlan(BaseR, NuevaBase, CostoPlan),
	Costo is CostoPlan + CostoAccion, !.
ejecutarPlan(Base, Base, 0).

% Acciones --------------------------------------------------------------------

ejecutarAccion(Accion, Base, Base, 0) :-
	probExito(Accion, Base, P),
	X is random_float,
	X > P,
	writeln('fracaso'), !, fail.

ejecutarAccion(agarrar(Objeto), Base, NuevaBase, Costo) :-
	objetoDerecho(Base, nil),
	posicionActual(Base, Posicion),
	eliminarObjeto(Objeto, Posicion, Base, BaseA),
	eliminarObjetoCreencia(Objeto, Posicion, BaseA, BaseB),
	modificar_propiedad(robot, brazo_derecho, Objeto, BaseB, NuevaBase),
	costo(agarrar(Objeto), Base, Costo),
	writeln('éxito'), !.

ejecutarAccion(agarrar(Objeto), Base, NuevaBase, Costo) :-
	objetoIzquierdo(Base, nil),
	posicionActual(Base, Posicion),
	eliminarObjeto(Objeto, Posicion, Base, BaseA),
	eliminarObjetoCreencia(Objeto, Posicion, BaseA, BaseB),
	modificar_propiedad(robot, brazo_izquierdo, Objeto, BaseB, NuevaBase),
	costo(agarrar(Objeto), Base, Costo),
	writeln('éxito'), !.

ejecutarAccion(buscar(Objeto), Base, Base, Costo) :-
	posicionActual(Base, Posicion),
	objetoEnUbicacion(Objeto, Base, Posicion),
	costo(buscar(Objeto), Base, Costo),
	writeln('éxito'), !.

ejecutarAccion(colocar(Objeto), Base, NuevaBase, Costo) :-
	\+ objetoDerecho(Base, nil),
	posicionActual(Base, Posicion),
	agregarObjeto(Objeto, Posicion, Base, BaseA),
	agregarObjetoCreencia(Objeto, Posicion, BaseA, BaseB),
	modificar_propiedad(robot, brazo_derecho, nil, BaseB, NuevaBase),
	costo(colocar(Objeto), Base, Costo),
	writeln('éxito'), !.

ejecutarAccion(colocar(Objeto), Base, NuevaBase, Costo) :-
	\+ objetoIzquierdo(Base, nil),
	posicionActual(Base, Posicion),
	agregarObjeto(Objeto, Posicion, Base, BaseA),
	agregarObjetoCreencia(Objeto, Posicion, BaseA, BaseB),
	modificar_propiedad(robot, brazo_izquierdo, nil, BaseB, NuevaBase),
	costo(colocar(Objeto), Base, Costo),
	writeln('éxito'), !.

ejecutarAccion(mover(Inicio, Fin), Base, NuevaBase, Costo) :-
	\+ ubicacionVisitada(Fin, Base),
	marcarVisitada(Fin, Base, Base2),
	modificar_propiedad(robot, posicion, Fin, Base2, Base3),
	obtenerObservacion(Fin, Base3, Observacion),
	(verificarObservacion(Observacion, Fin, Base3)
	->	Base5 = Base3
	;	buscar(objeto([agenda], _, _, _), Base3, objeto(_, A, P, R)),
		reemplazar(
			objeto([agenda], A, P, R),
			objeto([agenda], A, [], R),
			Base3, Base4
		),
		buscar(objeto([diagnostico], _, _, _), Base3, objeto(_, Ad, Pd, Rd)),
		reemplazar(
			objeto([diagnostico], Ad, Pd, Rd),
			objeto([diagnostico], Ad, [], Rd),
			Base4, Base5
		)
	),
	guardarObservacion(Observacion, Fin, Base5, NuevaBase),
	costo(mover(Inicio, Fin), Base5, Costo),
	writeln('éxito'), !.
ejecutarAccion(mover(Inicio, Fin), Base, NuevaBase, Costo) :-
	modificar_propiedad(robot, posicion, Fin, Base, NuevaBase),
	costo(mover(Inicio, Fin), Base, Costo),
	writeln('éxito'), !.
