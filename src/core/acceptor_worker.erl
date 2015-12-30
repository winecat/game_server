%% @author mxr
%% @doc @todo Add description to acceptor_worker.


-module(acceptor_worker).
-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%% ====================================================================
%% API functions
%% ====================================================================
-export([
		 start_link/1
		 ]).

-include("game.hrl").

%% flash跨域策略文件内容
-define(FL_POLICY_FILE, <<"<cross-domain-policy><allow-access-from domain='*' to-ports='*' /></cross-domain-policy>">>).
%% 游戏客户端握手消息
-define(SOCKET_INFO_NORMAL, <<"game_client------------">>).
%% 游戏客户端握手消息
-define(SOCKET_INFO_TESTER, <<"game_tester------------">>).
%% flash策略文件请求
-define(CLIENT_FL_POLICY_REQ, <<"<policy-file-request/>\0">>).

%% ====================================================================
%% Behavioural functions 
%% ====================================================================

start_link(LSocket) ->
	gen_server:start_link(?MODULE, [LSocket], []).

%% init/1
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:init-1">gen_server:init/1</a>
-spec init(Args :: term()) -> Result when
	Result :: {ok, State}
			| {ok, State, Timeout}
			| {ok, State, hibernate}
			| {stop, Reason :: term()}
			| ignore,
	State :: term(),
	Timeout :: non_neg_integer() | infinity.
%% ====================================================================
init([LSocket]) ->
%% 	self() ! loop,
	{ok, LSocket}.


%% handle_call/3
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:handle_call-3">gen_server:handle_call/3</a>
-spec handle_call(Request :: term(), From :: {pid(), Tag :: term()}, State :: term()) -> Result when
	Result :: {reply, Reply, NewState}
			| {reply, Reply, NewState, Timeout}
			| {reply, Reply, NewState, hibernate}
			| {noreply, NewState}
			| {noreply, NewState, Timeout}
			| {noreply, NewState, hibernate}
			| {stop, Reason, Reply, NewState}
			| {stop, Reason, NewState},
	Reply :: term(),
	NewState :: term(),
	Timeout :: non_neg_integer() | infinity,
	Reason :: term().
%% ====================================================================
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.


%% handle_cast/2
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:handle_cast-2">gen_server:handle_cast/2</a>
-spec handle_cast(Request :: term(), State :: term()) -> Result when
	Result :: {noreply, NewState}
			| {noreply, NewState, Timeout}
			| {noreply, NewState, hibernate}
			| {stop, Reason :: term(), NewState},
	NewState :: term(),
	Timeout :: non_neg_integer() | infinity.
%% ====================================================================
handle_cast(_Msg, State) ->
    {noreply, State}.


%% handle_info/2
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:handle_info-2">gen_server:handle_info/2</a>
-spec handle_info(Info :: timeout | term(), State :: term()) -> Result when
	Result :: {noreply, NewState}
			| {noreply, NewState, Timeout}
			| {noreply, NewState, hibernate}
			| {stop, Reason :: term(), NewState},
	NewState :: term(),
	Timeout :: non_neg_integer() | infinity.
%% ====================================================================
handle_info(loop, LSocket) ->
	case gen_tcp:accept(LSocket) of
		{ok, Socket} ->
			gen_tcp:controlling_process(Socket, erlang:spawn(fun() -> accept(Socket) end)),
			self() ! loop;
		{error, Reason} ->
			?ERR("listen socket error :~w", [Reason]),
			skip
	end,
	{noreply, LSocket};

handle_info(_Info, State) ->
    {noreply, State}.


%% terminate/2
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:terminate-2">gen_server:terminate/2</a>
-spec terminate(Reason, State :: term()) -> Any :: term() when
	Reason :: normal
			| shutdown
			| {shutdown, term()}
			| term().
%% ====================================================================
terminate(_Reason, _State) ->
    ok.


%% code_change/3
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:code_change-3">gen_server:code_change/3</a>
-spec code_change(OldVsn, State :: term(), Extra :: term()) -> Result when
	Result :: {ok, NewState :: term()} | {error, Reason :: term()},
	OldVsn :: Vsn | {down, Vsn},
	Vsn :: term().
%% ====================================================================
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%% ====================================================================
%% Internal functions
%% ====================================================================
accept(Socket) ->
	case gen_tcp:recv(Socket, 23, 10000) of
		{ok, ?CLIENT_FL_POLICY_REQ} ->%%策略文件
			gen_tcp:send(Socket, ?FL_POLICY_FILE),
			gen_tcp:close();
		{ok, ?SOCKET_INFO_NORMAL} -> create_connection(?CLIENT_TYPE_GAME, Socket);
		{ok, ?SOCKET_INFO_TESTER} -> create_connection(?CLIENT_TYPE_TESTER, Socket);
		_Else ->
			?DEBUG("build link fail :~w, socket info {IP,Port}}:~w", [_Else, inet:peername(Socket)]),
			gen_tcp:close(Socket)
	end.

create_connection(ClientType, Socket) ->
	try
		{ok, {Ip, Port}} = inet:peername(Socket),
		{ok, Pid} = game_link:create_link([ClientType, Socket, Ip, Port]),
		ok = gen_tcp:controlling_process(Socket, Pid),
		?DEBUG("成功建立一个新连接(类型:~p),(socket:~p)", [ClientType, Socket])
	catch
		T:X ->
			?ERR("建立连接失败[~w : ~w]", [T, X]),
			gen_tcp:close(Socket)
	end.