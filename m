From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  3 Jun 2011 21:13:18 +0200
Subject: [PATCH 00/11] Pool locking
Message-ID: <cover.1307127169.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patchset tries to optimize creation of VG structure from config_tree.
When the config_tree is unchange and we know VG structure is not modified
we could reuse this structure multiple times.

Patchset currently has few limitation and is not the optimal solution,
but it present relatively very small set of changes with good improvements.

Patchset tries to avoid modification of VG structure for read-only operations.
And then introducion pool locking - debugging uses mprotect to generate
segfault in the moment of memory write access.
Normal code currently uses simple CRC checksum - could be later disabled,
once we are sure there could be no write operation.

Few things are left for the future:
vg_mark_partial is in wrong layer currentl.
clvmd would greatly benefit from 'smarter' cache flushing - VG structure
could be the reused more extensively.

Patch is splited in way to allow easier review.

Zdenek Kabelac (11):
  Introduce laopts structure
  Add laopts
  Replace ACTIVATE
  Replace MERGING in activation
  FIXME
  FIXME - remove test for status flag
  Remove ACTIVATE_EXCL appearance from the code
  Code move vg_mark_partial up in stack
  Pool locking code
  Share VG multiple times
  lv_postorder unlock and lock

 lib/activate/activate.c          |  114 ++++++++++++++++++++----------------
 lib/activate/activate.h          |   10 +++-
 lib/activate/dev_manager.c       |  120 +++++++++++++++++++++-----------------
 lib/activate/dev_manager.h       |   10 ++-
 lib/cache/lvmcache.c             |   73 +++++++++++++++++++++++-
 lib/cache/lvmcache.h             |    5 ++
 lib/error/errseg.c               |    1 +
 lib/format_text/flags.c          |    1 -
 lib/format_text/import.c         |    6 ++
 lib/metadata/metadata-exported.h |    1 -
 lib/metadata/metadata.c          |   45 ++++++++++++--
 lib/metadata/metadata.h          |    1 -
 lib/metadata/mirror.c            |    4 +-
 lib/metadata/segtype.h           |   13 +++--
 lib/metadata/vg.h                |    2 +
 lib/mirror/mirrored.c            |   15 +++--
 lib/replicator/replicator.c      |    2 +
 lib/snapshot/snapshot.c          |    5 +-
 lib/striped/striped.c            |    1 +
 lib/unknown/unknown.c            |    1 +
 lib/zero/zero.c                  |    1 +
 libdm/libdevmapper.h             |    7 ++
 libdm/mm/pool-debug.c            |   27 +++++++++
 libdm/mm/pool-fast.c             |   70 +++++++++++++++++++++-
 libdm/mm/pool.c                  |  106 +++++++++++++++++++++++++++++++++-
 make.tmpl.in                     |    2 +
 26 files changed, 503 insertions(+), 140 deletions(-)

-- 
1.7.5.2


