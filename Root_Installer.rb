#!/usr/bin/env ruby
#Encoding: UTF-8
VERSION = 1.1

%w(io/console net/http fileutils).each(&method(:require))
PATH = File.join(File.dirname(__FILE__), 'cowspeak')
STDOUT.sync = true

class String
	define_method(:colourize) do |final = ''|
		colours, line_length = [], -1
		sample_colour, rev, repeat = rand(7), rand < 0.5, rand < 0.5
		temp = ''

		each_line do |c|
			n, i = c.length, -1

			if line_length != n
				step, line_length = 255.0./(n), n
				colours.clear

				while (i += 1) < n
					colours.<<(
						case sample_colour
							when 0 then i.*(step).then { |l| [ l.*(2).to_i.clamp(0, 255), l.to_i.clamp(0, 255), 255.-(l).to_i.clamp(0, 255) ] }
							when 1 then i.*(step).then { |l| [ 255, 255.-(l).to_i.clamp(0, 255), l.to_i.clamp(0, 255) ] }
							when 2 then i.*(step).then { |l| [ l.to_i.clamp(0, 255), 255.-(l).to_i.clamp(0, 255), l.to_i.clamp(0, 255) ] }
							when 3 then i.*(step).then { |l| [ l.*(2).to_i.clamp(0, 255), 255.-(l).to_i.clamp(0, 255), 100.+(l / 2).to_i.clamp(0, 255) ] }
							when 4 then i.*(step).then { |l| [ 30, 255.-(l / 2).to_i.clamp(0, 255), 110.+(l / 2).to_i.clamp(0, 255) ] }
							when 5 then i.*(step).then { |l| [ 255.-(l * 2).to_i.clamp(0, 255), l.to_i.clamp(0, 255), 200 ] }
							when 6 then i.*(step).then { |l| [ 50.+(255 - l).to_i.clamp(0, 255), 255.-(l / 2).to_i.clamp(0, 255), (l * 2).to_i.clamp(0, 255) ] }
							else  i.*(step).then { |l| [ l.*(2).to_i.clamp(0, 255), 255.-(l).to_i.clamp(0, 255), 100.+(l / 2).to_i.clamp(0, 255) ] }
						end
					).tap { | x | x.reverse! if repeat }
				end
			end

			i = -1
			temp.concat "\e[38;2;#{colours[i][0]};#{colours[i][1]};#{colours[i][2]}m#{c[i]}" while (i += 1) < n
		end
		temp << final
	end
end

In = Class.new do
	define_singleton_method(:gets) do |*arg|
		IO.new(STDOUT.fileno).tap { |x| x.write(*arg.map { |x| String === x ? x.colourize : x.to_s.colourize }.join("\n") ) }.close
		STDIN.gets.strip.downcase
	end
end

define_method(:detect_os) do
	begin
		STDOUT.puts("Attempting to detect the current operating system".colourize)
		STDOUT.puts "Detected #{IO.readlines('/etc/os-release').select { |i| i.start_with?('NAME') }[-1].to_s.split('=')[1].strip.undump} #{RUBY_PLATFORM}".colourize
		true
	rescue Exception
		STDOUT.puts "Can't determine the OS".colourize
	end
end

