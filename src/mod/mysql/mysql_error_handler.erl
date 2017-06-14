%%----------------------------------------------------
%% 
%% @author qingxuan
%%----------------------------------------------------
-module(mysql_error_handler).
-behaviour(gen_server).
-export([
        start/0
]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-include("game.hrl").

-record(state, {}).

start() ->
    case whereis(?MODULE) of
        undefined ->
            gen_server:start({local, ?MODULE}, ?MODULE, [], []);
        _ ->
            ok
    end.

init([]) ->
    {ok, #state{}}.

handle_call(_Request, _From, State) ->
    {noreply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info({error, Pool, Conn, Query, Msg}, State) ->
    io:format("\n"
    "======================================\n"
    "\tmysql async_exec error:\n\n"
    "\t- pool  : ~p\n"
    "\t- conn  : ~p\n"
    "\t- query : ~p\n"
    "\t- reason: ~p\n"
    "======================================\n"
    , [Pool, Conn, Query, Msg]),
    {noreply, State};

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


