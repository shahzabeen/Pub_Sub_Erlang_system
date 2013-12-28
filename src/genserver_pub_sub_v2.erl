%%% -------------------------------------------------------------------
%%% Author  : Rahnuma
%%% Description :
%%%
%%% Created : May 31, 2012
%%% -------------------------------------------------------------------
-module(genserver_pub_sub_v2).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
-export([start_link/1,handle_client_msg/3,publish_event/4,register_channel/3, read_channel/2,replicate_publish/4,test/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {data=[], data_pids=[]}).

-record(channel, {key, eventdata}).


%% ====================================================================
%% External functions
%% ====================================================================


%% start the server
start_link(Channel) ->	
	gen_server:start_link({local,Channel}, ?MODULE, {Channel}, []). 


%%Handle message coming from 'listener_pub_sub.erl'
handle_client_msg(Pid, JSONMessage,Node)->

	 	io:format("server testing"),
	
		%% Decodes JSON string into Erlang tuple 

		{ok,ErlangText,[]}=rfc4627:decode(JSONMessage),
		io:format(" Erlang String : "),
		io:write(ErlangText),
		{ok,Action}=rfc4627:get_field(ErlangText, "action"),
		{ok,Channel}=rfc4627:get_field(ErlangText, "channel"),

				
		ActionNew = binary_to_list(Action),
		ChannelNew = binary_to_list(Channel),

		

%% 		io:write(ActionNew),
%% 		io:write(ChannelNew),

		
		case ActionNew of 					  
		         "register" ->
				    register_channel(Pid, list_to_atom(ChannelNew),Node);	
			
 			     "publish" ->
					 {ok,ID}=rfc4627:get_field(ErlangText, "GUID"),
					 Key = binary_to_list(ID),
					 io:format(" Key is: "),
					 io:write(Key),
					 
                     {ok,Text}=rfc4627:get_field(ErlangText, "data"),
					 TextNew = binary_to_list(Text),
					 io:write(TextNew),
 				     publish_event(TextNew, list_to_atom(ChannelNew),Node,Key);
			
			     _ ->
                	io:format(" Upsss!~n")
		end.
		


%% publish data to channel
publish_event(Text, Channel,Node,Key) ->
	gen_server:call({Channel,Node}, {publish, Text,Channel,Key}).


%% register client Pid
register_channel(Pid, Channel,Node)->
	gen_server:call({Channel,Node}, {register, Pid}).

%% Read data from ETS table
read_channel(Channel,Key) ->
	gen_server:call(Channel, {read_channel, Channel,Key}).

%% publish to replicate nodes
replicate_publish(Text, Channel,Node,Key)->
	gen_server:call({Channel,Node}, {publish_replica,Text,Channel,Key}).




%% Test Routine
test()->
	    start_link(c1),
 		register_channel(0.76,c1,'b@rahnuma.usask.ca'),
 		publish_event("madmuc",c1,'b@rahnuma.usask.ca',"05:57:321"),
		read_channel(c1,"05:57:321").





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

%% {keypos,Pos} Specfies which element in the stored tuples should be used as key.

init({Channel}) ->
	
	%%create ets and dets table at the server initialization
	dets:open_file(Channel, [{file, Channel},{keypos, #channel.key}]),
 	ets:new(Channel,[named_table,{keypos, #channel.key}]),	
	
	DATA = #channel{key="", eventdata = ""},	
	dets:insert(Channel, DATA),	
	
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

%% When we want to store Erlang records in which the first position of the record is the name of the record type.


%% Register client Pids into a list   	
handle_call({register, PidReg}, From, State) ->
    io:format("Registering client Pid ... "),	
	io:write(PidReg),
	io:format("\n\n"),
	
	
	%% Storing client pids
    #state{data_pids = Data1} = State, 
	NewStatePid = #state{data_pids = [PidReg|Data1]},
	io:write(NewStatePid),
	{reply, ok, NewStatePid};


%% Handle read call
handle_call({read_channel, Channel,Key}, From, State) ->
	
	 io:format("Reading Message from channel..... "),
	 io:write(Channel),
	 io:format("\n\n"),
	
	%% get results
    Results = ets:lookup(Channel,Key), 
	
	if 
		
		%% no results were found
		Results ==  [] -> 
			{reply, "error", State};
		
		%% results found
		Results =/= [] ->
			
			%% get first match
			[{_Channel, _ChannelName, Texts}|_] = Results,
			
			%% return resource state
			{reply, Texts, State}
	
	end;


%% Handle publish call
handle_call({publish,Item,Channel,Key}, From, State) ->
	
	%%io:format("Publishing to Channel......"),
	%%io:write(Channel),
	%%io:format("\n\n"),
	

	
	%% get results
	DetsResults = dets:lookup(Channel, Key),
		
	if 
		
		%% no results were found
		DetsResults ==  [] -> 
			
				DATA = #channel{key=Key, eventdata = Item},	
				
				%% 	io:format(" First Key : "),
				%% 	io:write(Key),
				
	            dets:insert(Channel, DATA),
				dets:to_ets(Channel, Channel),
				
				%%[{_Channel, _ChannelName, Texts}|_] = Results,
				
				ETSResults = ets:lookup(Channel, Key),	
				
				io:write(ETSResults),
				
				
				[{_Channel, _ChannelKey, ETSTexts}|_] = ETSResults,								   		
				#state{data_pids = PIDS} = State, 
				
				%%Converting into JSON string
%% 	                [{channel,TimeStamp,Message}] = ETSResults,
%% 					I = [{obj,[{id,TimeStamp},{item,Message}]}],
%% 					JSONI = {obj,[{channel,I}]},
%% 					JSONString = rfc4627:encode(JSONI),
				
				
				%% Disseminate messages to all clients
				
 				     %send_to_pid(PIDS,ETSTexts),

			

				%%Calculating the timestamp after each send operation

 						io:format(" Timestamp : "),
						Timestamp=erlang:now(),	
				
						{Mega,Sec,Micro}=Timestamp,
				
				        MegaInSec = Mega*1000000,
		
		                MicroInSec = Micro/1000000,
				 				
						TimeInSec = MegaInSec + Sec + MicroInSec,						
								
						io:write(TimeInSec),
				
				
			%% making call to web_services
				
				     %%gen_server:call({Channel,Node}, {handle_EB_request,_Channel,_ChannelKey,ETSTexts}),
				
					io:format("making rpc call to web_services"),
					%%Nodec1 = 'c1@pp08002795968d.usask.ca',
				    Nodec1 = 'c1@rahnuma.usask.ca',
    				rpc:call(Nodec1, web_services, webservice_post, [Channel,Key,Item,Nodec1]),
				
			%%	Nodes=nodes(),
			%%	io:write(Nodes),
			%%	send_to_replicas(Nodes,ETSResults,Channel,Key),
		
			{reply, "ok", State};
		
		
		
		
		%% results found
		DetsResults =/= [] ->
			
			io:format("Results found......... "),
			
			%% get first match
			[{_Channel, _ChannelKey, Texts}|_] = DetsResults,
			
			if 
				
				_ChannelKey == Key -> 
					io:format("  duplicate key... "),
					{reply, "Duplicate Key error", State};
			
				_ChannelKey =/= Key ->
				io:format(" New Key... "),
				NewTexts = lists:append([Item, "\n\n", Texts]),			
				DATA = #channel{key=Key, eventdata = NewTexts},	
				dets:insert(Channel, DATA),
 				dets:to_ets(Channel, Channel),
		
		   
			
			%% ETS lookup to push events to the registered subscribers   
			   ETSResults = ets:lookup(Channel, Key),	
								
								%%io:format(" ETS Results2 : "),
							 	%%io:write(ETSResults),
			if 
				
				%% no results were found
				ETSResults ==  [] -> 
					{reply, "error", State};
				
				%% results found
				ETSResults =/= [] ->
	
				%% get first match
				[{_Channel, _ChannelKey, ETSTexts}|_] = ETSResults,			
		   		#state{data_pids = PIDS} = State, 
				
	
			   %% Disseminate messages to all clients

					%send_to_pid(PIDS,ETSTexts),
				
			   %%Calculating the current time after each send operation

 						io:format(" Timestamp : "),
						Timestamp=erlang:now(),	
				
						{Mega,Sec,Micro}=Timestamp,
				
				        MegaInSec = Mega*1000000,
		
		                MicroInSec = Micro/1000000,
				 				
						TimeInSec = MegaInSec + Sec + MicroInSec,						
								
						io:write(TimeInSec), 
				
				%% making call to web_services
				
				     %%gen_server:call({Channel,Node}, {handle_EB_request,_Channel,_ChannelKey,ETSTexts}),
				
					io:format("making rpc call to web_services"),
					%%Nodec1 = 'c1@pp08002795968d.usask.ca',
				    Nodec1 = 'c1@rahnuma.usask.ca',
    				rpc:call(Nodec1, web_services, webservice_post, [Channel,Key,Item,Nodec1]),
				
			%%	Nodes=nodes(),
			%%	io:write(Nodes),
			%%	send_to_replicas(Nodes,ETSResults,Channel,Key),
				
			{reply, "ok", State}
		   end
        end
	end;

		



%% %% Handle publish_replica call
handle_call({publish_replica,Item,Channel,Key}, From, State) ->
	

	io:format("  publish testing 4 "),	
	%% get results
	DetsResult = dets:lookup(Channel, Key),
	io:format(" Replicating DETS Results : "),
	io:write(DetsResult),
	
	if 
		
		%% no results were found
		DetsResult ==  [] -> 
				DATA = #channel{key=Key, eventdata = Item},	
				
				io:format(" Replicate First Key : "),
	  			io:write(Key),				
	            dets:insert(Channel, DATA),	
				dets:to_ets(Channel, Channel),	
				
			{reply, "ok", State};
		
		%% results found
		DetsResult =/= [] ->
			
			%% get first match
			[{_Channel, _ChannelKey, Texts}|_] = DetsResult,
			
			if 
				
				_ChannelKey == Key -> 
					io:format("  replicate_duplicate key... "),
					{reply, "key duplication error", State};
			
				_ChannelKey =/= Key ->
				io:format(" replicate_no key duplication... "),
				NewTexts = lists:append([Item, "\n\n", Texts]),			
				DATA = #channel{key=Key, eventdata = NewTexts},	
				dets:insert(Channel, DATA),
 				dets:to_ets(Channel, Channel),			
			{reply, "ok", State}
		 
        end
	end;



%% to check if there is a gen_server register under your name, following command need to execute
%% rpc:call(b@rahnuma.usask.ca,erlang,whereis,[c1]). 
	
%% 	#state{data_pids = PIDS} = State, 
%% 	io:write(PIDS),
%% 	send_to_pid(PIDS,Item),
%%     {reply, ok, State}; 





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

%% Send message to registered clients
send_to_pid([],Message)-> true;
send_to_pid([Pid|Rest],Message) ->
	%%io:format ("  sending"),
	Pid ! {Message},
	send_to_pid(Rest,Message).


%% %% Send message to replicas
send_to_replicas([],ETSResults,Channel,Key)-> true;
send_to_replicas([Node|Rest],ETSResults,Channel,Key)->
	
	%% checking for registered nodes
	Result = rpc:call(Node,erlang,whereis,[Channel]),
	io:format ("  sending to replicas"),
	io:write(Result),
	if Result =/= "undefined" ->
		  rpc:call(Node,?MODULE,replicate_publish,[ETSResults,Channel,Node,Key])		  
	end,
    send_to_replicas(Rest,ETSResults,Channel,Key).









