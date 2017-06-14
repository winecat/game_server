%%----------------------------------------------------
%% 工具包
%% 
%% @author yeahoo2000@gmail.com
%%----------------------------------------------------
-module(util).
-export(
    [
         eval/1
        ,eval2/1
        ,do_qlc/1
        ,implode/2
        ,implode/3
        ,explode/3
        ,for/3
        ,for/4
        ,sleep/1
        ,get_now_secs/0
        ,unixtime/0
        ,unixtime/1     %% 获取一些特殊的时间戳，今天、明天、昨天的0:0:0的时间戳，周一0:0:0的时间戳，某时间段时间戳
        ,get_hour/0  %% 获取当前的小时值
        ,mktime/1
        ,timef/1
        ,time_left/2
        ,strftime/1
        ,strftime/2
        ,md5/1
        ,num2str/1
        ,floor/1
        ,ceil/1
        ,rand/2
        ,list_rand/1
        ,list_rands/1
        ,list_rands/2
        ,list_rands_by_rate/2
        ,list_rands_by_rate_bind/2
        ,rand_test/1
        ,list_keypop/3
        ,percent/0
        ,permille/0
        ,get_time_left/2
        ,get_time_left1/2
        ,thing_to_list/1
        ,term_to_string/1
        ,string_to_term/1
        ,string_to_term/2
        ,string_to_num/1
        ,bitstring_to_term/1
        ,term_to_bitstring/1
        ,term_to_bitstring2/1
        ,term_to_liststring/1
        ,get_peer_ip/1
        ,ip2bin/1
        ,ipstr2tuple/1
        ,to_integer/1
        ,to_atom/1
        ,to_string/1            %% 所有类型转list
        ,all_to_binary/1        %% 将所有类型转换为binary
        ,to_binary/1
        ,batch_list2atom/2
        ,lists_wrap_one/3
        ,text_banned/1
        ,filter_text/1
        ,strtotime/1
        ,get_date_ymd/0
        ,get_date_ymd2/0
        ,in_time_limit/2        %% 检查是否在某个时间段
        ,in_time_limit/3        %% 检查是否在某个时间段
        ,send_after/4           %% 下一天的同一时间发消息
        ,parse_qs/1
        ,parse_qs/3
        ,shuffle/1
        ,escape_uri/1
        ,list_unique/1
        ,get_diff_sec/1
        ,get_week_num/0     %% 获取今天是星期几
        ,legal_name/1       %% 名称合法性检测:非法字符(只允许使用汉字、字母、数字和下划线)
        ,get_server_id/0
        ,is_union_server/0  %% 当前游戏服是否合服
        ,list_index/2   %% 元素在列中的索引号
        ,list_index/3   %% 元素在列中的索引号，带默认值
        ,list_keysort/2 %% 多键值排序
        ,list_keysort_by_order/2 %% 多键值排序(带选项)
        ,unset_clock/1  %% 清除回调
        ,set_clock/3    %% 设定时间回调
        ,set_clock/4    %% 设定时间回调
        ,set_clock/5
        ,disorder/1     %% 随机打乱一个list里面的元素
        ,get_value/2    %% tuple list 按键取值，跟proplists:get_value/2用法一样，效率更高
        ,get_value/3
        ,strlen/1       %% 字符数量
        ,test/0
        ,time_to_binary/1   %% 时间转2进制显示 {10, 12, 00} -> <<"10:12:00">>
        ,time_to_binary/2
        ,in_week_num/1  %% 是否在星期几
        ,condition/1
        ,to_role_link/1 %% 生成客户格式的角色连接菜单
        ,float/2
        ,get_rand_val/1
        ,update_proplists/3 %%更新属性列表值 List格式为[{Key, Value}, .....]
        ,mutil_update_list/2 %%更新多个属性
        ,run_interval/1
        ,init_interval/1
        ,is_process_alive/1   %% 本地/跨节点查询进程是否存活
        ,shuffle_v1/1
        ,split_list_by_num/2   %% 将List按照Num均分成多个SubList
        ,odd_even_list/1
        ,url_encode/1
        ,positive_int/1
        ,positive_num/1
		,combine_list_by_key/1  %% [{key, value}, ...] 合并key相同的 value相加
        ,combine_list_by_value/2
        ,decrease_list_by_key/2  %% [{key, value}]第一个列表减第二个列表
        ,decrease_list_with_value_0/2  %% [{key, value}]第一个列表减第二个列表,不够减时保留value = 0 
        ,list_get_one_segment/3 %% 获取列表的某段元素列表
        ,list_delete_sublist/2
        ,proplists_get_min_key/1
        ,lists_get_same_key_num/4
		,plus_max/3		%% 一个数base增加Plus值后，最大只能达到Max,直接返回Result
		,minus_min/3	%% 一个数base减小minus值后，最小只能小到Min,直接返回Result
        ,one_page_days/0 %% 获取日历中一页的所有天数
        ,one_page_days/1 
        ,pos/2
		,split_num/2
		,check_after_open_time/1
		,filter_first_element/2
        ,list_insert/3
    ]
).
-include("game.hrl").

-define(BETWEEN(A,B,X), ((X>A-1) and (X<B+1))).

%% 执行一个字符串
%% 返回执行结果:term()
eval(Bin) when is_binary(Bin) ->
    eval(binary_to_list(Bin));
eval(Str) when is_list(Str) ->
    {ok, Ts, _} = erl_scan:string(Str),
    Ts1 = case reverse(Ts) of
        [{dot, _} | _] -> Ts;
        TsR -> reverse([{dot, 1} | TsR])
    end,
    {ok, Expr} = erl_parse:parse_exprs(Ts1),
    {value, Value, _} = erl_eval:exprs(Expr, []),
    Value.

%% -> 返回序列化的字符串格式
eval2(Str) ->
    term_to_bitstring(util:eval(Str)).
    %{Screen, Return} = io_capture:do(fun()-> util:eval(Str) end),
    %term_to_bitstring(Screen) ++ "\n\n" ++ term_to_bitstring(Return).

%% 仅供eval使用
reverse([] = L) -> L;
reverse([_] = L) -> L;
reverse([A, B]) -> [B, A];
reverse([A, B | L]) -> lists:reverse(L, [B, A]).

%% 执行一个qlc查询
do_qlc(Q) ->
    {atomic, Val} = mnesia:transaction(fun() -> qlc:e(Q) end),
    Val.

%% 在List中的每两个元素之间插入一个分隔符
implode(_S, [])->
    [<<>>];
implode(S, L) when is_list(L) ->
    implode(S, L, []).
implode(_S, [H], NList) ->
    lists:reverse([thing_to_list(H) | NList]);
implode(S, [H | T], NList) ->
    L = [thing_to_list(H) | NList],
    implode(S, T, [S | L]).

%% 拆分binary类型的字符
%% 返回: list()
explode(list, Str, S) ->
    string:tokens(Str, S);
explode(binary, Bin, S) ->
    Str = bitstring_to_list(Bin),
    explode(list, Str, S).

thing_to_list(X) when is_integer(X) -> integer_to_list(X);
thing_to_list(X) when is_float(X)   -> float_to_list(X);
thing_to_list(X) when is_atom(X)    -> atom_to_list(X);
thing_to_list(X) when is_binary(X)  -> binary_to_list(X);
thing_to_list(X) when is_tuple(X)  -> tuple_to_list(X);
thing_to_list(X) when is_list(X)    -> X.

%% for循环
for(Min, Max, _F) when Min>Max ->
    error;
for(Max, Max, F) ->
    F(Max);
for(I, Max, F)   ->
    F(I),
    for(I+1, Max, F).

