-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

Format: 3.0 (quilt)
Source: git
Binary: git, git-man, git-core, git-doc, git-arch, git-cvs, git-svn, git-mediawiki, git-email, git-daemon-run, git-daemon-sysvinit, git-gui, gitk, git-el, gitweb, git-all
Architecture: any all
Version: 1:2.7.4-0ubuntu1.9
Maintainer: Ubuntu Developers <ubuntu-devel-discuss@lists.ubuntu.com>
Uploaders: Jonathan Nieder <jrnieder@gmail.com>
Homepage: https://git-scm.com/
Standards-Version: 3.9.6.0
Vcs-Browser: http://repo.or.cz/w/git/debian.git/
Vcs-Git: https://repo.or.cz/r/git/debian.git/
Build-Depends: libz-dev, libpcre3-dev, gettext, libcurl4-gnutls-dev, libexpat1-dev, subversion, libsvn-perl, libyaml-perl, tcl, libhttp-date-perl | libtime-modules-perl, python, cvs, cvsps, libdbd-sqlite3-perl, unzip, libio-pty-perl, dpkg-dev (>= 1.16.2~)
Build-Depends-Indep: asciidoc, xmlto, docbook-xsl
Package-List:
 git deb vcs optional arch=any
 git-all deb vcs optional arch=all
 git-arch deb vcs optional arch=all
 git-core deb vcs optional arch=all
 git-cvs deb vcs optional arch=all
 git-daemon-run deb vcs optional arch=all
 git-daemon-sysvinit deb vcs extra arch=all
 git-doc deb doc optional arch=all
 git-el deb vcs optional arch=all
 git-email deb vcs optional arch=all
 git-gui deb vcs optional arch=all
 git-man deb doc optional arch=all
 git-mediawiki deb vcs optional arch=all
 git-svn deb vcs optional arch=all
 gitk deb vcs optional arch=all
 gitweb deb vcs optional arch=all
Checksums-Sha1:
 a4198b668ec85d569fc088072c49e1d4172e6d66 3909636 git_2.7.4.orig.tar.xz
 393ffaac0d97cb2c7d0ceda6b3cba66f89f33062 572052 git_2.7.4-0ubuntu1.9.debian.tar.xz
Checksums-Sha256:
 dee574defbe05ec7356a0842ddbda51315926f2fa7e39c2539f2c3dcc52e457b 3909636 git_2.7.4.orig.tar.xz
 2ab39ce8a9d1d94a549be4d086e6b59ae2c4201bc022dd1368a38eebe98cdf24 572052 git_2.7.4-0ubuntu1.9.debian.tar.xz
Files:
 b0219fcb6d73104361f4fbdba3741d00 3909636 git_2.7.4.orig.tar.xz
 1a74f9679cb5aab3ca6b63da6f6d284b 572052 git_2.7.4-0ubuntu1.9.debian.tar.xz
Original-Maintainer: Gerrit Pape <pape@smarden.org>

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEEUMSg3c8x5FLOsZtRZWnYVadEvpMFAl6eAFQACgkQZWnYVadE
vpPT/BAAjThL2O12E3JgZQzJpUFiWP51rMUhLgias6twOin63aXtccnWt3yvQo0V
gTocWbaNjbJ9FuKtsBm2KlbU2tm0glZfUXCCBBWCCGlZ2fIHENdXwJfpiP/Dy6zr
SejjMMd24w4ELNEF37CCAIvTN2aausWzVA6Sipxr2TrKiCMuj2huH0b+nlppHdP0
w/s7eY+y02NHggvEAsJ0ladAEYzRqpybG3mLlFjY2QHOQtWDiyTIMN2q4VhbkgNt
kegdgWvoW9b6sd/sadBkyaB8FZzW2bs0esgZxJzXZvN/hEuqC/hvWzX8DG+eJJSc
kMAO45ULMtF8ST0AC3ZXlO2D+ItN7p2wIBHYi1PdabWIDwfqPHmlwpNwBq516HdR
YSeQCkgMh2p1Hoq4p+xGHmaouX3tDOhi3uaofumipZJGixoG5eX30ntbNJ3MQw/X
5l2+n6vOSrGMxAUwkS/dQMcRDXjRuUhLdlt5k4ajyE+5Tpo7pG0GRzW30kw9EFTE
EtB7zZ1xuy8P0er7n503PLB3ZsKoSZY4OIGftQmWXH28j4lPQYyZuKtFWaM0X6mw
KsqQtfZKYvx/yTPu7tVIfEizzVMTjs6OmccpXZV3ntaggkcwmjs+SOV6CQ+c+D85
7BqwakQusnfKiZB0+liL/43YqFjmFt8LF8OEinEUQAR5Dj9es4I=
=+ZMA
-----END PGP SIGNATURE-----
