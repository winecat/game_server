%% %%----------------------------------------------------
%% %% @doc 数据库API封装
%% %% 
%% %% @type sql() = string() | binary(). SQL语句，带参数时，可用~s代替，示例：select * from role where id=~s
%% %% @type argument() = integer() | float() | string() | binary(). sql参数
%% %% @type arguments() = [argument()]. sql参数列表
%% %% @type db() = atom(). DB连接池
%% %% @type table() = atom(). 数据表名
%% %% @type field() = atom(). 字段名
%% %% @type value() = integer() | float() | binary(). 结果集中，一个字段的值
%% %% @type row() = [value()]. 一行数据
%% %% @type rows() = [row()].  几行数据
%% %% 
%% %% @author yeahoo2000@gmail.com
%% %% @end
%% %%----------------------------------------------------
-module(db_log).
%% -export(
%%     [
%%         test/1
%%         ,execute/1
%%         ,execute/2
%%         ,try_exec/1
%%         ,try_exec/2
%%         ,cast/1
%%         ,cast/2
%%         ,execute2/2
%%         ,spec_execute/2
%%         ,spec_execute/3
%%         ,select_limit/3
%%         ,select_limit/4
%%         ,get_one/1
%%         ,get_one/2
%%         ,spec_get_one/2
%%         ,get_row/1
%%         ,get_row/2
%%         ,spec_get_row/3
%%         ,get_all/1
%%         ,get_all/2
%%         ,spec_get_all/2
%%         ,get_insert_sql/2
%%         ,get_insert_sql/3
%%         ,get_update_sql/3
%%         ,format_sql/2
%%         ,last_insert_id/0
%%         ,insert/3
%%         ,batch_insert/2
%%         ,tx/1               %% 事务
%%         ,format/2
%%         ,conn_info/0        %% 连接信息
%%         ,microtime/0
%%     ]
%% ).
%% -include("game.hrl").
%% -include("db.hrl").
%% -include("emysql.hrl").
%% 
%% %% db日志开关
%% -define(db_log_enabled, 'true').
%% -ifdef(db_log_enabled).
%%     -ifdef(debug).
%%     -define(profile_start, (BeginTime_ = microtime())).
%%     -define(profile(Sql), db_prof:log(Sql, round(microtime()-BeginTime_)/1000000)).
%%     -else.
%%     -define(profile_start, ignore).
%%     -define(profile(_Sql), ignore).
%%     -endif.
%% -else.
%%     -define(profile_start, ignore).
%%     -define(profile(_Sql), ignore).
%% -endif.
%% 
%% %% 取得当前毫秒
%% microtime() ->
%%     {_M, S, Micro} = erlang:now(),
%%     S*1000000 + Micro.
%% 
%% %% @spec execute(sql()) -> integer()
%% %% @doc 执行一个SQL查询,返回影响的行数
%% execute(Sql) ->
%%     ?profile_start,
%%     Result = case mysql_log:fetch(?DB_LOG_POOL, Sql) of
%%         {updated, #mysql_result{affectedrows = R}} -> R;
%%         {error, #mysql_result{error = Reason}} -> mysql_halt([Sql, Reason]);
%%         {error, _Reason} -> erlang:error({db_error, [_Reason]})
%%     end,
%%     ?profile(Sql),
%%     Result.
%% 
%% %% @spec execute(sql(), arguments()) -> integer()
%% %% @doc <pre>带参数执行一个SQL语句，返回影响的行数
%% %% 使用方法：db_log:execute("UPDATE role SET coin=~s WHERE name=~s", [10000, "test"]).
%% %% </pre>
%% execute(Sql, Args) ->
%%     Query = format_sql(Sql, Args),
%%     ?profile_start,
%%     Result = case mysql_log:fetch(?DB_LOG_POOL, Query) of
%%         {updated, #mysql_result{affectedrows = R}} -> R;
%%         {error, #mysql_result{error = Reason}} -> mysql_halt([Query, Reason]);
%%         {error, _Reason} -> erlang:error({db_error, [_Reason]})
%%     end,
%%     ?profile(Sql),
%%     Result.
%% 
%% %% @spec execute2(sql(), arguments()) -> integer()
%% %% @doc 带参数执行一个SQl，不返回任何信息
%% execute2(Sql, Args) ->
%%     Query = format_sql(Sql, Args),
%%     ?profile_start,    
%%     Result = try mysql_log:fetch(?DB_LOG_POOL, Query) of
%%         _Any -> ok
%%     catch
%%         _:_ -> error
%%     end,
%%     ?profile(Sql),
%%     Result.
%% 
%% %% -> int() | {error, timeout} | {error, Reason} 
%% try_exec(Sql) ->
%%     try execute(Sql) 
%%     catch 
%%         A : B = {timeout, _} ->
%%             %?ERR("~p : ~p : ~p", [A, B, erlang:get_stacktrace()]),
%%             ?ERR("~p : ~p", [A, B]),
%%             {error, timeout};
%%         A : B -> 
%%             ?ERR("~p : ~p : ~p", [A, B, erlang:get_stacktrace()]),
%%             %?ERR("~p : ~p", [A, B]),
%%             {error, B}
%%     end.
%% 
%% %% -> int() | {error, timeout} | {error, Reason} 
%% try_exec(Sql, Args) ->
%%     try execute(Sql, Args) 
%%     catch 
%%         A : B = {timeout, _} ->
%%             %?ERR("~p : ~p : ~p", [A, B, erlang:get_stacktrace()]),
%%             ?ERR("~p : ~p", [A, B]),
%%             {error, timeout};
%%         A : B -> 
%%             ?ERR("~p : ~p : ~p", [A, B, erlang:get_stacktrace()]),
%%             %?ERR("~p : ~p", [A, B]),
%%             {error, B}
%%     end.
%% 
%% %% -> ok
%% cast(Sql) ->
%%     ?profile_start,
%%     mysql_log:async_exec(?DB_LOG_POOL, Sql),
%%     ?profile(Sql),
%%     ok.
%% 
%% %% -> ok
%% cast(Sql, Args) ->
%%     Query = format_sql(Sql, Args),
%%     ?profile_start,
%%     mysql_log:async_exec(?DB_LOG_POOL, Query),
%%     ?profile(Sql),
%%     ok.
%% 
%% %% @spec spec_execute(db(), sql()) -> integer()
%% %% @doc 指定Db连接池，执行一个SQL查询,返回影响的行数
%% spec_execute(Db, Sql) ->
%%     ?profile_start,
%%     Result = case mysql_log:fetch(Db, Sql) of
%%         {updated, #mysql_result{affectedrows = R}} -> R;
%%         {error, #mysql_result{error = Reason}} -> mysql_halt([Sql, Reason]);
%%         {error, _Reason} -> erlang:error({db_error, [_Reason]})
%%     end,
%%     ?profile(Sql),
%%     Result.
%% 
%% %% @spec spec_execute(db(), sql(), arguments()) -> integer()
%% %% @doc 指定Db连接池，带参数执行一个SQL语句，返回影响的行数
%% spec_execute(Db, Sql, Args) ->
%%     Query = format_sql(Sql, Args),
%%     ?profile_start,
%%     Result = case mysql_log:fetch(Db, Query) of
%%         {updated, #mysql_result{affectedrows = R}} -> R;
%%         {error, #mysql_result{error = Reason}} -> mysql_halt([Query, Reason]);
%%         {error, _Reason} -> erlang:error({db_error, [_Reason]})
%%     end,
%%     ?profile(Sql),
%%     Result.
%% 
%% %% @spec select_limit(sql(), Offset, Num) -> rows()
%% %% Offset = integer()
%% %% Num = integer()
%% %% @doc 执行分页查询返回结果中的所有行
%% select_limit(Sql, Offset, Num) ->
%%     S = list_to_binary([Sql, <<" limit ">>, integer_to_list(Offset), <<", ">>, integer_to_list(Num)]),
%%     ?profile_start,
%%     Result = case mysql_log:fetch(?DB_LOG_POOL, S) of
%%         {data, #mysql_result{rows = R}} -> R;
%%         {error, #mysql_result{error = Reason}} -> mysql_halt([Sql, Reason]);
%%         {error, _Reason} -> erlang:error({db_error, [_Reason]})
%%     end,
%%     ?profile(Sql),
%%     Result.
%% 
%% %% @spec select_limit(sql(), arguments(), Offset, Num) -> rows()
%% %% Offset = integer()
%% %% Num = integer()
%% %% @doc 带参数，执行分页查询返回结果中的所有行
%% select_limit(Sql, Args, Offset, Num) ->
%%     S = list_to_binary([Sql, <<" limit ">>, list_to_binary(integer_to_list(Offset)), <<", ">>, list_to_binary(integer_to_list(Num))]),
%%     ?profile_start,
%%     mysql_log:prepare(s, S),
%%     Result = case mysql_log:execute(?DB_LOG_POOL, s, Args) of
%%         {data, #mysql_result{rows = R}} -> R;
%%         {error, #mysql_result{error = Reason}} -> mysql_halt([Sql, Reason]);
%%         {error, _Reason} -> erlang:error({db_error, [_Reason]})
%%     end,
%%     ?profile(Sql),
%%     Result.
%% 
%% %% @spec get_one(sql()) -> value() | null
%% %% @doc <pre>取出查询结果中的第一行第一列
%% %% 未找到时返回null
%% %% </pre>
%% get_one(Sql) ->
%%     ?profile_start,
%%     Result = case mysql_log:fetch(?DB_LOG_POOL, Sql) of
%%         {data, #mysql_result{rows = Rows}} when Rows =:= [] -> null;
%%         {data, #mysql_result{rows = Rows}} -> [[R]] = Rows, R;
%%         {error, #mysql_result{error = Reason}} -> mysql_halt([Sql, Reason]);
%%         {error, _Reason} -> erlang:error({db_error, [_Reason]})
%%     end,
%%     ?profile(Sql),
%%     Result.
%% 
%% %% @spec get_one(sql(), arguments()) -> value() | null
%% %% @doc <pre>带参数，取出查询结果中的第一行第一列
%% %% 未找到时返回null
%% %% </pre>
%% %% @end
%% get_one(Sql, Args) ->
%%     Query = format_sql(Sql, Args),
%%     ?profile_start,
%%     Result = case mysql_log:fetch(?DB_LOG_POOL, Query) of
%%         {data, #mysql_result{rows = Rows}} when Rows =:= [] -> null;
%%         {data, #mysql_result{rows = Rows}} -> [[R]] = Rows, R;
%%         {error, #mysql_result{error = Reason}} -> mysql_halt([Sql, Reason]);
%%         {error, _Reason} -> erlang:error({db_error, [_Reason]})
%%     end,
%%     ?profile(Sql),
%%     Result.
%% 
%% %% @spec spec_get_one(db(), sql()) -> value() | null
%% %% @doc <pre>指定DB，带参数，取出查询结果中的第一行第一列
%% %% 未找到时返回null
%% %% </pre>
%% spec_get_one(Db, Sql) ->
%%    ?profile_start,
%%     Result = case mysql_log:fetch(Db, Sql) of
%%         {data, #mysql_result{rows = Rows}} when Rows =:= [] -> null;
%%         {data, #mysql_result{rows = Rows}} -> [[R]] = Rows, R;
%%         {error, #mysql_result{error = Reason}} -> mysql_halt([Sql, Reason]);
%%         {error, _Reason} -> erlang:error({db_error, [_Reason]})
%%     end,
%%     ?profile(Sql),
%%     Result.
%% 
%% %% @spec get_row(sql()) -> row()
%% %% @doc 取出查询结果中的第一行
%% get_row(Sql) ->
%%     ?profile_start,
%%     Result = case mysql_log:fetch(?DB_LOG_POOL, Sql) of
%%         {data, #mysql_result{rows = Rows}} when Rows =:= [] -> [];
%%         {data, #mysql_result{rows = Rows}} -> [R] = Rows, R;
%%         {error, #mysql_result{error = Reason}} -> mysql_halt([Sql, Reason]);
%%         {error, _Reason} -> erlang:error({db_error, [_Reason]})
%%     end,
%%     ?profile(Sql),
%%     Result.
%% 
%% %% @spec get_row(sql(), arguments()) -> row()
%% %% @doc 带参数，取出查询结果中的第一行
%% get_row(Sql, Args) when is_atom(Sql) ->
%%     ?profile_start,
%%     Result = case mysql_log:execute(?DB_LOG_POOL, Sql, Args) of
%%         {data, #mysql_result{rows = Rows}} when Rows =:= [] -> [];
%%         {data, #mysql_result{rows = Rows}} -> [R] = Rows, R;
%%         {error, #mysql_result{error = Reason}} -> mysql_halt([Sql, Reason]);
%%         {error, _Reason} -> erlang:error({db_error, [_Reason]})
%%     end,
%%     ?profile(Sql),
%%     Result;
%% get_row(Sql, Args) ->
%%     Query = format_sql(Sql, Args),
%%     ?profile_start,
%%     Result = case mysql_log:fetch(?DB_LOG_POOL, Query) of
%%         {data, #mysql_result{rows = Rows}} when Rows =:= [] -> [];
%%         {data, #mysql_result{rows = Rows}} -> [R] = Rows, R;
%%         {error, #mysql_result{error = Reason}} -> mysql_halt([Sql, Reason]);
%%         {error, _Reason} -> erlang:error({db_error, [_Reason]})
%%     end,
%%     ?profile(Sql),
%%     Result.
%% 
%% %% @spec spec_get_row(db(), sql(), arguments()) -> row()
%% %% @doc 指定DB，带参数，取出查询结果中的第一行
%% spec_get_row(Db, Sql, Args) ->
%%     Query = format_sql(Sql, Args),
%%     ?profile_start,
%%     Result = case mysql_log:fetch(Db, Query) of
%%         {data, #mysql_result{rows = Rows}} when Rows =:= [] -> [];
%%         {data, #mysql_result{rows = Rows}} -> [R] = Rows, R;
%%         {error, #mysql_result{error = Reason}} -> mysql_halt([Sql, Reason]);
%%         {error, _Reason} -> erlang:error({db_error, [_Reason]})
%%     end,
%%     ?profile(Sql),
%%     Result.
%% 
%% %% @spec get_all(sql()) -> rows()
%% %% @doc 取出查询结果中的所有行
%% get_all(Sql) ->
%%     ?profile_start,
%%     Result = case mysql_log:fetch(?DB_LOG_POOL, Sql) of
%%         {data, #mysql_result{rows = R}} -> R;
%%         {error, #mysql_result{error = Reason}} -> mysql_halt([Sql, Reason]);
%%         {error, _Reason} -> erlang:error({db_error, [_Reason]})
%%     end,
%%     ?profile(Sql),
%%     Result.
%% 
%% %% @spec get_all(sql(), arguments()) -> rows()
%% %% @doc 带参数，取出查询结果中的所有行
%% %% @end
%% %% get_all(Sql, Args) when is_atom(Sql) ->
%% %%     case mysql_log:execute(?DB_LOG_POOL, Sql, Args) of
%% %%         {data, {_, _, R, _, _}} -> R;
%% %%         {error, {_, _, _, _, Reason}} -> mysql_halt([Sql, Reason]);
%% %%         {error, _Reason} -> erlang:error({db_error, [_Reason]})
%% %%     end;
%% get_all(Sql, Args) ->
%%     Query = format_sql(Sql, Args),
%%     ?profile_start,
%%     Result = case mysql_log:fetch(?DB_LOG_POOL, Query) of
%%         {data, #mysql_result{rows = R}} -> R;
%%         {error, #mysql_result{error = Reason}} -> mysql_halt([Sql, Reason]);
%%         {error, _Reason} -> erlang:error({db_error, [_Reason]})
%%     end,
%%     ?profile(Sql),
%%     Result.
%% 
%% %% @spec spec_get_all(db(), sql()) -> rows()
%% %% @doc 指定DB，取出查询结果中的所有行
%% spec_get_all(Db, Sql) ->
%%     ?profile_start,
%%     Result = case mysql_log:fetch(Db, Sql) of
%%         {data, #mysql_result{rows = R}} -> R;
%%         {error, #mysql_result{error = Reason}} -> mysql_halt([Sql, Reason]);
%%         {error, _Reason} -> erlang:error({db_error, [_Reason]})
%%     end,
%%     ?profile(Sql),
%%     Result.
%% 
%% %% @spec mysql_halt(Info) -> any()
%% %% Info = list()
%% %% @doc 显示人可以看得懂的错误信息
%% %% Info = [sql(), Reason::term()]
%% %% @end
%% mysql_halt([Sql, Reason]) ->
%%     ?ERR("~n[Database Error]: ~nQuery:   ~s~nError:   ~s", [Sql, Reason]),
%%     erlang:error({db_error, []}).
%% 
%% %% @spec insert(table(), [field()], [value()]) -> integer()
%% %% @doc 插入操作, 返回影响的行数
%% insert(Table, Key, Data) ->
%%     execute(get_insert_sql(Table, Key, Data)).
%% 
%% %% @spec batch_insert(binary, [[A,B,C...], [A1,B1,C1...]]) -> integer()
%% %% @doc 批量插入，传入插表语句和参数列表，返回影响的行数。通过insert/3同样可以实现批量的插入，只是接口参数不同
%% batch_insert(InsertSql, ValuesList) ->
%%     SqlBody = get_insert_sql_f1(ValuesList, []),
%%     Sql = <<InsertSql/binary, SqlBody/binary>>,
%%     execute(Sql).
%% 
%% %% @spec get_insert_sql(table(), [{field(), value()}]) -> sql()
%% %% @doc 解析生成insert的sql语句
%% get_insert_sql(Table, Data) ->
%%     parse_insert_sql(Data, Table, [], []).
%% 
%% %% @spec get_insert_sql(table(), [field()], [value()]) -> sql()
%% %% @doc 解析生成insert的sql语句
%% get_insert_sql(Table, Keys, Data) ->
%%     <<_:1/binary, KeysBin/binary>> = list_to_binary([[",`", atom_to_list(Key),"`"]|| Key <- Keys]),
%%     SqlHead = list_to_binary(["INSERT INTO `", atom_to_list(Table), "`(",KeysBin, ") VALUES"]),
%%     SqlBody = get_insert_sql_f1(Data, []),
%%     <<SqlHead/binary, SqlBody/binary>>.
%%     
%% get_insert_sql_f1([], Res) -> list_to_binary(lists:reverse(Res));
%% get_insert_sql_f1([Row|T], Res) ->
%%     EndChar = 
%%     case T == [] of
%%     false -> ",";
%%     true -> ";"
%%     end,
%%     SqlBody = list_to_binary(["(~s", lists:duplicate(length(Row)-1, ",~s") ,")", EndChar]),
%%     get_insert_sql_f1(T, [format_sql(SqlBody, Row)|Res]).
%% 
%% %% 解析生成replace的sql语句
%% %% @param Table:atom()
%% %% @param Keys:[atom()]
%% %% @param Data:[[term()]]
%% %% @return binary()
%% %get_replace_sql(Table, Keys, Data) ->
%% %    <<_:1/binary, KeysBin/binary>> = list_to_binary([[",`", atom_to_list(Key),"`"]|| Key <- Keys]),
%% %    SqlHead = list_to_binary(["REPLACE INTO `", atom_to_list(Table), "`(",KeysBin, ") VALUES"]),
%% %    SqlBody = get_insert_sql_f1(Data, []),
%% %    <<SqlHead/binary, SqlBody/binary>>.
%% 
%% %% @spec get_update_sql(table(), [field()], [{field(), value()}]) -> sql()
%% %% @doc 解析生成update的sql语句
%% get_update_sql(Table, PKeyList, Data) ->
%%     parse_update_sql(Data, Table, PKeyList, [], []).
%% 
%% 
%% %% 解析生成insert的sql语句
%% %% @return binary()
%% parse_insert_sql([], Table, KeyList, VarList) ->
%%     {_, Keys} = split_binary(list_to_binary(KeyList), 1),
%%     {_, Vars} = split_binary(list_to_binary(VarList), 1),
%%     list_to_binary([<<"insert into `">>, erlang:atom_to_binary(Table, utf8), <<"` (">>, Keys, <<") values(">>, Vars, <<");">>]);
%% %%
%% parse_insert_sql([{Key, Var}|TData], Table, KeyList, VarList) ->
%%     K = [<<",`">>, erlang:atom_to_binary(Key, utf8), <<"`">>],
%%     V = case is_number(Var) of
%%         true -> [<<",">>, integer_to_list(Var)];
%%         _ -> [<<",'">>, Var, <<"'">>]
%%     end,
%%     parse_insert_sql(TData, Table, [K|KeyList], [V|VarList]).
%% 
%% %% 解析生成update的sql语句
%% %% @return binary()
%% parse_update_sql([], Table, _PKeyList, PKVList, KVList) ->
%%     list_to_binary([<<"update `">>, erlang:atom_to_binary(Table, utf8), <<"` set ">>, KVList, <<" where ">>, PKVList, <<";">>]);
%% %%
%% parse_update_sql([{Key, Var}|TData], Table, PKeyList, PKVList, KVList) ->
%%     V = case is_number(Var) of
%%         true -> integer_to_list(Var);
%%         _ -> Var
%%     end,
%%     case lists:member(Key, PKeyList) of
%%         true  ->
%%             KV = case PKVList of
%%                 [] -> [<<"`">>, erlang:atom_to_binary(Key, utf8), <<"`='">>, V, <<"'">>];
%%                 _  -> [<<"`">>, erlang:atom_to_binary(Key, utf8), <<"`='">>, V, <<"' and ">>]
%%             end,
%%             parse_update_sql(TData, Table, PKeyList, [KV|PKVList], KVList);
%%         false ->
%%             KV = case KVList of
%%                 [] -> [<<"`">>, erlang:atom_to_binary(Key, utf8), <<"`='">>, V, <<"'">>];
%%                 _  -> [<<"`">>, erlang:atom_to_binary(Key, utf8), <<"`='">>, V, <<"',">>]
%%             end,
%%             parse_update_sql(TData, Table, PKeyList, PKVList, [KV|KVList])
%%     end.
%% 
%% %% @spec format_sql(sql(), arguments()) -> binary()
%% %% @doc <pre>
%% %% 格式化sql语句
%% %% 变量用~s表示
%% %% </pre>
%% format_sql(Sql, Args) when is_list(Sql) ->
%%     %S = re:replace(Sql, "\\?", "~s", [global, {return, list}]),
%%     L = [mysql_log:encode(A) || A <- Args],
%%     list_to_bitstring(format(Sql, L));
%% format_sql(Sql, Args) when is_bitstring(Sql) ->
%%     format_sql(bitstring_to_list(Sql), Args).
%% 
%% %% @deprecated 不建议使用
%% %% @spec last_insert_id() -> integer()
%% %% @doc 最后插入的ID（需要结合事务使用）(不建议使用)
%% last_insert_id() ->
%%     db_log:get_one("SELECT LAST_INSERT_ID()").
%% 
%% %% @deprecated 不建议使用
%% %% @spec tx(Fun) -> {ok, Result} | {error, Reason}
%% %% Fun = function()
%% %% @doc <pre>
%% %% 事务(不建议使用)
%% %% </pre>
%% tx(Fun) ->
%%     tx(Fun, undefined).
%% 
%% tx(Fun, Timeout) ->
%%     case mysql_log:transaction(?DB_LOG_POOL, Fun, Timeout) of
%%         {atomic, Result} ->
%%             {ok, Result};
%%         {aborted, {Reason, {rollback_result, _Result}}} ->
%%             {error, Reason}
%%     end.
%% 
%% %% 格式化字符串
%% format(Format, []) ->
%%     Format;
%% format(Format, Args) ->
%%     format(Format, Args, []).
%% 
%% format([$~, $s|T], [Arg|Args], Ret) when is_list(Arg) ->
%%     format(T, Args, [Arg|Ret]);
%% format([$~, $s|T], [Arg|Args], Ret) when is_integer(Arg) ->
%%     format(T, Args, [integer_to_list(Arg)|Ret]);
%% format([$~, $s|T], [Arg|Args], Ret) when is_float(Arg) ->
%%     format(T, Args, [float_to_list(Arg)|Ret]);
%% format([$~, $s|T], [Arg|Args], Ret) when is_atom(Arg) ->
%%     format(T, Args, [atom_to_list(Arg)|Ret]);
%% format([$~, $s|T], [_Arg|Args], Ret) ->
%%     format(T, Args, Ret);
%% format(_L=[$~, $s|_], [], _Ret) ->
%%     %lists:flatten(lists:reverse([L|Ret]));
%%     throw({error, bad_arity});
%% format([H|T], Args, Ret) ->
%%     format(T, Args, [H|Ret]);
%% format([], [_|_], _Ret) ->
%%     throw({error, bad_arity});
%% format([], _Args, Ret) ->
%%     lists:flatten(lists:reverse(Ret)).
%% 
%% 
%% %% 返回数据库连接信息
%% conn_info() ->
%%     {status, _Pid, {module, _Mod}, [_PDict, _SysState, _Parent, _Debug, FmtMisc]} = sys:get_status(mysql_dispatcher_log),
%%     [ State || {data, [{"State", State}|_]} <- FmtMisc ].
%% 
%% 
%% %% ----------------------------------------------------
%% 
%% %% @hidden
%% test(lan) ->
%%     Data = [
%%         {id, 1}
%%         ,{name, <<"test">>}
%%         ,{notice, <<"test">>}
%%         ,{builder_id, 2}
%%         ,{head_id, 2}
%%         ,{realm, 2}
%% 		,{lev, 0}
%%         ,{head_name, <<"lan">>}
%%         ,{updated_time, 1454212}
%%         
%%     ],
%%     Sql = get_update_sql(guild, [id], Data),
%%     %% ?DEBUG("~n SQL:~p~n", [binary_to_list(Sql)]),
%%     (execute(Sql) > 0);
%% 
%% test(sys) ->
%%     _D1 = db_log:get_one(<<"select name from role where id=10017 limit 1">>), ?DEBUG("get_one/1[D1]:~w", [_D1]),
%%     _D2 = db_log:get_one(<<"select name from role where id=~s limit 1">>, [10017]), ?DEBUG("get_one/2[D2]:~w", [_D2]),
%%     _D3 = db_log:get_one(<<"select id from role where name='传说哥' limit 1">>), ?DEBUG("get_one/1[D3]:~w", [_D3]),
%%     _D4 = db_log:get_one(<<"select id from role where name=~s limit 1">>, [<<"传说哥">>]), ?DEBUG("get_one/2[D4]:~w", [_D4]),
%% 
%%     _D5 = db_log:get_row(<<"select * from role where id=10017 limit 1">>),
%%     ?DEBUG("get_row/1[D5]:~w", [_D5]),
%% 
%%     _D6 = db_log:get_row(<<"select * from role where id=~s limit 1">>, [10017]),
%%     ?DEBUG("get_row/2[D6]:~w", [_D6]),
%% 
%%     _D7 = db_log:get_row(<<"select * from role where name=~s limit 1">>, [<<"传说哥">>]), ?DEBUG("get_row/2[D7]:~w", [_D7]),
%% 
%%     _D8 = db_log:get_row(<<"select * from role where name='传说哥' limit 1">>), ?DEBUG("get_row/1[D8]:~w", [_D8]),
%% 
%%     _D9 = db_log:get_all(<<"select id, name from role where id=10017 or id=10018 or id=10019 or id=234232">>), ?DEBUG("get_all/1[D9]:~w", [_D9]),
%% 
%%     _D10 = db_log:get_all(<<"select id, name from role where id=~s or id=~s or id=~s or id=~s">>, [10017, 10018, 10019, 234232]), ?DEBUG("get_all/2[D10]:~w", [_D10]),
%% 
%%     _D11 = db_log:select_limit(<<"select id, name, lev from role">>, 0, 10), ?DEBUG("get_select_limit/3[D11]:~w", [_D11]),
%% 
%%     _D12 = db_log:select_limit(<<"select id, name, lev from role where id<~s">>, [100], 0, 10), ?DEBUG("get_select_limit/4[D12]:~w", [_D12]),
%% 
%%     _D13 = db_log:execute(<<"update role set lev=119 where id=10017">>), ?DEBUG("execute/1[D13]:~w", [_D13]),
%%     _D17 = db_log:get_one(<<"select lev from role where id=10017 limit 1">>), ?DEBUG("get_one/1[D17]:~w", [_D17]),
%%     _D14 = db_log:execute(<<"update role set lev=~s where id=~s">>, [100, 10017]), ?DEBUG("execute/2[D14]:~w", [_D14]),
%%     _D15 = db_log:get_one(<<"select lev from role where id=10017 limit 1">>), ?DEBUG("get_one/1[D15]:~w", [_D15]),
%%     _D16 = db_log:execute(<<"update role set lev=~s where id=~s">>, [100, 10017]), ?DEBUG("execute/2[D16]:~w", [_D16]),
%%     ok.
