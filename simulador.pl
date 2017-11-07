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

simulador(Base, Base) :-
	\+ accionPendiente(Base).
simulador(Base, NuevaBase) :-
	accionPendiente(Base),
	diagnostico(Base, BaseA),
	decision(BaseA, BaseB),
	planeacion(BaseB, BaseC),
	ejecutarPlan(BaseC, BasePlan),
	simulador(BasePlan, NuevaBase).

% Este predicado es verdadero si el robot aún tiene acciones pendientes por
% realizar.
accionPendiente(Base) :-
	buscar(objeto(agenda, _, _, _), Base, objeto(_, _, [], _)), !,
	fail.
accionPendiente(_).

% Ejecuta las acciones contenidas en la agenda del robot, hasta que éstas se
% agoten o bien, hasta que ocurra un error.
ejecutarPlan(Base, NuevaBase) :-
	buscar(objeto(agenda, _, _, _), Base, objeto(_, P, [Acc | Resto], R)),
	reemplazar(
		objeto(agenda, P, [Acc | Resto], R),
		objeto(agenda, P, Resto, R),
		Base, NuevaBase),
	escribir(['Ejecutando la acción ', Acc]).
