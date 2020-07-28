#!/usr/bin/env ruby

SOURCE_FILE = File.join(%w(latest-src usr bin cowspeak))

abort "#{SOURCE_FILE} doesn't exist!" unless File.readable?(SOURCE_FILE)

source, i = IO.readlines(SOURCE_FILE), 0

v_lines = source
	.reduce({}) { |h, x| h.merge!((i += 1) => x[/\bVERSION\s*=.*\b/]) }
	.to_a.select { |x| x[1] }

abort <<~EOF if v_lines.size > 1
	\e[1;31mMultiple declaration of VERSION!\e[0m
	Make sure #{SOURCE_FILE} has only one VERSION declaration.

	Versions including:
		#{ v_lines.map { |x| "\n\tLine #{x[0]}: #{x[1]}" }.join.delete_prefix("\n\t") }
EOF

abort("#{SOURCE_FILE} has no VERSION") if v_lines.empty?

puts v_lines[0][1][/([1-9]\d*|0)(\.\d+)|(\b\d)/]
