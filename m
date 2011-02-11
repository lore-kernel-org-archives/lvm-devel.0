From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 11 Feb 2011 11:30:46 +0100
Subject: [PATCH 00/16] Misc patches
Message-ID: <cover.1297419991.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Mixture of patches - should be easy for overview:

Hash needs decisions - I'd would vote for simple J.Belkins
(Version3 seems too complex for our use case)

Do we still want to support build without DEVMAPPER_SUPPORT?
(patch is fixing build in this case - but maybe we should drop
this completely?)

Adding few missing stack traces.

Hiding some unused variables in comments (keeping it in sources).

Zdenek Kabelac (16):
  Align orphan strings
  Perf: speed up hash tables
  Perf: New HASH function
  Perf: optimize _eat_space and _get_token
  Remove fs_unlock after failed suspend
  Fix !DEVMAPPER_SUPPORT build
  Void* arithmetic replaced with char*
  API change - support more const arg
  Use cleaner const *pointer
  Const fixing
  const - static merge to const patch
  Add missing stacks to toollib.c
  Add missing stack traces for polldaemon
  Add debug message for open_count failure
  Remove dead assignment of lock_flags
  Remove dead assignment in vgconvert_single

 daemons/clvmd/clvmd-command.c    |    3 +-
 daemons/clvmd/clvmd.c            |    4 +-
 daemons/clvmd/clvmd.h            |    2 +-
 lib/activate/activate.c          |   40 +++++++--
 lib/activate/activate.h          |    2 +-
 lib/config/config.c              |   36 ++++----
 lib/filters/filter-regex.c       |    2 +-
 lib/format1/format1.c            |   10 ++-
 lib/format1/lvm1-label.c         |    9 ++-
 lib/format_pool/format_pool.c    |    4 +-
 lib/format_text/format-text.c    |   16 +++-
 lib/format_text/text_label.c     |    9 +-
 lib/metadata/lv.h                |    2 +-
 lib/metadata/lv_manip.c          |    3 +-
 lib/metadata/metadata-exported.h |    8 +-
 lib/metadata/metadata.c          |   27 +++--
 lib/metadata/mirror.c            |   18 ++--
 lib/mirror/mirrored.c            |    2 +
 lib/report/properties.c          |    3 +-
 lib/report/report.c              |   14 +--
 lib/snapshot/snapshot.c          |    2 +
 lib/uuid/uuid.c                  |    2 +-
 libdm/datastruct/hash.c          |  189 +++++++++++++++++++++++++++++++------
 libdm/libdevmapper.h             |    8 +-
 libdm/libdm-deptree.c            |    5 +-
 libdm/libdm-report.c             |    2 +-
 liblvm/lvm_vg.c                  |    4 +-
 tools/lvcreate.c                 |    2 +-
 tools/polldaemon.c               |    4 +-
 tools/reporter.c                 |    4 +-
 tools/toollib.c                  |   27 ++++--
 tools/toollib.h                  |    4 +-
 tools/vgcfgrestore.c             |    2 +-
 tools/vgconvert.c                |    5 +-
 tools/vgcreate.c                 |    2 +-
 tools/vgextend.c                 |    4 +-
 tools/vgmerge.c                  |    2 +-
 tools/vgreduce.c                 |    2 +-
 tools/vgrename.c                 |    2 +-
 tools/vgsplit.c                  |    2 +-
 40 files changed, 338 insertions(+), 150 deletions(-)

-- 
1.7.4


