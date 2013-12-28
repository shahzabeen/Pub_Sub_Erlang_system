%% Author: Ashik
%% Created: 2012-10-13
%% Description: TODO: Add description to listener_middleware
-module(ws_timmer).

%%
%% Include files
%%

%%
%% Exported Functions
%%
    %%-export([read/3, readwrite_timer/0, read_timer/1, write_timer/3 ]).
    -export([subscription/1, read/3, write/3 ]).

%%test function
%%Run command


%% ws_timmer:readwrite_timer(9,1).
%%  
%%
%% API Functions
%%

%% Route message from client to  gen_server
%% readwrite_timer()->	
%% 	{ok,L}=ws_client:connect("http://rahnuma.usask.ca:7777/websockets_endpoint_pub_sub.yaws"),
%% 	{frame, text, Data}= ws_client:send_text(L,"connected"),
%% 	Time_read=read(1,0,L).

%% 
%% read_timer(L)->
%% 	T1 =os:timestamp(),
%% 	
%% 	%% HTTPC GET request to server.
%% 
%% 	{frame, text, Data}= ws_client:send_text(L,"orpa said Hi"),
%% 	io:write(Data).
%%    
%% 
%% %%Http write
%% write_timer(0, Time,L)->	
%% 	Time;
%% 
%% write_timer(N,Time,L)->
%% 	T1 = os:timestamp(),
%% 		
%% %% POST request to server 
%% %%JsonOb="{\"id\":3,\"name\": \"wheat\"}",
%% 	
%% 	{frame, text, Data} = ws_client:send_text(L,"{\"action\":\"post\",\"resourcename\":\"crops\"}"),
%% 	T2 =os:timestamp(),
%%     Time_for_request=timer:now_diff(T2, T1),
%% 	io:write(Time_for_request),
%% 	M=N-1,
%% 	write_timer(M, Time+Time_for_request, L).
%% 


subscription(L)->
	T1 = os:timestamp(),
	io:format("T1: "),
	io:write(T1),
	io:fwrite("~n"),
	
	{frame, text, Data} = ws_client:send_text(L, "{\"verb\":\"POST\",\"url\":\"http://rahnuma.usask.ca/subscribe\",\"version\":\"HTTP/1.1\",\"host\":\"rahnuma.usask.ca\",\"contenttype\":\"application/JSON\",\"action\":\"register\",\"channel\":\"c1\",\"client\":\"monica\"}"),
	
	T2 = os:timestamp(),
	io:format("T2"),
	io:write(T2),
	io:fwrite("~n"),
		
	Time_for_request = timer:now_diff(T2, T1),
	io:format("Time_for_request is: "),
	io:write(Time_for_request),
	io:fwrite("~n").


read(0,Time,L)->
	io:format("Total time is: "),
	Time;
	%%file:close(R);

read(N,Time,L)->
	
	{ok, W} = file:open("write.dat", [read,write,append]),
	
	T1 = os:timestamp(),
	io:format("T1: "),
	io:write(T1),
	io:fwrite("~n"),
	
	{frame, text, Data} = ws_client:send_text(L, "{\"verb\":\"GET\",\"url\":\"http://rahnuma.usask.ca/read\",\"version\":\"HTTP/1.1\",\"host\":\"rahnuma.usask.ca\",\"contenttype\":\"application/JSON\",\"GUID\":\"16:4:201\",\"action\":\"read\",\"channel\":\"c1\",\"client\":\"rahnuma\"}"),
	
	T2 = os:timestamp(),
	io:format("T2"),
	io:write(T2),
	io:fwrite("~n"),
		
	Time_for_request = timer:now_diff(T2, T1),
	io:format("Time_for_request is: "),
	io:write(Time_for_request),
	io:fwrite("~n"),
	
	io:fwrite(W, "~p~n", [Time_for_request]),

	M=N-1,
	read(M,Time+Time_for_request,L).
		
	
	
write(0,Time,L)->
	io:format("Total time difference is: "),
	Time;

write(N,Time,L)->
	
	{ok, P} = file:open("publish.dat", [read,write,append]),
	
	T1 = os:timestamp(),
	io:format("T1: "),
	io:write(T1),
	io:fwrite("~n"),
	
	%% 5kb
	{frame, text, Data} = ws_client:send_text(L, "{\"verb\":\"POST\",\"url\":\"http://rahnuma.usask.ca/publish\",\"version\":\"HTTP/1.1\",\"host\":\"rahnuma.usask.ca\",\"contenttype\":\"application/JSON\",\"GUID\":\"16:4:203\",\"action\":\"publish\",\"channel\":\"c1\",\"client\":\"monica\",\"data\":\"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\"}"),

	%%{frame, text, Data}= ws_client:send_text(L,"{\"verb\":\"POST\",\"url\":\"http://rahnuma.usask.ca/publish\",\"version\":\"HTTP/1.1\",\"host\":\"rahnuma.usask.ca\",\"contenttype\":\"application/JSON\",\"GUID\":\"16:13:200\",\"action\":\"publish\",\"channel\":\"c1\",\"client\":\"rahnuma\",\"data\":\"beautiful morning..\"}"),
	
	io:write(Data),
	io:fwrite("~n"),
	
	T2 = os:timestamp(),
	io:format("T2"),
	io:write(T2),
	io:fwrite("~n"),
		
	Time_for_request = timer:now_diff(T2, T1),
	io:format("Time_for_request is: "),
	io:write(Time_for_request),
	io:fwrite("~n"),
	
	io:fwrite(P, "~p~n", [Time_for_request]),
	
	M=N-1,
	read(M,Time+Time_for_request,L).







