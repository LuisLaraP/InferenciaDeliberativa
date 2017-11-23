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

	
% Módulo de toma de decisiones.
%	Arg. 1 - Base de entrada.
%	Arg. 2 - Base de salida.
decision(KB, NKB) :-
	decisionPedido(KB, TKB, P),
	decisionOrdenar(TKB, P, NKB).

% Decide los productos a entregar, escribie la decision en la base de conocimiento e 
% imprime la decision en pantalla.
%       Arg. 1 - La base de conocimento de entrada.
%       Arg. 2 - La base de conocimiento de salida.
%       Arg. 3 - La lista de productos a entregar.
decisionPedido(KB, NKB, P) :- 
	pedido(KB, P),
	escribirPedido(P, KB, NKB),
	length(P, N),
	imprimePedido(P, N).

% Decide los productos a reacomodar, escribie la decision en la base de conocimiento e
% imprime la decision en pantalla.
%       Arg. 1 - La base de conocimento de entrada.
%       Arg. 2 - Los productos que se entregaran al cliente.
%       Arg. 3 - La base de conocimiento de salida.
decisionOrdenar(KB, P, NKB) :-
	ordenar(KB, TO),
	eliminaPedidoRep(P, TO, TO2),
	length(P, N),
	tomar(N, TO2, O),
	escribirOrdenar(O, KB, NKB),
	length(O, M),
	imprimeOrdenar(O, M).

% Escribe la decisión en la base de conocimiento de los productos que se van a entregar al cliente.
%       Arg. 1 - Lista de productos. 
%       Arg. 2 - Base de conocimiento de entrada.
%       Arg. 3 - Base de conocimiento de salida.
escribirPedido(L, KB, NKB) :-
	filtrar(objetoSeLlama(entregar), KB, NL),
	eliminarTodos(NL, KB, TKB),
	agregar(objeto([entregar], decisiones_robot, L, []), TKB, NKB).

% Escribe la decisión en la base de conocimiento de los productos que se van a ordenar en los estantes.
%       Arg. 1 - Lista de productos.
%       Arg. 2 - La base de conocimiento de entrada.
%       Arg. 3 - La base de conocimiento de salida.
escribirOrdenar(L, KB, NKB) :-
	filtrar(objetoSeLlama(reacomodar), KB, NL),
	eliminarTodos(NL, KB, TKB),
	agregar(objeto([reacomodar], decisiones_robot, L, []), TKB, NKB).

% Imprim en pantalla la decisión de los productos que serán entregados al cliente.
%       Arg. 1 - La lista de productos.
%       Arg. 2 - El número de elementos en la lista de productos.
imprimePedido(_, 0).

imprimePedido(P, _) :-
	writeln("He decidio entregar los siguientes productos:"),
	writeln(P).

% Imprime en pantalla la decisión de los productos que serán reacomodados.
%       Arg. 1 - La lista de productos.
%       Arg. 2 - El número de productos en la lista.
imprimeOrdenar(_, 0).
imprimeOrdenar(O, _) :-
	writeln("He decidio reacomodar los siguientes productos:"),
	writeln(O).

% Obtiene el pedido del cliente.
%       Arg. 1 - La base de conocimento de entrada.
%       Arg. 2 - La lista de productos que serán entregados al cliente.
pedido(KB, P) :-
	propiedadesObjeto(orden, KB, P).

% Obtiene los productos que serán reacomidados.
%       Arg. 1 - La base de conocimento de entrada.
%       Arg. 2 - La lista de productos.
ordenar(KB, P) :-
	fueraDeLugar(KB, R), aLista(R, P).

% Convierte una lista de triadas a una lista con la proyección del primer elemento.
%       Arg. 1 - Lista de triadas.
%       Arg. 2 - Lista de elementos.
aLista([],[]).

aLista([(A, _, _) | T], [A | NT]) :-
	aLista(T, NT).

% Elimina de la lista de reacomodo los productos que serán entregados al cliente.
%       Arg. 1 - Lista de productos a entregar.
%       Arg. 2 - Lista de productos a reacomodar.
%       Arg. 3 - Lista de productis a reacomodar sin productos a entregar.
eliminaPedidoRep([], A, A).

eliminaPedidoRep([H | P], O, NO) :-
	eliminaPedidoAux(H, O, TO),
	eliminaPedidoRep(P, TO, NO).