def help
	message = if system("sh -c 'type -p dpkg &> /dev/null && type -p pacman &>/dev/null'")
			"\n\u{2022} Recommendation: Your system seems to have both dpkg and pacman...\n"\
			"\t\u{2023} If you are using Arch Linux or derivatives, you can get cowspeak from AUR:\n"\
			"\t\thttps://aur.archlinux.org/packages/cowspeak/\n"\
			"\t\u{2023} If you are on debian / debian based system, you can install the deb file:\n"\
			"\t\thttps://github.com/Souravgoswami/cowspeak-root/tree/master/Debian"
		elsif system("sh -c 'type -p dpkg &> /dev/null'")
			"\n\u{2022} Recommendation: If you are using debian / debian based system, you can install the deb file:\n"\
			"\t\u{2023} https://github.com/Souravgoswami/cowspeak-root/tree/master/Debian"
		elsif system("sh -c 'type -p pacman &> /dev/null'")
			"\n\u{2022} Recommendation: If you are using Arch Linux or derivatives, you can get cowspeak from AUR:\n"\
			"\t\u{2023} https://aur.archlinux.org/packages/cowspeak/\n"\
		else ''
	end

	opts = "--help / -h       Shows this help and exit. * --install / -i    Installs cowspeak. *
			--licence / -l    Shows the licence. * --uninstall / -u  Uninstalls cowspeak."
				.split(?*).map { |x| "\t#{File.basename($0)} #{x.strip}" }.join(?\n)

	STDOUT.puts <<~EOF.each_line.map(&:colourize).join
		Cowspeak speaks a quote on your terminal.
		It is customizable. It can also show you useful system information.
		This is cowspeak installer #{VERSION}
		#{message}

		Usage:
		#{opts}
	EOF
end

def install
	throw :WriteError if !File.writable?(PATH) && File.exist?(PATH)
	STDOUT.puts("Downloading file fromhttps://raw.githubusercontent.com/Souravgoswami/cowspeak-root/master/latest-src/usr/bin/cowspeak. Press Enter to Confirm.".colourize)
	return nil unless STDIN.getch == ?\r

	loop do
		if File.directory?(PATH)
			STDOUT.puts("Looks like #{PATH} is a directory. Press Enter to remove the #{PATH} directory before proceeding...")
			return nil unless STDIN.getch == ?\r
			FileUtils.rm_rf(PATH)
		else break
		end
	end

	anim, str = %W(\xE2\xA0\x82 \xE2\xA0\x92 \xE2\xA0\xB2 \xE2\xA0\xB6), 'Please Wait'
	t = Thread.new { loop while str.size.times { |i| print(" \e[2K#{anim.rotate![0]} #{str[0...i]}#{str[i].swapcase}#{str[i.next..-1]}#{?..*((i += 1) % 4)}\r") || sleep(0.15) } }

	data = Net::HTTP.get(URI('https://raw.githubusercontent.com/Souravgoswami/cowspeak-root/master/latest-src/usr/bin/cowspeak'))
	t.kill

	File.write(PATH, data)
	STDOUT.puts("Downloaded #{File.basename(PATH)} to #{File.dirname(PATH)}".colourize("\n\n"))

	STDOUT.puts("Attempting to change the permission of /usr/bin/cowspeak to 755. Press Enter to Confirm.".colourize)
	return nil unless STDIN.getch == ?\r
	File.chmod(0755, PATH)
	STDOUT.puts("Changed permission to 755".colourize("\n\n"))

	STDOUT.puts("Attempting to change the owner and group of #{PATH} to root. Press Enter to Confrim.".colourize)
	return nil unless STDIN.getch == ?\r
	File.chown(0, 0, PATH)
	STDOUT.puts("Changed the owner and group to root".colourize("\n\n"))

	STDOUT.puts("Attempting to move #{PATH} to /usr/bin/ directory. Press Enter to Confirm.".colourize)
	return nil unless STDIN.getch == ?\r
	FileUtils.mv(PATH, '/usr/bin/')
	STDOUT.puts("\e[38;5;10mMoved #{PATH} to /usr/bin/\e[0m\n\n")

	STDOUT.puts("All Done!! Just run /usr/bin/cowspeak -dl to Download the data files to /usr/share/cowspeak".colourize)
end

