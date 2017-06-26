%%----------------------------------------------------
%% db profile
%%----------------------------------------------------
-module(db_prof).
-include("game.hrl").
-compile(export_all).

-define(prof_output, "../var/db_prof.log").
-define(log_output, "../var/db.log").
%-define(open_db_prof, true).

-record(state, 
        {
         dict    
         ,total = 0
         ,start
         ,log_fd
        }).

log(Sql) ->
    Pid = ensure_started(),
    gen_server:cast(Pid, {log, Sql, self()}).
log(Sql, Time) ->
    Pid = ensure_started(),
    gen_server:cast(Pid, {log, Sql, self(), Time}).

write() ->
    write(?prof_output).

write(File) when is_list(File) ->
    Pid = ensure_started(),
    gen_server:cast(Pid, {write, File}).

empty() ->
    case whereis(?MODULE) of
        undefined -> ok;
        Pid -> gen_server:cast(Pid, empty)
    end.

ensure_started() ->
    case whereis(?MODULE) of
        undefined ->
            {ok, Pid} = gen_server:start({local, ?MODULE}, ?MODULE, [], []),
            Pid;
        Pid -> Pid
    end.

%% -----------------
init([]) ->
    {ok, LogFd} = file:open(?log_output, [append]),
    State = #state{dict = dict:new(),total = 0,
                   start = erlang:localtime(), log_fd = LogFd},
    {ok, State}.

handle_call(_Request, _From, State) ->
    {noreply, State}.

handle_cast({log, Sql, Pid}, State) -> handle_cast({log, Sql, Pid, undefined}, State);
handle_cast({log, Sql, Pid, Time}, State) ->
    Dict = 
        case dict:find(Sql, State#state.dict) of
            error -> dict:store(Sql, 1, State#state.dict);
            {ok, Count} -> dict:store(Sql, Count+1, State#state.dict)
        end,
    {{Y,M,D},{H,I,S}} = erlang:localtime(),
    io:format(State#state.log_fd, "#~p/~p/~p ~p:~p:~p ~p $ ~f -> ~s\n", [Y,M,D,H,I,S,Pid,Time,Sql]),
    {noreply, State#state{dict=Dict, total=State#state.total+1}};
    
handle_cast({write, File}, State) ->
    case file:open(File, [write]) of
        {ok, Fd} ->
            io:format("start writing...\n"),
            {{Y,M,D}, {H,I,S}} = State#state.start,
            {{Y1,M1,D1}, {H1,I1,S1}} = erlang:localtime(),
            io:format(Fd, "profile from ~p/~p/~p ~p:~p:~p to ~p/~p/~p ~p:~p:~p\n Count, Percent, Sql\n", [Y,M,D,H,I,S, Y1,M1,D1,H1,I1,S1]),
            List = lists:keysort(2, dict:to_list(State#state.dict)),
            lists:foldr(fun({Key, Val}, _) ->
                %io:format("% ~p\n~s\n", [Val, Key]),
                Percent = Val/State#state.total*100.0,
                io:format(Fd, "% ~p  ~.2f%\n~s\n", [Val, Percent, Key])
            end, 0, List),
            file:close(Fd),
            io:format("finished!\n");
        _ -> ignore
    end,
    {noreply, State};

handle_cast(empty, State) ->
    file:truncate(State#state.log_fd),
    io:format("truncating db.log ...\n"),
    {noreply, State};

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, State) ->
    file:close(State#state.log_fd),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


