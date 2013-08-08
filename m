From: Ian Stakenvicius <axs@gentoo.org>
Date: Thu, 08 Aug 2013 11:57:40 -0400
Subject: [PATCH] build-system fixes for --enable-static
Message-ID: <5203BFF4.2030005@gentoo.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA256

The following patch fixes missing LDFLAGS from dependent packages when
building lvm2 statically.  It also adjusts the build system for
libselinux CFLAGS/LIBS, to attempt to grab them from pkg-config first.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iF4EAREIAAYFAlIDv/QACgkQ2ugaI38ACPDQmAEAmiiJOY3ujUXTapGaO9y7P4jZ
u5303fR4Bz7wLqBlP4oA/0OIuRJQzmecUtwH3ih9D+iMNbVxZR0sBm4Ww/rasmaI
=dJfi
-----END PGP SIGNATURE-----
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-2.02.99-static.patch
Type: text/x-patch
Size: 4423 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20130808/b3c17014/attachment.bin>
