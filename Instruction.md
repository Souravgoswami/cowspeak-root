### This package contains all the files required for root installation of cowspeak.

#### Making Linux packages:
+ Debian:
	Debian packages are built automatically from the latest-src directory.
	When commiting a code, please modify the contents of latest-src/

+ Arch Linux:
	The packages are built from the tarballs directory.
	Tarballs are built from the latest-src directory.

	To create the package:
	1. Follow the tarball instruction first (below), because AUR package fetches the tarball.
	2. Make a new tarball based if you have committed changes.
	3. Push that change.
	4. Fetch changes.

	When commiting a code, please modify the contents of latest-src/

+ Tarball Instruction:
	To create tarballs, you are requested to:
	1. Go to the cowspeak-root directory.
	2. Make sure you have the version_info.rb file
	3. Run:

	```
	generate_tarball.sh
	```

	Make sure you have the version_info.rb file
