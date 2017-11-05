#! /usr/bin/swipl -f -q
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

:- [decision].
:- [diagnostico].
:- [planeacion].
:- [simulador].

:- op(800, xfx, '=>').

:- initialization main.

main :-
	current_prolog_flag(argv, Args),
	main(Args).

main([]).
main([NombreBase | _]) :-
	inf_delib(NombreBase),
	halt.

inf_delib(NombreBase) :-
	atom_concat('bases/', NombreBase, Ruta),
	open(Ruta, read, Archivo),
	read(Archivo, Base),
	close(Archivo),
	simulador(Base, _).