%% 带返回状态的for循环
%% @return {ok, State}
for(Max, Min, _F, State) when Min<Max -> {ok, State};
for(Max, Max, F, State) -> F(Max, State);
for(I, Max, F, State)   -> {ok, NewState} = F(I, State), for(I+1, Max, F, NewState).

%% 暂停执行T毫秒
sleep(T) ->
    receive
    after T ->
            true
    end.

%% @spec get_now_secs() -> NowSecs.
%%            NowSecs::integer()
%% @doc 获取当前秒数
get_now_secs() ->
    {Hour, Min, Sec} = erlang:time(),
    Hour*3600 + Min*60 + Sec.

%% 取得当前的unix时间戳
unixtime() ->
    {M, S, _} = erlang:now(),
    M * 1000000 + S.

%% 取得当前unix时间戳，精确到毫秒3位
unixtime(micro) ->
    {M, S, Micro} = erlang:now(),
    M * 1000000 + S + Micro / 1000000;

%%  获取当天12时0分0秒的时间戳
unixtime(noon) ->
    unixtime(today) + 43200;

%% 获取当天0时0分0秒的时间戳（这里是相对于当前时区而言，后面的unixtime调用都基于这个函数
unixtime(today) ->
    {M, S, MS} = erlang:now(),
    {_, Time} = calendar:now_to_local_time({M, S, MS}), %% 性能几乎和之前的一样
    M * 1000000 + S - calendar:time_to_seconds(Time);

%% 获取当前这个小时开始时的时间戳
unixtime(this_hour_begin) ->
    {_Date, {NowH, _NowM, _NowS}} = calendar:local_time(),
    unixtime(today) + NowH * 3600;

%% 获取下一个小时开始时的时间戳
unixtime(next_hour_begin) ->
    {_Date, {NowH, _NowM, _NowS}} = calendar:local_time(),
    unixtime(today) + (NowH + 1) * 3600;


%% 获取离该时间点最接近的时间戳 例现在是16:58 调用后是 17:00
unixtime({near_hour, SetTime}) ->
    {_Y, _M, _D, H, M, _S} = util:mktime({to_date, SetTime}),
    Differ = SetTime - unixtime(today),
    Day = case Differ < 0 of
        true -> Differ div 86400 - 1;
        false -> Differ div 86400
    end,
    case M > 30 of
        true -> unixtime(today) + Day * 86400 + (H + 1) * 3600;
        false -> unixtime(today) + Day * 86400 + H * 3600
    end; 

%% 获取明天0时0分0秒的时间戳
unixtime(tomorrow) ->
    unixtime(today) + 86400;

%% @doc 获取明天12时0分0秒的时间戳
unixtime(tomorrow_noon) ->
    unixtime(today) + 129600;

%% 获取昨天0时0分0秒的时间戳
unixtime(yesterday) ->
    unixtime(today) - 86400;

%% 获取本周周一00:00:00的时间戳
unixtime(thisweek) ->
    {Date, _} = calendar:local_time(),
    Week = calendar:day_of_the_week(Date),
    Today = unixtime(today),
    Today - (Week - 1) * 86400;
unixtime(nextweek) ->
    unixtime(thisweek) + 604800;
%% 获取某时间戳的00:00:00的时间戳
unixtime({today, Unixtime}) ->
    Base = unixtime(today),  %% 当前周一
    case Unixtime > Base of
        false -> Base - (Base - Unixtime) div 86400 * 86400;
        true -> (Unixtime - Base) div 86400 * 86400 + Base
    end;
%% 获取当天某时间的时间戳
%% 例如: unixtime({12, 0, 0})、unixtime({0, 0, 60}) 
unixtime({H, M, S}) ->
    unixtime(today) + 3600 * H + 60 * M + S;

%% 获取下次某时间的时间戳
unixtime({next, {H, M, S}}) ->
    Target = unixtime({H, M, S}),
    case unixtime() of
        Now when Now < Target -> Target;   %% 今天
        Now when Now >= Target -> Target + 86400  %% 明天
    end.

%% @doc 获取当前的小时数值
%% @spec () -> int(0-23)
get_hour() ->
     {_Date, {NowH, _NowM, _NowS}} = calendar:local_time(),
     NowH.

%% 获取离下一个星期W的H时M分S秒 还有多少秒的时间
%% @return int()
get_diff_sec({W, H})      -> get_diff_sec({W, H, 0, 0});
get_diff_sec({W, H, M})   -> get_diff_sec({W, H, M, 0});
get_diff_sec({W, H, M, S}) ->
    {Date, {NowH, NowM, NowS}} = calendar:local_time(),
    NowW = calendar:day_of_the_week(Date),
    Diff = (W - NowW) * 3600 * 24 
    + (H - NowH) * 3600 
    + (M - NowM) * 60 
    + (S - NowS),
    case Diff > 0 of
        true -> Diff;
        false -> Diff + 7 * 3600 * 24
    end.


%% 获取今天是星期几
get_week_num() ->
    {Date, _} = calendar:local_time(),
    calendar:day_of_the_week(Date).

%% 是否在星期几
in_week_num(Num) when is_integer(Num) ->
    get_week_num() =:= Num;

in_week_num(NumList) when is_list(NumList) ->
    lists:member(get_week_num(), NumList).

%% 取得以今天为止，昨天或明天等等天数算数
%% {day, -1} 取得昨天0:00的时间戳
strtotime({day, Val}) ->
    Ts = unixtime(today),
    Ts + Val* 86400.

%% 从YmdHis格式读入时间，生成unix时间戳
%% @param Time int()
%% @return int()
mktime({"YmdHis", Time}) ->
    Year    = list_to_integer(lists:sublist(Time, 1, 4)),
    Month   = list_to_integer(lists:sublist(Time, 5, 2)),
    Day     = list_to_integer(lists:sublist(Time, 7, 2)),
    Hour    = list_to_integer(lists:sublist(Time, 9, 2)),
    Minute  = list_to_integer(lists:sublist(Time, 11, 2)),
    Second  = list_to_integer(lists:sublist(Time, 13, 2)),
    util:mktime({{Year, Month, Day}, {Hour, Minute, Second}});

%% 输入秒数 该时间的 GMT 日期格式（无时区问题
%% param UnixSec int  unixtime() 返回的秒数
%% 比老的大概慢1/10左右
%% {Y, M, D ,H ,I, S}
mktime({to_date, UnixSec})->
    DT = calendar:gregorian_seconds_to_datetime(UnixSec + calendar:datetime_to_gregorian_seconds({{1970,1,1}, {0,0,0}})),
    {{Y, M, D},{H, I, S}} = erlang:universaltime_to_localtime(DT),
    {Y, M, D, H, I, S};

%%mktime({to_date, UnixSec})->
%%    {{Y, M, D},{H, I, S}} = calendar:gregorian_seconds_to_datetime(UnixSec+calendar:datetime_to_gregorian_seconds({{1970,1,1}, {8,0,0}})),
%%    {Y, M, D, H, I, S};

%% 生成一个指定日期的unix时间戳（无时区问题
%% Date = date() = {Y, M, D}
%% Time = time() = {H, I, S}
%% 参数必须大于1970年1月1日
%% 这里比老的大概慢了1/4左右
mktime({Date, Time}) ->
    DT = erlang:localtime_to_universaltime({Date, Time}),
    calendar:datetime_to_gregorian_seconds(DT) - calendar:datetime_to_gregorian_seconds({{1970,1,1}, {0,0,0}}).

