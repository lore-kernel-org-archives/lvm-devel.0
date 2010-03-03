From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  3 Mar 2010 21:42:46 +0100
Subject: [PATCH 00/15] configure update v2
Message-ID: <cover.1267648294.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patchset tries to mainly address linking problems.
First few patches are rather cosmetic cleanups.

Interesting patches starts with: Readline linking update.

With this patchset libpthread, libselinux, libdl, libudev libraries
are linked only to objects which really use them.
Tested it on Fedora, Debian and RHEL4 distribution.

configure diff is not part of patch (~0.5MB)

Zdenek Kabelac (15):
  Update AC_PREREQ version to 2.61
  Help display --disable-fsadm
  Fix autoconf WARNING:
  Fix usage of $(top_builddir)
  Replace just one CFLOW_CMD
  Use $() instead of ${} for Makefile variables
  Move include before  DEFS+=
  Introduce LVMINTERNAL_LIBS
  Readline linking update
  Pthread linking change
  Remove -rdynamic
  SELinux configure update
  Move "-ldl" from LIBS to DL_LIBS
  Introduce UDEV_LIBS
  Update generated misc/configure.in

 configure.in                                  |  134 ++++++++++++-------------
 daemons/Makefile.in                           |    2 +-
 daemons/clvmd/Makefile.in                     |    5 +-
 daemons/cmirrord/Makefile.in                  |    2 +-
 daemons/dmeventd/Makefile.in                  |    9 +-
 daemons/dmeventd/plugins/Makefile.in          |    2 +-
 daemons/dmeventd/plugins/lvm2/Makefile.in     |    4 +-
 daemons/dmeventd/plugins/mirror/Makefile.in   |    6 +-
 daemons/dmeventd/plugins/snapshot/Makefile.in |    6 +-
 doc/Makefile.in                               |    2 +-
 lib/Makefile.in                               |    4 +-
 lib/format1/Makefile.in                       |    2 +-
 lib/format_pool/Makefile.in                   |    2 +-
 lib/locking/Makefile.in                       |    2 +-
 lib/mirror/Makefile.in                        |    2 +-
 lib/misc/configure.h.in                       |    3 -
 lib/snapshot/Makefile.in                      |    2 +-
 libdm/Makefile.in                             |    4 +-
 liblvm/Makefile.in                            |    4 +-
 make.tmpl.in                                  |   10 ++
 man/Makefile.in                               |    6 +-
 old-tests/device/Makefile.in                  |    4 +-
 old-tests/filters/Makefile.in                 |    6 +-
 old-tests/format1/Makefile.in                 |   22 ++--
 old-tests/mm/Makefile.in                      |    6 +-
 old-tests/regex/Makefile.in                   |   10 +-
 po/Makefile.in                                |    2 +-
 scripts/Makefile.in                           |    2 +-
 test/api/Makefile.in                          |    2 +-
 tools/Makefile.in                             |   31 +++---
 udev/Makefile.in                              |    2 +-
 31 files changed, 149 insertions(+), 151 deletions(-)


