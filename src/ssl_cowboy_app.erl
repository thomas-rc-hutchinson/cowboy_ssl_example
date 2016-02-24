-module(ssl_cowboy_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
        {ok,KeyValuePid} = key_value_gen:start_link(),
        key_value_gen:put("req_id",1,KeyValuePid),
        
        Dispatch = cowboy_router:compile([
		{'_', [
			{"/echo", echo_handler, [KeyValuePid]}
		]}
	]),
	PrivDir = code:priv_dir(ssl_cowboy),
	{ok, _} = cowboy:start_https(https, 100, [
		{port, 8443},
		{cacertfile, PrivDir ++ "/ssl/cowboy-ca.crt"},
		{certfile, PrivDir ++ "/ssl/server.crt"},
		{keyfile, PrivDir ++ "/ssl/server.key"}
	], [{env, [{dispatch, Dispatch}]}]),
	ssl_cowboy_sup:start_link().

stop(_State) ->
	ok.
