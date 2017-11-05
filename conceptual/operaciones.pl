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
% operaciones.pl
% Operaciones realizables sobre la base de conocimiento.
% =============================================================================

:- op(800, xfx, '=>').

% Agregar información ---------------------------------------------------------

agregarPropiedadObjetos([], _, Base, Base).
agregarPropiedadObjetos([objeto(N, P, Props, R) | Rs], Propiedad, Base, NBase) :-
	agregar(Propiedad, Props, NuevasProps), !,
	reemplazar(objeto(N, P, Props, R), objeto(N, P, NuevasProps, R), Base, Temp),
	agregarPropiedadObjetos(Rs, Propiedad, Temp, NBase).

agregarRelacionObjetos([], _, Base, Base).
agregarRelacionObjetos([objeto(N, P, Props, Rels) | R], Rel, Base, NBase) :-
	agregar(Rel, Rels, NuevasRels), !,
	reemplazar(objeto(N, P, Props, Rels), objeto(N, P, Props, NuevasRels), Base, Temp),
	agregarRelacionObjetos(R, Rel, Temp, NBase).
agregarRelacionObjetos([_ | R], Rel, Base, NBase) :-
	agregarRelacionObjetos(R, Rel, Base, NBase).

generarId(Base, NuevoId) :-
	generarId(Base, 1, NuevoId).
generarId(Base, Num, NuevoId) :-
	atom_concat('anonimo', Num, NuevoId),
	\+ existeObjeto(NuevoId, Base).
generarId(Base, Num, NuevoId) :-
	Sig is Num + 1,
	generarId(Base, Sig, NuevoId).

verificarNuevaClase(clase(_, nil, _, _), Base) :-
	buscar(clase(_, nil, _, _), Base, _),
	error(['No puede haber más de una clase raíz.']), !, fail.
verificarNuevaClase(clase(_, Padre, _, _), Base) :-
	Padre \= nil,
	\+ existeClase(Padre, Base),
	error(['No se conoce la clase ', Padre, '.']), !, fail.
verificarNuevaClase(clase(Nombre, _, _, _), Base) :-
	existeClase(Nombre, Base),
	error(['Ya existe la clase ', Nombre, '.']), !, fail.
verificarNuevaClase(_, _).

verificarNuevaPropiedadClase(Nombre, _, Base) :-
	\+ existeClase(Nombre, Base),
	error(['No se conoce la clase ', Nombre, '.']), !, fail.
verificarNuevaPropiedadClase(Nombre, Propiedad, Base) :-
	buscar(clase(Nombre, _, _, _), Base, Clase),
	claseTienePropiedad(Propiedad, Clase),
	error(['La clase ', Nombre, ' ya tiene la propiedad ', Propiedad]), !, fail.
verificarNuevaPropiedadClase(_, _, _).

verificarNuevaRelacionClase(Nombre, _, _, Base) :-
	\+ existeClase(Nombre, Base),
	error(['No se conoce la clase ', Nombre, '.']), !, fail.
verificarNuevaRelacionClase(Nombre, Relacion, Objetivo, Base) :-
	buscar(clase(Nombre, _, _, _), Base, Clase),
	claseTieneRelacion(Relacion, Objetivo, Clase),
	error(['La clase ', Nombre, ' ya tiene la relacion ', Relacion, ' con ',
		Objetivo, '.']), !, fail.
verificarNuevaRelacionClase(_, _, Objetivo, Base) :-
	\+ existeEntidad(Objetivo, Base),
	error(['No se conoce la clase o el objeto ', Objetivo, '.']), !, fail.
verificarNuevaRelacionClase(_, _, _, _).

verificarNuevoObjeto(objeto(_, Padre, _, _), Base) :-
	\+ existeClase(Padre, Base),
	error(['No se conoce la clase ', Padre, '.']), !, fail.
verificarNuevoObjeto(objeto(_, _, _, _), _).

verificarNuevaPropiedadObjeto(Nombre, _, Base) :-
	\+ existeObjeto(Nombre, Base),
	error(['No se conoce el objeto ', Nombre, '.']), !, fail.
verificarNuevaPropiedadObjeto(Nombre, Propiedad, Base) :-
	filtrar(objetoSeLlama(Nombre), Base, Objetos),
	filtrar(objetoTienePropiedad(Propiedad), Objetos, Filtrada),
	Filtrada \= [],
	error(['Los siguientes objetos ya tienen la propiedad ', Propiedad, ': ']),
	imprimirLista(Filtrada), !, fail.
verificarNuevaPropiedadObjeto(_, _, _).

verificarNuevaRelacionObjeto(Nombre, _, _, Base) :-
	\+ existeObjeto(Nombre, Base),
	error(['No se conoce el objeto ', Nombre, '.']), !, fail.
verificarNuevaRelacionObjeto(Nombre, Relacion, Objetivo, Base) :-
	filtrar(objetoSeLlama(Nombre), Base, Objetos),
	filtrar(objetoTieneRelacion(Relacion, Objetivo), Objetos, Filtrada),
	Filtrada \= [],
	error(['Los siguientes objetos ya tienen la relación ', Relacion,
		' con ', Objetivo, ':']),
	imprimirLista(Filtrada), !, fail.
