%%% -------------------------------------------------------------------
%%% Author  : Rahnuma
%%% Description :
%%%
%%% Created : May 31, 2012
%%% -------------------------------------------------------------------
-module(event_broker).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
-export([start_link/1,add_host_node/2, create_channel/2,list_of_channels/1,publish_to_channel/6,read_from_channel/2,subscribe_to_channel/4,read_test/3]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {nodenames=[]}).

-record(routinginfo, {channelname, channelpid}).


%% ====================================================================
%% External functions
%% ====================================================================


%% start the server
start_link(Node) ->	
	gen_server:start_link({global,Node}, ?MODULE, {Node}, []).  


%% 
%% 
%% handle_client_msg(ClientName, Message,Node)->
%% 
%% 		{ok,ErlangText,[]}=rfc4627:decode(Message),
%% 		io:format(" Erlang String : "),
%% 		io:write(ErlangText),
%% 		{ok,Action}=rfc4627:get_field(ErlangText, "action"),
%% 		{ok,Channel}=rfc4627:get_field(ErlangText, "channel"),
%% 				
%% 		Operation = binary_to_list(Action),
%% 		ChannelName = binary_to_list(Channel),
%% 		
%% 		case Operation of 					  
%% 		         "register" ->
%% 				    subscribe_to_channel(Node,ChannelName,ClientName);	
%% 			
%%  			     "publish" ->
%% 					 {ok,ID}=rfc4627:get_field(ErlangText, "GUID"),
%% 					 Key = binary_to_list(ID),
%% 					 io:format(" Key is: "),
%% 					 io:write(Key),
%% 					 
%%                      {ok,Text}=rfc4627:get_field(ErlangText, "data"),
%% 					 TextNew = binary_to_list(Text),
%% 					 io:write(TextNew),
%%  				     publish_to_channel(list_to_atom(ChannelName),Node,Key,TextNew);
%% 			
%% 			     _ ->
%%                 	io:format(" Upsss!~n")
%% 		end.


%% register client Pid
add_host_node(Node,Nodename)->
	gen_server:call({global,Node}, {addnode, Nodename}).


%% publish data to channel
create_channel(Node,ChannelName) ->
	gen_server:call({global,Node}, {channelcreate,Node,ChannelName}).


%% Lists all created channels
list_of_channels(Node)->
	gen_server:call({global,Node}, {channellist,Node}).

%% Subscribe to channel
subscribe_to_channel(Node,GRname,ClientName,ChannelName)->
    gen_server:call({global,Node}, {subscribe,GRname,ClientName,ChannelName}).


%% Post message to a channel
publish_to_channel(ConnectorPid,Node,ClientName,ChannelName,ID,Item)->
%%	io:format("event_broker..."),
	
	%%
%% 	Pid = global:whereis_name(rahnuma),
%% 	io:write(Pid),
	%%

    gen_server:call({global,Node}, {publish,ConnectorPid,Node,ClientName,ChannelName,ID,Item}).


%% Read from a channel
read_from_channel(Node,ChannelName)->
    gen_server:call({global,Node}, {read,ChannelName}).


%% Read from a channel
read_test(Node,Key,ChannelName)->
	io:format("read_test ..."),
    gen_server:call({global,Node}, {readtest,Key,ChannelName}).



%% Test Routine
%% test()->
%%   	       start_link(eb),
%% 
%% 		   add_host_node(eb,'b@rahnuma.usask.ca'),
%% 
%%            create_channel(eb,c1),
%% 
%%            list_of_channels(eb),
%% 
%%            publish_to_channel(eb,c1,"idc11","JQueryMobile4"),
%% 		   
%% 		   read_from_channel(eb,c1).

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