%% 生成一个指定日期的unix时间戳
%% Date = date() = {Y, M, D}
%% Time = time() = {H, I, S}
%% 参数必须大于1970年1月1日
%% 因为calendar直接是人肉从1970,1,1 0:0:0计算起，没有考虑时区问题，所以我们这里要加上8小时，为北京
%%mktime({Date, Time}) ->
%%    calendar:datetime_to_gregorian_seconds({Date, Time}) - calendar:datetime_to_gregorian_seconds({{1970,1,1}, {8,0,0}}).

%% 把秒数装换成格式 “xx小时xx分xx秒”
%% @return binary()
timef(Sec) ->
    H = (Sec div 3600),
    M = (Sec div 60) - (H * 60),
    S = (Sec rem 60),
    L = case H > 0 of
        true ->
            [integer_to_list(H), <<"小时">>, integer_to_list(M), <<"分">>, integer_to_list(S), <<"秒">>];
        false ->
            case M > 0 of
                true  -> [integer_to_list(M), <<"分">>, integer_to_list(S), <<"秒">>];
                false -> [integer_to_list(S), <<"秒">>]
            end
    end,
    list_to_binary(L).

%% @spec time_left(TimeMax::integer(), Begin::erlang:timestamp()) -> integer() | infinity
%% @doc 计算剩余时间，单位：毫秒
time_left(TimeMax, Begin)->
    case is_integer(TimeMax) of
        true ->
            TL = util:floor(TimeMax - timer:now_diff(erlang:now(), Begin) / 1000),
            case TL > 0 of
                true -> TL;
                false -> 0
            end;
        false ->
            TimeMax
    end.

%% 时间戳->Human-readable日期格式
strftime("Y-m-d H:i:s") ->
    strftime("Y-m-d H:i:s", util:unixtime()).

strftime("Y-m-d H:i:s", Ts) ->
    {Y, M, D, H, I, S} = mktime({to_date, Ts}),
    lists:concat([Y, "-", M, "-", D, " ", H, ":", I, ":", S]).

%% @doc 返回一个20100707时间样板
get_date_ymd()->
    {Y,M,D} = erlang:date(),
    Y*10000+M*100+D.

%% @doc 返回一个201204010000时间样板
get_date_ymd2() ->
    {Y, M, D} = erlang:date(),
    Y * 100000000 + M * 1000000 + D * 10000.

%% 转换成HEX格式的md5
md5(S) ->
    list_to_binary([io_lib:format("~2.16.0b",[N]) || N <- binary_to_list(erlang:md5(S))]).

%% 数字转字符串
num2str(N) ->
    lists:append(io_lib:format("~p", [N])).

%% 取小于X的最大整数 
floor(X) ->
    T = erlang:trunc(X),
    case (X < T) of
        true -> T - 1;
        _ -> T
    end.

%% 取大于X的最小整数
ceil(X) ->
    T = erlang:trunc(X),
    case (X > T) of
        true -> T + 1;
        _ -> T
    end.

%% 获取剩余时间，单位：毫秒
get_time_left(TimeMax, Begin)->
    TL = util:floor(TimeMax - timer:now_diff(erlang:now(), Begin) / 1000),
    case TL > 0 of
        true-> TL;
        false-> 0
    end.

%% 获取剩余时间，单位：毫秒
get_time_left1(TimeMax, Begin)->
    TL = util:floor(TimeMax - Begin),
    case TL > 0 of
        true-> TL;
        false-> 0
    end.

%% 产生一个介于Min到Max之间的随机整数
rand(Arg1, Arg2) when not is_integer(Arg1); not is_integer(Arg2) -> 0;
rand(Same, Same) -> Same;
rand(Min, Max) when Min > Max -> Max;
rand(Min, Max) ->
    %% 如果没有种子，将从核心服务器中去获取一个种子，以保证不同进程都可取得不同的种子
    case get("rand_seed") of
        undefined ->
            RandSeed = srv_rand:get_seed(),
            random:seed(RandSeed),
            put("rand_seed", RandSeed);
        _ -> skip
    end,
    %% random:seed(erlang:now()),
    M = Min - 1,
    random:uniform(abs(Max - M)) + M.

%% 从一个list中随机取出一项
%% null | term()
list_rand([]) -> null;
list_rand([I]) -> I;
list_rand(List) -> 
    Len = length(List),
    Index = rand(1, Len),
    get_term_from_list(List, Index).

get_term_from_list(List, 1) ->
    [Term|_R] = List,
    Term;
get_term_from_list(List, Index) ->
    [_H|R] = List,
    get_term_from_list(R, Index - 1).

%% 从一个list中随机取出N项,并返回这N项和剩余的项
%% @return {ok, TupleList1, TupleList2}
list_rands(List, N) ->
    list_rands(List, N, []).
%%
list_rands(List, N, List1) when (N > 0 andalso length(List) > 0) ->
    case list_rands(List) of
        {Term, RestList} -> list_rands(RestList, N - 1, [Term | List1]);
        _ -> {ok, List1, List}
    end;
list_rands(List, _N, List1) -> {ok, List1, List}.


%% 从一个list中随机取出一项,并返回这个项,和剩余的项
%% @return {Term, RestList} | null
list_rands([]) -> null;
list_rands(List) -> 
    Len = length(List),
    Index = rand(1, Len),
    get_term_from_lists(List, Index, []).

get_term_from_lists(List, 1, Rest) ->
    [Term | R] = List,
    {Term, R ++ Rest};
get_term_from_lists(List, Index, Rest) ->
    [H | R] = List,
    Nrest = [H | Rest],
    get_term_from_lists(R, Index - 1, Nrest).

%% @doc 从[{ItemId, ItemNum, Weight}...]列表中按照概率抽取不重复的多个元组
%% @spec [{ItemId, ItemNum, Weight}...], int() -> [{ItemId, ItemNum, Weight}...]
list_rands_by_rate(List, N) when is_list(List) andalso N > 0 ->
    if 
        N > length(List) ->
            [];
        N =:= length(List) ->
            List;
        N < length(List) ->
            TotalWeight = lists:foldl(fun({_Id, _Num, Weight}, Sum) ->
                        Weight + Sum
                end, 0, List),
            list_rands_by_rate(List, N, TotalWeight, []);
        true ->
            []
    end.

list_rands_by_rate(List, N, TotalWeight, Result) when N > 0 ->
    RandIndex = util:rand(1, TotalWeight),
    {Id, Num, Weight} = find_one_by_rate(List, RandIndex, 1, 0),
    list_rands_by_rate(List -- [{Id, Num, Weight}], N - 1, TotalWeight - Weight, Result ++ [{Id, Num, Weight}]);

list_rands_by_rate(_List, N, _TotalWeight, Result) when N =:= 0 ->
    Result.

%% 根据随机数RandIndex遍历数组，找到一个元组
find_one_by_rate(List, RandIndex, ArrayNth, LeftValue) ->
    {Id, Num, Weight} = lists:nth(ArrayNth, List),
    RightValue = LeftValue + Weight,
    case RandIndex > LeftValue andalso RandIndex =< RightValue of
        true ->
            {Id, Num, Weight};
        false ->
            find_one_by_rate(List, RandIndex, ArrayNth + 1, RightValue)
    end.

%%list_rands_by_rate 加bind字段
%% @doc 从[{ItemId, ItemNum, Weight, IsBind}...]列表中按照概率抽取不重复的多个元组
%% @spec [{ItemId, ItemNum, Weight, IsBind}...], int() -> [{ItemId, ItemNum, Weight, IsBind}...]
list_rands_by_rate_bind(List, N) when is_list(List) andalso N > 0 ->
    NewList = [{ItemId, ItemNum, Weight} || {ItemId, ItemNum, Weight, _IsBind} <- List],
    case list_rands_by_rate(NewList, N) of
        [] -> [];
        ReturnList ->
            F = fun({TItemId, TItemNum, TWeight}) ->
                case [IsBind1 || {ItemId1, ItemNum1, Weight1, IsBind1} <- List, ItemId1 =:= TItemId, ItemNum1 =:= TItemNum, Weight1 =:= TWeight ] of
                    [] -> 1;
                    [RIsBind | _] -> RIsBind
                end
            end,
            [{TItemId, TItemNum, TWeight, F({TItemId, TItemNum, TWeight})} || {TItemId, TItemNum, TWeight} <- ReturnList]
    end.
    
