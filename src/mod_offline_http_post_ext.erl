-module(mod_offline_http_post_ext).
-author("mitulmlakhani99@gmail.com").

-behaviour(gen_mod).

-export([start/2, stop/1, ccreate_message/1, mod_opt_type/1, depends/2, mod_options/1]).

-include("scram.hrl").
-include("xmpp.hrl").
-include("logger.hrl").

start(_Host, _Opt) ->
  ?INFO_MSG("mod_offline_http_post_ext loading", []),
  inets:start(),
  ?INFO_MSG("HTTP client started", []),
  ejabberd_hooks:add(offline_message_hook, _Host, ?MODULE, ccreate_message, 1).

stop (_Host) ->
  ?INFO_MSG("stopping mod_offline_http_post_ext", []),
  ejabberd_hooks:delete(offline_message_hook, _Host, ?MODULE, ccreate_message, 1).

depends(_Host, _Opts) ->
    [].

mod_opt_type(auth_token) ->
  fun iolist_to_binary/1;
mod_opt_type(post_url) ->
  fun iolist_to_binary/1.

mod_options(_Host) ->
    [
      auth_token,
      post_url
    ].

ccreate_message({Action, Packet} = Acc) when (Packet#message.type == chat) and (Packet#message.body /= []) ->
  [{text, _, Body}] = Packet#message.body,
  ?INFO_MSG("Message Body is ~p~n ", [Body]),
  Action = Action,
  From = Packet#message.from,
  To = Packet#message.to,

  Token = gen_mod:get_module_opt(To#jid.lserver, ?MODULE, auth_token),
  PostUrl = gen_mod:get_module_opt(To#jid.lserver, ?MODULE, post_url),
  
  ToUser = To#jid.luser,
  ?INFO_MSG("to is ~p~n ", [ToUser]),
  FromUser = From#jid.luser,
  ?INFO_MSG("From is ~p~n ", [FromUser]),
  
  SenderId = fxml:get_path_s(xmpp:encode(Packet), [{elem,list_to_binary("channel")}, {attr, list_to_binary("senderId")}]),
  ?INFO_MSG("SenderId is ~p~n ", [SenderId]),
  RecipientId = fxml:get_path_s(xmpp:encode(Packet), [{elem,list_to_binary("channel")}, {attr, list_to_binary("recipientId")}]),
  ?INFO_MSG("RecipientId is ~p~n ", [RecipientId]),

  post_offline_message(PostUrl, Token, Body),
  Acc;

ccreate_message(Acc) ->
  Acc.

post_offline_message(PostUrl, Token, Data) ->
  ?INFO_MSG("post ~p to ~p using ~p~n ", [Data, PostUrl, Token]),
  Request = {binary_to_list(PostUrl), [{"Authorization", binary_to_list(Token)}], "application/x-www-form-urlencoded;  charset=utf-8", Data},
  httpc:request(post, Request,[],[]),
  ?INFO_MSG("post request sent", []).
