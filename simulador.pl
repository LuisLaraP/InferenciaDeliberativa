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

simulador :-
	base(Base),
	diagnostico(Base, BaseA),
	decision(BaseA, BaseB),
	planeacion(BaseB, BaseC),
	retract(base(_)),
	assert(base(BaseC)),
	repeat,
	(base(BaseAntes), ejecutarSigAccion(BaseAntes, BaseDespues)
	-> retract(base(_)), assert(base(BaseDespues)), fail
	; !
	).
