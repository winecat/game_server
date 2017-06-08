-module(game_global).
-author("mars <x9mars@qq.com>").
-export([get/1, get/2, put/2, delete/1]).
-include("game_global.hrl").

%% notice
%% 此模块根据mochiweb中的mochiglobal模块，结合自己项目自身需求做了一些特殊优化而来的，
%% 注意，是特殊处理
%% 部分系统常量的定义，可通过此方法做beam化处理，加速访问速度

%% key 的约定
%% 所有key必须是原子atom格式，并且是以 ugl_ 开头
%% 原子key类型统一定义在 util_global.hrl 头文件里

-spec get(atom()) -> any() | undefined.
%% @equiv get(Key, undefined)
get(Key) when is_atom(Key)->
    get(Key, undefined).

-spec get(atom(), T) -> any() | T.
%% @doc Get the term for K or return Default.
get(Key, Default) ->
    try Key:term()
    catch error:undef ->
            Default
    end.

-spec put(atom(), any()) -> ok.
%% @doc Store term Val at Key, replaces an existing term if present.
put(Key, Val) ->
    case erlang:atom_to_list(Key) of
        [103, 108, 111, 98, 97, 108, 95|_] -> %%"global_" ASCII十进制码
            Bin = compile(Key, Val),
            code:purge(Key),
            {module, Key} = code:load_binary(Key, atom_to_list(Key) ++ ".erl", Bin),
            ok;
        _ -> ?TYPE_ERROR('put error key not atom', Key)
    end.


-spec delete(atom()) -> boolean().
%% @doc Delete term stored at K, no-op if non-existent.
delete(Key) when is_atom(Key) ->
    code:purge(Key),
    code:delete(Key).

-spec compile(atom(), any()) -> binary().
compile(Module, T) ->
    {ok, Module, Bin} = compile:forms(forms(Module, T),
                                      [verbose, report_errors]),
    Bin.

-spec forms(atom(), any()) -> [erl_syntax:syntaxTree()].
forms(Module, T) ->
    [erl_syntax:revert(X) || X <- term_to_abstract(Module, term, T)].

-spec term_to_abstract(atom(), atom(), any()) -> [erl_syntax:syntaxTree()].
term_to_abstract(Module, Getter, T) ->
    [%% -module(Module).
     erl_syntax:attribute(
       erl_syntax:atom(module),
       [erl_syntax:atom(Module)]),
     %% -export([Getter/0]).
     erl_syntax:attribute(
       erl_syntax:atom(export),
       [erl_syntax:list(
         [erl_syntax:arity_qualifier(
            erl_syntax:atom(Getter),
            erl_syntax:integer(0))])]),
     %% Getter() -> T.
     erl_syntax:function(
       erl_syntax:atom(Getter),
       [erl_syntax:clause([], none, [erl_syntax:abstract(T)])])].

%%
%% Tests
%%
-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
get_put_delete_test() ->
    K = '$$test$$mochiglobal',
    delete(K),
    ?assertEqual(
       bar,
       get(K, bar)),
    try
        ?MODULE:put(K, baz),
        ?assertEqual(
           baz,
           get(K, bar)),
        ?MODULE:put(K, wibble),
        ?assertEqual(
           wibble,
           ?MODULE:get(K))
    after
        delete(K)
    end,
    ?assertEqual(
       bar,
       get(K, bar)),
    ?assertEqual(
       undefined,
       ?MODULE:get(K)),
    ok.
-endif.