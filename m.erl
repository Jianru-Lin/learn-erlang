%% -*- erlang -*-
%%! -smp enable -sname factorial -mnesia debug verbose

%% 中文

main(["is-binary", V]) ->
	io:format("~p~n", [is_binary(V)]);
main(["is-list"]) ->
	V = "",
	io:format("~p~n", [is_list(V)]);
main(["is-list", V]) ->
	io:format("~p~n", [is_list(V)]);
main(["list-to-integer", V]) ->
	io:format("~p~n", [list_to_integer(V)]);
main(["list-to-atom", V]) ->
	io:format("~p~n", [list_to_atom(V)]);
main(["list-to-binary"]) ->
	V = "",
	io:format("~p~n", [list_to_binary(V)]);
main(["list-to-binary", V]) ->
	io:format("~p~n", [list_to_binary(V)]);
main(["list-to-bitstring"]) ->
	V = "",
	io:format("~p~n", [list_to_bitstring(V)]);
main(["list-to-bitstring", V]) ->
	io:format("~p~n", [list_to_bitstring(V)]);
main(["system-info"]) ->
	io:format("~p~n", [erlang:system_info()]);
% main(["time", "now"]) ->
% 	io:format("~p~n", [erlang:now()]);
main(["time", "system"]) ->
	io:format("~p~n", [erlang:system_info(os_system_time_source)]);
main(["time", "system-monotonic"]) ->
	io:format("~p~n", [erlang:system_info(os_monotonic_time_source)]);
main(["time", "erlang"]) ->
	io:format("~p~n", [erlang:system_time()]);
main(["time", "erlang-monotonic"]) ->
	io:format("~p~n", [erlang:monotonic_time()]);
main(["time", "erlang-offset"]) ->
	io:format("~p~n", [erlang:time_offset()]);
main(["time", "stamp"]) ->
	io:format("~p~n", [erlang:timestamp()]);
main(["calendar", "local-time"]) ->
	io:format("~p~n", [calendar:local_time()]);	
main(["calendar", "universal-time"]) ->
	io:format("~p~n", [calendar:universal_time()]);	
main(["calendar", "is-leap-year", Text]) ->
	Year = list_to_integer(Text),
	io:format("~p~n", [calendar:is_leap_year(Year)]);	
main(["file", "consult", F]) ->
	case file:consult(F) of
		{error, Reason} ->
			io:format("~p~n", [Reason]);
		{ok, Term} ->
			io:format("~p~n", [Term])
	end;
main(["file", "open", Name]) ->
	{ok, F} = file:open(Name, read),
	io:format("~p~n", [F]),
	ok = file:close(F);	
main(["file", "make-dir", Name]) ->
	R = file:make_dir(Name),
	io:format("~p~n", [R]);
main(["file", "del-dir", Name]) ->
	R = file:del_dir(Name),
	io:format("~p~n", [R]);
main(["file", "native-name-encoding"]) ->
	R = file:native_name_encoding(),
	io:format("~p~n", [R]);
main(["io", "read"]) ->
	main(["io", "read", ""]);
main(["io", "read", Prompt]) ->
	R = io:read(standard_io, Prompt),
	io:format("~p~n", [R]);
main(["toy", "line-by-line", FileName]) ->
	line_by_line(FileName);
main(["toy", "write-file", FileName]) ->
	R = write_file(FileName),
	io:format("~p~n", [R]);
main(["toy", "copy", SrcFileName, DstFileName]) ->
	R = copy(SrcFileName, DstFileName),
	io:format("~p~n", [R]);
main(["toy", "tick", Interv]) ->
	Interv2 = list_to_integer(Interv),
	tick(Interv2);
main(["toy", "sleep", V]) ->
	V2 = list_to_integer(V),
	io:format("sleep ~wms~n", [V2]),
	sleep(V2),
	io:format("done.~n");
main(["toy", "hex", V]) ->
	V2 = list_to_integer(V),
	hex(V2);
main(["toy", "dump-binary", V]) ->
	Bin = unicode:characters_to_binary(V, unicode, utf16),
	dump_binary(Bin);
main(["toy", "utf8", V]) ->
	Bin = unicode:characters_to_binary(V, unicode, utf8),
	dump_binary(Bin);
main(["toy", "utf16", V]) ->
	Bin = unicode:characters_to_binary(V, unicode, utf16),
	dump_binary(Bin);
