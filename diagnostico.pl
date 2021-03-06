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

% Módulo de diagnóstico.
%	Arg. 1 - Base de entrada.
%	Arg. 2 - Base de salida.
diagnostico(Base, NuevaBase):-
	observacionesActuales(Base,Actuales),
	creenciaActual(Base,[H|T]),
	asignarPosiciones(Actuales,T,NuevaCreencia),
	buscar(objeto([reporte],_,_,_),Base,objeto(N,A,P,R)),
	reemplazar(objeto(N,A,P,R),objeto(N,A,[H|NuevaCreencia],R),Base,Mod1),
	buscar(objeto([creencia],_,_,_),Mod1,objeto(N2,A2,P2,R2)),
	reemplazar(objeto(N2,A2,P2,R2),objeto(N2,A2,[H|NuevaCreencia],R2),Mod1,NuevaBase),
	quitaVacios(NuevaCreencia,NoVacios),
	transformar([H|NoVacios],S),
	writeln("El estado de los estantes de acuerdo a mi diagnóstico es el siguiente:\n"),
	writeln(NuevaCreencia),
	writeln("\nY se llevó a cabo mediante las siguientes acciones:\n"),
	imprimirLista(S),
	writeln("\n").


% Busca en la base actual las observaciones a tener en cuenta
% en el diagnóstico
%    Arg. 1 - La base de conocimiento.
%    Arg. 2 - Lista con las observaciones contendas en la base.
observacionesActuales([],[]).
observacionesActuales([objeto(_,observaciones,[Obs],_)|T],[Obs|C]):-
	observacionesActuales(T,C),!.
observacionesActuales([_|T],L):-
	observacionesActuales(T,L).


% Busca en la base actual la creencia del acomodo de los
% productos en los estantes.
% Al inicio del simulador esa creencia es el orden según
% el reporte del asistente.
%    Arg. 1 - La base de conocimiento.
%    Arg. 2 - Lista con la creencia del acomodo de los
%             productos en los estantes.
creenciaActual(Base,Creencia) :-
	buscar(objeto([reporte],_,Creencia,_),Base,C),
	creenciaActual(C,Creencia).

creenciaActual(objeto(_,_,Obs,_),Obs).


% Dada una lista de observaciones y una creencia,
% la actualiza en el orden en que se van analizando
% las observaciones.
%    Arg. 1 - La lista de observaciones.
%    Arg. 2 - La creencia.
%    Arg. 3 - La creencia actualizada
% Opcion 1 de asignarPosiciones
asignarPosiciones([],Creencia,Creencia).

asignarPosiciones(L,Creencia,NuevaCreencia):-
	last(L,Ultima),
	delete(L,Ultima,ParaIgnorar),
	eliminarTodos(ParaIgnorar,Creencia,AModificar),
	mezcla(Ultima,AModificar,Asignados),
	concatena(ParaIgnorar,Asignados,NuevaCreencia).

%Cod 2 - Alternativa de  de asignar posiciones(no se usó)
%asignarPosiciones([],Creencia,Creencia).
%
%asignarPosiciones(L,Creencia,NuevaCreencia):-
%	last(L,Ultima),
%	delete(L,Ultima,ParaIgnorar),
%	guardaPosiciones(Creencia,ParaIgnorar,Posiciones),
%	eliminarTodos(ParaIgnorar,Creencia,AModificar),
%	mezcla(Ultima,AModificar,Asignados),
%	reestableceEnPosiciones(ParaIgnorar,Posiciones,Asignados%,NuevaCreencia).


% Dada una observación (ei => [...]) y una creencia,
% primero compara los productos que difieran en ei.
% Los que están perdidos los acomoda en otros estantes
% aleatoriamente; los que no se sabía que estaban ahí,
% primero se verifica si no están en otro lado, en caso
% contrario se colocan en ei.
%    Arg. 1 - La observación.
%    Arg. 2 - La creencia en ese momento(lista).
%    Arg. 3 - La creencia actualizada.
mezcla(Estante => ContenidoObs, Creencia, NuevaCreencia):-
	insertaObservacion(Estante => ContenidoObs,Creencia,P1),
	valorFlecha(Estante,Creencia,ContenidoSup),
	restar(ContenidoSup,ContenidoObs,Perdidos),
	restar(ContenidoObs,ContenidoSup,Agregados),
	repartePerdidos(Estante,Perdidos,P1,P2),
	eliminaNoPresentes(Estante,Agregados,P2,NuevaCreencia),!.


% Reparte aleatoriamente productos que no están en
% su lugar (no se toma en cuenta el estante donde
% se encontraron)
%    Arg. 1 - El estante que se va a ignorar.
%    Arg. 2 - Lista de productos a acomodar.
%    Arg. 3 - Lista de ubicaciones.
%    Arg. 4 - Nueva lista de ubicaciones actualizada.
repartePerdidos(_,[],L,L).

