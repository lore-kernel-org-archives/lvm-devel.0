From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 16 Dec 2010 11:36:08 +0100
Subject: [PATCH 00/20] Const fixes
Message-ID: <cover.1292495195.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Primary reason for this patchset is to make stronger
const limitation around config_tree handling.
So we can be sure where this tree could be modified.
It also cleanup quite a few hidden const warning
(-Wbad-function-cast -Wcast-qual)

Patch is extended with few more minor patches gathers
from my tree which should be easy to review. Some of them
are probably some minor bugs in the code so it's worth to
check them in.

Zdenek Kabelac (20):
  Add more strict const pointers around config tree
  Const fixes and additions
  Use const char* const *
  Remove wrong cast to (char*)
  Remove const from destroy callback
  Replace void* arithmetic with char*
  Use const char * arithmetic for offset calculation
  Use const char * for name and old_name in vg
  Replace stack trace with failure exit path
  Simplify usage fprintf clvmd
  Add test for 'read' result
  Add test for allocation results for node clonning
  Properly use dm_free
  Remove dead store in _clog_ctr
  Remove dead assignment in _init_logging
  Remove dead store in lvm_run_command
  Remove dead assignment in dev_manager_transient
  Remove dead assignment in _remove
  Remove unused dev_dir_provided
  Add internal error if pointer is uninitialized

 daemons/clvmd/clvmd.c           |   41 ++++++++--------
 daemons/cmirrord/functions.c    |   32 +++++-------
 lib/activate/activate.c         |    6 +-
 lib/activate/dev_manager.c      |    2 +-
 lib/commands/toolcontext.c      |   17 +++----
 lib/config/config.c             |  100 ++++++++++++++++++++++----------------
 lib/config/config.h             |   14 +++---
 lib/datastruct/btree.c          |    2 +-
 lib/device/dev-cache.c          |    6 +-
 lib/error/errseg.c              |    4 +-
 lib/filters/filter-persistent.c |    2 +-
 lib/filters/filter-regex.c      |    8 ++--
 lib/filters/filter-regex.h      |    2 +-
 lib/filters/filter.c            |    4 +-
 lib/format1/format1.c           |    4 +-
 lib/format_pool/disk_rep.c      |    5 ++
 lib/format_pool/format_pool.c   |    6 +-
 lib/format_text/flags.c         |    2 +-
 lib/format_text/format-text.c   |   12 ++--
 lib/format_text/import-export.h |   12 ++--
 lib/format_text/import.c        |    2 +-
 lib/format_text/import_vsn1.c   |   67 +++++++++++++-------------
 lib/format_text/tags.c          |    2 +-
 lib/freeseg/freeseg.c           |    4 +-
 lib/metadata/lv_manip.c         |    4 +-
 lib/metadata/metadata.h         |    4 +-
 lib/metadata/segtype.h          |    4 +-
 lib/metadata/vg.h               |    4 +-
 lib/mirror/mirrored.c           |    8 ++--
 lib/mm/memlock.c                |    2 +-
 lib/replicator/replicator.c     |    8 ++--
 lib/snapshot/snapshot.c         |    4 +-
 lib/striped/striped.c           |    6 +-
 lib/unknown/unknown.c           |    4 +-
 lib/zero/zero.c                 |    4 +-
 libdm/libdevmapper.h            |    4 +-
 libdm/regex/matcher.c           |    2 +-
 liblvm/lvm_base.c               |    2 +-
 tools/dmsetup.c                 |   10 ++--
 tools/lvmcmdline.c              |   20 +++++---
 tools/toollib.c                 |    2 -
 41 files changed, 232 insertions(+), 216 deletions(-)

-- 
1.7.3.3


