%%----------------------------------------------------
%% code hot upgrade
%% x-mars
%%----------------------------------------------------
-module(game_code).
-export([
         init/0
        ,beam_file/0
        ,beam_hash/0
        ,beam_hash/1
        ,up/0
        ,up/1
        ,up/2
        ,make/1
    ]
).

-define(EBIN_DIR, "./../ebin").

-include("game.hrl").

%% @spec init() -> ok
%% @doc 初始化
init() ->
    ?INFO("[~w] starting...", [?MODULE]),
    ets:new(sys_code, [named_table, public, set]),
    [ets:insert(sys_code, X) || X <- beam_hash()],
    ?INFO("[~w] start succeed...", [?MODULE]),
    ok.

%% @spec make(Param :: list()) -> up_to_date | error
%% @doc 编译源码
make(Param) ->
    file:set_cwd("../"),
    Rtn = make:all(Param),
    file:set_cwd("ebin"),
    Rtn.

%% @spec beam_file() -> List :: list().
%% @doc 获取ebin目录下的beam文件列表
beam_file() ->
    case file:list_dir(?EBIN_DIR) of
        {ok, FList} ->
            {ok, do_beam_file(FList, [])};
        {error, Why} ->
            {error, Why}
    end.

%% @spec beam_hash() -> {ok, List} | {error, Why}
%% List = list()
%% Why = term()
%% @doc 获取所有beam文件的hash值
beam_hash() ->
    case beam_file() of
        {ok, F} ->
            do_beam_hash(F);
        {error, Why} ->
            {error, Why}
    end.

%% @spec beam_hash(M) -> List
%% M = atom()
%% List = list()
%% @doc 获取指定beam文件的hash值
beam_hash(M) ->
    do_beam_hash([M]).

%% @spec up() -> ok
%% @doc 重新检查并加载所有的模块
up() ->
    O = ets:tab2list(sys_code),
    N = beam_hash(),
    do_up(N, O, [], fun code:soft_purge/1).

%% @spec up(force) -> ok
%% @doc 重新检查并加载所有的模块，并强制清除运行中的旧代码
up(force) ->
    N = beam_hash(),
    O = ets:tab2list(sys_code),
    do_up(N, O, [], fun code:purge/1);

%% @spec up(ModList) -> ok
%% ModList = list()
%% @doc 重新检查并加载指定的模块
up(ModList) ->
    O = ets:tab2list(sys_code),
    N = do_beam_hash(ModList),
    do_up(N, O, [], fun code:soft_purge/1).

%% @spec up(ModList, force) -> ok
%% @doc 重新检查并加载指定的模块，并强制清除运行中的旧代码
up(ModList, force) ->
    O = ets:tab2list(sys_code),
    N = do_beam_hash(ModList),
    do_up(N, O, [], fun code:purge/1).

%% ----------------------------------------------------
%% 私有函数
%% ----------------------------------------------------

%% 返回所有的beam文件
do_beam_file([], List) -> List;
do_beam_file([F | T], List) ->
    NL = case filename:extension(F) =:= ".beam" of
        true ->
            M = filename:basename(filename:rootname(F)),
            [M | List];
        _ -> List
    end,
    do_beam_file(T, NL).

%% 返回beam hash
do_beam_hash(ModList) ->
    file:set_cwd("../ebin"),
    List = handle_beam_hash(ModList, []),
    file:set_cwd("../config"),
    List.

handle_beam_hash([], List) -> List;
handle_beam_hash([N | T], List) ->
    NL = 
        case beam_lib:md5(N) of
            {ok, {M, Md5}} ->
                [{M, util:md5(Md5)} | List];
            {error, Why} ->
                ?ERR("fail to get file[~w] hash value WHY :~p", [N, Why]),
                List;
            _Err -> 
                ?ERR("fail to get file[~w] hash value ERROR :~p", [N, _Err]),
                List
        end,
    handle_beam_hash(T, NL).

%% 执行更新
do_up([], _O, Rtn, _Fun) -> Rtn;
do_up([{Mod, NewHash} | N], O, Rtn, Fun) ->
    NewRtn = case lists:keyfind(Mod, 1, O) of
        false ->
            [load_beam(Mod, NewHash, Fun) | Rtn];
        {_, OldHash} ->
            case OldHash =:= NewHash of
                true -> Rtn;
                false -> [load_beam(Mod, NewHash, Fun) | Rtn]
            end
    end,
    do_up(N, O, NewRtn, Fun).

%% 加载beam文件(热更新)
load_beam(Mod, Hash, PurgeFun) ->
    PurgeFun(Mod),
    case code:load_file(Mod) of
        {module, _} ->
            ets:insert(sys_code, {Mod, Hash}),
            {Mod, ok};
        {error, Why} ->
            {Mod, {error, Why}}
    end.