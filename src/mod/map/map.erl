%% @author mxr
%% @doc 场景


-module(map).
-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%% ====================================================================
%% API functions
%% ====================================================================
-export([]).

-include("map.hrl").


%% ====================================================================
%% Behavioural functions 
%% ====================================================================
-record(state, {}).

%% init/1
init([]) ->
    {ok, #state{}}.


%% handle_call/3
handle_call(Request, From, State) ->
    Reply = ok,
    {reply, Reply, State}.


%% handle_cast/2
handle_cast(Msg, State) ->
    {noreply, State}.


%% handle_info/2
handle_info(Info, State) ->
    {noreply, State}.


%% terminate/2
terminate(Reason, State) ->
    ok.


%% code_change/3
code_change(OldVsn, State, Extra) ->
    {ok, State}.


%% ====================================================================
%% Internal functions
%% ====================================================================


