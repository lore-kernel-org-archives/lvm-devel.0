From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 11:55:04 +0100
Subject: [PATCH 00/29] Fixes for analyzer problems
Message-ID: <cover.1290682013.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Another patchset with fixes based on static analyzer.

Close inspection required for patches:

0010 - Add some backtrace - Attention please
0013 - Put some FIXME warnings in lvmcache_update_vg processing
0026 - Add stack traces for dev_set/close_immediate error path

It's not completly obvious what we should exactly do.

Zdenek Kabelac (29):
  Cleanup remove test for NULL
  Fix check for empty system_dir
  Remove printing of LCK_CACHE
  Reset vg pointer after release
  Test *buf for NULL
  Replace  snprintf -> dm_snprintf
  Test success from dm_poll_create
  Fix memory leak in error path
  Remove check for lv is NULL
  Add some backtrace - Attention please
  Add stack trace for error path
  Add test for 'read' result
  Put some FIXME warnings in lvmcache_update_vg processing
  Remove unneeded check for NULL pvd->system_id
  Modify test to catch passing NULL pointer
  Test uuid for NULL
  Optimize second call to strchr with same parameters
  Check result of vginfo_from_vgname
  Test for error status
  Add test for lv_name not NULL
  Instrument with nonnull  dev_manager_transient
  Ensure pointer first is notnull before dereference
  Add test and error message for failure case
  Test for str_list_add
  Check for unlink result
  Add stack traces for dev_set/close_immediate error path
  Add standard check for result of lv_info call
  Check type is not NULL before access
  Check for NULL pointer

 daemons/clvmd/clvmd-command.c   |   20 +++++++-------
 daemons/clvmd/clvmd.c           |    9 ++++--
 daemons/clvmd/lvm-functions.c   |    5 +--
 lib/activate/dev_manager.c      |   15 +++++-----
 lib/activate/dev_manager.h      |    2 +-
 lib/cache/lvmcache.c            |    6 ++++
 lib/commands/toolcontext.c      |    2 +-
 lib/config/config.c             |   10 +++++-
 lib/format1/disk-rep.c          |    2 +-
 lib/format1/format1.c           |    8 +++---
 lib/format1/import-export.c     |    2 +-
 lib/format_pool/import_export.c |   10 +++++-
 lib/format_text/archiver.c      |    4 ++-
 lib/format_text/export.c        |   56 ++++++++++++++++++--------------------
 lib/metadata/lv_manip.c         |    8 ++++-
 lib/metadata/metadata.c         |    6 +++-
 lib/mirror/mirrored.c           |   12 +++++++-
 libdm/ioctl/libdm-iface.c       |   15 +++++++---
 libdm/libdm-common.c            |   14 +++-------
 libdm/libdm-report.c            |    6 ++++
 tools/dmsetup.c                 |    4 ++-
 tools/lvmcmdline.c              |   12 +++++---
 tools/reporter.c                |    4 +++
 tools/toollib.c                 |    7 +++--
 24 files changed, 143 insertions(+), 96 deletions(-)

-- 
1.7.3.2


