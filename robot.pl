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

agregarObjetoCreencia(Objeto, Ubicacion, Base, NuevaBase) :-
	propiedadesObjeto(creencia, Base, Props),
	buscar(Ubicacion => _, Props, _ => Elementos),
	agregar(Objeto, Elementos, NElementos),
	modificar_propiedad(creencia, Ubicacion, NElementos, Base, NuevaBase).

costo(Accion, Base, Costo) :-
	Accion =.. [Nombre | Args],
	buscar(objeto([Nombre], acciones_robot, _, _), Base, objeto(_, _, Props, _)),
	buscar(costo => _, Props, _ => Exitos),
	agregar(Costo, Args, PatronCosto),
	buscar(PatronCosto, Exitos, _), !.
costo(Accion, Base, Costo) :-
	Accion =.. [Nombre | Args],
	buscar(objeto([Nombre], acciones_robot, _, _), Base, objeto(_, _, Props, _)),
	buscar(costo => _, Props, _ => Exitos),
	invertir(Args, Args2),
	agregar(Costo, Args2, PatronCosto),
	buscar(PatronCosto, Exitos, _).

eliminarObjetoCreencia(Objeto, Ubicacion, Base, NuevaBase) :-
	propiedadesObjeto(creencia, Base, Props),
	buscar(Ubicacion => _, Props, _ => Elementos),
	eliminar(Objeto, Elementos, NElementos),
	modificar_propiedad(creencia, Ubicacion, NElementos, Base, NuevaBase).

ubicacionObjeto(Objeto, Base, Ubicacion) :-
	propiedadesObjeto(creencia, Base, Props),
	filtrar(objetoEnUbicacion(Objeto), Props, [Ubicacion => _ | _]).

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
