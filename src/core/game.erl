%% @author mxr
%% @doc @todo Add description to game.


-module(game).
-behaviour(application).
-export([start/2, stop/1]).

%% ====================================================================
%% API functions
%% ====================================================================
-export([
		 start/0
		]).


%% -include("game.hrl").

-define(APPS, [sasl, game]).

%% ====================================================================
%% Behavioural functions
%% ====================================================================
start() ->
	io:setopts([{encoding, unicode}]),
	game_boot:start_apps(?APPS).

%% start/2
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/apps/kernel/application.html#Module:start-2">application:start/2</a>
-spec start(Type :: normal | {takeover, Node} | {failover, Node}, Args :: term()) ->
	{ok, Pid :: pid()}
	| {ok, Pid :: pid(), State :: term()}
	| {error, Reason :: term()}.
%% ====================================================================
start(_Type, _StartArgs) ->
    io:setopts([{encoding, unicode}]),
	init_error_log(),
	ok = game_code:init(),
	ok = game_boot:init_mysql(),
	ok = game_ets:init(),
	game_sup:start_link(),
	ok.

%% stop/1
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/apps/kernel/application.html#Module:stop-1">application:stop/1</a>
-spec stop(State :: term()) ->  Any :: term().
%% ====================================================================
stop(_State) ->
    ok.

%% ====================================================================
%% Internal functions
%% ====================================================================

init_error_log() ->
	LogPath = 
		case application:get_env(log_path) of
			undefined -> "./../var/";
			Var -> Var
		end,
	{{Y, M, D}, {H, I, S}} = erlang:localtime(),
	Date = io_lib:format("~w_~w_~w_~w_~w_~w", [Y, M, D, H, I, S]),
	error_logger:logfile([{open, lists:concat([LogPath, Date, ".log"])}]),
	ok.


