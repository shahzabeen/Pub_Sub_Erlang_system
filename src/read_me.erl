%% Author: Rahnuma
%% Created: 2013-08-01
%% Description: TODO: Add description to read_me
-module(read_me).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([]).

%%
%% API Functions
%%



%%
%% Local Functions
%%



%%%%%%%%%%%%%% INFO %%%%%%%%%%%%%%%%%%%%


%% /*
%% 	To run this application, 
%% 	1. start yaws server with a name (e.g yaws -name a)
%% 	2. open 2 werl windows from project ebin source with a name (werl -name b) and 	(werl -name c) 
%% 	3. Connect both nodes to yaws server e.g net_adm:ping('a@rahnuma.usask.ca')
%% 	4. On node a start EB

%% */

%%
%% To start yaws with setcookie 
%% yaws -name a --runmod start_up
%%
%% To start any erlang node with setcookie 
%% werl -name b -setcookie abc
%%



%% channel:test().
%% 
%% 
%% 
%% channel:start_link(c1).
%% 
%% channel:subscribe_to_channel(c1,rahnuma).
%% 
%% channel:publish_to_channel(c1,"id1","madmuc").
%% 
%% channel:read_from_channel(c1,"id1").
%% 
%% channel:unsubscribe_to_channel(c1,monica).
%% 
%% 
%% 
%% net_adm:ping('a@rahnuma.usask.ca').
%% 
%% net_adm:ping('b@rahnuma.usask.ca').
%% 
%% event_broker:start_link(eb).
%% 
%% event_broker:add_host_node(eb,'c@rahnuma.usask.ca').
%% 
%% event_broker:create_channel(eb,c1).
%% 
%% event_broker:list_of_channels(eb).
%% 
%% event_broker:publish_to_channel(eb,c1,"id1","JQueryMobile").
%% 
%% event_broker:read_from_channel(eb,c1).
%% 
%% 
%% event_broker_1:test().
%% 
%% 
%% 
%% connector:start_link(rahnuma).
%% 
%% connector:eventbroker_send(rahnuma,c1,"id14","mucis14").
%% 
%% listener:connector_send(rahnuma,c1,"id14","music14").
%% 
%% listener:connector_send(0.54,rahnuma,c1,"id1","music1").
%% 
%% 
%% callback:listener_subscription(rahnuma,c1).
%% 
%% callback:listener_publish(rahnuma,c1,"id14","music14").
%% 
%% 
%% 
%% callback:read_from_channel(rahnuma,c1).
%% 
%% channel:read_test(c1). 
%% 
%% 
%% 
%% global:whereis_name(rahnuma).




	
			
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