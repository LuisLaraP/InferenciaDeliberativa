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

inf_delib(NombreBase) :-
	atom_concat('bases/', NombreBase, Ruta),
	open(Ruta, read, Archivo),
	read(Archivo, Base),
	close(Archivo).
