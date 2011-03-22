From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 22 Mar 2011 22:21:54 +0100
Subject: [PATCH 0/6] VG share v2
Message-ID: <cover.1300828168.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Second version of VG sharing patch.
Still rather in 'proposal' form as some part of code are not fully
finished (pool-debug code is missing, usage of posix_memalign).
If someone notices some weak points - let me know.

Patchset add support for locking and unlocking memory pool.
Such pool has volatile memory area attached.
VG sharing is made in way the only 1 user could work with such VG.
It may optionaly modify few small parts (only uin64_t is supported)
which are reverted before next reuse.

2 methods to catch writes are implemented - 
mprotect - memory consuming, and creates immediate segfault when
           expected change of pool content happens.
           But it's fast and give exact location of such writer.
           
pool_crc - simple hash crc checksum - gives notice that after multiple
           uses is not in its original state - doesn't segfault, but it's
           hard to detect such writer. And checksumming consumes some CPU.

Pool volatile area uses very simle 'exception pair values' - if there
would be a lot of them - more efficent code would be needed.
Also support for storing more differnet types would add some complexity.
Both these extension do not seem to be needed with current code.

Patch set - as is - passes valgrind tests.


Zdenek Kabelac (6):
  Pool locking code
  Code move vg_mark_partial up in stack
  Share VG multiple times
  Use dm_pool_set_uint64
  lv_postorder using dm_pool_set_uint64
  lv_postorder unlock and lock

 lib/activate/activate.c       |    5 +-
 lib/cache/lvmcache.c          |  111 ++++++++++++++++++-
 lib/cache/lvmcache.h          |    3 +
 lib/metadata/lv.h             |    5 +-
 lib/metadata/metadata.c       |   58 ++++++++--
 lib/metadata/snapshot_manip.c |   15 ++-
 lib/metadata/vg.h             |    2 +
 libdm/libdevmapper.h          |   11 ++
 libdm/mm/pool-debug.c         |    9 ++
 libdm/mm/pool-fast.c          |   74 ++++++++++++-
 libdm/mm/pool.c               |  246 ++++++++++++++++++++++++++++++++++++++++-
 11 files changed, 517 insertions(+), 22 deletions(-)

-- 
1.7.4.1


