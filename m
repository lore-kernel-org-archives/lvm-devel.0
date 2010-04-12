From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 12 Apr 2010 17:21:28 +0200
Subject: [PATCH 00/22] Replicator 100412
Message-ID: <cover.1271085009.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Rebased set of replicator patches.
Log creation code is still kept separately as many changes
are still on going in this code.

Updated parts:

* previous set had wrong month number.
* converted Makefiles.
* renamed some functions (removed lvm_ prefix).
* renamed vg_name_list -> vgs_list.
* moved code from validation to segment checking.

* Added dm_list_splice
* Changed API for process_each_lv_in_vg()
* lock_lv_vol() detects missing VGs before calling lock_vol().

* Using common typedef between dm and lvm part for operation mode.
* Minor code reoganization based on review
* Extended validation code.
* Added manpages updates to patches to document API
  still this is ongoing task to make all the options working.
* API around vg_name_list which is now autonomous entity.
* Processed VG contains list of opened VGs and flag for missing VGs.


Zdenek Kabelac (22):
  Add dm_list_splice() for list join.
  API change for args of process_each_lv_in_vg()
  Replicator: add libdm support
  Replicator: suspend/deactivate replicator
  Replicator: add lvm support
  Replicator: check replicator segment
  Replicator: extend _lv_each_dependency() rep. deps
  Replicator: extend volume_group with list of VGs
  Replicator: add sorted vgs_list
  Replicator: add find_replicator_vgs
  Replicator: add read and release VGs for rsites
  Replicator: use vgs_list for _process_one_vg()
  Replicator: use vgs_list for process_each_lv_in_vg()
  Replicator: lock_vol() finds missing VGs
  Replicator: activate checks for missing vgs
  Replicator: update _create_partial_dtree()
  Replicator: vg with missing_vgs does not print
  Replicator: add replicator to dtree
  Replicator: do not remove of replicators' LVs
  Replicator: activate change for vgchange
  Replicator: add new options for replicator
  Replicator: man pages for lvcreate, lvchange

 configure.in                     |   17 +
 lib/Makefile.in                  |   10 +
 lib/activate/activate.c          |   22 +-
 lib/activate/dev_manager.c       |  135 +++++++-
 lib/commands/toolcontext.c       |    5 +
 lib/config/defaults.h            |    1 +
 lib/format_text/flags.c          |    2 +
 lib/locking/locking.h            |    4 +-
 lib/metadata/lv_manip.c          |   10 +
 lib/metadata/merge.c             |   17 +
 lib/metadata/metadata-exported.h |  105 +++++-
 lib/metadata/metadata.c          |    4 +
 lib/metadata/replicator_manip.c  |  718 ++++++++++++++++++++++++++++++++++
 lib/metadata/segtype.h           |    8 +
 lib/replicator/.exported_symbols |    1 +
 lib/replicator/Makefile.in       |   25 ++
 lib/replicator/replicator.c      |  794 ++++++++++++++++++++++++++++++++++++++
 libdm/.exported_symbols          |    4 +
 libdm/datastruct/list.c          |   12 +
 libdm/libdevmapper.h             |   38 ++
 libdm/libdm-deptree.c            |  359 +++++++++++++++++-
 man/lvchange.8.in                |   57 +++
 man/lvcreate.8.in                |   55 +++
 tools/args.h                     |   13 +
 tools/commands.h                 |    7 +
 tools/lvcreate.c                 |   55 +++
 tools/lvmcmdline.c               |    9 +
 tools/toollib.c                  |  115 ++++--
 tools/toollib.h                  |    1 +
 tools/tools.h                    |    1 +
 tools/vgchange.c                 |    9 +-
 tools/vgdisplay.c                |    2 +-
 32 files changed, 2567 insertions(+), 48 deletions(-)
 create mode 100644 lib/metadata/replicator_manip.c
 create mode 100644 lib/replicator/.exported_symbols
 create mode 100644 lib/replicator/Makefile.in
 create mode 100644 lib/replicator/replicator.c


