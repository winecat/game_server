%%%------------------------------------------------
%%% File    : link.hrl
%%% Description:  socket link 定义
%%%------------------------------------------------
-ifndef(LINK_HRL).        %% LINK_HRL START
-define(LINK_HRL, ok).



%% flash跨域策略文件内容
-define(FL_POLICY_FILE, <<"<cross-domain-policy><allow-access-from domain='*' to-ports='*' /></cross-domain-policy>">>).
%% 游戏客户端握手消息
-define(SOCKET_INFO_NORMAL, <<"game client @#$%$EDEE^TSWS#%">>).
%% 游戏客户端握手消息
-define(SOCKET_INFO_TESTER, <<"game tester $#SE$S#SER$">>).
%% flash策略文件请求
-define(CLIENT_FL_POLICY_REQ, <<"<policy-file-request/>\0">>).


-define(CLIENT_TYPE_GAME, 0).
-define(CLIENT_TYPE_TESTER 1).


-record(link_state,
        {
         socket = undefined 
         ,type = 0
         ,ip = undefined
         ,port = undefined
         ,connect_time = 0
         ,read_head = false
         ,seq = 0
         ,recv_count = 0
        }).


%% -record(conn, {
%%                object = ?NULL,      %% 控制对象
%%                type = 0,            %% 连接器类型
%%                account = <<>>,      %% 连接器的所有者帐号名
%%                pid_object = ?NULL,  %% 控制对象pid
%%                socket = ?NULL,      %% socket
%%                ip = {0,0,0,0},      %% 客户端IP
%%                port = 0,            %% 客户端连接端口
%%                connect_time = 0,    %% 建立连接的时间
%%                read_head = false,   %% 标识正在读取数据包头
%%                recv_count = 0,      %% 已接收的消息数量
%%                send_count = 0,      %% 已发送的消息数量
%%                error_send = 0,      %% 发送错误次数
%%                bad_req_count = 0    %% 记录客户端发送的错误数据包个数
%%               }).

-endif. %% LINK_HRL END
