From: Milan Broz <mbroz@redhat.com>
Date: Wed, 13 May 2009 17:23:08 +0200
Subject: [PATCH 0/9 v2] Fix lv_count & max_lv problems in lvm2
Message-ID: <cover.1242227458.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

(reposted with some fixed thisng after review)

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

This patchset
 - rearanges code to be cleaner
 - removes lv_count counter and use function to do that (simplify code)
 - forces max_lv count only for new volume creation
 (per previous discussion we allow temporarily violate max_lv count)

Milan Broz (9):
  Fix snapshot segment import to not use duplicate segments & replace.
  Remove vg->lv_count and use counter function.
  Tidy format1 import LV function.
  Introduce vg_link_lv and vg_unlink_lv functions.
  Fix lv_is_visible to handle virtual origin.
  Introduce lv_set_visible & lv_set_hidden and use lv_is_visible
    always.
  Merge lv_is_displayable and lv_is_visible.
  Remove unneeded import parameter from lv_create_empty.
  Check max_lv on only place and force the check only for new volume.

 lib/activate/activate.c          |    6 +-
 lib/display/display.c            |    4 +-
 lib/format1/disk-rep.h           |    3 +-
 lib/format1/import-export.c      |   30 +++++-----
 lib/format_pool/format_pool.c    |    1 -
 lib/format_pool/import_export.c  |   16 +----
 lib/format_text/export.c         |    4 +-
 lib/format_text/import_vsn1.c    |   22 +------
 lib/metadata/lv_manip.c          |  130 ++++++++++++++++++++++++--------------
 lib/metadata/metadata-exported.h |   23 ++++---
 lib/metadata/metadata.c          |   76 ++++++++++++++--------
 lib/metadata/metadata.h          |    5 --
 lib/metadata/mirror.c            |   16 +++---
 lib/metadata/snapshot_manip.c    |   73 ++++++++++-----------
 lib/report/report.c              |    4 +-
 lib/snapshot/snapshot.c          |    6 +--
 test/t-lvcreate-usage.sh         |   23 +++++++-
 test/test-utils.sh               |    1 +
 tools/lvchange.c                 |    2 +-
 tools/lvconvert.c                |    3 +-
 tools/lvcreate.c                 |   12 +++-
 tools/lvdisplay.c                |    2 +-
 tools/lvscan.c                   |    2 +-
 tools/pvmove.c                   |    2 +-
 tools/reporter.c                 |    4 +-
 tools/vgchange.c                 |    4 +-
 tools/vgmerge.c                  |    1 -
 tools/vgsplit.c                  |    6 +--
 28 files changed, 262 insertions(+), 219 deletions(-)