%% 弹出列表中的一个元素
%% @return {Term|null, TupleList1}
list_keypop(Key, N, TupleList) ->
    case lists:keyfind(Key, N, TupleList) of
        false -> {null, TupleList};
        Term -> {Term, lists:keydelete(Key, N, TupleList)}
    end.

%% 获取元素的索引
list_index(Elem, List) ->
    list_index_loop(Elem, List, 1, 0).

list_index(Elem, List, Def) ->
    list_index_loop(Elem, List, 1, Def).
    
list_index_loop(_Elem, [], _I, Def) -> Def;
list_index_loop(E, [E|_T], I, _Def) -> I;
list_index_loop(Elem, [_E|T], I, Def) -> list_index_loop(Elem, T, I+1, Def).

%% 百分概率
%% @return int()
percent() -> 
    %% (100 - rand(1, 100)).
    rand(0, 99).

%% 千分概率
%% @return int()
permille() -> 
    %% (1000 - rand(1, 1000)).
    rand(0, 999).

%% 概率命中
%% @return true | false
rand_test(Rate) ->
    R = round(Rate * 100),
    case rand(1, 10000) of
        N when N =< R ->
            true;
        _ ->
            false
    end.

%% term序列化，term转换为string格式，e.g., [{a},1] => "[{a},1]" 
term_to_string(Term) ->
    binary_to_list(list_to_binary(io_lib:format("~p", [Term]))).

%% term序列化，term转换为bitstring格式，e.g., [{a},1] => <<"[{a},1]">> 
term_to_bitstring(Term) ->
    erlang:list_to_bitstring(io_lib:format("~p", [Term])).

%% term序列化，term转换为bitstring格式，使用~w格式化，没有回车换行，e.g., [{a},1] => <<"[{a},1]">> 
term_to_bitstring2(Term) ->
    erlang:list_to_bitstring(io_lib:format("~w", [Term])).

%% 使用通用参数，转换list，int list [171,167,...] 不会保存成 string
term_to_liststring(Term) ->
    erlang:list_to_bitstring(io_lib:format("~w", [Term])).

%% term反序列化，string转换为term，e.g., "[{a},1]"  => [{a},1]
string_to_term(String) when is_list(String) ->
    case erl_scan:string(String++".") of
        {ok, Tokens, _} ->
            case erl_parse:parse_term(Tokens) of
                {ok, Term} -> Term;
                _Err -> undefined
            end;    
        _Error ->
            undefined
    end;
string_to_term(String) when is_binary(String) ->
    string_to_term(binary_to_list(String));
string_to_term(Other) -> 
    Other.

string_to_term(String, Def) -> 
    case string_to_term(String) of
        undefined -> Def;
        Term -> Term
    end.


%% 字符转数字，整数或者浮点数
string_to_num(String) ->
    case lists:member($., String) of
        true  -> list_to_float(String);
        false -> list_to_integer(String)
    end.

%% term反序列化，bitstring转换为term，e.g., <<"[{a},1]">>  => [{a},1]
bitstring_to_term(undefined) -> undefined;
bitstring_to_term(BitString) ->
    string_to_term(binary_to_list(BitString)).

%% 获取客户端ip
%% @spec get_peer_ip(socket()) -> string()
get_peer_ip(Socket) when is_port(Socket) ->
    case inet:peername(Socket) of
        {ok, {{A, B, C, D}, _}} -> lists:concat([A, ".", B, ".", C, ".", D]);
        {error, _} -> ""
    end;
get_peer_ip(_) -> "".

%% IP元组转字符
ip2bin({A, B, C, D}) ->
    list_to_binary([integer_to_list(A), ".", integer_to_list(B), ".", integer_to_list(C), ".", integer_to_list(D)]).

%% 字符型转成tuple
ipstr2tuple(Ip) ->
    [P1, P2, P3, P4] = string:tokens(Ip, "."),
    {list_to_integer(P1), list_to_integer(P2), list_to_integer(P3), list_to_integer(P4)}.

%% 将变量转换为原子
to_atom(Val) when is_atom(Val) -> Val;
to_atom(Val) when is_list(Val) -> list_to_atom(Val);
to_atom(Val) when is_binary(Val) -> to_atom(binary_to_list(Val));
to_atom(Val) -> Val.

%% 将变量转换位整数
to_integer(null) -> 0;
to_integer(undefined) -> 0;
to_integer([]) -> 0;
to_integer(Val) when is_integer(Val) -> Val;
to_integer(Val) when is_binary(Val) -> to_integer(binary_to_list(Val));
to_integer(Val) when is_list(Val) -> to_integer(list_to_integer(Val));
to_integer(Val) when is_float(Val) -> to_integer(float_to_list(Val));
to_integer(Val) -> Val.

%% 将变量转行为字符串
to_string(Val) when is_list(Val) -> Val;
to_string(Val) when is_binary(Val) -> binary_to_list(Val);
to_string(Val) when is_integer(Val) -> integer_to_list(Val);
to_string(Val) when is_atom(Val) -> atom_to_list(Val);
to_string(Val) -> Val.

%% 将列里的不同类型转行成字节型，如 [<<"字节">>, 123, asdasd, "asdasd"] 输出 <<"字节123asdasdasdasd">>
all_to_binary(List) -> all_to_binary(List, []).

all_to_binary([], Result) -> list_to_binary(Result);
all_to_binary([P | T], Result) when is_list(P) -> all_to_binary(T, lists:append(Result, P));
all_to_binary([P | T], Result) when is_integer(P) -> all_to_binary(T, lists:append(Result, integer_to_list(P)));
all_to_binary([P | T], Result) when is_binary(P) -> all_to_binary(T, lists:append(Result, binary_to_list(P)));
all_to_binary([P | T], Result) when is_float(P) -> all_to_binary(T, lists:append(Result, float_to_list(P)));
all_to_binary([P | T], Result) when is_atom(P) -> all_to_binary(T, lists:append(Result, atom_to_list(P)));
all_to_binary([P | T], Result) when is_pid(P) -> all_to_binary(T, lists:append(Result, pid_to_list(P))).

to_binary(Val) when is_integer(Val) -> list_to_binary(integer_to_list(Val));
to_binary(Val) when is_float(Val) -> list_to_binary(float_to_list(Val));
to_binary(Val) when is_list(Val) -> list_to_binary(Val);
to_binary(Val) when is_binary(Val) -> Val;
to_binary(_Val) -> <<>>.


%%转行 规则中的list 为atom
batch_list2atom([], RL) ->
    lists:reverse(RL);
batch_list2atom([{LField, Val}|T], RL) ->
    batch_list2atom(T, [{to_atom(LField), to_integer(Val)}|RL]).


%%向List 里 插入一个字符 （字符排第一）
lists_wrap_one([],_WrapS,RL)->
    [_H02|T02] = RL,
    T02;
lists_wrap_one(L,WrapS,RL) ->
    [H|T] = L,
    H1 = 
    if 
        is_integer(H) -> integer_to_list(H);
        is_atom(H) -> atom_to_list(H);
        is_float(H) -> float_to_list(H);
        true -> H
    end,
    T1 = lists:append([RL,[WrapS],[H1]]),
    lists_wrap_one(T,WrapS,T1).



