% INSTRUCTIONS
% =swipl echo-server.pl=
% =:- start_server.=
%
% Then navigate to http://localhost:3000 in your browser


:- module(echo_server,
  [ start_server/0,
    stop_server/0
  ]
).


:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_files)).
:- use_module(library(http/websocket)).
:- use_module(library(http/http_path)).
:- use_module(library(http/http_server_files)).
:- use_module(library(lists)).
:- include('chatbot.pl').
:- include('tablepion.pl').

http:location(js,	root(js), []).
http:location(css,	root(css), []).

:- multifile user:file_search_path/2.

user:file_search_path(js,'../web/js').
user:file_search_path(css,'../web/css').

% http_handler docs: http://www.swi-prolog.org/pldoc/man?predicate=http_handler/3
% =http_handler(+Path, :Closure, +Options)=
%
% * root(.) indicates we're matching the root URL
% * We create a closure using =http_reply_from_files= to serve up files
%   in the local directory
% * The option =spawn= is used to spawn a thread to handle each new
%   request (not strictly necessary, but otherwise we can only handle one
%   client at a time since echo will block the thread)
:- http_handler(root(.),
                http_reply_from_files('../web/.', []),
                [prefix]).

:- http_handler(js(.),
                serve_files_in_directory(js),
                [prefix]).

:- http_handler(css(.),
                serve_files_in_directory(css),
                [prefix]).

% * root(echo) indicates we're matching the echo path on the URL e.g.
%   localhost:3000/echo of the server
% * We create a closure using =http_upgrade_to_websocket=
% * The option =spawn= is used to spawn a thread to handle each new
%   request (not strictly necessary, but otherwise we can only handle one
%   client at a time since echo will block the thread)
:- http_handler(root(echo),
                http_upgrade_to_websocket(echo, []),
                [spawn([])]).

start_server :-
    default_port(Port),
    start_server(Port).
start_server(Port) :-
    http_server(http_dispatch, [port(Port)]).

stop_server() :-
    default_port(Port),
    stop_server(Port).
stop_server(Port) :-
    http_stop_server(Port, []).

default_port(3000).

%! echo(+WebSocket) is nondet.
% This predicate is used to read in a message via websockets and echo it
% back to the client
echo(WebSocket) :-
    ws_receive(WebSocket, Message, [format(json)]),
    ( Message.opcode == close
    -> true
    ; choice(Message.data.type,Message,Response),
      ws_send(WebSocket, json(Response)),
      echo(WebSocket)
    ).

%! get_response(+Message, -Response) is det.
% Pull the message content out of the JSON converted to a prolog dict
% then add the current time, then pass it back up to be sent to the
% client

choice("msg",Message,Response):- get_response_chatbot(Message.data,Response).
choice("play",Message,Response):- get_response_player(Message.data, Response).
choice("barr",Message,Response):- get_response_barr(Message.data, Response).
choice("ia",Message,Response):- get_response_IA(Message.data, Response).


get_response_player(Message, Response) :-
  list_list_tuple(Message.listPlayers, LSj),
  list_list_tuple(Message.listWalls, LSb),
  list_tuple(Message.posPlayerNow, PlayerNow),
  list_tuple(Message.posPlayer, PlayerMov),
  aprouved(LSj,LSb,PlayerNow,PlayerMov)
  -> Response = _{type:"play",message:"true"}; Response = _{message:"false"}.

get_response_barr(Message, Response) :-
   list_list_tuple(Message.listPlayers, LSj),
   list_list_tuple(Message.listWalls, LSb),
   list_tuple(Message.posPlayer, Player),
   list_tuple(Message.posBarr, Barr),
   aprouved(LSj,LSb,Player,Barr)
   -> Response = _{type:"barr",message:"true"}; Response = _{message:"false"}.

get_response_IA(Message, Response) :-
   list_list_tuple(Message.listPlayers, LSj),
   list_list_tuple(Message.listWalls, LSb),
   iA(LSj, LSb, Message.color, Return),
   tuple_to_string(Return, X, Y, O),
   Response =_{type:"ia",posX:X, posY:Y, ori:O}.



get_response_chatbot(Message, Response) :-
  quoridoria(Message.message,Solution),
  Response = _{type:"msg",message:Solution}.


list_tuple([A|[]], (A)).
list_tuple([A|T], (A,B)) :- list_tuple(T, B).

list_list_tuple([],[]).
list_list_tuple([[A,B]|T], [(A, B)|Y]) :- list_list_tuple(T, Y).
list_list_tuple([[A,B,C]|T], [(A,B,C)|Y]) :- list_list_tuple(T, Y).
list_list_tuple([[A,B,C,D]|T], [(A,B,C,D)|Y]) :- list_list_tuple(T, Y).

% tuple_to_string((A,B,C),[A,B]).

tuple_to_string((A,B,_,D),A,B,D).
tuple_to_string((A,B,_),A,B,2).

