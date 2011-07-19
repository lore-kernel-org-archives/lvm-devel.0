From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 19 Jul 2011 15:43:51 +0200
Subject: [PATCH 0/7] ShareVG
Message-ID: <cover.1311082436.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Another incarnation of sharing VG structures.

This version changes  free_vg() to release_vg() to avoid term confusion
(free should be free).

Reference counting moved to VG structure - though I'm not 100% conviced
it's the best choice here - as every counter is touching pool - this makes
a bit more problematic following memory pool locking (keeping the
reference within vginfo referenced from VG would make it simplier).

Some name corrections happend with the pool locking debug.

Option verify_vg_crc was added to make crc runtime configurable for debug.

As a bit unrelated patch is the first one where INCONSISTENG_VG.
(It's part of this patchset as it's made this patchset simplier
there is no need for dropping VG from cache now)
This patchset also needs inspection as there is small change in code
behaviour which might be seen as a bugfix?


Zdenek Kabelac (7):
  Remove INCONSISTENG_VG flag
  Change free_vg to release_vg
  Add cache_vg
  Pool locking code
  Lock memory for shared VG
  Add verify_vg_crc
  Spaces

 WHATS_NEW                        |    2 +
 daemons/clvmd/lvm-functions.c    |    2 +-
 doc/example.conf.in              |    5 ++
 lib/activate/activate.c          |   14 ++--
 lib/cache/lvmcache.c             |   29 ++++++++-
 lib/cache/lvmcache.h             |    2 +
 lib/commands/toolcontext.c       |    2 +
 lib/format_pool/format_pool.c    |    2 +-
 lib/format_text/archive.c        |    2 +-
 lib/format_text/archiver.c       |    6 +-
 lib/format_text/format-text.c    |    4 +-
 lib/format_text/import_vsn1.c    |    2 +-
 lib/locking/locking.h            |    4 +-
 lib/metadata/metadata-exported.h |    6 --
 lib/metadata/metadata.c          |  115 +++++++++++++++++++-------------------
 lib/metadata/metadata.h          |    1 -
 lib/metadata/replicator_manip.c  |    6 +-
 lib/metadata/vg.c                |   62 ++++++++++++++++++++
 lib/metadata/vg.h                |   12 ++++
 lib/misc/lvm-globals.c           |   11 ++++
 lib/misc/lvm-globals.h           |    2 +
 libdm/libdevmapper.h             |    9 +++
 libdm/mm/pool-debug.c            |   30 ++++++++++
 libdm/mm/pool-fast.c             |   66 +++++++++++++++++++++-
 libdm/mm/pool.c                  |  106 ++++++++++++++++++++++++++++++++++-
 liblvm/lvm_vg.c                  |    8 +-
 make.tmpl.in                     |    2 +
 test/lib/aux.sh                  |    1 +
 tools/lvconvert.c                |   10 ++--
 tools/lvcreate.c                 |    4 +-
 tools/lvrename.c                 |    4 +-
 tools/lvresize.c                 |    4 +-
 tools/polldaemon.c               |   10 ++--
 tools/pvchange.c                 |    8 +-
 tools/pvcreate.c                 |    2 +-
 tools/pvdisplay.c                |    4 +-
 tools/pvmove.c                   |    4 +-
 tools/pvresize.c                 |    4 +-
 tools/reporter.c                 |    4 +-
 tools/toollib.c                  |   10 ++--
 tools/vgcreate.c                 |    6 +-
 tools/vgextend.c                 |    6 +-
 tools/vgmerge.c                  |   12 ++--
 tools/vgreduce.c                 |    6 +-
 tools/vgrename.c                 |   10 ++--
 tools/vgsplit.c                  |   18 +++---
 46 files changed, 480 insertions(+), 159 deletions(-)

-- 
1.7.6


