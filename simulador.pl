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
	writeln('Infiriendo'),
	diagnostico(Base, BaseA),
	decision(BaseA, BaseB),
	planeacion(BaseB, BaseC),
	ejecutarPlan(BaseC, BasePlan),
	simulador(BasePlan, NuevaBase).

% Este predicado es verdadero si el robot aún tiene acciones pendientes por
% realizar.
accionPendiente(Base) :-
	buscar(objeto([agenda], _, _, _), Base, objeto(_, _, [], _)), !,
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

ejecutarAccion(mover(_, Fin), Base, NuevaBase) :-
	modificar_propiedad(robot, posicion, Fin, Base, NuevaBase),
	writeln('éxito'), !.

ejecutarAccion(_, Base, Base) :-
	writeln('éxito').
