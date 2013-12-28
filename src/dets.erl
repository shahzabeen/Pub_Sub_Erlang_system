%%% -------------------------------------------------------------------
%%% Author  : Rahnuma
%%% Description :
%%%
%%% Created : May 31, 2012
%%% -------------------------------------------------------------------
-module(dets).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
-export([start_link/1,subscribe_to_channel/2,unsubscribe_to_channel/2,post_to_channel/3,read_from_channel/2,subscriber_list/1,read_test/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {client_names=[]}). 

-record(data, {key, eventdata}). 


%% ====================================================================
%% External functions
%% ==================================================================== 


%% start the server
start_link(Channel) ->	
	io:write(Channel),
	io:format("start_link: channnel is created..."),
	gen_server:start_link({global,Channel}, ?MODULE, {Channel}, []).


%% register client Pid
subscribe_to_channel(Client_name,Channel)->
	gen_server:call({global,Channel}, {subscribe, Client_name}).


%% List of subscribers
subscriber_list(Channel)->
	gen_server:call({global,Channel}, {listsubscriber, Channel}).


%% Publish data to channel
post_to_channel(Channel,Key,Text) ->
%%	io:format("channel: post to channel"),
	
%% 	%%
%% 	Pid = global:whereis_name(rahnuma),
%% 	io:write(Pid),
%% 	%%

  	gen_server:call({global,Channel}, {postchannel,Channel,Key,Text}). 


%% Read data from ETS table
read_from_channel(Channel, Key) ->
 	gen_server:call({global,Channel}, {readchannel, Channel, Key}). 


%% Register client Pid
unsubscribe_to_channel(Channel,Client_name)->
	gen_server:call({global,Channel}, {unsubscribe, Client_name}). 


read_test(Channel)->
	gen_server:call({global,Channel}, {readtest,Channel}). 

%% Test Routine
%%  test()-> 
%%  	        start_link(n1),
%%   			subscribe_to_channel(n1,rahnuma),
%% 				subscribe_to_channel(n1,monica),
%% 				subscribe_to_channel(n1,misha),
%% 				subscribe_to_channel(n1,aliya),
%%   			publish_to_channel(n1,"id8","madmuc"),
%%  		    read_from_channel(n1,"id8"),
%% 		    	unsubscribe_to_channel(n1,monica).
 
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

init({Channel}) ->
	
	dets:open_file(Channel, [{file, Channel},{keypos, #data.key}]),
	ets:new(Channel,[named_table,{keypos, #data.key}]),	
	
	DATA = #data{key="", eventdata = ""},	
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
handle_call({subscribe, ClientName}, From, State) ->
    io:format("Registering client name ... "),	
	io:write(ClientName),
	io:format("\n\n"),
		
	%% Storing client pids
    #state{client_names = Existing_client_name} = State, 	
	ClientList = #state{client_names = [ClientName|Existing_client_name]},
	
	io:format("List of subscribers ... "),	
	io:write(ClientList),	
	io:format("\n\n"),
	
	{reply, ok, ClientList};


%% Fetches the subscriber list 	
handle_call({listsubscriber, Channel}, From, State) ->
 %%   io:format("Subscriber Lists ... "),	
%%	io:format("\n\n"),
		
	#state{client_names = Names} = State, 

	{reply, Names, State};


%% Handle publish call
handle_call({postchannel,Channel,Key,Item}, From, State) -> 
	

						Timestamp=erlang:now(),
										
						{Mega,Sec,Micro}=Timestamp,
						
						Microsec = (Mega * 1000000 + Sec) * 1000000 + Micro,
						MicrosecToSec = Microsec / 1000000,
						SecToMilisec = MicrosecToSec * 1000,
								
						io:fwrite("~n"),
						io:write(SecToMilisec),
		 
		 
		 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%% get results
	DetsResults = dets:lookup(Channel, Key),
		
	if 
		
		%% no results were found
		DetsResults ==  [] -> 
			
				DATA = #data{key=Key, eventdata = Item},	
				
	            dets:insert(Channel, DATA),
				dets:to_ets(Channel, Channel),				
				ETSResults = ets:lookup(Channel, Key),	
				
			{reply, "NEW MESSAGE2", State};
		

		%% results found
		DetsResults =/= [] ->
			
			
			%% get first match
			[{_Channel, _ChannelKey, Texts}|_] = DetsResults,
			
			if 
				
				_ChannelKey == Key -> 
					%%io:format("  duplicate key... "),
					{reply, "Duplicate Key error", State};
			
				_ChannelKey =/= Key ->														
				
				ETSResults = ets:lookup(Channel, Key),
				
			%%	io:format("ETS Result ... "),	
			%%	io:write(ETSResults),
			%%	io:format("\n\n"),
			
			{reply, "NEW MESSAGE2", State}

        end
	end;



%% Handle read call
handle_call({readchannel, Channel, Key}, From, State) ->
	
	%% io:format("Reading Message from channel..... "),
	%% io:write(Channel),
	%% io:format("\n\n"),


	 %% get results
     Results = ets:lookup(Channel,Key), 
	
	if 
		
		%% no results were found 
		Results ==  [] -> 
			{reply, "error", State};
		
		%% results found
		Results =/= [] ->
			
			%% get first match
			[{_Channel, _ID, Texts}|_] = Results,
			
			%% return resource state
			{reply,Texts,State}
	
	end;


%% Register client Pids into a list   	
handle_call({unsubscribe, ClientName}, From, State) ->

	%% unsubscribing client name
    #state{client_names = Existing_client_name} = State, 
	ClientList = #state{client_names = [ClientName|Existing_client_name]},
			
	{_,L1}=ClientList,
	
	io:format("\n\n"),
	io:format("Old List:  "),
	io:write(L1),

	%%ClientList = #client.client_names,
	
	NewClientList = delete(ClientName,L1),
	io:format("\n\n"),
	io:format("New List,L2:  "),
	io:write(NewClientList),
	
	{reply, ok, ClientList};



handle_call({readtest,Channel}, From, State) ->
	
		 	Lines = ets:tab2list(Channel), 	
		 	io:format("Reading and Delivering event message from channel..... "),
		 	%%io:write(Lines),
		 	io:format("\n\n"),	
			
			ETSJsonString = convert_to_json(Lines),
			
		 	{reply, ETSJsonString, State}; 


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

handle_info({readchannelinfo, Channel}, State) ->
	io:format("Reading Channel"),	
    {noreply, State};

handle_info({postchannelinfo, Channel,Key,Item}, State) ->
	io:format("Publishing Channel"),	
    {noreply, State};

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


delete(Cname,L1)->
	delete(Cname,L1,[]).

delete(Cname,[],L2)-> L2;

delete(Cname,[Cname|T],L2)->
	delete(Cname,T,L2);
	
delete(Cname,[H|T],L2)->
	delete(Cname,T,L2++[H]).									  

	

convert_to_json(Lines)->									 
	Data = [{obj,
		      [{updatekey, Line#data.key},
			   {updatedata, Line#data.eventdata}]}
			|| Line<-Lines],
	JsonData = {obj,[{data,Data}]},
	rfc4627:encode(JsonData).






