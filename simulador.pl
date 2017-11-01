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

simulador(Base, NuevaBase) :-
	diagnostico(Base, BaseA),
	decision(BaseA, BaseB),
	planeacion(BaseB, BaseC),
	ejecutarPlan(BaseC, NuevaBase).
