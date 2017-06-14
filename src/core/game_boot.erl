%% @author mxr
%% @doc @todo apps boot


-module(game_boot).

-include("game.hrl").
-include("db.hrl").

-export([
		 start_apps/1
		 ,stop_apps/1
		 ,init_mysql/0
		]).


apps_control(Iterate, Do, Undo, 
			 InterruptError, ErrorNotice, 
			 Apps) ->
	Fun = fun(App, AccIn) ->
				  case Do(App) of
					  ok -> [App|AccIn];
					  {error, {InterruptError, _}} -> AccIn;
					  {error, Reason} ->
						  lists:foreach(Undo, AccIn),
						  throw({error, {ErrorNotice, App, Reason}})
				  end
		  end,
	Iterate(Fun, [], Apps).

start_apps(Apps) ->
	apps_control(
	  fun lists:foldl/3
	  ,fun application:start/1
	  ,fun application:stop/1
	  ,already_started
	  ,cannot_start_application
	  ,Apps
				).

stop_apps(Apps) ->
	apps_control(
	  fun lists:foldl/3
	  ,fun application:start/1
	  ,fun application:stop/1
	  ,already_started
	  ,cannot_start_application
	  ,lists:reverse(Apps)
				).

init_mysql() ->
    {ok, DbHost, DBPort, DBUser, DBPWD, DBName, DBEnCode, DBSYNCPool, DBASYNCPool, DBLogPool} = application:get_env(db_conf),
    ok = init_mysql_pool(msyql, ?DB_SYNC_POOL, DbHost, DBPort, DBUser, DBPWD, DBName, DBEnCode, DBSYNCPool),
    ok = init_mysql_pool(msyql, ?DB_ASYNC_POOL, DbHost, DBPort, DBUser, DBPWD, DBName, DBEnCode, DBASYNCPool),
    ok = init_mysql_pool(msyql_log, ?DB_LOG_POOL, DbHost, DBPort, DBUser, DBPWD, DBName, DBEnCode, DBLogPool),
    ok.

init_mysql_pool(MOD, DBPoolId, DbHost, DBPort, DBUser, DBPWD, DBName, DBEnCode, DBConNum) ->
    MOD:start_link(DBPoolId, DbHost, DBPort, DBUser, DBPWD, DBName, fun(_, _, _, _) -> ok end, DBEnCode), %% 与mysql数据库建立连接
    util:for(1, DBConNum,
             fun(_I) -> MOD:connect(DBPoolId, DbHost, DBPort, DBUser, DBPWD, DBName, DBEnCode, true)
             end
            ),
    ?INFO(" start mysql ~w:~w，connect num is ~w", [MOD, DBPoolId, DBConNum]),
    ok.
