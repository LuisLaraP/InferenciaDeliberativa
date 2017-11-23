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

%:- op(800, xfx, '=>').


%:-['conceptual/consultas'].
%:-['conceptual/listas'].
%:-['conceptual/modificar'].
%:-['conceptual/operaciones'].
%:-['conceptual/utilidades'].


%leerBase(X) :- open('bases/ejemplo', read, Archivo), read(Archivo, X),close(Archivo).

%escribeBase(X) :- open('bases/salida', write, Archivo), writeq(Archivo, X), put_char(Archivo, .), close(Archivo).
	
% Módulo de toma de decisiones.
%	Arg. 1 - Base de entrada.
%	Arg. 2 - Base de salida.
decision(KB, NKB) :- pedido(KB, P), escribirPedido(P, KB, TKB), ordenar(TKB, O),  eliminaPedidoRep(P, O, TO),escribirOrdenar(TO, TKB, NKB).

% Escribe la decisión en la base de conocimiento de los productos que se van a entregar al cliente.
escribirPedido(L, KB, NKB) :- filtrar(objetoSeLlama(entregar), KB, NL), eliminarTodos(NL, KB, TKB), agregar(objeto([entregar], decisiones_robot, L, []), TKB, NKB).

% Escribe la decisión en la base de conocimiento de los productos que se van a ordenar en los estantes.
escribirOrdenar(L, KB, NKB) :- filtrar(objetoSeLlama(reacomodar), KB, NL), eliminarTodos(NL, KB, TKB), agregar(objeto([reacomodar], decisiones_robot, L, []), TKB, NKB).

% Obtiene el pedido del cliente.
pedido(KB, P) :- propiedadesObjeto(orden, KB, P).

ordenar(KB, P) :- fueraDeLugar(KB, R), aLista(R, P).

aLista([],[]).
aLista([(A, _, _) | T], [A | NT]) :- aLista(T, NT).

eliminaPedidoRep([], A, A).
eliminaPedidoRep([H | P], O, NO) :- eliminaPedidoAux(H, O, TO), eliminaPedidoRep(P, TO, NO).

eliminaPedidoAux(_, [], []).
eliminaPedidoAux(H, [H | T], NT) :- eliminaPedidoAux(H, T, NT).
eliminaPedidoAux(H, [S | T], [S | NT]) :-  eliminaPedidoAux(H, T, NT).
	
fueraDeLugar(KB, R) :- propiedadesObjeto(creencia, KB, L), procesaPropiedades(L, C), comparaCreencia(C, KB, A), eliminaCor(A, R).

procesaPropiedades([], []).
procesaPropiedades([H | T], L) :- procesaPropiedades(T, L1), procesaEstante(H, L2), append(L2, L1, L).

procesaEstante(_ => [], []).
procesaEstante(X => [H | T], [(H,X)| NT]) :- procesaEstante(X => T, NT).

comparaCreencia([], _, []).
comparaCreencia([(O, E) | T], KB, [(O, E, P) | NT]) :- obtenEstante(O, KB, P), comparaCreencia(T, KB, NT).

obtenEstante(O, KB, E) :- filtrar(objetoSeLlama(O), KB, [objeto(_, C,_,_)|_]), propiedadesClase(C, KB, P), estante(P, E).
	
estante([estante => Est | _], Est).
estante([_ | L], Est) :- estante(L, Est).

eliminaCor([], []).
eliminaCor([(_, B, B) | T], NT) :- eliminaCor(T, NT).
eliminaCor([A | T], [A | NT]) :- eliminaCor(T, NT).

eliminaPedido([], A, A).
eliminaPedido([O | P], F, NP) :- eliminaFL(O, F, R), eliminaPedido(P, R, NP).

eliminaFL(_, [], []).
eliminaFL(O, [(O,_,_) | T], NT) :- eliminaFL(T, NT).
eliminaFL(_, [A | T], [A | NT]) :- eliminaFL(T, NT). 
