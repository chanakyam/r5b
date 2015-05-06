-module(home_page_handler).
-author("venkateshk@@ybrantdigital.com").
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

	Url = "http://api.contentapi.ws/videos?channel=us_mlb&limit=1&skip=0&format=long",
	% io:format("movies url: ~p~n",[Url]),
	{ok, "200", _, Response_mlb} = ibrowse:send_req(Url,[],get,[],[]),
	ResponseParams_mlb = jsx:decode(list_to_binary(Response_mlb)),	
	[Params] = proplists:get_value(<<"articles">>, ResponseParams_mlb),

	Text_Us_Sports = "http://api.contentapi.ws/news?channel=us_sports&limit=3&skip=6&format=short",
	{ok, "200", _, Response_Text_Us_Sports} = ibrowse:send_req(Text_Us_Sports,[],get,[],[]),
	ResponseParams_Text_Us_Sports = jsx:decode(list_to_binary(Response_Text_Us_Sports)),	
	TextUsSportsParams = proplists:get_value(<<"articles">>, ResponseParams_Text_Us_Sports),

	Text_Us_Nba = "http://api.contentapi.ws/news?channel=us_nba&limit=3&skip=0&format=short",
	{ok, "200", _, Response_Text_Us_Nba} = ibrowse:send_req(Text_Us_Nba,[],get,[],[]),
	ResponseParams_Text_Us_Nba = jsx:decode(list_to_binary(Response_Text_Us_Nba)),	
	TextUsNbaParams = proplists:get_value(<<"articles">>, ResponseParams_Text_Us_Nba),

	Text_Us_Nfl = "http://api.contentapi.ws/news?channel=us_nfl&limit=3&skip=0&format=short",
	{ok, "200", _, Response_Text_Us_Nfl} = ibrowse:send_req(Text_Us_Nfl,[],get,[],[]),
	ResponseParams_Text_Us_Nfl = jsx:decode(list_to_binary(Response_Text_Us_Nfl)),	
	TextUsNflParams = proplists:get_value(<<"articles">>, ResponseParams_Text_Us_Nfl),

	Text_Us_Nhl = "http://api.contentapi.ws/news?channel=us_nhl&limit=3&skip=0&format=short",
	{ok, "200", _, Response_Text_Us_Nhl} = ibrowse:send_req(Text_Us_Nhl,[],get,[],[]),
	ResponseParams_Text_Us_Nhl = jsx:decode(list_to_binary(Response_Text_Us_Nhl)),	
	TextUsNhlParams = proplists:get_value(<<"articles">>, ResponseParams_Text_Us_Nhl),

	Text_Top_Us_Sports = "http://api.contentapi.ws/news?channel=us_sports&limit=3&skip=0&format=short",
	{ok, "200", _, Response_Text_Top_Us_Sports} = ibrowse:send_req(Text_Top_Us_Sports,[],get,[],[]),
	ResponseParams_Text_Top_Us_Sports = jsx:decode(list_to_binary(Response_Text_Top_Us_Sports)),	
	TextTopUsSportsParams = proplists:get_value(<<"articles">>, ResponseParams_Text_Top_Us_Sports),
	
	{ok, Body} = index_dtl:render([{<<"videoParam">>,Params},{<<"topSportsNews">>,TextUsSportsParams},{<<"topNbaNews">>,TextUsNbaParams},{<<"topNflNews">>,TextUsNflParams},{<<"topNhlNews">>,TextUsNhlParams},{<<"topNewsWithImages">>,TextTopUsSportsParams}]),
    {Body, Req, State}.