%% application app file
{application, game,
	[
	 {description, "A game server system"}
	 ,{svn, "1.0"}
	 ,{modules, [game]}
	 ,{modules,[game, game_sup]}
	 ,{registered, []}
	 ,{applications, [kernel, stdlib, game]}
	 ,{mod, {game, []}}
	 ,{env, [
	 		 {platform, <<"">>}
	 		 %%,{server_id, 0}
	 		 %%,{server_ids, []}
	 		 ,{log_path, "./../var/"}
	 		 ,{tcp_linstener_count, 10}
	 		 ,{tcp_opts, [binary, {packet, 0}, {active, false}, {reuseaddr, true}, nodelay, false}, {delay_send, true}, {exit_on_close, false}, {send_timeout, 10000}, {send_timeout_close, false}]}
	 		 ,{tcp_flash_843_opts, [binary, {packet, 0}, {active, false}, {reuseaddr, true}, {exit_on_close, false}]}
	 		 ,{db_conf, ["127.0.0.1", 3306, "root", "admin", "game_db", utf8, 20]}
	 		]}
	]
}.