From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  7 May 2010 16:14:47 +0200
Subject: [PATCH 0/9] Makefile and Require cleanups
Message-ID: <cover.1273241256.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patchset tries to address few things:

it should be fixing Gentoo linkage bug
https://bugs.gentoo.org/show_bug.cgi?id=318513
But properly linking needed librarie to .so files.
Another part is cleanup Require.private in .pc file.
2 patches are touching pthread cleanups.
One patch cleans the 'extra' cat command call from Makefile.
And the last patch introduces pkgconfigdir so user could easily
overwrite his favourite locate of .pc installation dir.

Zdenek Kabelac (9):
  Not using pthread library functions here
  Link liblvm2cmd.so with their depending libraries
  Fix linking libdevmapper-event.so
  Plugins do not use pthread or lvm2cmd directly
  Skip unneeded 'cat' command
  Use Require.private: field
  Add UDEV_PC and SELINUX_PC subst variables
  Requires.private: update
  Use pkgconfigdir for placement of .pc files

 configure                                          |    8 +++++++-
 configure.in                                       |    8 +++++++-
 daemons/dmeventd/Makefile.in                       |    5 +++--
 daemons/dmeventd/libdevmapper-event.pc.in          |    3 +--
 daemons/dmeventd/plugins/mirror/Makefile.in        |    2 +-
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c  |    2 --
 daemons/dmeventd/plugins/snapshot/Makefile.in      |    2 +-
 .../dmeventd/plugins/snapshot/dmeventd_snapshot.c  |    3 +--
 libdm/Makefile.in                                  |    2 +-
 libdm/libdevmapper.pc.in                           |    2 +-
 liblvm/Makefile.in                                 |    2 +-
 liblvm/liblvm2app.pc.in                            |    2 +-
 make.tmpl.in                                       |   15 ++++-----------
 tools/Makefile.in                                  |    3 +++
 14 files changed, 32 insertions(+), 27 deletions(-)


