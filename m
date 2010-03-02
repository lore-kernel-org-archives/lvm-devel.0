From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue,  2 Mar 2010 13:07:18 +0100
Subject: [PATCH 0/9] configure update
Message-ID: <cover.1267529065.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patchset tries to mainly address linking problems.
First few patches are rather cosmetic cleanups.

Interestings patches starts with: Readline linking update.

With this patchset libpthread and libselinux are linked only
to object files which really needs this library.
Tested it on Fedora & Debian distribution.

Zdenek Kabelac (9):
  Help display --disable-fsadm
  Fix autoconf WARNING:
  For Makefile vars use $() instead of ${}
  Move include before  DEFS+=
  Readline linking update
  Pthread linking change
  Remove -rdynamic
  SELinux configure update
  misc/configure.in  modification

 configure.in                                  |   91 +++++++++++--------------
 daemons/clvmd/Makefile.in                     |    4 +-
 daemons/dmeventd/Makefile.in                  |    4 +-
 daemons/dmeventd/plugins/lvm2/Makefile.in     |    4 +-
 daemons/dmeventd/plugins/mirror/Makefile.in   |    6 +-
 daemons/dmeventd/plugins/snapshot/Makefile.in |    6 +-
 lib/misc/configure.h.in                       |    3 -
 libdm/Makefile.in                             |    4 +-
 make.tmpl.in                                  |    1 +
 man/Makefile.in                               |    4 +-
 test/api/Makefile.in                          |    2 +-
 tools/Makefile.in                             |   13 ++--
 12 files changed, 65 insertions(+), 77 deletions(-)


