-module(more_videos_handler).
-author("chanakyam@koderoom.com").
-modified("sushmap@ybrantinc.com").

-include("includes.hrl").
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

	{PageBinary, _} = cowboy_req:qs_val(<<"p">>, Req),
	PageNum = list_to_integer(binary_to_list(PageBinary)),
	SkipItems = (PageNum-1) * ?NEWS_PER_PAGE,	

	Url = "http://api.contentapi.ws/videos?channel=us_mlb&limit=1&skip=2&format=long",
	% io:format("movies url: ~p~n",[Url]),
	{ok, "200", _, Response_mlb} = ibrowse:send_req(Url,[],get,[],[]),
	ResponseParams_mlb = jsx:decode(list_to_binary(Response_mlb)),	
	[Params] = proplists:get_value(<<"articles">>, ResponseParams_mlb),

	Url_all_news = string:concat("http://api.contentapi.ws/videos?channel=us_mlb&limit=9&format=short&skip=", integer_to_list(SkipItems)),
	% io:format("all news : ~p~n",[Url_all_news]),
	{ok, "200", _, ResponseAllNews} = ibrowse:send_req(Url_all_news,[],get,[],[]),
	ResponseParams = jsx:decode(list_to_binary(ResponseAllNews)),
	ResAllNews = proplists:get_value(<<"articles">>, ResponseParams),

	Text_Top_Us_Sports = "http://api.contentapi.ws/news?channel=us_sports&limit=6&skip=0&format=short",
	{ok, "200", _, Response_Text_Top_Us_Sports} = ibrowse:send_req(Text_Top_Us_Sports,[],get,[],[]),
	ResponseParams_Text_Top_Us_Sports = jsx:decode(list_to_binary(Response_Text_Top_Us_Sports)),	
	TextTopUsSportsParams = proplists:get_value(<<"articles">>, ResponseParams_Text_Top_Us_Sports),

	{ok, Body} = more_videos_dtl:render([{<<"videoParam">>,Params},{<<"allnews">>,ResAllNews},{<<"topNewsWithImages">>,TextTopUsSportsParams}]),
    {Body, Req, State}.




