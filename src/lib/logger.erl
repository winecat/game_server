%%----------------------------------------------------
%% 日志记录器
%%----------------------------------------------------
-module(logger).
-export([
         info/1				
         ,info/2				
         ,info/4				
         ,debug/1			
         ,debug/2			
         ,debug/4			
         ,error/1			
         ,error/2			
         ,error/4			
        ]).

-include("game.hrl").

%% info
info(MSG) ->
    info(MSG, []).
info(Format, Args) ->
    info(Format, Args, null, null).
info(Format, Args, Mod, Line) ->
    MSG = format("info", Format, Args, Mod, Line),
    io:format("~ts", [MSG]).

%% debug
debug(MSG) ->
    debug(MSG, []).
debug(Format, Args) ->
    debug(Format, Args, null, null).
debug(Format, Args, Mod, Line) ->
	MSG = format("debug", Format, Args, Mod, Line),
	io:format("~ts", [MSG]).

%% error
error(MSG) ->
    ?MODULE:error(MSG, []).
error(Format, Args) ->
    ?MODULE:error(Format, Args, null, null).
error(Format, Args, Mod, Line) ->
    MSG = format("error", Format, Args, Mod, Line),
    io:format("~ts", [MSG]),
    error_log(MSG).


%% @doc 格式化日志信息
format(T, F, A, Mod, Line) when is_binary(F) ->
    format(T, unicode:characters_to_list(F), A, Mod, Line);
format(T, F, A, Mod, Line) ->
    {{Y, M, D}, {H, I, S}} = erlang:localtime(),
    Date = lists:concat([Y, "/", M, "/", D, " ", H, ":", I, ":", S]),
    case Line of
        null -> unicode:characters_to_binary(io_lib:format(lists:concat(["## ", T, " ~s ", F, "~n"]), [Date] ++ A));
        _ -> unicode:characters_to_binary(io_lib:format(lists:concat(["## ", T, " ~s[~w:~w] ", F, "~n"]), [Date, Mod, Line] ++ A))
    end.

%% 通知错误日志进程
error_log(MSG) -> game_logger:error(MSG).