verificarNuevaRelacionObjeto(_, _, Objetivo, Base) :-
	\+ existeEntidad(Objetivo, Base),
	error(['No se conoce la clase o el objeto ', Objetivo, '.']), !, fail.
verificarNuevaRelacionObjeto(_, _, _, _).

% Eliminar información --------------------------------------------------------

eliminarPropiedad(_, [], []).
eliminarPropiedad(Propiedad, [Propiedad | ListaProps], NuevasProps) :-
	eliminarPropiedad(Propiedad, ListaProps, NuevasProps), !.
eliminarPropiedad(Propiedad, [not(Propiedad) | ListaProps], NuevasProps) :-
	eliminarPropiedad(Propiedad, ListaProps, NuevasProps), !.
eliminarPropiedad(Propiedad, [Propiedad => _ | ListaProps], NuevasProps) :-
	eliminarPropiedad(Propiedad, ListaProps, NuevasProps), !.
eliminarPropiedad(Propiedad, [not(Propiedad => _) | ListaProps], NuevasProps) :-
	eliminarPropiedad(Propiedad, ListaProps, NuevasProps), !.
eliminarPropiedad(Propiedad, [X | ListaProps], [X | NuevasProps]) :-
	eliminarPropiedad(Propiedad, ListaProps, NuevasProps).

eliminarRelacion(_, _, [], []).
eliminarRelacion(Relacion, Objetivo, [Relacion => Objetivo | Lista], NuevaLista) :-
	eliminarRelacion(Relacion, Objetivo, Lista, NuevaLista), !.
eliminarRelacion(Relacion, Objetivo, [not(Relacion => Objetivo) | Lista], NuevaLista) :-
	eliminarRelacion(Relacion, Objetivo, Lista, NuevaLista), !.
eliminarRelacion(Relacion, Objetivo, [X | Lista], [X | NuevaLista]) :-
	eliminarRelacion(Relacion, Objetivo, Lista, NuevaLista).

eliminarPropiedadObjetos([], _, Base, Base).
eliminarPropiedadObjetos([objeto(N, P, Props, R) | Rs], Propiedad, Base, NuevaBase) :-
	eliminarPropiedad(Propiedad, Props, NuevasProps),
	reemplazar(objeto(N, P, Props, R), objeto(N, P, NuevasProps, R), Base, Temp),
	eliminarPropiedadObjetos(Rs, Propiedad, Temp, NuevaBase).

eliminarRelacionObjetos([], _, _, Base, Base).
eliminarRelacionObjetos([objeto(N, P, Props, R) | Rs], Relacion, Objetivo, Base, NuevaBase) :-
	eliminarRelacion(Relacion, Objetivo, R, NR),
	reemplazar(objeto(N, P, Props, R), objeto(N, P, Props, NR), Base, Temp),
	eliminarRelacionObjetos(Rs, Relacion, Objetivo, Temp, NuevaBase).

verificarEliminarClase(Nombre, Base) :-
	\+ existeClase(Nombre, Base),
	error(['No se conoce la clase ', Nombre, '.']), !, fail.
verificarEliminarClase(_, _).

verificarEliminarObjeto(Nombres, Base) :-
	\+ existeObjeto(Nombres, Base),
	error(['No se conoce ningún objeto llamado ', Nombres, '.']), !, fail.
verificarEliminarObjeto(_, _).

verificarEliminarPropiedadClase(Nombre, _, Base) :-
	\+ existeClase(Nombre, Base),
	error(['No se conoce la clase ', Nombre, '.']), !, fail.
verificarEliminarPropiedadClase(Nombre, Propiedad, Base) :-
	buscar(clase(Nombre, _, _, _), Base, Clase),
	\+ claseTienePropiedad(Propiedad, Clase),
	error(['La clase ', Nombre, ' no tiene la propiedad ', Propiedad, '.']), !, fail.
verificarEliminarPropiedadClase(_, _, _).

verificarEliminarPropiedadObjeto(Nombre, _, Base) :-
	\+ existeObjeto(Nombre, Base),
	error(['No se conoce ningún objeto llamado ', Nombre, '.']), !, fail.
verificarEliminarPropiedadObjeto(Nombre, Propiedad, Base) :-
	filtrar(objetoSeLlama(Nombre), Base, Objetos),
	filtrar(objetoTienePropiedad(Propiedad), Objetos, Filtrada),
	Filtrada \= Objetos,
	restar(Objetos, Filtrada, SinProp),
	advertencia(['Los siguientes objetos no tienen la propiedad ', Propiedad, ': ']),
	imprimirLista(SinProp).
verificarEliminarPropiedadObjeto(_, _, _).

verificarEliminarRelacionClase(Nombre, _, _, Base) :-
	\+ existeClase(Nombre, Base),
	error(['No se conoce la clase ', Nombre, '.']), !, fail.
