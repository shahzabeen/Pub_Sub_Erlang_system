%% Author: rahnuma
%% Created: Dec 2, 2013
%% Description: TODO: Add description to callback
-module(test).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([insert/0, read/2, hello/0]).

%%
%% API Functions
%%

hello()->
	io:format("Format").
	
 %%insert(0,Time)->
 	%%io:format("Total time difference is: "),
 	%%io:write(Time);

	%%{ok, WT} = file:open("writeTotal.dat", [read,write,append]),
	%%io:fwrite(WT, "~p~n", [Time]);

%%insert(N,Time) ->
insert() ->
	%%{ok, W} = file:open("writeTotal.dat", [read,write,append]),
	
 	T1=os:timestamp(), 

	Data="aaaaaa",
    dets:post_to_channel('c1',1,Data),
	
 	T2 = os:timestamp(),
 	Time_for_request = timer:now_diff(T2, T1), %% in microseconds 
	ReqTimeInMiliSec = Time_for_request/1000.
	%%io:write(Time_for_request),
	%%io:fwrite(W, "~p~n", [ReqTimeInMiliSec]),
	%%book_database:delete(),
	
	%%M=N-1,
	%%insert(M,Time+ReqTimeInMiliSec).



 read(0,Time)->
	{ok, WT} = file:open("readTotal.dat", [read,write,append]),
	io:fwrite(WT, "~p~n", [Time]);

	
read(N,Time) ->
	%%{ok, R} = file:open("read.dat", [read,write,append]),
	
	T1 = os:timestamp(),
	{ok, Result} = book_database:get_all(),
	%%io:write(Result),
	
	T2 = os:timestamp(),
	Time_for_request = timer:now_diff(T2, T1),
	ReqTimeInMiliSec = Time_for_request/1000,
	%%io:fwrite(R, "~p~n", [ReqTimeInMiliSec]).

	M=N-1,
	read(M,Time+ReqTimeInMiliSec).



%%
%% Local Functions
%%

