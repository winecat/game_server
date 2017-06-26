%% db mysql hrl

-ifndef(DB_HRL).       %% DB_HRL START
-define(DB_HRL, ok).

-include("game.hrl").

-define(DB_SYNC_POOL, mysql_sync_pool).
-define(DB_ASYNC_POOL, mysql_async_pool).
%% -define(DB_LOG_POOL, mysql_log_pool).


%%数据库
-define(DB_GAME_POOL, gs_mysql_game_conn).
-define(DB_LOG_POOL, gs_mysql_log_conn).

-record(db_result, 
        {
         affected_rows = 0 %% integer()
         ,insert_id = 0 %% integer()
         ,rows = [] %% [[term()]]
        }).

-endif.     %% DB_HRL END