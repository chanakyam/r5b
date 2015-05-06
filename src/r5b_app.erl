-module(r5b_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
	Dispatch = cowboy_router:compile([
		{'_',[
				
                {"/api/news/topnews", news_topnews_handler, []},
                {"/", home_page_handler, []},
                {"/moresportsnews", all_news_pagination_handler, []},
                {"/morevideos", more_videos_handler, []},
                {"/playvideo/:id", play_video_handler, []},
                {"/api/news/count", news_count_handler, []},     
                {"/api/news/topnews_with_images", top_news_and_graphics_handler, []},
                {"/slideshow/:id", slideshow_handler, []},                      
                {"/n/:id", news_page_handler, []},
                {"/termsandconditions", tnc_page_handler, []},  
                {"/css/[...]", cowboy_static, 
					[
                		{directory, {priv_dir, r5b, ["public/css"]}},
                		{mimetypes, {fun mimetypes:path_to_mimes/2, default}}
            		]
            	},
                
                {"/images/[...]", cowboy_static, 
                    [
                        {directory, {priv_dir, r5b, ["public/images"]}},
                        {mimetypes, {fun mimetypes:path_to_mimes/2, default}}
                    ]
                },
                {"/js/[...]", cowboy_static, 
                    [
                        {directory, {priv_dir, r5b, ["public/js"]}},
                        {mimetypes, {fun mimetypes:path_to_mimes/2, default}}
                    ]
                },
                {"/players/[...]", cowboy_static, 
                    [
                        {directory, {priv_dir, r5b, ["public/players"]}},
                        {mimetypes, {fun mimetypes:path_to_mimes/2, default}}
                    ]
                },
                {"/test", cowboy_static, 
                    [
                        {directory, {priv_dir, r5b, ["public"]}},
                        {file, "testslider.html"},
                        {mimetypes, {fun mimetypes:path_to_mimes/2, default}}
                    ]
                }
                
			 ]
		}

	]), 
    ok = application:start(compiler),
    ok = application:start(syntax_tools),
    ok = application:start(goldrush),
    ok = application:start(lager),
    ok = application:start(crypto),
    ok = application:start(jsx),
    ok = application:start(ranch),
    ok = application:start(cowlib),
    ok = application:start(cowboy),
    ok = application:start(ibrowse),

	{ok, _} = cowboy:start_http(http,100, [{port, 9910}],[{env, [{dispatch, Dispatch}]},
                                                          {onrequest, fun request_hook_responder:set_cors/1},
                                                          {onresponse, fun error_hook_responder:respond/4}
              ]),
    r5b_sup:start_link().

stop(_State) ->
    ok.
