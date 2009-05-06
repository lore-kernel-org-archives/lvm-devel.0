From: Milan Broz <mbroz@redhat.com>
Date: Wed,  6 May 2009 16:42:57 +0200
Subject: [PATCH 0/7] Fix lv_count & max_lv problems in lvm2
Message-ID: <cover.1241620083.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

LVM2 allows setting of maximal logical count in metadata.

Logically, the maximal count of LVs should be count of user-visible LVs.

Curently there are several problems:
 - we have several variables and code paths counts visible/diplayable LVs
   not consistently

 - some code paths violates these restrictions

 - there are situations when code allows creating new LV, but then
   during metadata loading the VG is not read (because of violating limits)

   Only possible fix if this happen is to restore metadata from backup
   an manualy edit max_lv (or remove some volume).
   (vgchange -l doesn't work too here)

This patchset tries to consistenly use visible LV count and fixes
all code paths which are temporarily violating the restrictions.

See also bug https://bugzilla.redhat.com/show_bug.cgi?id=490298
(with reproducer)

Milan Broz (7):
  Fix snapshot segment import to not use duplicate segments & replace.
  Never set mirror log and images directly visible in metadata.
  Remove snapshot_count from VG and use function instead.
  Introduce vg_add_lc and vg_remove_lv functions.
  Introduce lv_set_visible & lv_set_hidden and use lv_is_visible
    always.
  Merge lv_is_displayable and lv_is_visible.
  Remove import paramater from lv_create_empty.

 lib/activate/activate.c          |    6 +-
 lib/display/display.c            |    4 +-
 lib/format1/disk-rep.h           |    3 +-
 lib/format1/import-export.c      |   28 ++++-----
 lib/format_pool/format_pool.c    |    1 -
 lib/format_pool/import_export.c  |   15 +----
 lib/format_text/export.c         |    4 +-
 lib/format_text/import_vsn1.c    |   22 +------
 lib/metadata/lv_manip.c          |  127 +++++++++++++++++++++++--------------
 lib/metadata/metadata-exported.h |   20 +++---
 lib/metadata/metadata.c          |   35 +++++------
 lib/metadata/metadata.h          |    4 +-
 lib/metadata/mirror.c            |   20 +++----
 lib/metadata/snapshot_manip.c    |   44 ++++++-------
 lib/report/columns.h             |    4 +-
 lib/report/report.c              |   22 +++---
 lib/snapshot/snapshot.c          |   19 +++++-
 test/t-lvcreate-usage.sh         |   22 ++++++-
 test/test-utils.sh               |    1 +
 tools/lvchange.c                 |    2 +-
 tools/lvconvert.c                |    3 +-
 tools/lvcreate.c                 |    6 +-
 tools/lvdisplay.c                |    2 +-
 tools/lvscan.c                   |    2 +-
 tools/pvmove.c                   |    2 +-
 tools/reporter.c                 |    4 +-
 tools/vgmerge.c                  |    2 -
 tools/vgsplit.c                  |    5 +-
 28 files changed, 221 insertions(+), 208 deletions(-)


