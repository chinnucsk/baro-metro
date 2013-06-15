-module(broadcaster).
-behaviour(gen_server).

-export([add/1, remove/1, send/1]).
-export([start/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).


add(Con) -> 
	gen_server:call(?MODULE, {add, Con}).
remove(Con) -> 
	gen_server:call(?MODULE, {remove, Con}).
send(Msg) -> 
	gen_server:call(?MODULE, {msg, Msg}).

%
% genserver
%

start() -> 
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
	{ok, []}.

handle_call({add, Con}, _From, State) ->
	{reply, ok, State ++ [Con]};

handle_call({remove, Con}, _From, State) -> 
	{reply, ok, State -- [Con]};

handle_call({msg, Msg}, _From, State) -> 
	JsonMsg = jsonx:encode(Msg),
	lists:map(fun(C) -> C:send(JsonMsg) end, State),
	{reply, ok, State};

handle_call(_Msg, _From, State) -> {reply, ok, State}.

handle_cast(_Msg, State) -> {noreply, State}.
handle_info(_Info, State) ->  {noreply, State}.

terminate(_Reason, State) -> 
	lists:map(fun(C) -> C:close() end, State),
	ok.
code_change(_OldVsn, State, _Extra) -> {ok, State}.



