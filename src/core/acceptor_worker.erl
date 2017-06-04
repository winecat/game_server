%% @author mxr
%% @doc @todo Add description to acceptor_worker.


-module(acceptor_worker).
-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

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
init([LSocket]) ->
%% 	self() ! loop,
	{ok, LSocket}.


%% handle_call/3
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.


%% handle_cast/2
handle_cast(_Msg, State) ->
    {noreply, State}.


%% handle_info/2
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
terminate(_Reason, _State) ->
    ok.


%% code_change/3
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


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