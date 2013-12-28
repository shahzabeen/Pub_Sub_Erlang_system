%% Author: Rahnuma
%% Created: 2012-11-26
%% Description: TODO: Add description to listener
-module(listener).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([connector_subscription/3,connector_publish/5,process_data/1,connector_read/3,connector_read_test/4]).



connector_subscription(CallBackPid,ClientName,ChannelName)->
	
	   LPid = spawn(?MODULE, process_data, [CallBackPid]),

	   io:format("...Spawn Listener..."),
	   io:write(LPid), 
	   io:format("\n\n"),
	   SClientname = atom_to_list(ClientName),
	   SChannel = atom_to_list(ChannelName),
	   SGRname=string:concat(SClientname,SChannel),
	   GRname=list_to_atom(SGRname),
	   global:register_name(GRname, LPid),
	   PrintPid=global:whereis_name(GRname),
	   io:format("...Pid of GRname..."),
	   io:write(GRname),
	   io:format("\n\n"),
	   io:write(PrintPid), 
	   io:format("\n\n"),
   
       ClientPid = global:whereis_name(ClientName),
	   io:format("ClientPid...."),
	   io:write(ClientPid),
	   
	   
	   	   
	   
	   if
		ClientPid == 'undefined' ->
			 ConnectorPid = spawn(connector, start_link, [ClientName,ChannelName]),	 
	   		 io:write(ConnectorPid), 
	         io:format("\n\n"),
			 looping(CallBackPid,GRname,ClientName,ChannelName);
		 
		
		ClientPid =/= 'undefined' ->			
			io:format("..Pid Found.."),
	        io:write(ClientPid),
			get_sub_data(CallBackPid,GRname,ClientName,ChannelName)

      end.

	   
	   
	   
	   
	   
%% 	   io:format("...Spawn Connector..."),	   
%% 	   ConnectorPid = spawn(connector, start_link, [ClientName,ChannelName]),	 
%% 	   io:write(ConnectorPid), 
%% 	   io:format("\n\n"),
%% 	   looping(GRname,ClientName,ChannelName).




connector_publish(CallBackPid,ClientName,ChannelName,ID,Item)-> 
	  
	%%  io:format("...connector_publish..."),
      Pid = global:whereis_name(ClientName),
	%%  io:write(Pid),
	%%  io:format("\n\n"),
	 
	 
	  Return = connector:eventbroker_publish(ClientName,ChannelName,ID,Item),
	  yaws_api:websocket_send(CallBackPid,{text,list_to_binary(Return)}).
	  %%send(CallBackPid,Return).


connector_read(CallBackPid,ClientName,ChannelName)-> 
	  
	  %%io:format("..read..."),
	  %%io:format("\n\n"),	  
	  Return = connector:read_from_channel(ClientName,ChannelName),
	  %%io:format("..listener: Results from ETS in JSON..."),	
	  %%io:write(Return),
	  %%io:format("\n\n"),
	  yaws_api:websocket_send(CallBackPid,{text,list_to_binary(Return)}).

connector_read_test(CallBackPid,ID,ClientName,ChannelName)-> 
	  
	  io:format(".read."),
	  io:format("\n\n"),	 	 
	  %%Return = connector:read_from_channel(ClientName,ChannelName),

	  %% following read handle_call is for experiment purposes - reading event messages from Channel 
	  Return = connector:read_from_channel_test(ID, ClientName,ChannelName),
	  io:format("..listener: Results from ETS in JSON..."),	
	  io:write(Return),
	  io:format("\n\n"),
	  yaws_api:websocket_send(CallBackPid,{text,list_to_binary(Return)}).



looping(CallBackPid,GRname,ClientName,ChannelName)->
		
	 Pid = global:whereis_name(ClientName),
	 io:write(Pid),

	if
		Pid == 'undefined' ->
			looping(CallBackPid,GRname,ClientName,ChannelName);
		
		
		Pid =/= 'undefined' ->			
			io:format("..Pid Found.."),
	        io:write(Pid),
			get_sub_data(CallBackPid,GRname,ClientName,ChannelName)

    end.

%% passes subscription request to connector  
get_sub_data(CallBackPid,GRname,ClientName,ChannelName)->
	
	 Return = connector:eventbroker_subscription(GRname,ClientName,ChannelName),
	 io:write(Return),
	 %%yaws_api:websocket_send(CallBackPid,{text, Return}). %% used for WS_client
	 yaws_api:websocket_send(CallBackPid,{text,list_to_binary(Return)}).

	 
	 %%io:write(Return).

 
send(CallBackPid,Return)->
	 io:format("...send_data..."),
 	 io:write(Return).


	   
%%
%% API Functions
%%



%%
%% Local Functions
%%


   process_data(CallBackPid) ->
		               io:format("..process_data.."),
					   receive
						   {Data}-> 
						   io:format("...Data..."),
						   io:write(Data),
						   %yaws_api:websocket_send(CPid,{text,list_to_binary(Data)}),
					       process_data(CallBackPid)
					   end.
