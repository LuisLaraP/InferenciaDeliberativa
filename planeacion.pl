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

% Módulo de planeación.
%	Arg. 1 - Base de entrada.
%	Arg. 2 - Base de salida.
planeacion(Base, NuevaBase) :-
	estadoInicial(Base, Inicio),
	write("Estado inicial: "),
	writeln(Inicio),
	filtrar(objetoSeLlama(diagnostico), Base, Objetos),
	agregarPropiedadObjetos(Objetos, parar, Base, NuevaBase).

estadoInicial(Base, Inicio) :-
	propiedadesObjeto(robot, Base, Robot),
	propiedadesObjeto(creencia, Base, Mundo),
	concatena(Robot, Mundo, Inicio).
