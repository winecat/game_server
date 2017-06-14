%% @author mxr
%% @doc game start function modules.


-module(game_mods).

-export([
		 server_list/2
		 ]).


server_list(_Host, Port) ->
	[{acceptor_sup, {acceptor_sup, start_link, []}, permanent, 10000, supervisor, [acceptor_sup]}
    ,{game_listener, {game_listener, start_link, [Port]}, transient, 10000, worker, [game_listener]}].


%% Internal functions