verificarEliminarRelacionClase(Nombre, Relacion, Objetivo, Base) :-
	buscar(clase(Nombre, _, _, _), Base, Clase),
	\+ claseTieneRelacion(Relacion, Objetivo, Clase),
	error(['La clase ', Nombre, ' no tiene la relación ', Relacion, ' con ',
		Objetivo]), !, fail.
verificarEliminarRelacionClase(_, _, _, _).

verificarEliminarRelacionObjeto(Nombre, _, _, Base) :-
	\+ existeObjeto(Nombre, Base),
	error(['No se conoce ningún objeto llamado ', Nombre, '.']), !, fail.
verificarEliminarRelacionObjeto(Nombre, Relacion, Objetivo, Base) :-
	filtrar(objetoSeLlama(Nombre), Base, Objetos),
	filtrar(objetoTieneRelacion(Relacion, Objetivo), Objetos, Filtrada),
	Filtrada \= Objetos,
	restar(Objetos, Filtrada, SinRel),
	advertencia(['Los siguientes objetos no tienen la relación ', Relacion,
		' con ', Objetivo, ':']),
	imprimirLista(SinRel).
verificarEliminarRelacionObjeto(_, _, _, _).

% Consultas -------------------------------------------------------------------

clasesHijasDe(Nombre, Base, Hijos) :-
	filtrar(claseTienePadre(Nombre), Base, Hijos).

existeClase(Nombre, Base) :-
	estaEn(Base, clase(Nombre, _, _, _)).

existeObjeto(Nombre, Base) :-
	filtrar(objetoSeLlama(Nombre), Base, Resultado),
	Resultado \= [].

existeEntidad(Nombre, Base) :-
	existeClase(Nombre, Base).
existeEntidad(Nombre, Base) :-
	existeObjeto(Nombre, Base).

objetosHijosDe(Nombre, Base, Hijos) :-
	filtrar(objetoTienePadre(Nombre), Base, Hijos).

% Propiedades de clases --------------------------------------------------------

cambiarPadre(_, [], Base, Base).
cambiarPadre(Padre, [clase(Nombre, Viejo, Props, Rels)| R], Base, NuevaBase) :-
	reemplazar(
		clase(Nombre, Viejo, Props, Rels),
		clase(Nombre, Padre, Props, Rels), Base, Temp),
	cambiarPadre(Padre, R, Temp, NuevaBase).
cambiarPadre(Padre, [objeto(Nombres, Viejo, Props, Rels)| R], Base, NuevaBase) :-
	reemplazar(
		objeto(Nombres, Viejo, Props, Rels),
		objeto(Nombres, Padre, Props, Rels), Base, Temp),
	cambiarPadre(Padre, R, Temp, NuevaBase).

claseTienePadre(Padre, clase(_, Padre, _ , _)).

claseTienePropiedad(Propiedad, clase(_, _, Props, _)) :-
	estaEn(Props, Propiedad).
claseTienePropiedad(Propiedad, clase(_, _, Props, _)) :-
	estaEn(Props, Propiedad => _).
claseTienePropiedad(Propiedad, clase(_, _, Props, _)) :-
	estaEn(Props, not(Propiedad)).
claseTienePropiedad(Propiedad, clase(_, _, Props, _)) :-
	estaEn(Props, not(Propiedad => _)).

% Propiedades de objetos -------------------------------------------------------

objetoSeLlama(Nombres, objeto(ListaNombres, _, _, _)) :-
	is_list(Nombres), !,
	paraCada(Nombres, estaEn(ListaNombres)).
objetoSeLlama(Nombre, objeto(ListaNombres, _, _, _)) :-
	estaEn(ListaNombres, Nombre).

objetoTienePadre(Padre, objeto(_, Padre, _, _)).

objetoTienePropiedad(Propiedad, objeto(_, _, Props, _)) :-
	estaEn(Props, Propiedad).
objetoTienePropiedad(Propiedad, objeto(_, _, Props, _)) :-
	estaEn(Props, Propiedad => _).
objetoTienePropiedad(Propiedad, objeto(_, _, Props, _)) :-
	estaEn(Props, not(Propiedad)).
objetoTienePropiedad(Propiedad, objeto(_, _, Props, _)) :-
	estaEn(Props, not(Propiedad => _)).

% Relaciones de clases --------------------------------------------------------

claseTieneRelacion(Relacion, Objetivo, clase(_, _, _, Rels)) :-
	estaEn(Rels, Relacion => Objetivo).
claseTieneRelacion(Relacion, Objetivo, clase(_, _, _, Rels)) :-
	estaEn(Rels, not(Relacion => Objetivo)).

% Relaciones de objetos -------------------------------------------------------

objetoTieneRelacion(Relacion, Objetivo, objeto(_, _, _, Rels)) :-
	estaEn(Rels, Relacion => Objetivo).
objetoTieneRelacion(Relacion, Objetivo, objeto(_, _, _, Rels)) :-
	estaEn(Rels, not(Relacion => Objetivo)).
