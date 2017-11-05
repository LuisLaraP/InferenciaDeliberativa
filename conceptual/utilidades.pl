% =============================================================================
% Universidad Nacional Autónoma de México
% Inteligencia Artificial
%
% Proyecto 1 - Representación del conocimiento
%
% Luis Alejandro Lara Patiño
% Roberto Monroy Argumedo
% Alejandro Ehecatl Morales Huitrón
%
% utilidades.pl
% Predicados para realizar operaciones misceláneas.
% =============================================================================

% Escribe una advertencia en pantalla. Usado para informar de cosas que el
% usuario podría no notar, pero no impiden la ejecución de un comando.
advertencia(Mensaje) :-
	escribir(['Advertencia: ' | Mensaje]).

% Escribe un mensaje de error en pantalla. Se usa para indicar la razón por la
% cual un comando no se ejecutó.
error(Mensaje) :-
		escribir(['Error: ' | Mensaje]).

% Escribe los elementos de la lista proporcionada en una línea. Emula el
% funcionammiento de printf.
escribir(Lista) :-
	paraCada(Lista, write), nl.
