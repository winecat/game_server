%% @author mxr
%% @doc @todo Add description to game_link.


-module(game_link).
-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).


-export([
		 create_link/1
		]).

-include("game.hrl").
-include("link.hrl").


create_link(Params) ->
	gen_server:start(?MODULE, Params, []).

%% init/1
init([ClientType, Socket, Ip, Port]) ->
	erlang:process_flag(trap_exit, true),
	game_link_api:init_heartbeat(),
	LinkState = #link_state{socket = Socket, type = ClientType,
							ip = Ip, port = Port,
							connect_time = util:unixtime()},
	self() ! 'read_next', %% init read msg
	{ok, LinkState}.


%% handle_call/3
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.


%% handle_cast/2
handle_cast(_Msg, State) ->
    {noreply, State}.


%% handle_info/2

%% heartbeat check
handle_info('check_heartbeat', LinkSate) ->
	game_link_api:check_heartbeat(LinkSate);

handle_info('read_next', LinkState) ->
	game_link_api:read_next(LinkState);

%% handle data from client socket
%% <<Len:32, Seq:8, Chk:8, Cmd:32, Bin/bainry>>
handle_info({inet_async, _Socket, _Ref, {error, closed}}, LinkState) ->
	{stop, normal, LinkState};
handle_info({inet_async, Socket, _Ref, {ok, <<Len:32>>}}, #link_state{read_head = true} = LinkState) ->
	prim_inet:async_recv(Socket, Len, 80000),
	{noreply, LinkState#link_state{read_head = false, length = Len}};
handle_info({inet_async, _Socket, _Ref, {ok, <<Seq:8, Chk:8, Cmd:32, Bin/binary>>}}, 
			#link_state{seq = Seq, length = Len, read_head = false} = LinkState) ->
	%% msg checksum
	case Chk =:= (((Seq + Len) rem 134) bxor 134) of
		true -> game_link_api:service_routeing(Cmd, Bin, LinkState#link_state{seq = (Seq + 1) rem 255});
		false -> {stop, normal, LinkState}
	end;
%% same socket
handle_info({inet_async, Socket, _Ref, {ok, _Bin}},
			#link_state{socket = Socket, bad_req_count = BadReqCount} = LinkState) ->
	{noreply, LinkState#link_state{bad_req_count = BadReqCount + 1}};
%% unknow socket
handle_info({inet_async, _Socket, _Ref, {ok, _Bin}},
			#link_state{bad_socket_req_count = BadSocketReqCount} = LinkState) 
  when BadSocketReqCount =< 10 ->
	{noreply, LinkState#link_state{bad_socket_req_count = BadSocketReqCount + 1}};
handle_info({inet_async, _Socket, _Ref, {error, _Rason}}, LinkState) ->
	{stop, normal, LinkState};

handle_info(_Info, State) ->
    {noreply, State}.


%% terminate/2
terminate(_Reason, _LinkState) ->
    ok.


%% code_change/3
code_change(OldVsn, State, Extra) ->
    {ok, State}.


%% Internal functions