% Elimina un producto de la lista.
%       Arg. 1 - Producto a eliminar.
%       Arg. 2 - Lista de productos.
%       Arg. 3 - Lista sin el producto.
eliminaPedidoAux(_, [], []).

eliminaPedidoAux(H, [H | T], NT) :-
	eliminaPedidoAux(H, T, NT).

eliminaPedidoAux(H, [S | T], [S | NT]) :-
	eliminaPedidoAux(H, T, NT).

% Obtiene los elementos que no están en el estante adecuado.
%       Arg. 1 - Base de conocimiento.
%       Arg. 2 - Lista de productos fuera de lugar.
fueraDeLugar(KB, R) :-
	propiedadesObjeto(creencia, KB, L),
	procesaPropiedades(L, C),
	comparaCreencia(C, KB, A),
	eliminaCor(A, R).

% Obtiene la lista de prodcutos a ordenar de una lista de propiedades de objeto.
%       Arg. 1 - La lista de propiedades.
%       Arg. 2 - La lista de productos.
procesaPropiedades([], []).

procesaPropiedades([H | T], L) :-
	procesaPropiedades(T, L1),
	procesaEstante(H, L2),
	append(L2, L1, L).

% Obtiene una lista de pares producto estante.
%       Arg. 1 - Propiedad estante.
%       Arg. 2 - Lista de producto estante.
procesaEstante(_ => [], []).

procesaEstante(X => [H | T], [(H,X)| NT]) :-
	procesaEstante(X => T, NT).

% Entrega una lista de triadas donde la primer entrada es el  producto, la segunda el estande donde se
% encuentra el producto y la tercera el lugar en donde debería estar el producto.
%       Arg. 1 - La lista de pares producto estante.
%       Arg. 2 - La base de conocimiento.
%       Arg. 3 - La lista de triadas-
comparaCreencia([], _, []).

comparaCreencia([(O, E) | T], KB, [(O, E, P) | NT]) :-
	obtenEstante(O, KB, P),
	comparaCreencia(T, KB, NT).

% Obtiene el estante en donde debería de estar el producto.
%       Arg. 1 - Producto a buscar. 
%       Arg. 2 - Base de conocimiento.
%       Arg. 3 - Estando donde debería encontrarse el producto.
obtenEstante(O, KB, E) :-
	filtrar(objetoSeLlama(O), KB, [objeto(_, C,_,_)|_]),
	propiedadesClase(C, KB, P), estante(P, E).

% Obtoiene el numero de estante de una lista de propiedades. 
%       Arg. 1 - Lista de propiedades.
%       Arg. 2 - Estante.
estante([estante => Est | _], Est).

estante([_ | L], Est) :-
	estante(L, Est).

% Elimina productos que se encuentran en su lugar.
%       Arg. 1 - Lista de triadas producto-estante-estante.
%       Arg. 2 - Lista de triadas de productos fuera de lugar.
eliminaCor([], []).

eliminaCor([(_, B, B) | T], NT) :-
	eliminaCor(T, NT).

eliminaCor([A | T], [A | NT]) :-
	eliminaCor(T, NT).

% Elimina los productos que fueron pedidos por el cliente de la lista de triadas.
%       Arg. 1 - Orden del cliente.
%       Arg. 2 - Lista de triadas.
%       Arg. 3 - Lista de triadas sin los productos en la orden del cliente.
eliminaPedido([], A, A).

eliminaPedido([O | P], F, NP) :-
	eliminaFL(O, F, R),
	eliminaPedido(P, R, NP).

% Elimina un producto de la lista de triadas.
%       Arg. 1 - Producto a eleminar.
%       Arg. 2 -  Lista de triadas.
%       Arg. 3 - La lista de triadas sin el producto.
eliminaFL(_, [], []).
 
eliminaFL(O, [(O,_,_) | T], NT) :-
	eliminaFL(T, NT).

eliminaFL(_, [A | T], [A | NT]) :-
	eliminaFL(T, NT). 

% Entrega k elementos de la lista. 
%         Arg. 1 - El numero de elementos a entregar.
%         Arg. 2 - La lista de donde seran tomados los elementos.
%	  Arg. 3 - Los k elementos entregados.			
tomar(_, [], []).
tomar(0, _, []).
tomar(X, [H|T], [H|L]) :- Y is X - 1, tomar(Y, T, L).

