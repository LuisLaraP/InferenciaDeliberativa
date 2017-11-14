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

:-['conceptual/listas'].
:-['conceptual/utilidades'].

:-['conceptual/consultas'].
:-['conceptual/comandos'].
:-['conceptual/operaciones'].



% Módulo de diagnóstico.
%	Arg. 1 - Base de entrada.
%	Arg. 2 - Base de salida.

diagnostico(X, N):-creaEstadoInicial(X).

% crea un estado inicial a partir de las observaciones
creaEstadoInicial(X) :- extensionClase(comestible,X,ListaAlimentos),
write(ListaAlimentos).

