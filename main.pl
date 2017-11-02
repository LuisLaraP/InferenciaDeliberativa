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
:- [robot].
:- [simulador].

:- op(800, xfx, '=>').

inf_delib(NombreBase) :-
	atom_concat('bases/', NombreBase, Ruta),
	open(Ruta, read, Archivo),
	read(Archivo, Base),
	close(Archivo),
	repeat,
	(simulador(Base, NuevaBase)
	-> !
	; fail
	).
