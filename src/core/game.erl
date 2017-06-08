%% @author mxr
%% @doc @todo Add description to game.


-module(game).
-behaviour(application).
-export([start/2, stop/1]).


-export([
		 start/0
		]).


-include("game.hrl").

-define(APPS, [sasl, game]).

start() ->
	io:setopts([{encoding, unicode}]),
	game_boot:start_apps(?APPS).

%% start/2
start(_Type, _StartArgs) ->
    io:setopts([{encoding, unicode}]),
	game_logger:logger_file(),
	ok = game_code:init(),
	ok = game_boot:init_mysql(),
	ok = game_ets:init(),
    ok = game_dets:init(),
    ok = sys_var:init(),
	game_sup:start_link(),
	ok.

%% stop/1
stop(_State) ->
    ok.

%% Internal functions