%% @doc 获取TupleList相同键值个数
%% @spec lists_get_same_key_num(int, int, list, 0) -> int
lists_get_same_key_num(_, _, [], Num) -> Num;
lists_get_same_key_num(Key, Nth, L, Num) ->
    case lists:keyfind(Key, Nth, L) of
        false -> lists_get_same_key_num(Key, Nth, [], Num);
        Tmp when is_tuple(Tmp) -> 
            NewL = L -- [Tmp],
            lists_get_same_key_num(Key, Nth, NewL, Num+1);
        _ -> lists_get_same_key_num(Key, Nth, [], Num)
    end.  

%% 名称过滤
%% @return true | false 是否含有敏感词
text_banned(Text) when is_bitstring(Text) ->
    S = bitstring_to_list(Text),
    text_banned(S);
text_banned(Text) when is_list(Text) ->
    L = case application:get_env(xge, platform) of
		{ok, "efunfun"} -> data_filter_tw:name();
		_ -> data_filter:name()
	end,
    text_banned(Text, L).
text_banned(_, []) ->
    false;
text_banned(Text, [H|L]) ->
    case re:run(Text, H, [{capture, none}, caseless]) of
        match -> true;
        _ -> text_banned(Text, L)
    end.

%% 敏感词过滤
%% @param Text list() | bitstring()
%% @return bitstring() 过滤后的文本
filter_text(Text) when is_binary(Text) ->
    srv_text_filter:filter(Text);
filter_text(Text) when is_list(Text) ->
    srv_text_filter:filter(list_to_binary(Text));
filter_text(_) ->
    <<>>.
%filter_text(Text) when is_bitstring(Text) ->
%    S = bitstring_to_list(Text),
%    filter_text(S);
%filter_text(Text) when is_list(Text) ->
%    L = data_filter:talk(),
%    filter_text(Text, L).
%filter_text(Text, []) ->
%    list_to_bitstring(Text);
%filter_text(Text, [H|L]) ->
%    S = re:replace(Text, H, "\*", [caseless, global]),
%    filter_text(S, L).

%% 判断现在是否在今天某一时间段内
in_time_limit({SH, SM, SS}, {EH, EM, ES}) -> in_time_limit(unixtime(), {SH, SM, SS}, {EH, EM, ES});

%% 判断现在是否在某年某月某日某时间段内
in_time_limit({SYea, SMon, SDay, SH, SM, SS}, {EYea, EMon, EDay, EH, EM, ES}) -> in_time_limit(unixtime(), {SYea, SMon, SDay, SH, SM, SS}, {EYea, EMon, EDay, EH, EM, ES}).

%% 判断某时间是否在某年某月某日某时间段内
in_time_limit(Timestamp, {SYea, SMon, SDay, SH, SM, SS}, {EYea, EMon, EDay, EH, EM, ES}) ->
    Timestamp >= mktime({{SYea, SMon, SDay}, {SH, SM, SS}}) andalso Timestamp =< mktime({{EYea, EMon, EDay}, {EH, EM, ES}});

%% 判断某时间是否在今天某一时间段内
in_time_limit(Timestamp, {SH, SM, SS}, {EH, EM, ES}) ->
    Timestamp >= unixtime({SH, SM, SS}) andalso Timestamp =< unixtime({EH, EM, ES}).

%% 下次的某时间发消息，timer:send_after再封装
%% Time = {Hour, Min, Sec}
%%  Hour = int()
%%  Min = int()
%%  Sec = int()
%% Dest = pid() | RegName
%%  LocalPid = pid() (of a process, alive or dead, on the local node)
%% Msg = term()
%% @return TimerRef
send_after(tomorrow, {H, M, S}, Dest, Msg) ->
    timer:send_after((unixtime({H, M, S}) + 86400 - unixtime()) * 1000, Dest, Msg);   %% 明天

send_after(next, {H, M, S}, Dest, Msg) ->
    End = unixtime({H, M, S}),
    case unixtime() of
        Now  when Now < End -> timer:send_after((End - Now) * 1000, Dest, Msg);   %% 今天
        Now2 when Now2 >= End -> timer:send_after((End + 86400 - Now2) * 1000, Dest, Msg)  %% 明天
    end.

%% 解析 QueryString
parse_qs(String) when is_bitstring(String) ->
    parse_qs(bitstring_to_list(String));

parse_qs(String) ->
    parse_qs(String, "&", "=").

parse_qs(String, Token1, Token2) when is_bitstring(String) ->
    parse_qs(bitstring_to_list(String), Token1, Token2);

parse_qs(String, Token1, Token2) ->
    [ list_to_tuple(string:tokens(KV, Token2)) || KV <- string:tokens(String, Token1) ].



%% @spec shuffle_v1(L) -> NewList
%% @doc 打乱数组顺序 PS:比shuffle/1要高效
shuffle_v1(L) when is_list(L) ->
    List1 = [{random:uniform(), X} || X <- L],
    List2 = lists:keysort(1, List1),
    [E || {_, E} <- List2].

%% 打乱一个list 的顺序 from http://en.literateprograms.org/Fisher-Yates_shuffle_(Erlang)
shuffle(List) when is_list(List)-> shuffle(List, []).

shuffle([], Acc) -> Acc;
shuffle(List, Acc) ->
    {Leading, [H | T]} = lists:split(random:uniform(length(List)) - 1, List),
    shuffle(Leading ++ T, [H | Acc]).

%% @spec split_list_by_num(Num, List) -> {[SubList1, SubList2...], LeftList}
%% @doc 对List按照Num平均划分成多个SubList，返回分组后的SubList以及余下不足Num个数据的LeftList
split_list_by_num(Num, List) ->
    case Num =< 0 of
        true ->
            case length(List) > 1 of
                true ->
                    {SubList, ListLeft} = lists:split(1, List),
                    split_list_by_num(1, ListLeft, [SubList]);
                false ->
                    {[], List}
            end;
        false ->
            case length(List) > Num of
                true ->
                    {SubList, ListLeft} = lists:split(Num, List),
                    split_list_by_num(Num, ListLeft, [SubList]);
                false ->
                    {[], List}
            end
    end.

split_list_by_num(Num, List, Result) ->
    case length(List) >= Num of
        true ->
            {SubList, ListLeft} = lists:split(Num, List),
            split_list_by_num(Num, ListLeft, [SubList | Result]);
        false ->
            {Result, List}
    end.

%% @spec odd_even_list(List) -> {OddList, EvenList}
%% @spec 将List按照元素的位置分成奇偶List
odd_even_list([H | T]) ->
    odd_even_list_get_even(T, [H], []).

odd_even_list_get_even([H | T], OddList, EvenList) ->
    odd_even_list_get_odd(T, OddList, [H | EvenList]);

odd_even_list_get_even([], OddList, EvenList) ->
    {OddList, EvenList}.

odd_even_list_get_odd([H | T], OddList, EvenList) ->
    odd_even_list_get_even(T, [H | OddList], EvenList);

odd_even_list_get_odd([], OddList, EvenList) ->
    {OddList, EvenList}.

%% 类似urlencode()
escape_uri(S) when is_list(S) ->
    escape_uri(unicode:characters_to_binary(S));
escape_uri(<<C:8, Cs/binary>>) when C >= $a, C =< $z ->
    [C] ++ escape_uri(Cs);
escape_uri(<<C:8, Cs/binary>>) when C >= $A, C =< $Z ->
    [C] ++ escape_uri(Cs);
escape_uri(<<C:8, Cs/binary>>) when C >= $0, C =< $9 ->
    [C] ++ escape_uri(Cs);
