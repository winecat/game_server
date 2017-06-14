%% @author mars
%% game error logger


-module(game_logger).
-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%% include files
%% ---------------------------------

-record(state, {}).

%% API functions
%% ---------------------------------
-export([
         logger_file/0
        ]).


logger_file() ->
    LogPath = 
        case application:get_env(log_path) of
            undefined -> "./../var/";
            Var -> Var
        end,
    {{Y, M, D}, {H, I, S}} = erlang:localtime(),
    Date = io_lib:format("~w_~w_~w_~w_~w_~w", [Y, M, D, H, I, S]),
    error_logger:logfile([{open, lists:concat([LogPath, Date, ".log"])}]),
    ok.

error(ErrMSG) ->
    gen_server:cast(?MODULE, {'error_msg', ErrMSG}).



%% init/1
init([]) ->
    {ok, #state{}}.


%% handle_call/3
handle_call(Request, From, State) ->
    Reply = ok,
    {reply, Reply, State}.


%% handle_cast/2
handle_cast(Msg, State) ->
    {noreply, State}.


%% handle_info/2
handle_info(Info, State) ->
    {noreply, State}.


%% terminate/2
terminate(Reason, State) ->
    ok.


%% code_change/3
code_change(OldVsn, State, Extra) ->
    {ok, State}.



%% Internal functions
%% ---------------------------------


