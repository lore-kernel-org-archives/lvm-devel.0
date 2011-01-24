From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 24 Jan 2011 11:50:24 +0100
Subject: [PATCH 00/15] Pvmin, udev, testing
Message-ID: <cover.1295865933.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patchset combince few 'smaller' changes which are trying to fix
couple problem with current git tree.

0001-0002 - add configurable pv_min_size

0003-0005 - fix udev problem with stacking multiple dev ops.

0006      - code optimization

0007-0011 - testing speedup

0012      - coverage improvement

0013      - man page fix proposal - we should decide which way to go

0014-0015 - gcc compilation warning fixes

Zdenek Kabelac (15):
  Add find_config_tree_int64 function
  Replace PV_MIN_SIZE with function pv_min_size()
  Test pv_min_size functionality
  Move add_dev_node to DM_DEVICE_RESUME
  Fix multiple operations on the same node
  Micro optimization of _eat_space and _get_token
  Testing: Display duration of tests
  Testing: Accelerate mirror tests
  Testing: Add udev_wait for sfdisk
  Testing: Lower mem usage of  inconsistent mda test
  Testing: Lower device size of pvmove test
  Skip compilation of debug code
  Man page consistency fixes
  Void* arithmetic replaced with char*
  const fixing

 daemons/clvmd/clvmd.c            |    4 +-
 daemons/clvmd/clvmd.h            |    2 +-
 doc/example.conf.in              |    5 +++
 lib/activate/activate.c          |    4 +-
 lib/activate/activate.h          |    2 +-
 lib/activate/fs.c                |   49 +++++++++++++++++++++++++++--
 lib/commands/toolcontext.c       |    8 ++++-
 lib/config/config.c              |   42 ++++++++++++++-----------
 lib/config/config.h              |    2 +
 lib/filters/filter-regex.c       |    2 +-
 lib/filters/filter.c             |    2 +-
 lib/format_text/text_label.c     |    4 +-
 lib/metadata/lv.h                |    2 +-
 lib/metadata/lv_manip.c          |    3 +-
 lib/metadata/metadata-exported.h |    9 ++---
 lib/metadata/metadata.c          |   33 +++++++++++--------
 lib/metadata/metadata.h          |    1 -
 lib/metadata/mirror.c            |   18 +++++-----
 lib/misc/lvm-globals.c           |   12 +++++++
 lib/misc/lvm-globals.h           |    5 ++-
 lib/report/properties.c          |    3 +-
 lib/report/report.c              |    6 ++--
 libdm/ioctl/libdm-iface.c        |    8 ++--
 libdm/libdm-common.c             |   57 +++++++++++++++++++++++++++-------
 libdm/mm/dbg_malloc.c            |    4 ++
 liblvm/lvm_vg.c                  |    4 +-
 man/pvcreate.8.in                |   63 +++++++++++++++++--------------------
 man/pvremove.8.in                |   15 +++++---
 man/pvresize.8.in                |   13 +++----
 man/pvscan.8.in                  |   14 +++-----
 test/api/percent.sh              |    2 +-
 test/lib/aux.sh                  |   10 ++++++
 test/lib/check.sh                |    4 ++-
 test/lib/harness.c               |   32 +++++++++++++------
 test/t-inconsistent-metadata.sh  |    2 +-
 test/t-lvconvert-mirror-basic.sh |    6 ++--
 test/t-pv-min-size.sh            |   25 +++++++++++++++
 test/t-pvcreate-operation-md.sh  |    8 ++++-
 test/t-pvmove-basic.sh           |   24 ++++++++------
 tools/lvcreate.c                 |    2 +-
 tools/pvresize.c                 |    6 ++--
 tools/reporter.c                 |    4 +-
 tools/toollib.c                  |   10 +++---
 tools/toollib.h                  |    4 +-
 tools/vgcfgrestore.c             |    2 +-
 tools/vgcreate.c                 |    2 +-
 tools/vgextend.c                 |    4 +-
 tools/vgmerge.c                  |    2 +-
 tools/vgreduce.c                 |    2 +-
 tools/vgrename.c                 |    2 +-
 tools/vgsplit.c                  |    2 +-
 51 files changed, 360 insertions(+), 191 deletions(-)
 create mode 100755 test/t-pv-min-size.sh

-- 
1.7.3.5


