%% Author: Rahnuma
%% Created: May 21, 2012
%% Description: TODO: Add description to callback_pub_sub
-module(callback_pub_sub).

%%
%% Include files
%%

%% Export for websocket callbacks
-export([handle_message/1]).



%%
%% API Functions
%%


%%connection message
handle_message({text, <<"connected">>}) ->
    io:format("saying hi in 3s.~n", []),
    {reply, {text, <<"Connected...">>}};



	
%% 	
%% Register client Pid	
handle_message({text, Message}) ->		
	io:format("test callback"),
	io:write(Message),
	listener_pub_sub:register_client(self(),Message),
    {reply, {text, <<"HTTP/1.1 OK">>}}.



%% %% Register client Pid
%% handle_message({text, Message}) ->	
%% 	
%% 	MessageNew=Message,
%% 	{ok,Text,[]}=rfc4627:decode(MessageNew),
%% 	io:format("basic echo handler got ~p~n", [Text]),
%% 	{reply, {text, <<"message sent...">>}}.




%echo text message
%% handle_message({text, Message}) ->
%%     io:format("basic echo handler got ~p~n", [Message]),
%%     {reply, {text, <<Message/binary>>}};

%echo binary message
%% handle_message({binary, Message}) ->
%%     {reply, {binary, Message}}.	
	




%%
%% Local Functions
%%