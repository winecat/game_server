%% @author mxr
%% @doc @todo Add description to game_listener.


-module(game_listener).
-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%% ====================================================================
%% API functions
%% ====================================================================
-export([
		 start_link/1
		 ,stop/0
		]).


-include("game.hrl").

%% ====================================================================
%% Behavioural functions 
%% ====================================================================

start_link(Port) ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [Port], []).

stop() ->
	supervisor:terminate_child(game, acceptor_sup),
	supervisor:terminate_child(game, game_listener),
	ok.

%% init/1
init([Port]) ->
	TcpOpts = application:get_env(tcp_opts),
	case gen_tcp:listen(Port, TcpOpts) of
		{ok, LSocket} ->
			start_acceptor(LSocket),
			{ok, ?MODULE};
		{error, Reason} ->
			?ERR("cannot listen port :~w, reason:~w", [Port, Reason]),
			{stop, listen_fail}
	end.


%% handle_call/3
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.


%% handle_cast/2
handle_cast(_Msg, State) ->
    {noreply, State}.


%% handle_info/2
handle_info(_Info, State) ->
    {noreply, State}.


%% terminate/2
terminate(_Reason, _State) ->
    ok.


%% code_change/3
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%% Internal functions

start_acceptor(LSocket) ->
	ListenCount = application:get_env(tcp_linstener_count),
	start_acceptor(ListenCount, LSocket).

start_acceptor(0, _LSocket) -> ok;
start_acceptor(ListenCount, LSocket) ->
	{ok, Pid} = supervisor:start_child(acceptor_sup, [LSocket]),
	Pid ! loop,
	start_acceptor(ListenCount - 1, LSocket).
