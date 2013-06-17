-module(data_source).
-behaviour(gen_server).

-include("settings.hrl").

-export([history/0]).
-export([start/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

history() -> 
	sockjs_json:encode(gen_server:call(?MODULE, history)).

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
	broadcaster:send(sockjs_json:encode([S])),
	next(),
	{noreply, NewState};

handle_info(_Msg, State) -> {noreply, State}.

terminate(_Reason, _State) -> ok.
code_change(_OldVsn, State, _Extra) -> {ok, State}.


%
% Data
%

init_device() -> 
	file:write_file(?I2C_CONTROL, ?BMP_INIT),
	ok.

take_sample() ->
	{{_Y, _Mo, _D}, {_H, Mi, S}} = erlang:localtime(),
	Tm = list_to_binary(io_lib:format('~2..0b:~2..0b', [Mi, S])),
	% Tv = random:uniform(40), 
	Tv = read_value(?BMP_TEMP) / 10,
	% Pv = random:uniform(1100), 
	Pv = read_value(?BMP_PRES) / 100,
	[{<<"tm">>, Tm}, {<<"t">>, Tv}, {<<"p">>, Pv}].

next() ->
	erlang:send_after(?TIMEOUT, self(), get_sample).

read_value(Filename) ->
	{ok, Val} = file:read_file(Filename),
	SVal = string:strip(binary_to_list(Val), right, $\n),
	list_to_integer(SVal).