repartePerdidos(Ignorado,[X|T],L,N):-
	repartePerdidosAux(Ignorado,X,L,R),
	repartePerdidos(Ignorado,T,R,N).

repartePerdidosAux(Ignorado,X,L,N):-
	nth1(Indice,L,Ignorado => Cont,P),
	random_member(E=>C,P),
	select(E=>C,P,E=>[X|C],I),
	nth1(Indice,N,Ignorado => Cont,I),!.

% Elimina de otros estantes los productos que bajo
% una observación (ei => [...]) se encontraron y en
% el reporte no está registrado que ahi se encuentran.
% Se omitirá el estante ei de la observación ya que
% ahi están ubicados esos productos
%    Arg. 1 - Estante que se va a ignorar.
%    Arg. 2 - Lista de productos a borrar.
%    Arg. 3 - Lista de ubicaciones.
%    Arg. 3 - Lista de ubicaciones verificada.
eliminaNoPresentes(_,[],L,L).

eliminaNoPresentes(Ignorado,B,L,N):-
	nth1(Indice,L,Ignorado => Cont,P),
	borraDeListaUbicaciones(B,P,I),
	nth1(Indice,N,Ignorado => Cont,I),!.



% Obtiene lista de locaciones actual
listaLocaciones([],[]).

listaLocaciones([X=>_|T],[X|C]):-
	listaLocaciones(T,C).

% Obtiene la losta de productos
listaProductos([],[]).

listaProductos([_=>Y|T],[Y|C]):-
	listaProductos(T,C).

quitaVacios([],[]).

quitaVacios([_=>[]|T],C):-
	quitaVacios(T,C),!.

quitaVacios([X=>Y|T],[X=>Y|C]):-
	quitaVacios(T,C).

transformar([inicio=>[],X=>Y|T],[mover(inicio,X)|C]):-
	escribirObjetos(Y,YS),
	transformar(X,T,R),
	concatena(YS,R,C),!.

transformar(Fin,[],[mover(Fin,inicio)]).

transformar(X,[Y=>Z|T],[mover(X,Y)|C]):-
	escribirObjetos(Z,ZS),
	transformar(Y,T,R),
	concatena(ZS,R,C),!.

escribirObjetos([],[]).

escribirObjetos([H|T],[colocar(H)|C]):-
	escribirObjetos(T,C).




% Utilidades--------------------------------------------------------

% Dado un estante ei y una lista de estantes, devuelve
% su lista de productos.
% En este caso buscamos valores asociados con el
% operador flecha "=>"
valorFlecha(X,[X=>Y|_],Y).
valorFlecha(X,[F=>_|T],R):-
	X \= F,
	valorFlecha(X,T,R),!.


% Introduce una observación (ei => [..])  dentro de
% una lista de estados, el único estado que cambia
% es ei.
%    Arg. 1 - La observación.
%    Arg. 2 - La lista de estados..
%    Arg. 3 - La lista actualizada.
insertaObservacion(_,[],[]).

insertaObservacion(X => Y,[X => _|T1],[X => Y|T2]):-
		  insertaObservacion(X => Y,T1,T2),!.

insertaObservacion(X => Y,[V => U|T1],[V => U|T2]):-
	insertaObservacion(X => Y,T1,T2),!.


% Elimina las ocurrencias de un elemento en una lista
eliminaDeLista(_,[],[]).
eliminaDeLista(H,[H|L],R):-
	eliminaDeLista(H,L,R),!.
eliminaDeLista(X,[H|L1],[H|L2]):-
	X \= H, eliminaDeLista(X,L1,L2),!.

% Elimina todas las ocurrecias de los elementos de
% una lista en otra
eliminaVariosDeLista([],L,L).

eliminaVariosDeLista([H|T],L,R):-
	eliminaDeLista(H,L,N),
	eliminaVariosDeLista(T,N,R),!.

% Elimina todas las ocurrecias de los elementos de
% una lista en una lista de ubicaciones de nuestra
% base.
borraDeListaUbicaciones(_,[],[]).

borraDeListaUbicaciones(B,[X => E|T],[X => M|C]):-
	eliminaVariosDeLista(B,E,M),
	borraDeListaUbicaciones(B,T,C),!.

% Guarda posiciones de ciertos elementos de una lista
guardaPosiciones(_,[],[]).
guardaPosiciones(L,[H|T],[N|P]):-
	nth1(N,L,H,_),
	guardaPosiciones(L,T,P),!.

% Reestablece elementos en ciertas posiciones en una lista
reestableceEnPosiciones([],[],R,R).

reestableceEnPosiciones([Elem|T],[Pos|C],Asignados,Resultado):-
	nth1(Pos,Parcial,Elem,Asignados),
	reestableceEnPosiciones(T,C,Parcial,Resultado).
