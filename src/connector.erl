%%% -------------------------------------------------------------------
%%% Author  : Rahnuma
%%% Description :
%%%
%%% Created : 2012-11-26
%%% -------------------------------------------------------------------
-module(connector).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
-export([start_link/2,eventbroker_send/4,eventbroker_subscription/3,eventbroker_publish/4,read_from_channel/2,read_from_channel_test/3]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {updatekey,updatedata}). 


%% ====================================================================
%% External functions
%% ====================================================================

start_link(ClientName,ChannelName) ->	
	io:format("Connector: client name ........"),
	io:write(ClientName),
	gen_server:start_link({global,ClientName}, ?MODULE, {ChannelName}, []). 
	%%gen_server:start_link({global,ClientName}, ?MODULE, [], []).       
  



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


 eventbroker_subscription(GRname,ClientName,ChannelName)->
	
	io:format("...eventbroker subscription..."),
	Node='eb',	
 	
 	Pid = global:whereis_name(ClientName),
 	io:write(Pid),
	
 	gen_server:call(Pid, {ebsubscribe,Node,GRname,ClientName,ChannelName}).



 eventbroker_publish(ClientName,ChannelName,ID,Item)->
	
	%%io:format("...eventbroker publish..."),
	Node='eb',	
 	
 	Pid = global:whereis_name(ClientName),
 	io:write(Pid),
	
 	gen_server:call(Pid, {ebpublish,Node,ClientName,ChannelName,ID,Item}).



read_from_channel(ClientName,ChannelName)->
	
	Pid = global:whereis_name(ClientName),
 	%%io:write(Pid),
		
    gen_server:call(Pid, {read,ChannelName}).



%% following read handle_call is for experiment purposes - reading event messages from Channel
read_from_channel_test(Key, ClientName,ChannelName)->
	
	Node='eb',
	
	Pid = global:whereis_name(ClientName),
 	io:write(Pid),
		
    gen_server:call(Pid, {read_tests, Node, Key, ChannelName}). 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% 
 eventbroker_send(ClientName,ChannelName,ID,Item)->
	io:format("eventbroker_send..."),
	Node='eb',	
 	
 	Pid = global:whereis_name(ClientName),
 	io:write(Pid),
	
 	gen_server:call(Pid, {eventbroker,Node,ClientName,ChannelName,ID,Item}).



%% ====================================================================
%% Server functions
%% ====================================================================

