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

agregarObjeto(Objeto, Ubicacion, Base, NuevaBase) :-
	propiedadesObjeto(escenario, Base, Props),
	buscar(Ubicacion => _, Props, _ => Elementos),
	agregar(Objeto, Elementos, NElementos),
	modificar_propiedad(escenario, Ubicacion, NElementos, Base, NuevaBase).

eliminarObjeto(Objeto, Ubicacion, Base, NuevaBase) :-
	propiedadesObjeto(escenario, Base, Props),
	buscar(Ubicacion => _, Props, _ => Elementos),
	eliminar(Objeto, Elementos, NElementos),
	modificar_propiedad(escenario, Ubicacion, NElementos, Base, NuevaBase).

objetoEnUbicacion(Objeto, _ => Lista) :-
	estaEn(Lista, Objeto).

objetoEnUbicacion(Objeto, Base, Ubicacion) :-
	propiedadesObjeto(escenario, Base, Props),
	buscar(Ubicacion => _, Props, _ => Objetos),
	estaEn(Objetos, Objeto).

obtenerObservacion(Ubicacion, Base, Observacion) :-
	propiedadesObjeto(escenario, Base, Props),
	buscar(Ubicacion => _, Props, _ => Observacion).