escape_uri(<<C:8, Cs/binary>>) when C == $. ->
    [C] ++ escape_uri(Cs);
escape_uri(<<C:8, Cs/binary>>) when C == $- ->
    [C] ++ escape_uri(Cs);
escape_uri(<<C:8, Cs/binary>>) when C == $_ ->
    [C] ++ escape_uri(Cs);
escape_uri(<<C:8, Cs/binary>>) ->
    escape_byte(C) ++ escape_uri(Cs);
escape_uri(<<>>) ->
    "".

escape_byte(C) ->
    "%" ++ hex_octet(C).

hex_octet(N) when N =< 9 ->
    [$0 + N];
hex_octet(N) when N > 15 ->
    hex_octet(N bsr 4) ++ hex_octet(N band 15);
hex_octet(N) ->
    [N - 10 + $a].


%% 移除数组中重复的值
%% @return list()
list_unique([]) -> [];
list_unique([A]) -> [A];
list_unique([A, B]) when A =:= B -> [A];
list_unique([A, B]) -> [A, B];
list_unique([A|L]) ->
    list_unique(L, [A]).

list_unique([], L2) -> lists:reverse(L2);
list_unique([A|L], L2) ->
    case lists:member(A, L2) of
        true  -> list_unique(L, L2);
        false -> list_unique(L, [A|L2])
    end.

%% 是否合法的名称(只允许使用汉字、字母、数字和下划线)
%% @return true | false
legal_name(Name) ->
    case re:run(Name, "[^a-zA-Z0-9\\x{4E00}-\\x{9FA5}_]", [{capture, none}, caseless, unicode]) of
        match -> false;
        nomatch -> true
    end.

%% 获取server_id
%% @return int()
get_server_id() ->
    case get(server_id) of
        undefined ->
            case application:get_env(xge, server_id) of
                {ok, I} when is_integer(I) -> 
                    I;
                {ok, L} when is_list(L) ->
                    list_to_integer(L);
                {ok, T} when is_tuple(T) ->
                    [H|_] = tuple_to_list(T),
                    list_to_integer(H);
                _ ->
                    0
            end;
        S ->
            S
    end.

%% 是否合服
%% @return true | false
is_union_server() ->
    case application:get_env(xge, server_id) of
        {ok, T} when is_tuple(T) ->
            true;
        _ ->
            false
    end.

%% 清除闹钟
unset_clock(Name) ->
    case get(Name) of
        {ok, TRef} -> 
            erase(Name),
            timer:cancel(TRef);
        _Any -> ok
    end.

%% 加个闹钟
%% Name = term()
%% TimeData = int() 秒数 | time() 
%% Mix = pid() | {Mod=atom(), Fun=atom(), Arg=list()}
set_clock(Name, TimeData, Info) ->
    set_clock(Name, TimeData, self(), Info).

%% 加个闹钟
set_clock(Name, TimeData, Pid, Info) ->
    unset_clock(Name),
    Sec =
    case TimeData of
        TmpSec when is_integer(TmpSec) -> TmpSec;
        {H, M, S} -> unixtime({next, {H, M, S}}) - unixtime()
    end,
    put(Name, timer:send_after(Sec * 1000, Pid, Info)). 

%% 加个闹钟
set_clock(Name, TimeData, Mod, Fun, Args) ->
    unset_clock(Name),
    Sec =
    case TimeData of
        TmpSec when is_integer(TmpSec) -> TmpSec;
        {H, M, S} -> unixtime({next, {H, M, S}}) - unixtime()
    end,   
    put(Name, timer:apply_after(Sec * 1000, Mod, Fun, Args)).

%% 列表乱序
disorder(List) ->
    disorder(List, []).
disorder([], Result) ->
    Result;
disorder(List, Result) ->
     {ok, H, T} = list_rands(List, 1),
     disorder(T, H++Result).

%% tuple list按键取值
get_value(Key, List) ->
    get_value(Key, List, undefined).

get_value(Key, List, Default) ->
    case lists:keyfind(Key, 1, List) of
        false ->
            Default;
        {Key, Value} ->
            Value
    end.

%% 字符数量
%% @return int()
strlen(Str) when is_list(Str) ->
    strlen(list_to_binary(Str));

strlen(Bin) when is_binary(Bin) ->
    length(unicode:characters_to_list(Bin)).

test() ->
    [strlen(<<"我们">>), strlen(<<"是要2">>), strlen("顺国"), strlen("顺在某些2")].

%% 时间转二进制
time_to_binary({H, M, S}) ->
    time_to_binary({H, M, S}, normal).

time_to_binary({H, M, _S}, simple) ->
    list_to_binary([
    case H < 10 of
        true -> ["0", integer_to_list(H)];
        false -> integer_to_list(H)
    end, ":",
    case M < 10 of
        true -> ["0", integer_to_list(M)];
        false -> integer_to_list(M)
    end]);

time_to_binary({H, M, S}, normal) ->
    list_to_binary([
    case H < 10 of
        true -> ["0", integer_to_list(H)];
        false -> integer_to_list(H)
    end, ":",
    case M < 10 of
        true -> ["0", integer_to_list(M)];
        false -> integer_to_list(M)
    end, ":",
    case S < 10 of
        true -> ["0", integer_to_list(S)];
        false -> integer_to_list(S)
    end]).

%% 条件判定函数
%% @return true | {false, FalseReason}
condition([]) ->
    true;
condition([{Fun, Args, FalseReason}|T]) when is_function(Fun) ->
    case erlang:apply(Fun, Args) of
        true ->
            condition(T);
        false ->
            {false, FalseReason}
    end.

%% 生成客户格式的角色连接菜单
%% @spec String
to_role_link({RoleId, RoleNameBin})->
    "[<a href='event:1/"++ integer_to_list(RoleId) ++ "," ++ binary_to_list(RoleNameBin) ++"'><u>"++binary_to_list(RoleNameBin)++"</u></a>]".

%% 格式化浮点数，X 小数点后几位
float(Number, X) ->
    N = math:pow(10, X), round(Number * N) / N.


%% @param L = [{百分率, 要返回的值}, ...]
get_rand_val(L) -> get_rand_val(L, util:percent()).
%%
get_rand_val([{_X1, X2}], _Rand) -> X2;
get_rand_val([{X1, X2} | _L], Rand) when X1 > Rand -> X2;
get_rand_val([{X1, _X2} | L], Rand) -> 
    get_rand_val(L, Rand - X1).

%%更新属性列表值 List格式为[{Key, Value}, .....]
update_proplists(Key, Value, [{K, V}|T]) -> 
    case Key =:= K of
        true ->
            [{Key, Value}|T];
        false ->
            [{K, V}|update_proplists(Key, Value, T)]
    end;
update_proplists(Key, Value, []) -> 
    [{Key, Value}].

%% 更新多个属性
mutil_update_list(_KVs,[]) -> [];
mutil_update_list([],List) -> List;
mutil_update_list([{Key,Value}|TailList],List) ->
    NewList = lists:keyreplace(Key, 1, List, {Key,Value}),
    mutil_update_list(TailList,NewList).

%% 多键值排序
%% util:list_keysort([2,1], [{1,2,3}, {2, 1, 3}, {2, 2, 2}]).
%% [{2, 1, 3}, {1, 2, 3}, {2, 2, 2}]
list_keysort(_Keys, []) -> [];
list_keysort(_Keys, [F]) -> [F];
list_keysort([], TupleList) when is_list(TupleList) -> TupleList;
list_keysort([Key], TupleList) when is_list(TupleList) -> lists:keysort(Key, TupleList);
list_keysort([Key|Keys], TupleList) when is_list(TupleList) ->
    [F|T] = lists:keysort(Key, TupleList),
    list_keysort_fun(T, Key, Keys, element(Key, F), [F], []). %% 分组