def uninstall
	exit if In.gets(':: Do you want to remove cowspeak? (Y/n): ') == ?n
	STDOUT.puts(':: If you find any bug or for feature request go to https://github.com/Souravgoswami/cowspeak-deb/issues/new'.colourize)

	%w(/usr/bin/cowspeak /usr/share/man/man1/cowspeak.1.gz /usr/share/cowspeak/).select do |x|
		File.exist?(x).tap { |y| STDOUT.puts y ? ":: Found: #{x.dump}" : ":: Not Found: #{x.dump}" }
	end.each do |f|
		if File.directory?(f)
			return nil unless In.gets(":: Will Remove\n#{Dir.glob("#{f}/**/**").join("\n")}\nPress Enter to confirm: ").empty?
			FileUtils.rm_r(f)
			STDERR.puts("Deleted #{f}".colourize)
		elsif File.file?(f)
			return nil unless In.gets(":: Attempting to remove #{f}. Press Enter to confirm: ").empty?
			File.delete(f)
			STDERR.puts("Removed #{f}".colourize)
		end
	end.empty?.tap { |x| STDOUT.puts "Cowspeak is not installed. Nothing to do. Run `#{$PROGRAM_NAME} --install` to install cowspeak".colourize if x }
end

if ARGV.any? { |x| x =~ /\A-(-\binstall\b|\bi\b)/ }
	begin
		detect_os && install
	rescue UncaughtThrowError
		STDOUT.puts("Can't open cowspeak for write!!".colourize)
	rescue SocketError
		STDOUT.puts("An active internet connection is required to download the source code. May be you don't have an internet connection?".colourize)
	rescue OpenSSL::SSL::SSLError
		STDOUT.puts("An active internet connection is required to download the source code. There may be an internet issue?".colourize)
	rescue Errno::EACCES
		STDOUT.puts("Cannot move #{PATH} to /usr/bin/cowspeak - Access Denied. Please try this running as root?".colourize)
		STDOUT.puts("The downloaded source file is #{PATH}".colourize)
	rescue Errno::EPERM
		STDOUT.puts("Cannot change ownership and group of #{PATH} to root - Access Denied. Please try this running as root?".colourize)
		STDOUT.puts("The downloaded source file is #{PATH}".colourize)
	rescue Errno::ENOTTY
		STDOUT.puts("No TTY found for inputs. Please try running #{File.basename(__FILE__)} in a terminal".colourize)
	rescue SignalException, Interrupt, SystemExit
		STDOUT.puts
	rescue Exception => e
		Kernel.warn("An Exception Caught:\n#{e.to_s.each_line.map { |err| "\t" << err }.join }\n".colourize + ?*.*((e.to_s.length + 8)).colourize)
		Kernel.warn("Error in:\n#{e.backtrace.map { |err| "\t#{err}\n" }.join}".colourize)
	end

elsif ARGV.any? { |x| x =~ /\A-(-\buninstall\b|\bu\b)/ }
	begin
		detect_os && uninstall
	rescue Errno::EACCES
		STDOUT.puts('Cannot remove cowspeak. Permission Denied.'.colourize)
		STDOUT.puts('Try running this as root'.colourize)
	rescue SignalException, Interrupt, SystemExit
		STDOUT.puts
	rescue Exception => e
		Kernel.warn("An Exception Caught:\n#{e.to_s.each_line.map { |err| "\t#{err}" }.join }\n".colourize + ?*.*(e.to_s.length.+(8)).colourize)
		Kernel.warn "Error in:\n#{e.backtrace.map { |err| "\t#{err}\n" }.join }".colourize
	end

elsif ARGV.any? { |x| x =~ /\A-(-\blicence\b|\bl\b)/ }
	d, i, chars = false, 0, %w(| / - \\)
	Thread.new { STDOUT.print("\e[2K#{chars[(i += 1) % chars.size].colourize} #{'Downloading licence! Please wait...'.colourize}\r") || sleep(0.1) until d }

	begin
		puts Net::HTTP.get(URI('https://raw.githubusercontent.com/Souravgoswami/cowspeak/master/LICENSE')).each_line.map(&:colourize).join
	rescue Exception
		STDERR.puts "Unable to Download the licence. Perhaps try again?".colourize
	ensure
		d = true
	end

else
	help
end
