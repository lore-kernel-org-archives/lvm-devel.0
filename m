From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 17 Mar 2010 14:46:53 +0100
Subject: [PATCH 00/25] Replicator
Message-ID: <cover.1268833246.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Rebased set of replicator patches.
Log creation code is still kept separately as many changes
are still on going in this code.

Updated parts:
* Using common typedef between dm and lvm part for operation mode.
* cmd_context now contains only vgs_lvs_retry dm_list - needs to be fixed.
* Minor code reoganization based on review
* Extended validation code.
* Added manpages updates to patches to document API
  still this is ongoing task to make all the options working
* Whole new API aroung vg_name_list which is now autonomous entity
* lock_vol now detects missing vgs using new LCK_MISSING_VG bit
* Tunning some API
* Processed vg contains list of opened vgs.

Zdenek Kabelac (25):
  Remove const from volume_group* in process_each
  Replicator: add libdm support
  Replicator: suspend/deactivate replicator
  Replicator: add lvm support
  Replicator: validate replicator segments
  Replicator: extend _lv_each_dependency() rep. deps
  Replicator: extend VG with list of opened vgs
  Replicator: add sorted vg_name_list
  Replicator: add lv_replicator_sites_check_vg
  Replicator: add read/release VG for rsites
  Replicator: use vg_name_list for _process_one_vg()
  Replicator: use str_list for process_each_lv_in_vg
  Replicator: lock_vol update replicator LV
  Replicator: extend activate with rsite resolving
  Replicator: update _create_partial_dtree()
  Replicator: vg with missing_vgs does not print
  Replicator: add replicator to dtree
  Replicator: do not remove of replicators' LVs
  Replicator: no crash lvresize if area_count is 0
  Replicator: activate change for vgchange
  Replicator: add new options for replicator
  Replicator: man pages for lvcreate, lvchange
  Replicator: update copyright dates
  Replicator: update generated lib/misc/configure.h.in
  Replicator: update generated configure.in

 configure                        |   33 ++-
 configure.in                     |   17 +
 lib/Makefile.in                  |    9 +
 lib/activate/activate.c          |   22 +-
 lib/activate/dev_manager.c       |  137 +++++++-
 lib/commands/toolcontext.c       |    6 +
 lib/commands/toolcontext.h       |    2 +
 lib/config/defaults.h            |    1 +
 lib/format_text/flags.c          |    2 +
 lib/locking/locking.c            |    3 +
 lib/locking/locking.h            |    7 +-
 lib/metadata/lv_manip.c          |   15 +
 lib/metadata/merge.c             |   14 +
 lib/metadata/metadata-exported.h |  105 +++++-
 lib/metadata/metadata.c          |  162 ++++++++
 lib/metadata/replicator_manip.c  |  576 +++++++++++++++++++++++++++
 lib/metadata/segtype.h           |   10 +-
 lib/misc/configure.h.in          |    3 +
 lib/replicator/.exported_symbols |    1 +
 lib/replicator/Makefile.in       |   29 ++
 lib/replicator/replicator.c      |  794 ++++++++++++++++++++++++++++++++++++++
 libdm/.exported_symbols          |    3 +
 libdm/libdevmapper.h             |   33 ++
 libdm/libdm-deptree.c            |  361 +++++++++++++++++-
 man/lvchange.8.in                |   60 +++-
 man/lvcreate.8.in                |   55 +++
 tools/args.h                     |   13 +
 tools/commands.h                 |   10 +-
 tools/lvcreate.c                 |   58 +++-
 tools/lvmcmdline.c               |    9 +
 tools/toollib.c                  |  119 ++++--
 tools/toollib.h                  |    2 +-
 tools/tools.h                    |    1 +
 tools/vgchange.c                 |    9 +-
 34 files changed, 2624 insertions(+), 57 deletions(-)
 create mode 100644 lib/metadata/replicator_manip.c
 create mode 100644 lib/replicator/.exported_symbols
 create mode 100644 lib/replicator/Makefile.in
 create mode 100644 lib/replicator/replicator.c


