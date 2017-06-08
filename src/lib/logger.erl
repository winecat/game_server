%%----------------------------------------------------
%% 日志记录器
%% 
%% @author yeahoo2000@gmail.com
%% @end
%%----------------------------------------------------
-module(logger).
-export([
        info/1				%% 输出系统信息到控制台
        ,info/2				%% 输出系统信息到控制台
        ,info/4				%% 输出系统信息到控制台
        ,debug/1			%% 输出调试信息到控制台
        ,debug/2			%% 输出调试信息到控制台
        ,debug/4			%% 输出调试信息到控制台
        ,error/1			%% 输出错误信息到控制台
        ,error/2			%% 输出错误信息到控制台
        ,error/4			%% 输出错误信息到控制台

        ,err_log/1			%% 输出错误信息到控制台并记录日志
        ,err_log/2 			%% 输出错误信息到控制台并记录日志
        ,err_log/4			%% 输出错误信息到控制台并记录日志

		,format/5			%% 格式化日志信息
    ]
).

-include("common.hrl").

%% --------------------------------------------
%% @doc 输出系统信息到控制台
%% --------------------------------------------
info(Msg) ->
    info(Msg, []).
info(Format, Args) ->
    info(Format, Args, null, null).
info(Format, Args, Mod, Line) ->
    Msg = format("info", Format, Args, Mod, Line),
    io:format("~ts", [Msg]).

%% --------------------------------------------
%% @doc 输出调试信息到控制台
%% --------------------------------------------
debug(Msg) ->
    debug(Msg, []).
debug(Format, Args) ->
    debug(Format, Args, null, null).
debug(Format, Args, Mod, Line) ->
	Msg = format("debug", Format, Args, Mod, Line),
	io:format("~ts", [Msg]).

%% --------------------------------------------
%% @doc 输出错误信息到控制台
%% --------------------------------------------
error(Msg) ->
    ?MODULE:error(Msg, []).
error(Format, Args) ->
    ?MODULE:error(Format, Args, null, null).
error(Format, Args, Mod, Line) ->
    Msg = format("error", Format, Args, Mod, Line),
    io:format("~ts", [Msg]).

%% --------------------------------------------
%% @doc 输出错误信息到控制台并记录日志
%% --------------------------------------------
err_log(Msg) ->
    err_log(Msg, []).
err_log(Format, Args) ->
    err_log(Format, Args, null, null).
err_log(Format, Args, Mod, Line) ->
    Msg = format("elog", Format, Args, Mod, Line),
    io:format("~ts", [Msg]),
    log(0, Msg).

%% --------------------------------------------
%% @doc 格式化日志信息
%% --------------------------------------------
-spec format(T, F, A, Mod, Line) -> binary() when
	T	:: bitstring(),			%% 日志最前面的标记字符串 debug info error 等
	F	:: list() | binary(),	%% 格式字符串(UTF8-list, UTF8-binary)
	A	:: list(),				%% 参数列表
	Mod	:: atom(),				%% 模块名
	Line:: integer().			%% 行

%% format(T, F, A, Mod, Line) when is_binary(F) ->
%% 	format(T, binary_to_list(F), A, Mod, Line);
%% format(T, F, A, Mod, Line) ->
%% 	try
%% 		{{Y, M, D}, {H, I, S}} = erlang:localtime(),
%% 		Date = lists:flatten(io_lib:format("~4..0w-~2..0w-~2..0w ~2..0w:~2..0w:~2..0w", [Y, M, D, H, I, S])),
%% 		case Line of
%% 			null -> unicode:characters_to_binary(io_lib:format(unicode:characters_to_list(list_to_binary(lists:concat(["## ", T, " ~s ", F, "~n"]))), [Date] ++ A));
%% 			_ -> unicode:characters_to_binary(io_lib:format(unicode:characters_to_list(list_to_binary(lists:concat(["## ", T, " ~s [~w:~w] ", F, "~n"]))), [Date, Mod, Line] ++ A))
%% 		end
%% 	catch _T:_X ->
%% 		catch io:format("## error ~ts:\n\t-fmt: ~ts\n\t-arg: ~w\n\t-stack: ~p\n", [<<"格式化错误">>, F, A, erlang:get_stacktrace()]),
%% 		<<>>
%% 	end.

format(T, F, A, Mod, Line) when is_binary(F) ->
    format(T, unicode:characters_to_list(F), A, Mod, Line);
format(T, F, A, Mod, Line) ->
    {{Y, M, D}, {H, I, S}} = erlang:localtime(),
    Date = lists:concat([Y, "/", M, "/", D, " ", H, ":", I, ":", S]),
    case Line of
        null -> unicode:characters_to_binary(io_lib:format(lists:concat(["## ", T, " ~s ", F, "~n"]), [Date] ++ A));
        _ -> unicode:characters_to_binary(io_lib:format(lists:concat(["## ", T, " ~s[~w:~w] ", F, "~n"]), [Date, Mod, Line] ++ A))
    end.


%% --------------------------------------------
%% @doc 持久化日志
%% --------------------------------------------
-spec log(Type, Msg) -> ok when
	Type	:: integer(),
	Msg		:: bitstring().

log(Type, Msg) ->
    spawn(
		fun() ->
			db:execute("insert into log_common(type, msg, ctime) values(~s, ~s, ~s)", [Type, Msg, util:unixtime()])
		end
	),
    ok.

