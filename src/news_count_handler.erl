-module(news_count_handler).
-author("venkateshk@ybrantdigital.com").
-modified("sushmap@ybrantinc.com").

-export([init/3]).

-export([content_types_provided/2]).
-export([welcome/2]).
-export([terminate/3]).

%% Init
init(_Transport, _Req, []) ->
	{upgrade, protocol, cowboy_rest}.

%% Callbacks
content_types_provided(Req, State) ->
	{[		
		{<<"text/html">>, welcome}	
	], Req, State}.

terminate(_Reason, _Req, _State) ->
	ok.

%% API
welcome(Req, State) ->
	{CategoryBinary, _} = cowboy_req:qs_val(<<"c">>, Req),
	Category  = binary_to_list(CategoryBinary),

	Url = r5b_util:news_top_text_graphics_news_with_limit_skip(Category, "10","0"), 
	{ok, "200", _, Response} = ibrowse:send_req(Url,[],get,[],[]),
	Res = string:sub_string(Response, 1, string:len(Response) -1 ),

	Body = list_to_binary(Res),
	{Body, Req, State}.

