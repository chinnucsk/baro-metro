-module(data_source).
-behaviour(gen_server).

-include("settings.hrl").

-export([history/0]).
-export([start/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(sample, { tm = undefine, temp = 0, pres = 0 }).


history() -> 
	gen_server:call(?MODULE, history).

%
% genserver
%

start() -> 
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
	ok = init_device(),
	next(),
	{ok, []}.

handle_call(history, _From, State) -> 
	{reply, State, State};

handle_call(_Msg, _From, State) -> {reply, ok, State}.

handle_cast(_Msg, State) -> {noreply, State}.

handle_info(get_sample, State) -> 
	S = take_sample(),
	NewState = lists:sublist(State ++ [S], ?QUERY_LEN),
	broadcaster:send([S]),
	next(),
	{noreply, NewState};

handle_info(_Msg, State) -> {noreply, State}.

terminate(_Reason, _State) -> ok.
code_change(_OldVsn, State, _Extra) -> {ok, State}.


%
% Data
%

init_device() -> 
	% file:write_file(?I2C_CONROL, ?BMP_INIT),
	ok.

take_sample() ->
	Tm = erlang:localtime(),
	T = random:uniform(60), % {ok, T} = file:read_file(?BMP_TEMP),
	P = random:uniform(60000), % {ok, P} = file:read_file(?BMP_PRES),
	#sample{ tm = Tm, temp = T, pres = P}.

next() ->
	erlang:send_after(?TIMEOUT, self(), get_sample).
