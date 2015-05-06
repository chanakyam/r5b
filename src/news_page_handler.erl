-module(news_page_handler).
-author("chanakyam@koderoom.com").
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
	{[{Name,Value}], Req2} = cowboy_req:bindings(Req),

 	Url = string:concat("http://api.contentapi.ws/t?id=",binary_to_list(Value) ),
	{ok, "200", _, Response} = ibrowse:send_req(Url,[],get,[],[]),
	Res = string:sub_string(Response, 1, string:len(Response) -1 ),
	Params = jsx:decode(list_to_binary(Res)),

	Url_video = "http://api.contentapi.ws/videos?channel=us_mlb&limit=1&skip=3&format=long",
	% io:format("movies url: ~p~n",[Url]),
	{ok, "200", _, Response_mlb} = ibrowse:send_req(Url_video,[],get,[],[]),
	ResponseParams_mlb = jsx:decode(list_to_binary(Response_mlb)),	
	[ParamsVideo] = proplists:get_value(<<"articles">>, ResponseParams_mlb),

	Text_Us_Nhl = "http://api.contentapi.ws/news?channel=us_nhl&limit=5&skip=0&format=short",
	{ok, "200", _, Response_Text_Us_Nhl} = ibrowse:send_req(Text_Us_Nhl,[],get,[],[]),
	ResponseParams_Text_Us_Nhl = jsx:decode(list_to_binary(Response_Text_Us_Nhl)),	
	TextUsNhlParams = proplists:get_value(<<"articles">>, ResponseParams_Text_Us_Nhl),

	Text_Top_Us_Sports = "http://api.contentapi.ws/news?channel=us_sports&limit=6&skip=0&format=short",
	{ok, "200", _, Response_Text_Top_Us_Sports} = ibrowse:send_req(Text_Top_Us_Sports,[],get,[],[]),
	ResponseParams_Text_Top_Us_Sports = jsx:decode(list_to_binary(Response_Text_Top_Us_Sports)),	
	TextTopUsSportsParams = proplists:get_value(<<"articles">>, ResponseParams_Text_Top_Us_Sports),
	

	{ok, Body} = news_page_dtl:render([{<<"newsParam">>,Params}, {<<"videoParam">>,ParamsVideo},{<<"topNhlNews">>,TextUsNhlParams},{<<"topNewsWithImages">>,TextTopUsSportsParams}]),
    {Body, Req2, State}.