list_keysort_fun([], _Key, Keys, _Val, Buff, Res) -> 
    NewBuff = list_keysort(Keys, Buff),
    Res ++ NewBuff;
list_keysort_fun([F|T], Key, Keys, Val, Buff, Res) ->
    case element(Key, F) of
    Val -> list_keysort_fun(T, Key, Keys, Val, [F|Buff], Res);  %% 同一组的放进buff
    Val2 -> 
        NewBuff = list_keysort(Keys, Buff),
        list_keysort_fun(T, Key, Keys, Val2, [F], Res ++ NewBuff)
    end.


%% @doc 多键值排序 附带键值排序(@Yujia)
%% @spec util:list_keysort_by_order( [{1,0},{2,1}], [{1,7,6},{1,2,4},{3,2,5}] ) -> [{1,7,6},{1,2,4},{3,2,5}]
%% @note param1 TupleList() 第1位为键值 第2位为排序选项(0升序 1降序)
%%       param2 TupleList() 要排的序列
%%       return TupleList()    
list_keysort_by_order(_Keys, []) -> [];
list_keysort_by_order(_Keys, [F]) -> [F];
list_keysort_by_order([], TupleList) when is_list(TupleList) -> TupleList;
list_keysort_by_order([Key], TupleList) when is_list(TupleList) -> 
    {K, Option} = Key,
    case Option of
        0 -> lists:keysort(K, TupleList);
        1 -> lists:reverse(lists:keysort(K, TupleList));
        _ -> lists:keysort(K, TupleList)
    end;
list_keysort_by_order([Key|Keys], TupleList) when is_list(TupleList) ->
    {K, Option} = Key,
    [F|T] = case Option of
        0 -> lists:keysort(K, TupleList);
        1 -> lists:reverse(lists:keysort(K, TupleList));
        _ -> lists:keysort(K, TupleList)
    end,
    list_keysort_fun_by_order(T, Key, Keys, element(K, F), [F], []). %% 分组
list_keysort_fun_by_order([], _Key, Keys, _Val, Buff, Res) -> 
    NewBuff = list_keysort_by_order(Keys, Buff),
    Res ++ NewBuff;
list_keysort_fun_by_order([F|T], Key, Keys, Val, Buff, Res) ->
    {K, _Option} = Key,
    case element(K, F) of
    Val -> list_keysort_fun_by_order(T, Key, Keys, Val, [F|Buff], Res);  %% 同一组的放进buff
    Val2 -> 
    NewBuff = list_keysort_by_order(Keys, Buff),
    list_keysort_fun_by_order(T, Key, Keys, Val2, [F], Res ++ NewBuff)
    end.



init_interval(Tag) ->
    put(run_interval, erlang:now()),
    io:format("tag:~w init~n", [Tag]).

run_interval(Tag) ->
    case get(run_interval) of
    undefined -> 
        put(run_interval, erlang:now()),
        io:format("tag:~w init~n", [Tag]);
    {MS, S, MS2} -> 
        {NewMS, NewS, NewMS2} = erlang:now(),
        I = ((NewMS * 1000000 + NewS) * 1000000 + NewMS2 - ((MS * 1000000 + S) * 1000000 + MS2)) div 1000 / 1000,
        put(run_interval, {NewMS, NewS, NewMS2}),
        io:format("tag:~w interval:~w~n", [Tag, I]),
        Bin = io_lib:format("date:~w~w mod:~w tag:~w interval:~w~n", [erlang:date(), erlang:time(), srv_auction, Tag, I]),
        file:write_file("auction.log",Bin,[append])
    end.


%% 跨节点询问进程是否存活
%% @spec is_process_alive(pid()) -> true | false
is_process_alive(Pid) when is_pid(Pid) ->
    case rpc:call(node(Pid), erlang, is_process_alive, [Pid]) of
        {badrpc, _Reason} -> false;
        Bool -> Bool
    end.

url_encode([H|T]) ->
    if
        H >= $a, $z >= H ->
            [H|url_encode(T)];
        H >= $A, $Z >= H ->
            [H|url_encode(T)];
        H >= $0, $9 >= H ->
            [H|url_encode(T)];
        H == $_; H == $.; H == $-; H == $/; H == $: -> %
            [H|url_encode(T)];
        true ->
            case integer_to_hex(H) of
                [X, Y] ->
                    [$%, X, Y | url_encode(T)];
                [X] ->
                    [$%, $0, X | url_encode(T)]
            end
     end;	
url_encode([]) ->
    [].

integer_to_hex(I) ->
    case catch erlang:integer_to_list(I, 16) of
        {'EXIT', _} ->
            old_integer_to_hex(I);
        Int ->
            Int
    end.
old_integer_to_hex(I) when I<10 ->
    integer_to_list(I);
old_integer_to_hex(I) when I<16 ->
    [I-10+$A];
old_integer_to_hex(I) when I>=16 ->
    N = trunc(I/16),
    old_integer_to_hex(N) ++ old_integer_to_hex(I rem 16).

%% @spec positive_int(Num) -> int()
%% @doc 取正整数
positive_int(Num) when Num > 0 -> trunc(Num); 
positive_int(_) -> 0.

%% @spec positive_num(Num) -> int()
%% @doc 取正数
positive_num(Num) when Num > 0 -> Num; 
positive_num(_) -> 0.

%% @doc  合并list中key相同的 值相加
combine_list_by_key([]) -> [];
combine_list_by_key(List) -> 
	F = fun({Key, Value}, Result) ->
		case lists:keyfind(Key, 1, Result) of
			false -> [{Key, Value} | Result];
			{_, Value1} -> 
                lists:keyreplace(Key, 1, Result, {Key, Value + Value1})
				%[{Key, Value + Value1} | lists:delete({Key, Value1}, Result)]
		end
	end,
	lists:foldl(F, [], List).

%% @doc 合并list中的值 并作为key返回
%% @note [{1,30},{2,32},{3,30},{4,31}] -> [{30,2},{32,1},{31,1}]
combine_list_by_value([], Rtn) ->
    combine_list_by_key(Rtn);
combine_list_by_value(List, Rtn) ->
    [FirstTuple|RList] = List,
    {_, Value} = FirstTuple,
    NewRtn = Rtn ++ [{Value, 1}],
    combine_list_by_value(RList, NewRtn).

%% @doc 两个[{Key, Value}] 列表，key相同时value相减。若已存在的值小于需减去的值，则把该键值对从List中删除
decrease_list_by_key([], _) -> [];
decrease_list_by_key(List, [{Key, Value} | T]) ->
    case lists:keyfind(Key, 1, List) of
        {Key, ExistValue} when ExistValue > Value ->
            decrease_list_by_key(lists:keyreplace(Key, 1, List, {Key, ExistValue - Value}), T);
        {Key, ExistValue} when ExistValue =< Value ->
            decrease_list_by_key(lists:keydelete(Key, 1, List), T);
        _ ->
            decrease_list_by_key(List, T)
    end;
decrease_list_by_key(List, []) -> List.

%% @doc 两个[{Key, Value}] 列表，key相同时value相减。若已存在的值小于需减去的值，则保留value = 0
decrease_list_with_value_0([], _) -> [];
decrease_list_with_value_0(List, [{Key, Value} | T]) ->
    case lists:keyfind(Key, 1, List) of
        {Key, ExistValue} when ExistValue > Value ->
            decrease_list_with_value_0(lists:keyreplace(Key, 1, List, {Key, ExistValue - Value}), T);
        {Key, ExistValue} when ExistValue =< Value ->
            decrease_list_with_value_0(lists:keyreplace(Key, 1, List, {Key, 0}), T);
        _ ->
            decrease_list_with_value_0(List, T)
    end;
