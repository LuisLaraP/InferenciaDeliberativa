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
	ejecutarPlan(BaseC, BasePlan),
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
ejecutarPlan(Base, Base) :-
	\+ accionPendiente(Base), !.
ejecutarPlan(Base, NuevaBase) :-
	buscar(objeto([agenda], _, _, _), Base, objeto(_, P, [Acc | Resto], R)),
	write(Acc),
	write("\t\t..."),
	ejecutarAccion(Acc, Base, BaseAccion),
	reemplazar(
		objeto([agenda], P, [Acc | Resto], R),
		objeto([agenda], P, Resto, R),
		BaseAccion, BaseR),
	ejecutarPlan(BaseR, NuevaBase), !.
ejecutarPlan(Base, Base).

% Acciones --------------------------------------------------------------------

ejecutarAccion(Accion, Base, Base) :-
	Accion =.. [Nombre | Args],
	buscar(objeto([Nombre], acciones_robot, _, _), Base, objeto(_, _, Props, _)),
	buscar(exito => _, Props, _ => Exitos),
	agregar(P, Args, PatronExito),
	buscar(PatronExito, Exitos, _),
	X is random_float,
	X > P,
	writeln('fracaso'), !, fail.

ejecutarAccion(agarrar(Objeto), Base, NuevaBase) :-
	objetoDerecho(Base, nil),
	posicionActual(Base, Posicion),
	eliminarObjeto(Objeto, Posicion, Base, BaseA),
	modificar_propiedad(robot, brazo_derecho, Objeto, BaseA, NuevaBase),
	writeln('éxito'), !.

ejecutarAccion(agarrar(Objeto), Base, NuevaBase) :-
	objetoIzquierdo(Base, nil),
	posicionActual(Base, Posicion),
	eliminarObjeto(Objeto, Posicion, Base, BaseA),
	modificar_propiedad(robot, brazo_izquierdo, Objeto, BaseA, NuevaBase),
	writeln('éxito'), !.

ejecutarAccion(buscar(Objeto), Base, NuevaBase) :-
	posicionActual(Base, Posicion),
	obtenerObservacion(Posicion, Base, Observacion),
	verificarObservacion(Observacion, Posicion, Base),
	estaEn(Observacion, Objeto),
	guardarObservacion(Observacion, Posicion, Base, NuevaBase),
	writeln('éxito'), !.

ejecutarAccion(colocar(Objeto), Base, NuevaBase) :-
	\+ objetoDerecho(Base, nil),
	posicionActual(Base, Posicion),
	agregarObjeto(Objeto, Posicion, Base, BaseA),
	modificar_propiedad(robot, brazo_derecho, nil, BaseA, NuevaBase),
	writeln('éxito'), !.

ejecutarAccion(colocar(Objeto), Base, NuevaBase) :-
	\+ objetoIzquierdo(Base, nil),
	posicionActual(Base, Posicion),
	agregarObjeto(Objeto, Posicion, Base, BaseA),
	modificar_propiedad(robot, brazo_izquierdo, nil, BaseA, NuevaBase),
	writeln('éxito'), !.

ejecutarAccion(mover(_, Fin), Base, NuevaBase) :-
	modificar_propiedad(robot, posicion, Fin, Base, NuevaBase),
	writeln('éxito'), !.
