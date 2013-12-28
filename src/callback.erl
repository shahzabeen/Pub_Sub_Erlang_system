%% Author: Rahnuma
%% Created: May 21, 2012
%% Description: TODO: Add description to callback_pub_sub
-module(callback).

%%
%% Include files
%%

%% Export for websocket callbacks
-export([handle_message/1, listener_subscription/2,listener_publish/4,read_from_channel/2]).



%%
%% API Functions
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

listener_subscription(ClientName,ChannelName) ->		

	listener:connector_subscription(self(),ClientName,ChannelName),
	
    {reply, {text, <<"HTTP/1.1 200 OK">>}}.




listener_publish(ClientName,ChannelName,ID,Item) ->		

	listener:connector_publish(self(),ClientName,ChannelName,ID,Item),
	
    {reply, {text, <<"HTTP/1.1 200 OK">>}}.



read_from_channel(ClientName,ChannelName)->
	
	listener:connector_read(ClientName,ChannelName),
	
    {reply, {text, <<"HTTP/1.1 200 OK">>}}.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%connection message
handle_message({text, <<"connected">>}) ->
    io:format("saying hi in 3s.~n", []),
    {reply, {text, <<"Connected...">>}};

	

%% 	
%% Register client Pid	
 handle_message({text, Message}) ->	
%% 	
 	%%io:format("test callback"),
 	%%io:write(Message),
%% 	
 	%% Decoding the Message
 	{ok,ErlangText,[]}=rfc4627:decode(Message),
 	io:format(" Erlang String : "),
 	io:write(ErlangText),
  	{ok,Action}=rfc4627:get_field(ErlangText, "action"),			
 	Operation = binary_to_list(Action),
 
  	case Operation of 					  
 		         "register" ->
 	 					{ok,Channel}=rfc4627:get_field(ErlangText, "channel"), 
 	 					{ok,Client}=rfc4627:get_field(ErlangText, "client"),

 	 					
 	 					ChannelString = binary_to_list(Channel),
 						ChannelName = list_to_atom(ChannelString),
 						
 	 					ClientString = binary_to_list(Client),
 						ClientName = list_to_atom(ClientString),
 	 					
 	 				    listener:connector_subscription(self(),ClientName,ChannelName);		
 		
 		
  			     "publish" ->
 	 					{ok,Channel}=rfc4627:get_field(ErlangText, "channel"), 
 	 					{ok,Client}=rfc4627:get_field(ErlangText, "client"),
 						{ok,GUID}=rfc4627:get_field(ErlangText, "GUID"),
 					    {ok,Data}=rfc4627:get_field(ErlangText, "data"),
 	 					
 	 					ChannelString = binary_to_list(Channel),
 						ChannelName = list_to_atom(ChannelString),
						
 	 					ClientString = binary_to_list(Client),
 						ClientName = list_to_atom(ClientString), 
 						
 						ID = binary_to_list(GUID),						
 						Item = binary_to_list(Data),
 
 											
 	 				    listener:connector_publish(self(),ClientName,ChannelName,ID,Item);
 
 		
  		 		"read" ->
 					
 					    {ok,Channel}=rfc4627:get_field(ErlangText, "channel"),  
	 					{ok,Client}=rfc4627:get_field(ErlangText, "client"),
 						{ok,GUID}=rfc4627:get_field(ErlangText, "GUID"),
 					
 						ChannelString = binary_to_list(Channel),
 						ChannelName = list_to_atom(ChannelString),
 						
 	 					ClientString = binary_to_list(Client),
 						ClientName = list_to_atom(ClientString),
 						
 						ID = binary_to_list(GUID),	
 																		
  					 	listener:connector_read(self(),ClientName,ChannelName);		
 						%%listener:connector_read_test(self(),ID,ClientName,ChannelName);
 
   			     _ ->
   
  					 io:format(" Upsss!~n")
     end,
 
   {reply, noreply}.

   %%{reply, {text, <<"HTTP/1.1 200 OK">>}}.








listener(ClientName,ChannelName,ID,Item)->
	
     listener:connector_send(self(),ClientName,ChannelName,ID,Item),
	 
	 {reply, {text, <<"HTTP/1.1 200 OK">>}}.


