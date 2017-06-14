%% @author mars
%% @doc @todo Add description to sys_api.


-module(sys_var_api).

%% include files
%% ---------------------------------


%% API functions
%% ---------------------------------
-export([
         load_from_application/0
         ,load_from_db/0
         ,sync_db/2
        ]).

%% application parms dynamic_compile
load_from_application() -> ok.

%% sys var form db dynamic_compile
load_from_db() ->
    SQL = <<"select `key`, `value` from `sys_var`">>,
    List = db:get_all(SQL),
    parse(List),
    ok.

sync_db(Key, Value) ->
    SQL = <<"replace into `sys_var` (`key`, `value`) values(~s, ~s)">>,
    db:execute(SQL, [Key, Value]).


%% Internal functions
%% ---------------------------------
parse([]) -> ok;
parse([[DBKey, DBValue]|List]) ->
    Key = util:to_atom(DBKey),
    Value = util:bitstring_to_term(DBValue),
    game_global:put(Key, Value),
    parse(List).



