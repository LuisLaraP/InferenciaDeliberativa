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
% interprete.pl
% Intérprete de comandos básico implementado en Prolog. Permite realizar
% operaciones sobre la base de conocimiento.
% =============================================================================

interprete :-
	repeat,
	catch(read(Comando), Error, (imprimirExcepcion(Error), interprete)),
	(Comando \= end_of_file, Comando \= salir ->
		kb(Base),
		call(comando(Comando), Base, NuevaBase),
		retract(kb(Base)),
		assert(kb(NuevaBase)),
		call(comando(guardar(backup)), NuevaBase, _),
		fail;
		!
	).

imprimirExcepcion(Excepcion) :-
	print_message(error, Excepcion).
