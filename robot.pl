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
