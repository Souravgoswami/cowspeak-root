#!/usr/bin/ruby -w
%w(fileutils open3).each(&method(:require))

# Debian package creation directory
DEB = File.join(__dir__, 'Debian-Build')

# Source codes and assets directory
SRC = File.join(__dir__, 'latest-src')

# Debian store directory
DEB_STORE = File.join(__dir__, 'Debian')

# Executable
EXECUTABLE = 'dpkg-deb'

# Target files
usr = File.join(SRC, 'usr')
control = File.join(__dir__, 'control')
bin, share = File.join(usr, 'bin'), File.join(usr, 'share')

# Destinations
# Debian Control file
d = File.join(DEB, 'DEBIAN')
dc = File.join(d, 'control')

usr_d = File.join(DEB, 'usr')
bin_d = File.join(usr, 'bin')
share_d = File.join(usr, 'share')

puts <<~EOF
	\e[1;38;2;255;80;100mThis program is intended to create a .deb package for cowspeak.\n
	It will directly exit if the #{SRC} is not valid...\n
	It will also clear out the #{DEB} directory. Please be careful.\e[0m
EOF

# Delete directories under DEB, start fresh
FileUtils.rm_rf(DEB)

# Permission check
abort(
	"\e[38;2;255;50;50mThis program requires \e[1mroot\e[0;38;2;255;50;50m privileges. "\
	"Please make sure you are the \e[1mroot\e[0;38;2;255;50;50m user."
) unless Process.uid == 0

# Executable check
unless ENV['PATH'].split(File::PATH_SEPARATOR).any? { |x| Dir.children(x).include?(EXECUTABLE) }
	puts "\e[1;38;2;255;50;50mCan't find executable #{EXECUTABLE}. Leaving everything untouched!\e[0m"
	exit! 2
end

# Check directories exists or not
[DEB, DEB_STORE, d, usr, bin, share, usr_d, bin_d, share_d, d].each do |x|
	if File.file?(x)
		print "#{x} is a file. Should I remove it to get this script working? (y/N): "
		abort unless STDIN.gets.tap(&:strip!) == ?y
		puts "Continuing!..."
		File.delete(x)
	end

	unless Dir.exist?(x)
		Dir.mkdir(x)
	end
end

# Control file check
unless File.readable?(control) && File.file?(control)
	puts "The control file doesn't exist.\nI am going to create it now! Please edit the #{control} after the operation"

	IO.write(control, <<~EOF.tap(&:strip!) << ?\n
		Package: cowspeak
		Version: 2
		Section: misc
		Priority: optional
		Architecture: all
		Depends: ruby
		Maintainer: Sourav Goswami <souravgoswami@protonmail.com>
		Description: Display an animal with a random quote or your own text.
	EOF
	)
end

Dir.glob("#{DEB}/**/*").each { |x| File.chmod(0644, x) if File.file?(x) }

FileUtils.cp_r(usr, File.join(DEB))
File.chmod(0755, usr_d)
FileUtils.chmod_R(0755, bin_d)
FileUtils.cp(control, dc)

sleep 1

chmod_755 = <<~EOF.split(?\n)
	#{usr_d}, bin
	#{d}
	#{usr_d}, share
	#{usr_d}, share, cowspeak
	#{usr_d}, share, cowspeak, arts
	#{usr_d}, share, doc
	#{usr_d}, share, doc, cowspeak
	#{usr_d}, share, man
	#{usr_d}, share, man, man1
	#{usr_d}, bin, cowspeak
EOF

chmod_755.each { |x| File.chmod(0755, File.join(x.split(?,).each(&:strip!))) }

FileUtils.chmod_R(0644, File.join(dc))
FileUtils.chmod_R(0644, File.join(usr_d, 'share', 'cowspeak', 'fortunes.data'))
Dir.glob(File.join(usr_d, 'share', 'cowspeak', 'arts', '*')).each { |x| File.chmod(0644, x) }
File.chmod(0644, File.join(usr_d, 'share', 'man', 'man1', 'cowspeak.1.gz'))
File.chmod(0644, File.join(usr_d, 'share', 'doc', 'cowspeak', 'copyright'))

version = IO.readlines(File.join(usr_d, 'bin', 'cowspeak'))
	.find { |x| x.start_with?(/VERSION\s.*=\s.*.+/) }
	.to_s.strip[/([1-9]\d*|0)(\.\d+)|(\b\d)/]

control_version = IO.readlines(control)
	.find { |x| x.start_with?(/Version:\s.*.+/) }
	.to_s.strip[/([1-9]\d*|0)(\.\d+)|(\b\d)/]

unless version == control_version
	puts "\e[1;38;2;255;50;50mProgram version and control version mismatch #{version} != #{control_version}\e[0m"
	abort("\e[1;38;2;255;150;50mExiting!\e[0m")
end

sleep 1
i = 0
out = "cowspeak-v#{version}"
output = "#{__dir__}/" + out + '.deb'
output = "#{__dir__}/#{out}-#{i += 1}.deb" while File.exist?(output)
FileUtils.chown_R('root', 'root', DEB)

Open3.popen2e(p %Q(#{EXECUTABLE} --build #{DEB} "#{output}")) { |x, y| puts y.read }
sleep 1

i = 0
output_2 = "#{DEB_STORE}/#{out}.deb"
output_2 = "#{DEB_STORE}/#{out}-#{i += 1}.deb" while(File.exist?(File.join(output_2)))
FileUtils.mv(output, output_2)
FileUtils.rm_rf(DEB)