init({Node}) ->
	
	dets:open_file(Node, [{file, Node},{keypos, #routinginfo.channelname}]),
	ets:new(Node,[named_table,{keypos, #routinginfo.channelname}]),	
	
	%%DATA = #routinginfo{channelname = " ",channelpid = " "},	
	%%dets:insert(Node, DATA),	
	
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


%% Creating the list of all available nodes   	
handle_call({addnode, NodeName}, From, State) ->
    io:format("Adding a node to the nodelist ... "),	
	io:write(NodeName),
	io:format("\n\n"),
		
	%% Adding node
    #state{nodenames = PreNode} = State, 
	NodeList = #state{nodenames = [NodeName|PreNode]},
	
	%%A = NodeList#state.nodenames,
	
	io:format("List of available nodes....."),	
	io:write(NodeList),	
	io:format("\n\n"),
	
	{reply, ok, NodeList};



%% Creating a Channel process 
handle_call({channelcreate, Node,ChannelName}, From, State) ->
	
	     io:format("...channel create..."),
		    
		 #state{nodenames = PrevNode} = State, 	 
	     %%NodeList = #state.nodenames,		 
		 io:write(PrevNode),
		 
		 %%Randomly obtaining a node from the Nodelist
		 Index = random:uniform(length(PrevNode)), 
		 N = lists:nth(Index, PrevNode),

		 %%spawning channel process on node N
 	     Pid = spawn(N,channel,start_link,[ChannelName]),
		  	 io:format("Registered pid ... "),	
 		 	 io:write(Pid),
		 	 io:format("Randomly chosen node ... "),	
			 io:write(N),
		 	 io:format("\n\n"),
		 
         %%Storing channel name and its pid into 'eb1' dets table
   		 DATA = #routinginfo{channelname = ChannelName, channelpid = Pid},						
 		     dets:insert(Node, DATA),
 		     dets:to_ets(Node, Node),
		 
	     {reply, "Done", State};




%% Creating a Channel process 
handle_call({channellist, Node}, From, State) ->
				
			 io:format("Lists of Channels with pids..... "),
			 io:write(Node),
			 io:format("\n\n"),
			
			 %% get results
		     Results = ets:tab2list(Node), 
			 
			 io:format("ETS..... "),
			 io:write(Results),
			 io:format("\n\n"),
		
			
			%% get first match
			%%[{_Channel, _ChannelName, Texts}|_] = NewResults,
			
			%% return resource state
			{reply, "OK", State};



%% Subscribing to a channel
handle_call({subscribe,GRname,ClientName,ChannelName}, From, State) ->
			
			channel:subscribe_to_channel(ClientName,ChannelName),
			%%channel:subscribe_to_channel(GRname,ClientName,ChannelName),

			{reply, "Subscription Done", State};


%% Handle post/publish call
handle_call({publish,ConnectorPid,Node,ClientName,ChannelName,ID,Item}, From, State) ->
	
	      %%  io:format("EB Publish..."),
	
%% 	        %% Lookup into the eb1 dets for the channel pid
%% 		    Result = ets:lookup(Node,ChannelName),
%% 	        [{_,_,ChannelPid}]=Result,
%% 			io:format("Requested channel pid..... "),
%% 			io:write(ChannelPid),
%% 			io:format("\n\n"),
					
			
		%% Publishing to the Channel			
 			channel:post_to_channel(ChannelName,ID,Item),
				
			
		%% fetching the list of subscribers
			SubscriberLists = channel:subscriber_list(ChannelName),
			io:format("eventbroker: list of subscribers ...."), 
			%%io:write(SubscriberLists),
			io:format("\n\n"),
			
			
		%% Fetching the published message from Channel 
			%%Text = channel:read_from_channel(ChannelName,ID), 
			%%Notification = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
			
			%% 1kb
			Notification2= "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
			
			%%Result = Text ++ Notification,
			%%Result = Notification,
			%%Result = Text,

			
		
			
		%% Sending message to registered subscribers
				%%send_to_subscribers(SubscriberLists,Result),

		%% Invoking Connector's handle_cast	
		%%	Closing for testing purposes
			%%send_to_connectors(SubscriberLists,ChannelName,Result),	
			
			
  			%%{reply, "NEW MESSAGE1", State};

			{reply, Notification2, State};
 		


%% Handle get/read call
handle_call({readtest,Key,ChannelName}, From, State) ->
	
	        %%io:format("eventbroker:readtest"),
			
			Return = channel:read_from_channel(ChannelName,Key),
			%%Return = channel:read_test(ChannelName),
			
			{reply, Return, State};


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

%% Unsubscribe a channel

delete(Cname,L1)->
	delete(Cname,L1,[]).

delete(Cname,[],L2)-> L2;

delete(Cname,[Cname|T],L2)->
	delete(Cname,T,L2);
	
delete(Cname,[H|T],L2)->
	delete(Cname,T,L2++[H]).									  


%% Send message to registered clients
send_to_subscribers([],Message)-> true;
send_to_subscribers([SName|Rest],Message) ->
	
	Pid = global:whereis_name(SName),
   	io:format("Pid of subscriber...."),
   	io:write(Pid),
    io:format("\n\n"),			
	Pid ! {Message},
	
	send_to_subscribers(Rest,Message).	


%% Send message to registered clients (used for asynchronous communication)

send_to_connectors([],ChannelName,Result)-> true;

send_to_connectors([SName|Rest],ChannelName,Result)->
	
		 gen_server:cast({global,SName}, {anything,ChannelName,Result}),
		 
		 send_to_connectors(Rest,ChannelName,Result).

