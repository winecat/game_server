%% 游戏看门狗进程 hrl

-ifndef(LINK_HRL).  %% LINK_HRL START
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

%% CLIENT TYPE
-define(CLIENT_TYPE_GAME, type_normal).
-define(CLIENT_TYPE_TESTER, type_tester).

%% flash跨域策略文件内容
-define(FL_POLICY_FILE, <<"<cross-domain-policy><allow-access-from domain='*' to-ports='*' /></cross-domain-policy>">>).
%% 游戏客户端握手消息
-define(SOCKET_INFO_NORMAL, <<"game_client #@DSerkseiwe">>).
%% 游戏客户端握手消息
-define(SOCKET_INFO_TESTER, <<"game_tester dil4309e3p49sp4e">>).
%% flash策略文件请求
-define(CLIENT_FL_POLICY_REQ, <<"<policy-file-request/>\0">>).

-endif.	    %% LINK_HRL END
