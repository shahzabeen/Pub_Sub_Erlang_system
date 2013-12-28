%% Author: Rahnuma
%% Created: May 21, 2012
%% Description: TODO: Add description to listener_pub_sub
-module(listener_pub_sub).

%%
%% Include files
%%

%%
%% Exported Functions
%%
  -export([register_client/2,process_data/1]).

%%
%% API Functions
%%

%% Register client to the gen_server by sending its process pid
%% Cpid = Client Pid
%% Pid = Process Pid

register_client(CPid, Message)->	
	
       Pid = spawn(?MODULE, process_data, [CPid]),
       io:format("test listener"),
	 	  
	 
	   {ok,ErlangText,[]}=rfc4627:decode(Message),
	   {ok,Channel}=rfc4627:get_field(ErlangText, "channel"),
	   io:format("channel"),
	   io:write(Channel),
	 
	   %%converting binary channel into string

	   io:format("New Channel"),
	   ChannelNew = binary_to_list(Channel),
	   io:write(ChannelNew),
	 
	 
%% 	    %% resolving the node
%% 	    %% Routing the request to the first connected node
%% 	 
%%  	Nodes=nodes(),
%% 		send_to_nodes(Nodes, ChannelNew, Pid, Message).

	   
	   [Node|Rest_nodes]=nodes(),
	   io:write(Node),
 	   rpc:call(Node, genserver_pub_sub_v2, handle_client_msg, [Pid,Message,Node]).
	 

%% 	 	Nodec1='m1c1@rahnuma.usask.ca',
%% 	    Nodec2='m1c2@rahnuma.usask.ca',
%% 	    Nodec3='m1c3@rahnuma.usask.ca',
%% 	 
%% 	 
%% 	   if 
%% 		   
%%          ChannelNew == "c1"->
%% 				 rpc:call(Nodec1, genserver_pub_sub_v2, handle_client_msg, [Pid,Message,Nodec1]);
%% 			
%% 	     ChannelNew == "c2"->
%% 	 			 rpc:call(Nodec2, genserver_pub_sub_v2, handle_client_msg, [Pid,Message,Nodec2]);
%% 		 
%% 		 ChannelNew == "c3"->
%% 	 			 rpc:call(Nodec3, genserver_pub_sub_v2, handle_client_msg, [Pid,Message,Nodec3])
%% 	 
%% 	  end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%	 	 
%% 	 [Node|Rest_nodes]=nodes(),
%% 	 io:write(Node),
%% 	 rpc:call(Node, genserver_pub_sub_v2, handle_client_msg, [Pid,Message,Node]).

	 
	 
	 
	 %% Routing the request to the first connected node
	 
%% 		 Nodes=nodes(),
%% 		 send_to_nodes(Nodes, Pid, Message),
	 


			 %% Resolving channel name
		
			  
%% 	 
%% send_to_nodes([],_,_,_)->ok;
%% 
%% send_to_nodes([Node|Rest],ChannelNew,Pid, Message)->
%% 	
%% 
%% 	%%if
%% 		%%lists:member(Channel++"@rahnuma.usask.ca", List)->
%% 			
%% 	%% 	 
%%  	 	Nodec1='c1@rahnuma.usask.ca',
%%  	    Nodec2='c2@rahnuma.usask.ca',
%%  	    Nodec3='c3@rahnuma.usask.ca',		
%% 	
%% 	if
%%         Node == ChannelNew+"@rahnuma.usask.ca"->
%% 			%%gen_server:call(ServerRef, Request)
%%        			 rpc:call(Nodec1, genserver_pub_sub_c1, handle_client_msg, [Pid,Message,Nodec1]);
%% 		Node == "c2@rahnuma.usask.ca"->
%% 				rpc:call(N, genserver_pub_sub_c2, handle_client_msg, [Pid,Message,N]);
%% 		Node == "c3@rahnuma.usask.ca"->
%% 				 rpc:call(N, genserver_pub_sub_c3, handle_client_msg, [Pid,Message,N])
%% 	end,
%% 	
%% 	   send_to_nodes(Rest,Pid, Message).
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	



   %% Receive message from server and send to the client 
   process_data(CPid) ->
		
					   receive
						   {Data}-> 
						   io:write(Data),
						   yaws_api:websocket_send(CPid,{text,list_to_binary(Data)}),
					       process_data(CPid)
					   end.
 
%%
%% Local Functions
%%
