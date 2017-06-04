%% 游戏看门狗进程 hrl

-ifndef(LINK_HRL).
-define(LINK_HRL, ok).

-include("game.hrl").

-record(link_state, 
		{
		 obj = undefined
		 ,type = undefined
		 ,account = <<>>
		 ,object_pid = undefined
		 ,socket = undefined
		 ,ip = {0,0,0,0}
		 ,port = 0
		 ,seq = 0
		 ,read_head = false
		 ,length = 0
		 ,recv_count = 0
		 ,send_count = 0
		 ,error_send = 0
		 ,bad_req_count = 0
		 ,bad_socket_req_count = 0
		 ,connect_time = 0
		}).

-record(link,
		{
		 socket = undefined
		 ,link_pid = undefined
		 ,ip = {0,0,0,0}
		 ,port = 0
		}).

-define(HEARTBEAT_CHECK_TIMEOUT, 120).

-endif.	%% LINK_HRL
