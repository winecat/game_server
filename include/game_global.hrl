%%全局变量定义

-ifndef(GAME_GLOBAL_HRL).      %% GAME_GLOBAL_HRL START
-define(GAME_GLOBAL_HRL, ok).


-type type_error() :: 'erlang exception error'.
-define(TYPE_ERROR(MSG, ARGS), erlang:error(MSG, ARGS)).

%% 用户自定义 global_ 开头
%%
-define(GLOBAL_TEST, global_test).    %% 测试key
-define(GLOBAL_OPEN_TIME, global_open_time).  %%开服时间

%% 后台使用便令定义 sys_ 开头
-define(SYS_MERGE_TIME, sys_merge_time).

-endif.      %% GAME_GLOBAL_HRL END