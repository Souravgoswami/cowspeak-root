### This package contains all the files required for root installation of cowspeak.

#### Making Linux packages:
+ Debian:
	Debian packages are built automatically from the latest-src directory.
	When commiting a code, please modify the contents of latest-src/

+ Arch Linux:
	The packages are built from the tarballs directory.
	Tarballs are built from the latest-src directory.

	To create the package:
	1. Follow the tarball instruction first (below).
	2. Modify PKGBUILD and put the URL for new tarball (from github).
	3. Run `makepkg -g` and put the md5sum in `md5sums`.
	4. Run `makepkg` again to generate tarball.
	5. Arch package is ready. Install that with `pacman -U ...`

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
