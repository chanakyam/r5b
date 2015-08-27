-module(play_video_handler).
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
	{[{_,Value}], Req2} = cowboy_req:bindings(Req),
	
	Url = "http://api.contentapi.ws/videos?channel=world_news&limit=1&skip=5&format=long",
	% io:format("movies url: ~p~n",[Url]), 
	{ok, "200", _, Response_mlb} = ibrowse:send_req(Url,[],get,[],[]),
	ResponseParams_mlb = jsx:decode(list_to_binary(Response_mlb)),	
	[Params] = proplists:get_value(<<"articles">>, ResponseParams_mlb),

	Url_all_news = "http://api.contentapi.ws/videos?channel=world_news&limit=12&format=short&skip=0",
	{ok, "200", _, ResponseAllNews} = ibrowse:send_req(Url_all_news,[],get,[],[]),
	ResponseParams = jsx:decode(list_to_binary(ResponseAllNews)),
	ResAllNews = proplists:get_value(<<"articles">>, ResponseParams),

	% Url_news = starstyle_util:play_video_item_url(binary_to_list(Value)),
	Url_news = string:concat("http://api.contentapi.ws/v?id=",binary_to_list(Value) ), 
	{ok, "200", _, ResponseNews} = ibrowse:send_req(Url_news,[],get,[],[]),
	ResNews = string:sub_string(ResponseNews, 1, string:len(ResponseNews) -1 ),
	ParamsNews = jsx:decode(list_to_binary(ResNews)),
	%io:format("params ~p ~n ",[ParamsNews]),	

	Text_Top_Us_Sports = "http://api.contentapi.ws/news?channel=us_sports&limit=6&skip=0&format=short",
	{ok, "200", _, Response_Text_Top_Us_Sports} = ibrowse:send_req(Text_Top_Us_Sports,[],get,[],[]),
	ResponseParams_Text_Top_Us_Sports = jsx:decode(list_to_binary(Response_Text_Top_Us_Sports)),	
	TextTopUsSportsParams = proplists:get_value(<<"articles">>, ResponseParams_Text_Top_Us_Sports),

	{ok, Body} = playvideo_dtl:render([{<<"videoParam">>,Params},{<<"newsParam">>,ParamsNews},{<<"topNewsWithImages">>,TextTopUsSportsParams},{<<"allnews">>,ResAllNews}]),
    {Body, Req2, State}.


