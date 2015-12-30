%% @author mxr
%% @doc @todo Add description to game_sup.


-module(game_sup).
-behaviour(supervisor).
-export([init/1]).

%% ====================================================================
%% API functions
%% ====================================================================
-export([
		 start_link/0
		]).



%% ====================================================================
%% Behavioural functions 
%% ====================================================================
start_link() ->
	Host = application:get_env(host),
	Port = application:get_env(port),
	supervisor:start_link({local, ?MODULE}, ?MODULE, [Host, Port]).

%% init/1
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/supervisor.html#Module:init-1">supervisor:init/1</a>
-spec init(Args :: term()) -> Result when
	Result :: {ok, {SupervisionPolicy, [ChildSpec]}} | ignore,
	SupervisionPolicy :: {RestartStrategy, MaxR :: non_neg_integer(), MaxT :: pos_integer()},
	RestartStrategy :: one_for_all
					 | one_for_one
					 | rest_for_one
					 | simple_one_for_one,
	ChildSpec :: {Id :: term(), StartFunc, RestartPolicy, Type :: worker | supervisor, Modules},
	StartFunc :: {M :: module(), F :: atom(), A :: [term()] | undefined},
	RestartPolicy :: permanent
				   | transient
				   | temporary,
	Modules :: [module()] | dynamic.
%% ====================================================================
init([Host, Port]) ->
	StartList = game_start:start_list(),
	FinalList = server_list(Host, Port),
	List = StartList ++ FinalList,
	{ok,{{one_for_one,0,1}, List}}.

%% ====================================================================
%% Internal functions
%% ====================================================================
server_list(_Host, Port) ->
	[{acceptor_sup, {acceptor_sup, start_link, []}, permanent, 10000, supervisor, [acceptor_sup]}
	 ,{game_listener, {game_listener, start_link, [Port]}, transient, 10000, worker, [game_listener]}].