main(["toy", "utf16be", V]) ->
	Bin = unicode:characters_to_binary(V, unicode, {utf16, big}),
	dump_binary(Bin);
main(["toy", "utf16le", V]) ->
	Bin = unicode:characters_to_binary(V, unicode, {utf16, little}),
	dump_binary(Bin);
main(["toy", "convert-encoding"]) ->
	io:format("convert-encoding <src-encoding> <src-file> <dst-encoding> <dst-file>");
main(["toy", "convert-encoding", SrcEncoding, SrcFile, DstEncoding, DstFile]) ->
	SrcEncodingAtom = encoding_name(SrcEncoding),
	DstEncodingAtom = encoding_name(DstEncoding),
	convert_encoding(SrcEncodingAtom, SrcFile, DstEncodingAtom, DstFile);
main(["scan", Text]) ->
	{ok, Tokens, _} = erl_scan:string(Text),
	io:format("~p~n", [Tokens]);
main(["parse", "term", TermText]) ->
	{ok, Tokens, _} = erl_scan:string(TermText),	
	{ok, Term} = erl_parse:parse_term(Tokens),
	io:format("~p~n", [Term]);
main(["code", "which", Name]) ->
	ModuleAtom = list_to_atom(Name),
	io:format("~p~n", [code:which(ModuleAtom)]);
main(_) ->
	io:format("usage: main <command> [options]~n").

line_by_line(FileName) ->
	{ok, F} = file:open(FileName, read),
	line_by_line(loop, F),
	ok = file:close(F).

line_by_line(loop, F) ->
	case io:get_line(F, '') of
		eof ->
			io:format("done.~n"),
			ok;
		L ->
			io:format("~ts", [L]),
			line_by_line(loop, F)
	end.

write_file(FileName) ->
	{ok, F} = file:open(FileName, write),
	write_file(loop, F),
	ok = file:close(F).

write_file(loop, F) ->
	case io:get_line(standard_io, "> ") of
		eof -> 
			ok;
		L -> 
			io:fwrite(F, "~ts", [L]),
			write_file(loop, F)
	end.

copy(SrcName, DstName) ->
	{ok, SrcF} = file:open(SrcName, [read, binary]),
	{ok, DstF} = file:open(DstName, [write, binary]),
	R = copy(loop, SrcF, DstF),
	file:close(SrcF),
	file:close(DstF),
	R.

copy(loop, SrcF, DstF) ->
	case file:read(SrcF, 1024 * 256) of
		eof ->
			ok;
		{ok, Bin} ->
			io:format("copy ~w Bytes~n", [byte_size(Bin)]),
			file:write(DstF, Bin),
			copy(loop, SrcF, DstF)
	end.

tick(Interv) ->
	tick(loop, Interv, 1).

tick(loop, Interv, I) ->
	io:format("tick ~w~n", [I]),
	sleep(Interv),
	tick(loop, Interv, I+1).

sleep(T) ->
	receive
		_ -> ok
	after T ->
		ok
	end.

hex(Value) ->
	io:format("0x~.16B~n", [Value]).

dump_binary(Bin) ->
	for_every_byte(Bin, fun(Byte) -> <<T>> = Byte, io:format("0x~.16B ", [T]) end).

for_every_byte(Bin, Fun) ->
	case byte_size(Bin) > 0 of
		true ->
			<<Byte:1/binary, Rest/binary>> = Bin,
			Fun(Byte),
			for_every_byte(Rest, Fun);
		false ->
			ok
	end.

convert_encoding(SrcEncoding, SrcFile, DstEncoding, DstFile) ->
	% 暂时我们采用一次性读入文件并转换的方式
	{ok, SrcFileBin} = file:read_file(SrcFile),
	io:format("read source file done, ~w bytes.~n", [byte_size(SrcFileBin)]),
	DstFileBin = unicode:characters_to_binary(SrcFileBin, SrcEncoding, DstEncoding),
	io:format("convert encoding done, ~w bytes generated.~n", [byte_size(DstFileBin)]),
	ok = file:write_file(DstFile, DstFileBin),
	io:format("write to dest file done.~n"),
	ok.

encoding_name(Name) ->
	case Name of
		"utf8" -> utf8;
		"utf16" -> utf16;
		"utf32" -> utf32;
		"unicode" -> unicode;
		"utf16le" -> {utf16, little};
		"utf16be" -> {utf16, big};
		"utf32le" -> {utf32, little};
		"utf32be" -> {utf32, big}
	end.