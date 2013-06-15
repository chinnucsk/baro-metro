-module(actions_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).


start(_Type, _Args) ->
	Events = sockjs_handler:init_state(<<"/a">>, fun events/3, state, [{response_limit, 4096}]),
	VRoutes = [
		{<<"/a/[...]">>, sockjs_cowboy_handler, Events},
		{<<"/[...]">>, cowboy_static, [
				{directory,  <<"./priv/www">>},
				{mimetypes, {fun mimetypes:path_to_mimes/2, default}} 
			]}],
	Routes = [{'_',  VRoutes}], 
	Dispatch = cowboy_router:compile(Routes),
	cowboy:start_http(webapp_http_listener, 100, 
					  [{port, 8080}],
					  [{env, [{dispatch, Dispatch}]}]),
	actions_sup:start_link().


stop(_State) ->
	ok.


%
% SockJS Events
%

events(Con, init, _) -> 
	{ok, undefine};
events(Con, {recv, <<"I">>}, State) -> 
	ok = broadcaster:add(Con),
	H = data_source:history(),
	HJ = jsonx:encode(H),
	Con:send(HJ),
	{ok, State};
events(Con, {recv, Msg}, State) -> 
	{ok, State};
events(Con, closed, State) -> 
	broadcaster:remove(Con),
	{ok, State}.
	