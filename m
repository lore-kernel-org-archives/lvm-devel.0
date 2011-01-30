From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 30 Jan 2011 13:57:23 +0100
Subject: [PATCH 00/24] Performance improvements
Message-ID: <cover.1296391340.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Main target in this patchset is to again considerably
speedup functinality of lvm tools.

1. PV_MIN_SIZE - updated init position for last patchset.

2. Fix and improve udev synchronization.
   (i.e. do not call fs_unlock after _lv_resume())

3. Hashing was consuming a lot of CPU - partly because of
   some small tables, partly becuase hash function for our
   data set was producing a lot of hash collisions.

4. Improves memory locking for multiple operation within
   one VG lock  (i.e. activation of a lot of LVs from 1 VG).

Patch set also has few const pointer fixes, and man page updates.
Allow 1 page difference between mlock munlock.
Few updates for test suite.
Minor extension for lvm2api -  I've also noticed, few  const
in this API are wrong - we cannot pass const handler to routines,
which are modifying them.

Zdenek Kabelac (24):
  Add find_config_tree_int64 function
  Replace PV_MIN_SIZE with function pv_min_size()
  Test pv_min_size functionality
  Move add_dev_node to DM_DEVICE_RESUME
  Perf: Fix multiple operations on the same node
  lv_info handle udev_sync
  Remove  open_count read from some lv_info calls
  Perf: optimize _eat_space and _get_token
  Align orphan strings
  Perf: speed up hash tables
  Perf: New HASH function
  Perf: Increase hash sizes
  Memory unlock allows 1 page difference
  Critical section
  Remove fs_unlock after failed suspend
  Man pages reformating
  Void* arithmetic replaced with char*
  API change - support more const arg
  Use cleaner  const *  pointer
  Const fixing
  Testing: remove -q from grep
  Testing: Try to prioritize locking process
  Extend lvm2api with lvm_lv_rename
  Testing  lvm_lv_rename

 daemons/clvmd/clvmd.c                   |    4 +-
 daemons/clvmd/clvmd.h                   |    2 +-
 daemons/clvmd/lvm-functions.c           |   12 +-
 doc/example.conf.in                     |    5 +
 lib/activate/activate.c                 |   36 ++++--
 lib/activate/activate.h                 |    2 +-
 lib/activate/fs.c                       |   70 +++++++++++-
 lib/activate/fs.h                       |    1 +
 lib/cache/lvmcache.c                    |   14 +-
 lib/commands/toolcontext.c              |   11 ++-
 lib/config/config.c                     |   42 ++++---
 lib/config/config.h                     |    2 +
 lib/device/dev-cache.c                  |    2 +-
 lib/device/dev-io.c                     |    2 +-
 lib/filters/filter-persistent.c         |    2 +-
 lib/filters/filter-regex.c              |    2 +-
 lib/filters/filter.c                    |    2 +-
 lib/format1/format1.c                   |   10 +-
 lib/format1/import-export.c             |    2 +-
 lib/format1/import-extents.c            |    2 +-
 lib/format1/lvm1-label.c                |    9 +-
 lib/format_pool/format_pool.c           |    4 +-
 lib/format_text/export.c                |    2 +-
 lib/format_text/format-text.c           |   18 ++-
 lib/format_text/import_vsn1.c           |    4 +-
 lib/format_text/text_label.c            |    9 +-
 lib/locking/locking.c                   |   14 ++-
 lib/log/log.c                           |    8 +-
 lib/metadata/lv.h                       |    2 +-
 lib/metadata/lv_manip.c                 |    3 +-
 lib/metadata/metadata-exported.h        |    9 +-
 lib/metadata/metadata.c                 |   45 ++++----
 lib/metadata/metadata.h                 |    1 -
 lib/metadata/mirror.c                   |   20 ++--
 lib/misc/lvm-globals.c                  |   12 ++
 lib/misc/lvm-globals.h                  |    5 +-
 lib/mm/memlock.c                        |   72 +++++++++---
 lib/mm/memlock.h                        |    6 +-
 lib/report/properties.c                 |    3 +-
 lib/report/report.c                     |   14 +--
 libdm/datastruct/hash.c                 |  188 ++++++++++++++++++++++++++-----
 libdm/ioctl/libdm-iface.c               |    8 +-
 libdm/libdevmapper.h                    |    8 +-
 libdm/libdm-common.c                    |   71 ++++++++++--
 libdm/libdm-deptree.c                   |    4 +-
 libdm/libdm-report.c                    |    2 +-
 liblvm/lvm2app.h                        |   16 +++
 liblvm/lvm_lv.c                         |   14 ++-
 liblvm/lvm_vg.c                         |    4 +-
 man/fsadm.8.in                          |   80 ++++++++------
 man/lvreduce.8.in                       |   65 ++++++-----
 man/lvremove.8.in                       |   17 ++--
 man/lvrename.8.in                       |   37 ++-----
 man/lvresize.8.in                       |   99 ++++++++--------
 test/api/Makefile.in                    |    2 +-
 test/api/lvtest.c                       |   64 +++++++++++
 test/api/lvtest.sh                      |   21 ++++
 test/t-lock-blocking.sh                 |   10 +-
 test/t-mirror-names.sh                  |    2 +-
 test/t-mirror-vgreduce-removemissing.sh |    2 +-
 test/t-pv-min-size.sh                   |   31 +++++
 test/t-pvcreate-operation.sh            |    2 +-
 test/t-snapshot-merge.sh                |    9 +-
 test/t-vgcreate-usage.sh                |    2 +-
 test/t-vgextend-usage.sh                |    2 +-
 tools/lvconvert.c                       |    2 +-
 tools/lvcreate.c                        |    2 +-
 tools/lvscan.c                          |    2 +-
 tools/pvresize.c                        |    6 +-
 tools/reporter.c                        |    4 +-
 tools/toollib.c                         |   10 +-
 tools/toollib.h                         |    4 +-
 tools/vgcfgrestore.c                    |    2 +-
 tools/vgcreate.c                        |    2 +-
 tools/vgextend.c                        |    4 +-
 tools/vgmerge.c                         |    2 +-
 tools/vgreduce.c                        |    2 +-
 tools/vgrename.c                        |    2 +-
 tools/vgsplit.c                         |    2 +-
 79 files changed, 898 insertions(+), 393 deletions(-)
 create mode 100644 test/api/lvtest.c
 create mode 100644 test/api/lvtest.sh
 create mode 100755 test/t-pv-min-size.sh

--
1.7.3.5


