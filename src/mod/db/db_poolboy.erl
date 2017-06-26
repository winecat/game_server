%%%-------------------------------------------------------------------
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%% mysql api
%%% @end
%%%-------------------------------------------------------------------
-module(db_poolboy).

-include("db.hrl").

%% -export([start/1]).

%% 注：
%% 这里所有执行的SQL语句格式，只需通用的sql语句格式即可
%% 

-export([
         execute/1
         ,execute/2
         ,execute/3
         ,execute_nohalt/1
         ,execute_nohalt/2
         ,execute_nohalt/3
        
         ,prepare/2
        
         ,transaction/1
         ,transaction/2
        
         ,get_all/1
         ,get_all/2
        
         ,get_one/1
         ,get_one/2
        
         ,get_row/1
         ,get_row/2
        
         ,batch_insert/3
         ,batch_insert/4
         ,make_insert_key_sql/1
         ,insert_return/2
         ,insert_return/3
        
         ,microtime/0
         ,mysql_start/0
        
        ]).


%% db日志开关
%% -define(db_log_enabled, 'true').
-ifdef(db_log_enabled).
-ifdef(debug).
-define(profile_start, (BeginTime_ = microtime())).
-define(profile(Sql), db_prof:log(Sql, round(microtime()-BeginTime_)/1000000)).
-else.
-define(profile_start, ignore).
-define(profile(_Sql), ignore).
-endif.
-else.
-define(profile_start, ignore).
-define(profile(_Sql), ignore).
-endif.

%% 取得当前毫秒
microtime() ->
    {_M, S, Micro} = erlang:now(),
    S*1000000 + Micro.



mysql_start() ->
    ?DEBUG("db poolboy init..."),
    boot:start_apps([poolboy, mysql, mysql_poolboy]),
%%     ok = gs_ctl:start(gs_sup, mysql_poolboy_sup, {mysql_poolboy_sup, start_link,[]}, mysql_poolboy_sup),
    [DbHost, DbPort, DbUser, DbPass, DbName, DbEncode, DbConnectNum] = config:get_mysql(),
    PoolOptions  = [{size, 2}, {max_overflow, 3}],
    MySqlOptions = [{host, DbHost}, {port, DbPort},
                    {user, DbUser}, {password, DbPass}, {database, DbName}],
    PoolIdGame = ?DB_GAME_POOL,
    ?DEBUG("add poolboy:~w...", [PoolIdGame]),
    mysql_poolboy:add_pool(PoolIdGame, PoolOptions, MySqlOptions),
    PoolIdLog = ?DB_LOG_POOL,
    ?DEBUG("add poolboy:~w...", [PoolIdLog]),
    mysql_poolboy:add_pool(PoolIdLog, PoolOptions, MySqlOptions),
    ok.


%% @doc return int
%% @doc 执行一个SQL查询,返回影响的行数
-spec execute(Sql :: bitstring()) -> Row :: integer() | no_return().
execute(Sql) ->
    ?profile_start,
    Result = 
        case mysql_poolboy:query(?DB_GAME_POOL, Sql) of
            #db_result{affected_rows = AffectRows} -> AffectRows;
            {error, Error} -> mysql_halt(Sql, Error)
        end,
    ?profile(Sql),
    Result.

%% @doc return int
%% @doc 执行一个SQL查询,返回影响的行数
-spec execute(Sql :: bitstring() | atom(), Args :: list()) -> Row :: integer() | no_return().
execute(Sql, Args) -> execute(?DB_GAME_POOL, Sql, Args).
execute(PoolId, Sql, Args) when is_atom(Sql) ->
    ?profile_start,
    Query = format_sql(Sql, Args),
    Result = 
        case mysql_poolboy:query(PoolId, Query) of
            #db_result{affected_rows = AffectRows} -> AffectRows;
            {error, Error} -> mysql_halt(Sql, Error)
        end,
    ?profile(Sql),
    Result;
execute(PoolId, Sql, Args) ->
    ?profile_start,
    Query = format_sql(Sql, Args),
    Result = 
        case mysql_poolboy:query(PoolId, Query) of
            #db_result{affected_rows = AffectRows} -> AffectRows;
            {error, Error} -> mysql_halt(Sql, Error)
        end,
    ?profile(Sql),
    Result.

