From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 22 Sep 2011 11:52:47 +0200
Subject: [PATCH 0/3] Clvmd -E fixes
Message-ID: <cover.1316684951.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patchset fixed restart of clvmd with -E option.

1st. Adds support for easier restart of clvmd
     (i.e.  -Isinglenode is preserved).

2nd. Bug fixes support of -E arg.

3rd. Allows to build test suite script for checking clvmd restart.
     (Any better idea here ?)

Zdenek Kabelac (3):
  Add named cluster_ops
  CLVMD bugfix support arg -E
  CLVMD support for CLVMD_BINARY and LVM_BINARY

 configure.in                     |    9 ++++--
 daemons/clvmd/clvmd-cman.c       |    1 +
 daemons/clvmd/clvmd-command.c    |   15 ++++-----
 daemons/clvmd/clvmd-comms.h      |    3 +-
 daemons/clvmd/clvmd-corosync.c   |    1 +
 daemons/clvmd/clvmd-openais.c    |    1 +
 daemons/clvmd/clvmd-singlenode.c |    1 +
 daemons/clvmd/clvmd.c            |   19 ++++++++++--
 daemons/clvmd/lvm-functions.c    |   61 ++++++++++++++-----------------------
 daemons/clvmd/lvm-functions.h    |    2 +-
 man/Makefile.in                  |    2 +-
 man/clvmd.8.in                   |   14 +++++++++
 12 files changed, 74 insertions(+), 55 deletions(-)

-- 
1.7.6.2


