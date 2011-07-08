From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  8 Jul 2011 17:52:22 +0200
Subject: [PATCH 0/3] Reuse VG
Message-ID: <cover.1310140154.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Reuse VG structure multiple times.
With separate debug patch.

Zdenek Kabelac (3):
  Share VG multiple times
  Pool locking code
  Use dm_pool locking

 lib/cache/lvmcache.c    |   74 ++++++++++++++++++++++++++++++++-
 lib/cache/lvmcache.h    |    5 ++
 lib/metadata/metadata.c |   42 ++++++++++++++++++-
 lib/metadata/vg.h       |    2 +
 libdm/libdevmapper.h    |    7 +++
 libdm/mm/pool-debug.c   |   27 ++++++++++++
 libdm/mm/pool-fast.c    |   66 ++++++++++++++++++++++++++++-
 libdm/mm/pool.c         |  106 ++++++++++++++++++++++++++++++++++++++++++++++-
 make.tmpl.in            |    2 +
 9 files changed, 325 insertions(+), 6 deletions(-)

-- 
1.7.6


