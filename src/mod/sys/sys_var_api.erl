%% @author mars
%% @doc @todo Add description to sys_api.


-module(sys_api).

%% include files
%% ---------------------------------


%% API functions
%% ---------------------------------
-export([
         load_from_application/0
         ,load_from_db/0
        ]).

%% application parms dynamic_compile
load_from_application() -> ok.

%% sys var form db dynamic_compile
load_from_db() ->
    SQL = <<"select key, value from sys_var">>,
    List = db:get_all(SQL),
    parse(List),
    ok.


%% Internal functions
%% ---------------------------------
parse(List) -> ok.


