From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 22 Mar 2011 22:34:09 +0100
Subject: [PATCH 0/8] Misc cleanups and optimalisations
Message-ID: <cover.1300829383.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Shorter patchset to address few different issue  - combined into
one patchset -  each patch is however separate and unrelated to others.

Zdenek Kabelac (8):
  Optimise write of error to _lvm_errmsg
  Fix sending random content in the cluster message
  Proposal - char alignment on word
  Use created hash tables for quick check of LV, PV.
  Simplify boundary checks
  Use id_equal instead of strncmp()
  Proposal - avoid parsing same data
  Few more files filtered from memory locking

 lib/cache/lvmcache.c          |   17 +++++--
 lib/cache/lvmcache.h          |    1 +
 lib/locking/cluster_locking.c |    6 ++-
 lib/log/log.c                 |   31 ++++++++++---
 lib/metadata/metadata.c       |   98 +++++++++++++++++++----------------------
 lib/mm/memlock.c              |    2 +
 libdm/mm/pool-fast.c          |    6 +-
 libdm/mm/pool.c               |    4 +-
 8 files changed, 94 insertions(+), 71 deletions(-)

-- 
1.7.4.1


