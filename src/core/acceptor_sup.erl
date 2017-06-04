%% @author mxr
%% @doc @todo Add description to acceptor_sup.


-module(acceptor_sup).
-behaviour(supervisor).
-export([init/1]).


-export([
		 start_link/0
		 ]).

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% init/1
init([]) ->
	AChild = {acceptor_worker,{acceptor_worker,start_link,[]},
			  permanent,2000,worker,[acceptor_worker]},
	{ok, {{simple_one_for_one, 10, 100}, [AChild]}}.



