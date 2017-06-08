%% @author mxr
%% @doc @todo Add description to game_sup.


-module(game_sup).
-behaviour(supervisor).
-export([init/1]).

%% API functions
-export([
		 start_link/0
		]).




%% Behavioural functions 
start_link() ->
    [Host, Port|_] = init:get_arguments(),
	supervisor:start_link({local, ?MODULE}, ?MODULE, [Host, Port]).

%% init/1
init([Host, Port]) ->
	StartList = game_start:start_list(),
	FinalList = game_mods:server_list(Host, Port),
	List = StartList ++ FinalList,
	{ok,{{one_for_one,0,1}, List}}.

%% Internal functions