execute_nohalt_pool(PoolId, Sql) ->
    ?profile_start,
    Result = 
        case mysql_poolboy:query(PoolId, Sql) of
             #db_result{affected_rows = AffectRows} -> AffectRows;
            {error, Error} -> mysql_halt(Sql, Error)
        end,
    ?profile(Sql),
    Result.
execute_nohalt(Sql) -> execute_nohalt(?DB_GAME_POOL, Sql, []).
execute_nohalt(Sql, Args) -> execute_nohalt(?DB_GAME_POOL, Sql, Args).
execute_nohalt(PoolId, Sql, Args) when is_atom(Sql) ->
    Query = format_sql(Sql, Args),
    ?profile_start,
    Result = 
        case mysql_poolboy:query(PoolId, Query) of
            #db_result{affected_rows = AffectRows} -> AffectRows;
            {error, Error} -> mysql_halt(Sql, Error)
        end,
    ?profile(Sql),
    Result;
execute_nohalt(PoolId, Sql, Args) ->
    Query = format_sql(Sql, Args),
    ?profile_start,
    Result = 
        case mysql_poolboy:query(PoolId, Query) of
             #db_result{affected_rows = AffectRows} -> AffectRows;
            {error, Error} -> mysql_halt(Sql, Error)
        end,
    ?profile(Sql),
    Result.

insert_return(Sql, Args) -> insert_return(?DB_GAME_POOL, Sql, Args).
insert_return(PoolId, Sql, Args) ->
    Query = format_sql(Sql, Args),
    ?profile_start,
    Result = 
        case mysql_poolboy:query(PoolId, Query) of
            #db_result{insert_id = InsertId} -> InsertId;
            {error, Error} -> mysql_halt(Sql, Error)
        end,
    ?profile(Sql),
    Result.

%% 事务处理
-spec transaction(F :: fun()) -> any() | {db_error,any()} | no_return().
transaction(F) ->
    transaction(F, undefined).

-spec transaction(F :: fun(),ErrFun :: fun()) -> any() | {db_error,any()} | no_return().
transaction(F, ErrFun) ->
    case mysql_poolboy:transaction(?DB_GAME_POOL, F, ErrFun) of
        {atomic, R} -> R;
        {aborted, Reason} -> {db_error, Reason};
        Error -> {db_error, Error}
    end.

prepare(Name, Query) ->
    emysql:prepare(Name, Query).

%% @doc return term | null
%% @doc 取出查询结果中的第一行第一列
-spec get_one(Sql :: bitstring()) -> Result :: term() | null.
get_one(Sql) ->
    ?profile_start,
    Result = 
        case mysql_poolboy:query(?DB_GAME_POOL, Sql) of
            #db_result{rows = []} -> null;
            #db_result{rows = [[D]|_]} -> D;
            {error, Error} -> mysql_halt(Sql, Error)
        end,
    ?profile(Sql),
    Result.
%% @doc return term | null
%% @doc 取出查询结果中的第一行第一列
-spec get_one(Sql :: bitstring() | atom(), Args :: list()) -> Result :: term() | null.
get_one(Sql, Args) when is_atom(Sql) ->
    ?profile_start,
    Query = format_sql(Sql, Args),
    Result = 
        case mysql_poolboy:query(?DB_GAME_POOL, Query) of
            #db_result{rows = []} -> null;
            #db_result{rows = [[D]|_]} -> D;
            {error, Error} -> mysql_halt(Sql, Error)
        end,
    ?profile(Sql),
    Result;
get_one(Sql, Args) ->
    Query = format_sql(Sql, Args),
   ?profile_start,
    Result = 
        case mysql_poolboy:query(?DB_GAME_POOL, Query) of
            #db_result{rows = []} -> null;
            #db_result{rows = [[D]|_]} -> D;
            {error, Error} -> mysql_halt(Sql, Error)
        end,
    ?profile(Sql),
    Result.

%% @doc return [] | [1,2|...]
%% @doc 取出查询结果中的第一行第一列
-spec get_row(Sql :: bitstring()) -> Result :: list() | [].
get_row(Sql) ->
    ?profile_start,
    Result = 
        case mysql_poolboy:query(?DB_GAME_POOL, Sql) of
            #db_result{rows = []} -> [];
            #db_result{rows = [D|_]} -> D;
            {error, Error} -> mysql_halt(Sql, Error)
        end,
    ?profile(Sql),
    Result.
