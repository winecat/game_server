%% @author mars
%% @doc @todo Add description to sys_var.


-module(sys_var).

%% include files
%% ---------------------------------


%% API functions
%% ---------------------------------
-export([
         init/0
        ]).


init() -> 
    ok = sys_var_api:load_from_application(),   %%application global
    ok = sys_var_api:load_from_db(),    %% sys var from db global
    ok.


get(Key) -> game_global:get(Key).

get(Key, Default) -> game_global:get(Key, Default).


%% Internal functions
%% ---------------------------------


