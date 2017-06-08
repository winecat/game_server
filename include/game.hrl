%% 游戏公用头文件

-ifndef(GAME_HRL).      %% GAME_HRL START
-define(GAME_HRL, ok).

%% 日志(输出到控制台)
%% 注意只输出一个Msg时不能含~w等特殊符号，否则用 ("~ts", [Utf8BinaryMsg]) 来输出
%% error会打印到文件
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


-define(cancel_timer(TimerRef), 
		case erlang:is_reference(TimerRef) of
			true -> erlang:cancel_timer(TimerRef);
			false -> skip
		end).

%% 三元表达式
-define(IF(Cond, DoTrue, DoElse),
		case Cond of
			true -> DoTrue;
			_ -> DoElse
		end
	   ).

-endif.	%% GAME_HRL END
