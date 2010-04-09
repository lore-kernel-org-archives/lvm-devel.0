From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  9 Apr 2010 17:42:52 +0200
Subject: [PATCH 0/3] Makefile updates v3
Message-ID: <cover.1270827575.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Updated patch, which fixes some problems using buildir and
taking created files from builddir.
Using INSTALL_PROGRAM and INSTALL_DATA commands.

Patch was tested on many combinations of different configure
parameters without noticing any problems.

Zdenek Kabelac (3):
  Do not use VPATH
  INSTALL rules updates
  Update intall rules for udev.

 Makefile.in                                   |    1 -
 configure.in                                  |   16 ++++---
 daemons/Makefile.in                           |    1 -
 daemons/clvmd/Makefile.in                     |    4 +-
 daemons/cmirrord/Makefile.in                  |    8 +--
 daemons/dmeventd/Makefile.in                  |   48 ++++++-----------------
 daemons/dmeventd/plugins/Makefile.in          |    1 -
 daemons/dmeventd/plugins/lvm2/Makefile.in     |   12 +-----
 daemons/dmeventd/plugins/mirror/Makefile.in   |   12 +-----
 daemons/dmeventd/plugins/snapshot/Makefile.in |   12 +-----
 doc/Makefile.in                               |   10 ++---
 lib/Makefile.in                               |    3 +-
 lib/format1/Makefile.in                       |   11 +----
 lib/format_pool/Makefile.in                   |   13 +-----
 lib/locking/Makefile.in                       |   12 +----
 lib/mirror/Makefile.in                        |   11 +----
 lib/snapshot/Makefile.in                      |   12 +----
 libdm/Makefile.in                             |   52 +++++++-----------------
 liblvm/Makefile.in                            |   45 +++++----------------
 make.tmpl.in                                  |   53 +++++++++++++++++++------
 man/Makefile.in                               |   52 +++++++++---------------
 po/Makefile.in                                |    5 +-
 scripts/Makefile.in                           |   21 +++++-----
 test/Makefile.in                              |    2 +-
 test/api/Makefile.in                          |    1 -
 tools/Makefile.in                             |   50 +++++++++++-------------
 udev/Makefile.in                              |   28 ++++---------
 27 files changed, 183 insertions(+), 313 deletions(-)