%% @doc return [] | [1,2|...]
%% @doc 取出查询结果中的第一行第一列
-spec get_row(Sql :: bitstring() | atom(), Args :: list()) -> Result :: list() | [].
get_row(Sql, Args) when is_atom(Sql) ->
   ?profile_start,
    Query = format_sql(Sql, Args),
    Result = 
        case mysql_poolboy:query(?DB_GAME_POOL, Query) of
            #db_result{rows = []} -> [];
            #db_result{rows = [D|_]} -> D;
            {error, Error} -> mysql_halt(Sql, Error)
        end,
    ?profile(Sql),
    Result;
get_row(Sql, Args) ->
    ?profile_start,
    Query = format_sql(Sql, Args),
    Result = 
        case mysql_poolboy:query(?DB_GAME_POOL, Query) of
            #db_result{rows = []} -> [];
            #db_result{rows = [D|_]} -> D;
            {error, Error} -> mysql_halt(Sql, Error)
        end,
    ?profile(Sql),
    Result.


%% @doc return [] | [[1,2]|...]
%% @doc 取出查询结果中的所有行
-spec get_all(Sql :: bitstring() | atom()) -> Result :: list() | [].
get_all(Sql) ->
    ?profile_start,
    Result = 
        case mysql_poolboy:query(?DB_GAME_POOL, Sql) of
            #db_result{rows = Rows} -> Rows;
            {error, Error} -> mysql_halt(Sql, Error)
        end,
    ?profile(Sql),
    Result.
%% @doc return [] | [[1,2]|...]
%% @doc 取出查询结果中的所有行
-spec get_all(Sql :: bitstring() | atom(), Args :: list()) -> Result :: list() | [].
get_all(Sql, Args) when is_atom(Sql) ->
   ?profile_start,
    Result = 
        case mysql_poolboy:query(?DB_GAME_POOL, Sql, Args) of
            #db_result{rows = Rows} -> Rows;
            {error, Error} -> mysql_halt(Sql, Error)
        end,
    ?profile(Sql),
    Result;
get_all(Sql, Args) ->
    Query = format_sql(Sql, Args),
    ?profile_start,
    Result = 
        case mysql_poolboy:query(?DB_GAME_POOL, Query) of
            #db_result{rows = Rows} -> Rows;
            {error, Error} -> mysql_halt(Sql, Error)
        end,
    ?profile(Sql),
    Result.


%% @doc return integer()
%% @doc 批量插入数据,返回影响的行数
%% %% @eg. batch_insert(test, [id, num], [[1, 100], [2, 200]])
-spec batch_insert(Table :: atom(), KeyList :: list(), DataList :: list()) -> integer().
batch_insert(Table, KeyList, DataList) -> 
    batch_insert(?DB_GAME_POOL, Table, KeyList, DataList).
batch_insert(PoolId, Table, KeyList, DataList) -> 
    execute_nohalt_pool(PoolId, get_insert_sql(Table, KeyList, DataList)).

%% ====================================================================
%% Internal functions
%% ====================================================================
%% @doc 格式化sql语句
-spec format_sql(Sql, Args) -> bitstring() when
	Sql		:: list() | bitstring(),
	Args	:: list().
format_sql(Sql, Args) when is_list(Sql) ->
    %%S = re:replace(Sql, "\\?", "~s", [global, {return, list}]),
    L = [encode(A) || A <- Args],
    list_to_bitstring(io_lib:format(Sql, L));
format_sql(Sql, Args) when is_bitstring(Sql) ->
    format_sql(bitstring_to_list(Sql), Args).

%% @doc 打印错误信息
%% @doc 显示人可以看得懂的错误信息
%% @doc 格式化sql执行错误
-spec mysql_halt(Sql :: binary(), Reason :: binary()) -> {error, MSG :: binary()}.
mysql_halt(Sql, Reason) ->
	Emsg = util:fbin(<<"MYSQL exec sql error :[SQL] ~p [ERR] ~p">>, [Sql, Reason]),
	?ERR("~ts", [Emsg]),
%% 	erlang:error({db_error, [Sql, Reason]}),
	{error, Emsg}.

get_insert_sql(Table, KeyList, DataList) when is_list(KeyList) ->
    KeyBin = make_insert_key_sql(KeyList),
    get_insert_sql(Table, KeyBin, DataList);
