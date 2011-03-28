From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 28 Mar 2011 13:59:11 +0200
Subject: [PATCH 0/6] Cleanup
Message-ID: <cover.1301313391.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Nice-to-have patch set.
Constains some warning fixes for various compilation builds which I'm
using on my machine (so not covering all configure options)
Should be easy to overview.

Zdenek Kabelac (6):
  Unreleased pool is INTERNAL_ERROR
  Remove double  brackets
  Add void and few more warning
  Add attribute printf
  Fix signes warnings
  const fixes

 daemons/clvmd/clvmd.c         |   11 ++++++-----
 daemons/clvmd/lvm-functions.c |    8 ++++----
 daemons/dmeventd/dmeventd.c   |    4 ++--
 lib/activate/dev_manager.c    |    2 +-
 lib/device/dev-io.c           |    2 +-
 lib/metadata/lv_manip.c       |    6 +++---
 lib/metadata/pv_manip.c       |    2 +-
 lib/misc/lvm-globals.c        |   24 ++++++++++++------------
 libdm/libdm-common.c          |    7 +++++--
 libdm/libdm-deptree.c         |    4 ++--
 libdm/mm/pool.c               |    2 +-
 tools/dmsetup.c               |    9 +++++----
 tools/pvmove.c                |    4 ++--
 tools/vgreduce.c              |    4 ++--
 14 files changed, 47 insertions(+), 42 deletions(-)

-- 
1.7.4.1