decrease_list_with_value_0(List, []) -> List.

%% @doc 取列表对应元素(@YuJia)
%% @spec list_get_one_segment(int, int, List()) -> NewList()
%% @note param1 起始元素位置
%%       param2 选取的段大小
%%       param3 原始列表
list_get_one_segment(0, _, _WholeList) -> [];
list_get_one_segment(_OffSet, _, []) -> [];
list_get_one_segment(OffSet, Size, WholeList) ->
    list_get_one_segment(OffSet, Size, WholeList, []).

list_get_one_segment(_OffSet, 0, _WholeList, Rtn) -> Rtn;
list_get_one_segment(OffSet, Size, WholeList, Rtn) when Size>0, OffSet>0 ->
    Element = try lists:nth(OffSet, WholeList)
        catch _:_ -> []
    end,
    NewL = case Element of
        [] -> Rtn;
        ElementTmp ->  Rtn ++ [ElementTmp]
    end,
    list_get_one_segment(OffSet+1, Size-1, WholeList, NewL);
list_get_one_segment(_, _, _, Rtn) ->
    Rtn.


%% @doc 列表批量删除元素
%% @spec list_delete_sublist(list(), list()) -> list()
list_delete_sublist([], RtnL) -> RtnL;
list_delete_sublist(SubList, List) ->
    [Elem | Left] = SubList,
    NewList = case lists:member(Elem, List) of
        true -> lists:delete(Elem, List);
        false -> List
    end,
    list_delete_sublist(Left, NewList).


%% @doc 获取列表元组最小值 [{4,5},{6,2},{1,7}] -> {1,2}
%% @spec proplists_get_min_key(List()) -> {int, int}
%% @spec 暂时只支持双元组 且小于1023 后续会改进
proplists_get_min_key(List) -> proplists_get_min_key(List, 1023, 1023).
proplists_get_min_key([], V1, V2) -> {V1, V2};
proplists_get_min_key(List, OV1, OV2) ->
    [First | RemainL] = List,
    {V1, V2} = First,
    NV1 = case V1 =< OV1 of
        true -> V1;
        false -> OV1
    end,
    NV2 = case V2 =< OV2 of
        true -> V2;
        false -> OV2
    end,
    proplists_get_min_key(RemainL, NV1, NV2).

%% @doc 一个数base增加Plus值后，最大只能达到Max,直接返回Result
%% @spec plus_max(int, int, int) -> int
%% @spec 一个数base增加Plus值后，最大只能达到Max,直接返回Result
plus_max(Base, Plus, Max) ->
	New = Base + Plus,
	case New >= Max of
		true ->
			Max;
		false ->
			New
	end.

%% @doc 一个数base减小minus值后，最小只能小到Min,直接返回Result
%% @spec minus_max(int, int, int) -> int
%% @spec 一个数base减小minus值后，最小只能小到Min,直接返回Result
minus_min(Base, Minus, Min) ->
	New = Base - Minus,
	case New =< Min of
		true ->
			Min;
		false ->
			New
	end.


%% ---------------------------------------------------------------------------
%% @doc 日历一页的所有天数
%% @spec one_page_days() -> [{Year, Month, Day}....].
%% ---------------------------------------------------------------------------
one_page_days() ->
    one_page_days(erlang:date()).
%% ---------------------------------------------------------------------------
%% @doc 本日期当前页的日历
%% @spec one_page_days({Y, M, D}) -> [{Year, Month, Day}....].
%% ---------------------------------------------------------------------------
one_page_days({Y, M, _D}) ->
    %% 本月的所有日期
    LastDay = calendar:last_day_of_the_month(Y, M),
    Month = [{Y, M, Day} || Day <- lists:seq(1, LastDay)],
    %% 上个月最后7天
    WeekDay1 = calendar:day_of_the_week({Y, M, 1}),
    LeftPrevDays1 = (WeekDay1 + 6) rem 7,
    Prev7Days = util:mktime({{Y, M, 1}, {0, 0, 0}}) - LeftPrevDays1 * 86400,
    {Y1, M1, _D1, _, _, _} = util:mktime({to_date, Prev7Days}),
    LastDay1 = calendar:last_day_of_the_month(Y1, M1),
    PrevMonth = [{Y1, M1, Day1} || Day1 <- lists:seq(LastDay1 - LeftPrevDays1 + 1, LastDay1)],
    %% 下个月前七天
    WeekDay2 = calendar:day_of_the_week({Y, M, LastDay}),
    LeftAfterDays = 7 - WeekDay2,
    After7Days = util:mktime({{Y, M, LastDay}, {0, 0, 0}}) + LeftAfterDays * 86400,
    {Y2, M2, _D2, _, _, _} = util:mktime({to_date, After7Days}),
    AfterMonth = [{Y2, M2, Day2} || Day2 <- lists:seq(1, LeftAfterDays)],
    PrevMonth ++ Month ++ AfterMonth.
%% ---------------------------------------------------------------------------
%% @doc 获取列表中某个元素的位置 Pos从1开始,找不到的时候返回0
%% @spec pos(Elem, List) -> Pos::int(). 
%% ---------------------------------------------------------------------------
pos(Elem, List) -> pos(Elem, List, length(List), 1).
pos(_Elem, [], ListLen, Pos) when ListLen >= Pos -> Pos;
pos(_Elem, [], _ListLen, _Pos) -> 0;
pos(Elem, [H|_List], _ListLen, Pos) when Elem =:= H -> Pos;
pos(Elem, [_H|List], ListLen, Pos) -> pos(Elem, List, ListLen, Pos + 1).



%% @doc Description: 拆分一个整数从个位数向左N位,位数不足的以0补齐  split_num(123213, 8) ->[3,1,2,3,2,1,0,0]; split_num(123213, 3) ->[3,1,2]
%% @spec Function: split_num
%% @spec Params: Id, N
%% @spec Returns: List
split_num(Id, N) when is_integer(Id) =/= true orelse N =< 0 ->
	[];
split_num(Id, N) when Id >= 0->
	split_num(Id, N, []);
split_num(Id, N) when Id < 0 ->
	split_num(-1 * Id, N, []).
split_num(_Id, Num, List) when Num =< 0 ->
	lists:reverse(List);
split_num(Id, Num, List) ->
	Elem = Id rem 10,
	Rest = Id div 10,
	split_num(Rest, Num -1, [Elem|List]).

%% @doc Description: 检查是否在开服Days天之后
%% @spec Function: check_after_open_time/1
%% @spec Params: Int(Days)
%% @spec Returns: true Days天之后，false Days天之内
check_after_open_time(Days) ->
	OpenTime = case xge_env:get(open_time) of
				   Time when is_integer(Time) -> Time;
				   _ -> 0
			   end,
	util:unixtime() - OpenTime >= Days * 86400.

%% 找出List符合F的第一个元素
%% list_map_first_element(fun(E)-> lists:member(E,[1,2,3]), [5,2,3]). return->2
%% return -> [] | Value
filter_first_element(_F, []) ->
	[];
filter_first_element(F, [Ele|List]) ->
	case F(Ele) of
		true -> Ele;
		false ->
			filter_first_element(F, List)
	end.
list_insert(Pos, Value, List) when Pos < 0 ->
    NewList = list_insert(abs(Pos), Value, lists:reverse(List)),
    lists:reverse(NewList);
list_insert(Pos, Value, List) when Pos > length(List) -> List ++ [Value];
list_insert(Pos, Value, List) ->
    {List1, List2} = lists:split(Pos, List),
    List1 ++ [Value] ++ List2.

