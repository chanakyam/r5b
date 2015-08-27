-module(all_news_pagination_handler).
-author("venkateshk@ybrantdigital.com").
-modified("sushmap@ybrantinc.com").

-export([init/3]).

-export([content_types_provided/2]).
-export([welcome/2]).
-export([terminate/3]).

-include("includes.hrl").
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
	{CategoryBinary, _} = cowboy_req:qs_val(<<"c">>, Req),

	PageNum = list_to_integer(binary_to_list(PageBinary)),
	Category  = binary_to_list(CategoryBinary),
	
	SkipItems = (PageNum-1) * ?NEWS_PER_PAGE,
	
 Url = case Category of 
		"text_us_sports" ->
			%Category = "US",
			string:concat("http://api.contentapi.ws/news?channel=us_sports&limit=20&format=short&skip=", integer_to_list(SkipItems));
		% "text_top_us_sports" ->
		% 	%Category = "US",
		% 	"http://api.contentapi.ws/news?channel=us_sports&limit=3&skip=0&format=short";
		"text_us_nba" ->
			%Category = "US",
			string:concat("http://api.contentapi.ws/news?channel=us_nba&limit=20&format=short&skip=", integer_to_list(SkipItems));
			
		"text_us_nfl" ->
			%Category = "Politics",
			string:concat("http://api.contentapi.ws/news?channel=us_nfl&limit=20&format=short&skip=", integer_to_list(SkipItems));
			
		"text_us_nhl" ->
			%Category = "Entertainment",
			string:concat("http://api.contentapi.ws/news?channel=us_nhl&limit=20&format=short&skip=", integer_to_list(SkipItems));
		
		
		_ ->
			%Category = "None",
			lager:info("#########################None")

	end,

	% Url_video = case Category of 
	% 	"text_us_sports" ->
	% 		%Category = "US",
	% 		"http://api.contentapi.ws/videos?channel=us_mlb&limit=1&skip=1&format=long";
	% 	% "text_top_us_sports" ->
	% 	% 	%Category = "US",
	% 	% 	"http://api.contentapi.ws/news?channel=us_sports&limit=3&skip=0&format=short";
	% 	"text_us_nba" ->
	% 		%Category = "US",
	% 		"http://api.contentapi.ws/videos?channel=us_mlb&limit=1&skip=6&format=long";
			
	% 	"text_us_nfl" ->
	% 		%Category = "Politics",
	% 		"http://api.contentapi.ws/videos?channel=us_mlb&limit=1&skip=7&format=long";
			
	% 	"text_us_nhl" ->
	% 		%Category = "Entertainment",
	% 		"http://api.contentapi.ws/videos?channel=us_mlb&limit=1&skip=8&format=long";
		
		
	% 	_ ->
	% 		%Category = "None",
	% 		lager:info("#########################None")

	% end,


	{ok, "200", _, ResponseAllNews} = ibrowse:send_req(Url,[],get,[],[]),
	% io:format("movies url: ~p~n",[Url]),
	ResponseParams = jsx:decode(list_to_binary(ResponseAllNews)),
	ResAllNews = proplists:get_value(<<"articles">>, ResponseParams),


	Url_video = "http://api.contentapi.ws/videos?channel=world_news&limit=1&skip=1&format=long",
	% io:format("movies url: ~p~n",[Url]),
	{ok, "200", _, Response_mlb} = ibrowse:send_req(Url_video,[],get,[],[]),
	ResponseParams_mlb = jsx:decode(list_to_binary(Response_mlb)),	
	[ParamsVideo] = proplists:get_value(<<"articles">>, ResponseParams_mlb),

	Text_Top_Us_Sports = "http://api.contentapi.ws/news?channel=us_sports&limit=6&skip=0&format=short",
	{ok, "200", _, Response_Text_Top_Us_Sports} = ibrowse:send_req(Text_Top_Us_Sports,[],get,[],[]),
	ResponseParams_Text_Top_Us_Sports = jsx:decode(list_to_binary(Response_Text_Top_Us_Sports)),	
	TextTopUsSportsParams = proplists:get_value(<<"articles">>, ResponseParams_Text_Top_Us_Sports),
	

	{ok, Body} = all_news_paginated_dtl:render([{<<"top_news">>,ResAllNews},{<<"category">>,Category}, {<<"videoParam">>,ParamsVideo},{<<"topNewsWithImages">>,TextTopUsSportsParams}]),
    {Body, Req, State}
.