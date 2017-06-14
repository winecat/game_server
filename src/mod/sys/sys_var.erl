%% @author mars
%% @doc @todo Add description to sys_var.


-module(sys_var).

%% include files
%% ---------------------------------
-include("game.hrl").


%% API functions
%% ---------------------------------
-export([
         init/0
        
         ,get/1
         ,get/2
         ,set/2
         ,sync_set/2
        ]).


init() -> 
    ok = sys_var_api:load_from_application(),   %%application global
    ok = sys_var_api:load_from_db(),    %% sys var from db global
    ok.


get(Key) -> game_global:get(Key).

get(Key, Default) -> game_global:get(Key, Default).

set(Key, Value) -> game_global:put(Key, Value).

sync_set(Key, Value) ->
    case game_global:put(Key, Value) of
        ok -> sys_var_api:sync_db(Key, Value);
        _ -> ?ERR("sync set error:~w/~w", [Key, Value])
    end.
    
%% Internal functions
%% ---------------------------------


