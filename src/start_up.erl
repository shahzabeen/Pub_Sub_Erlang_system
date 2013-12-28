%% Author: Rahnuma
%% Created: 2012-11-15
%% Description: TODO: Add description to start_up
-module(start_up).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([start/0]).

%%
%% API Functions
%%
start()->
	erlang:set_cookie(node(), abc).

%%
%% Local Functions
%%

