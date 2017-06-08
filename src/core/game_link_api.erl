%% @author mxr
%% @doc @todo Add description to game_link_api.


-module(game_link_api).

%% API functions
-export([
		 init_heartbeat/0
		 ,check_heartbeat/1
		 ,read_next/1
		]).

-include("link.hrl").



init_heartbeat() ->
	erlang:put("last_heartbeat", 0),
	send_next_heartbeat().
check_heartbeat(LinkState = #link_state{}) ->
	LastHeartBeat = erlang:get("last_heartbeat"),
	NowTime = util:unixtime(),
	case (NowTime - LastHeartBeat) > ?HEARTBEAT_CHECK_TIMEOUT of
		true -> 
			{stop, normal, LinkState};
		false -> 
			send_next_heartbeat(),
			{noreply, LinkState}
	end.

read_next(#link_state{socket = Socket, recv_count = RecvCount, read_head = false} = LinkState) ->
	prim_inet:async_recv(Socket, 4, 60000),
	{noreply, LinkState#link_state{recv_count = RecvCount + 1, read_head = true}};
read_next(LinkState) -> {noreply, LinkState}.

%% service_routeing(Cmd, Bin, LinkState#link_state{}) ->
    
	
%% Internal functions

send_next_heartbeat() ->
	?cancel_timer(erlang:get("heartbeat_ref")),
	TimerRef = erlang:send_after(30000, self(), 'check_heartbeat'),
	erlang:put("heartbeat_ref", TimerRef).
	