get_insert_sql(Table, KeysBin, DataList) when is_binary(KeysBin) ->
    SqlHead = list_to_binary(["INSERT INTO `", atom_to_list(Table), "`(",KeysBin, ") VALUES"]),
    SqlBody = get_insert_sql_body(DataList),
    %%?INFO("log1：~ts~n log2:~ts", [SqlHead, SqlBody]),
    <<SqlHead/binary, SqlBody/binary>>.
get_insert_sql_body(Data) -> get_insert_sql_body(Data, []).
get_insert_sql_body([], InsertList) -> list_to_binary(lists:reverse(InsertList));
get_insert_sql_body([Row], InsertList) ->%%最后一个
    SqlBody = list_to_binary(["(~s", lists:duplicate(length(Row)-1, ",~s") ,")", ";"]),
    get_insert_sql_body([], [format_sql(SqlBody, Row)|InsertList]);
get_insert_sql_body([Row|Tail], InsertList) ->
    SqlBody = list_to_binary(["(~s", lists:duplicate(length(Row)-1, ",~s") ,")", ","]),
    get_insert_sql_body(Tail, [format_sql(SqlBody, Row)|InsertList]).

make_insert_key_sql(KeyList) ->
    <<_:1/binary, KeysBin/binary>> = list_to_binary([[",`", atom_to_list(Key),"`"]|| Key <- KeyList]),
    KeysBin.



%% 从mysql.erl copy 到此处
%% @doc Encode a value so that it can be included safely in a MySQL query.
%%
%% @spec encode(Val::term(), AsBinary::bool()) ->
%%   string() | binary() | {error, Error}
encode(Val) ->
    encode(Val, false).
encode(Val, false) when Val == undefined; Val == null ->
    "null";
encode(Val, true) when Val == undefined; Val == null ->
    <<"null">>;
encode(Val, false) when is_binary(Val) ->
    binary_to_list(quote(Val));
encode(Val, true) when is_binary(Val) ->
    quote(Val);
encode(Val, true) ->
    list_to_binary(encode(Val,false));
encode(Val, false) when is_atom(Val) ->
    quote(atom_to_list(Val));
encode(Val, false) when is_list(Val) ->
    quote(Val);
encode(Val, false) when is_integer(Val) ->
    integer_to_list(Val);
encode(Val, false) when is_float(Val) ->
    [Res] = io_lib:format("~w", [Val]),
    Res;
encode({datetime, Val}, AsBinary) ->
    encode(Val, AsBinary);
encode({{Year, Month, Day}, {Hour, Minute, Second}}, false) ->
    Res = two_digits([Year, Month, Day, Hour, Minute, Second]),
    lists:flatten(Res);
encode({TimeType, Val}, AsBinary)
  when TimeType == 'date';
       TimeType == 'time' ->
    encode(Val, AsBinary);
encode({Time1, Time2, Time3}, false) ->
    Res = two_digits([Time1, Time2, Time3]),
    lists:flatten(Res);
encode(Val, _AsBinary) ->
    {error, {unrecognized_value, Val}}.

two_digits(Nums) when is_list(Nums) ->
    [two_digits(Num) || Num <- Nums];
two_digits(Num) ->
    [Str] = io_lib:format("~b", [Num]),
    case length(Str) of
    1 -> [$0 | Str];
    _ -> Str
    end.

%%  Quote a string or binary value so that it can be included safely in a
%%  MySQL query.
quote(String) when is_list(String) ->
    [39 | lists:reverse([39 | quote(String, [])])]; %% 39 is $'
quote(Bin) when is_binary(Bin) ->
    list_to_binary(quote(binary_to_list(Bin))).

quote([], Acc) ->
    Acc;
quote([0 | Rest], Acc) ->
    quote(Rest, [$0, $\\ | Acc]);
quote([10 | Rest], Acc) ->
    quote(Rest, [$n, $\\ | Acc]);
quote([13 | Rest], Acc) ->
    quote(Rest, [$r, $\\ | Acc]);
quote([$\\ | Rest], Acc) ->
    quote(Rest, [$\\ , $\\ | Acc]);
quote([39 | Rest], Acc) ->      %% 39 is $'
    quote(Rest, [39, $\\ | Acc]);   %% 39 is $'
quote([34 | Rest], Acc) ->      %% 34 is $"
    quote(Rest, [34, $\\ | Acc]);   %% 34 is $"
quote([26 | Rest], Acc) ->
    quote(Rest, [$Z, $\\ | Acc]);
quote([C | Rest], Acc) ->
    quote(Rest, [C | Acc]).


