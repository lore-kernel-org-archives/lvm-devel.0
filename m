From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  7 Apr 2010 14:28:34 +0200
Subject: [PATCH 0/3] Makefile updates
Message-ID: <cover.1270641130.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Updated patch, which fixes some problems using buildir and
taking created files from builddir.
Using INSTALL_PROGRAM and INSTALL_DATA commands.


Zdenek Kabelac (3):
  Do not use VPATH
  INSTALL rules updates
  Update intall rules for udev.

 Makefile.in                                   |    1 -
 configure.in                                  |   16 +++++----
 daemons/Makefile.in                           |    1 -
 daemons/clvmd/Makefile.in                     |    4 +--
 daemons/cmirrord/Makefile.in                  |    8 ++---
 daemons/dmeventd/Makefile.in                  |   41 ++++++----------------
 daemons/dmeventd/plugins/Makefile.in          |    1 -
 daemons/dmeventd/plugins/lvm2/Makefile.in     |   15 +++-----
 daemons/dmeventd/plugins/mirror/Makefile.in   |   13 ++-----
 daemons/dmeventd/plugins/snapshot/Makefile.in |   13 ++-----
 doc/Makefile.in                               |    8 ++---
 lib/Makefile.in                               |    3 +-
 lib/format1/Makefile.in                       |   12 +++----
 lib/format_pool/Makefile.in                   |   15 +++-----
 lib/locking/Makefile.in                       |   14 +++-----
 lib/mirror/Makefile.in                        |   13 +++----
 lib/snapshot/Makefile.in                      |   14 +++-----
 libdm/Makefile.in                             |   47 ++++++++-----------------
 liblvm/Makefile.in                            |   18 +++------
 make.tmpl.in                                  |   26 ++++++++++---
 man/Makefile.in                               |   36 +++++++------------
 po/Makefile.in                                |    5 +--
 scripts/Makefile.in                           |   12 ++----
 test/Makefile.in                              |    2 +-
 test/api/Makefile.in                          |    1 -
 tools/Makefile.in                             |   41 ++++++++-------------
 udev/Makefile.in                              |   28 +++++----------
 27 files changed, 150 insertions(+), 258 deletions(-)


