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

objetoDerecho(Base, Objeto) :-
	propiedadesObjeto(robot, Base, Props),
	buscar(brazo_derecho => _, Props, _ => Objeto).

objetoIzquierdo(Base, Objeto) :-
	propiedadesObjeto(robot, Base, Props),
	buscar(brazo_izquierdo => _, Props, _ => Objeto).

posicionActual(Base, Posicion) :-
	propiedadesObjeto(robot, Base, Props),
	buscar(posicion => _, Props, _ => Posicion).

guardarObservacion(Observacion, Ubicacion, Base, NuevaBase) :-
	nuevoNombreObs(Base, Id),
	agregar(objeto([Id], observaciones, [Ubicacion => Observacion], []), Base, NuevaBase).

verificarObservacion(Observacion, Ubicacion, Base) :-
	propiedadesObjeto(creencia, Base, Props),
	buscar(Ubicacion => _, Props, _ => Creencia),
	eliminarTodos(Observacion, Creencia, []),
	eliminarTodos(Creencia, Observacion, []).

nuevoNombreObs(Base, NuevoId) :-
	nuevoNombreObs(Base, 1, NuevoId).
nuevoNombreObs(Base, Num, NuevoId) :-
	atom_concat('observacion', Num, NuevoId),
	\+ existeObjeto(NuevoId, Base).
nuevoNombreObs(Base, Num, NuevoId) :-
	Sig is Num + 1,
	nuevoNombreObs(Base, Sig, NuevoId).