%% -------------------------------------------------------------------- 
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
%% init({ChannelName}) ->
%% 	
%% 	%%dets:open_file(ChannelName, [{file, ChannelName},{keypos, #state.updatekey}]),
%% 	
%% 	ets:new(ChannelName,[named_table,{keypos, #state.updatekey}]),	
%% 	
%%     {ok, #state{}}.



init({ChannelName}) ->
	
	%%ETStab =string:concat(atom_to_list(ChannelName),"notification"),
	%%ETStablename = list_to_atom(ETStab),    %% ETStablename = c1notification
	
	ETSLists = ets:all(),
	
	Boolean = lists:member(ChannelName, ETSLists),
	
	if 
		Boolean == true ->
			io:format("...ETS table exists...");
		Boolean == false ->
			ets:new(ChannelName,[named_table, public,{keypos, #state.updatekey}]),	
			io:format("Format")
	end,
	
    {ok, #state{}}.

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               | 
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handle_call({ebsubscribe,Node,GRname,ClientName,ChannelName}, From, State) ->
	
	        io:format("Connector...."),
			
			%%dets:open_file(ChannelName, [{file, ChannelName},{keypos, #state.updatekey}]),
			
			%%ets:new(ChannelName,[named_table,{keypos, #state.updatekey}]),	
						 
 			Return = event_broker:subscribe_to_channel(Node,GRname,ClientName,ChannelName),		
					
			{reply, Return , State};   




handle_call({ebpublish,Node,ClientName,ChannelName,ID,Item}, From, State) ->
	
	   %%   io:format("Connector...."),
						
 			Rst = event_broker:publish_to_channel(self(),Node,ClientName,ChannelName,ID,Item),
			
			%% For update propagation - publish follows with a read request
%% 			Lines = ets:tab2list(ChannelName),
%% 			ETSJsonString = convert_to_json(Lines),					
%% 			io:write(ETSJsonString),			
%% 			{reply, ETSJsonString, State};
			%%{reply, "NEW MESSAGE" , State};

			{reply, Rst , State};  




%% Handle get/read call
handle_call({read,ChannelName}, From, State) ->
	
		 %%io:format("Reading.... "),
		%%io:write(ChannelName),
		 %%io:format("\n\n"),
		
		 
		 %% get results

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		 
		 
		 %%io:format(" Timestamp : "),
						Timestamp=erlang:now(),
										
						{Mega,Sec,Micro}=Timestamp,
						%%io:format("Mega"),
						%%io:write(Mega),
						
						%%io:format("Sec"),
						%%io:write(Sec),
						
						%%io:format("Micro"),
						%%io:write(Micro),
				
						
						Microsec = (Mega * 1000000 + Sec) * 1000000 + Micro,
						MicrosecToSec = Microsec / 1000000,
						SecToMilisec = MicrosecToSec * 1000,

		
				 				
						%%TimeInSec = MegaInSec + Sec + MicroInSec,	
						%%TimeInMiliSec = TimeInSec * 1000,
								
						io:fwrite("~n"),
						io:write(SecToMilisec),
		 
		 				%%file:open("madmuc",[write]),
		 				%%file:write_file("madmuc", SecToMilisec),
		 
		 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		 
		 
		 

		 
		 %%ETStab =string:concat(atom_to_list(ChannelName),"notification"),
		 %%ETStablename = list_to_atom(ETStab),

	     Lines = ets:tab2list(ChannelName), 
		 
		 %%io:format("connector: results from ETS.... "),
		 %%io:format("\n\n"),
		 
		 ETSJsonString = convert_to_json(Lines), 
		
		
		%% return resource state
		 {reply, ETSJsonString, State};


%% following read handle_call is for experiment purposes - reading event messages from Channel 
handle_call({read_tests,Node, Key, ChannelName}, From, State) ->
	
		 io:format("Reading tests.... "),
		 io:write(ChannelName),
		 io:format("\n\n"),
		 
		 %%ETStab =string:concat(atom_to_list(ChannelName),"notification"),
		 %%ETStablename = list_to_atom(ETStab),
		 
		 
		 EtsResults = ets:lookup(ChannelName, Key),
		 
		 if 
			 EtsResults == [] ->
				io:format("No value for this key exists"),
		 		Return = event_broker:read_test(Node,Key,ChannelName),
			  	{reply, Return, State};
			 
			 EtsResults =/= [] ->
				 io:format("Value found"),
		  		 {reply, EtsResults, State}
		 end;
		

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 



%% Handle post/publish call

handle_call({eventbroker,Node,ClientName,ChannelName,ID,Item}, From, State) ->
	
	        io:format("Connector...."),
						
 			Return = event_broker:publish_to_channel(self(),Node,ClientName,ChannelName,ID,Item),
			receive
						   {Data}-> 
						   io:format("...Data..."),
						   io:write(Data),
			
						   {reply, Data, State}
						   %yaws_api:websocket_send(CPid,{text,list_to_binary(Data)}),
					       %process_data(CPid)
		    end;
			


handle_call(Request, From, State) ->
    Reply = ok,
    {reply, Reply, State}.



%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
 			

handle_cast({anything,ChannelName,Result}, State) ->
	
    io:format("Anything from Connector ... "),
	
	io:format("\n\n"),
	
    io:write(Result),
	
%%%%%%%%%%%%%%%%%%%	
	
	
		
	[{_data, Key, Value}] = Result,
	
	
	
	%%ETStab =string:concat(atom_to_list(ChannelName),"notification"),
	%%ETStablename = list_to_atom(ETStab),
	
	
	EtsResults = ets:lookup(ChannelName, Key),
	%%io:format("DetsResult .."),
	%%io:write(EtsResults),
		
	if 
		
		%% no results were found
		EtsResults ==  [] -> 
			
			    io:format("Results not found......... "),
			
				DATA = #state{updatekey = Key, updatedata = Value},	
				
	            ets:insert(ChannelName, DATA),
						
		    {noreply, State};
		

		%% results found
		EtsResults =/= [] ->
			
			io:format("Results found......... "),
			
			%% get first match
			[{_Channel, _ChannelKey, Texts}|_] = EtsResults,
			
			if 
				
				_ChannelKey == Key -> 
					
						io:format("  duplicate key... "),
						{noreply, State};
			
				_ChannelKey =/= Key ->
			
						DATA = #state{updatekey = Key, updatedata = Value},							
			            ets:insert(ChannelName, DATA),

						
%%%%%%%%%%%%%%%%%%%						
						
				
			
			{noreply, State}

        end
	end;
	
		

handle_cast(Msg, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info(Info, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(Reason, State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(OldVsn, State, Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------

convert_to_json(Lines)->									 
	Data = [{obj,
		      [{updatekey, Line#state.updatekey},
			   {updatedata, Line#state.updatedata}]}
			|| Line<-Lines],
	JsonData = {obj,[{data,Data}]},
	rfc4627:encode(JsonData).


chat()->
	receive
		{Data}->
			io:write(Data),						  
			chat()		
	end.
	
