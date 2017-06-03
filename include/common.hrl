%%%------------------------------------------------
%%% File    : common.hrl
%%% Description:  公共模块  定义
%%%------------------------------------------------
-ifndef(COMMON_HRL).        %% COMMON_HRL START
-define(COMMON_HRL, ok).


%%错误处理
%% 日志(输出到控制台)
%% 注意只输出一个Msg时不能含~w等特殊符号，否则用 ("~ts", [Utf8BinaryMsg]) 来输出
-ifdef(debug).
-define(DEBUG(Msg), logger:debug(Msg, [], ?MODULE, ?LINE)).
-define(DEBUG(F,A), logger:debug(F, A, ?MODULE, ?LINE)).
-define(INFO(Msg), logger:info(Msg, [], ?MODULE, ?LINE)).
-define(INFO(F,A), logger:info(F, A, ?MODULE, ?LINE)).
-define(ERR(Msg), logger:error(Msg, [], ?MODULE, ?LINE)).
-define(ERR(F,A), logger:error(F, A, ?MODULE, ?LINE)).
-else.
-define(DEBUG(Msg), ok).
-define(DEBUG(F,A), ok).
-define(INFO(Msg), catch logger:info(Msg, [], ?MODULE, ?LINE)).
-define(INFO(F,A), catch logger:info(F, A, ?MODULE, ?LINE)).
-define(ERR(Msg), catch logger:error(Msg, [], ?MODULE, ?LINE)).
-define(ERR(F,A), catch logger:error(F, A, ?MODULE, ?LINE)).
-endif.


%% 取消定时器
-define(cancel_timer(TimerRef),
    case is_reference(TimerRef) of
        false -> ok;
        true -> erlang:cancel_timer(TimerRef)
    end
).

-endif. %% COMMON_HRL END
