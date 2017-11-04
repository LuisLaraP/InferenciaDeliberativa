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

simulador(Base, Base) :-
	\+ accionPendiente(Base).
simulador(Base, NuevaBase) :-
	accionPendiente(Base),
	diagnostico(Base, BaseA),
	decision(BaseA, BaseB),
	planeacion(BaseB, BaseC),
	ejecutarPlan(BaseC, BasePlan),
	simulador(BasePlan, NuevaBase).
