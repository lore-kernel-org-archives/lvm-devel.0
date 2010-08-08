From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun,  8 Aug 2010 10:57:12 +0200
Subject: [PATCH 00/25] Replicator 100808
Message-ID: <cover.1281256234.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patchset enhances lvm with replicator metadata construction.

This version contains changes from Prague discussion.

Replicated-dev has been changed to replicated
(kernel driver though is still replicated-dev).
Sitemode has been renamed to sitepolicy.
Size and Extents are not needed when site argument is given.
Updated logic for specifying vg for lvcreate command.

Not yet finished:
HA LVM usage for activation of replicator.
Removal of replicator devices could be better.


Use case example:

# build remote devices
vgcreate vg_ny /dev/loop1
vgcreate vg_paris /dev/loop2

lvcreate -L10M -n L1 vg_ny
lvcreate -L10M -n L1 vg_paris
lvcreate -L20M -n L2 vg_ny
lvcreate -L20M -n L2 vg_paris

# build local replicator
vgcreate my /dev/loop0
lvcreate --replicator rep -L20M my

lvcreate --site Berlin --replicator my/rep
lvcreate --site NY --remotevg vg_ny --replicator my/rep
lvcreate --site Paris --remotevg vg_paris --replicator my/rep

lvcreate --replicated -L10M -n L1 my/rep
lvcreate --replicated -L20M -n L2 my/rep

lvremove my/L1

Note: after removing 'L1'  LV  'L1_rimage' and '_slog' devices
are left in VG Ideally user should use  own 'VG'
and for removal just run:

vgremove my

lvchange --site Berlin --replicator my/rep  -ay
== lvchange --site Berlin my/L1  -ay
== lvchange --site Berlin my/rep  -ay

Zdenek Kabelac (25):
  Update libdm for replicator
  SEG_REPLICATED dm-deptree
  Skip check missing rem.VGs for non-activate locks
  Replicator: check for active replicator
  Replicator: add reserved names
  Replicator: man page update for lvm
  Replicator: add _replicator_in_sync
  Replicator: add report for replicator/ed targets
  Replicator: improve detection of replicated segment
  Replicator: new defaults
  Replicator: metadata update
  Replicator: segtype.h - replicated
  Replicator: replicator_manip changes
  Replicator: replicator.c changes
  Replicator: add new command option read functions
  Replicator: new args
  Replicator: update of dev_manager.c
  Replicator: read site_params
  Replicator: lv_manip - create replicator
  Replicator: lvcreate implementation
  Replicator: man page update for lvcreate
  Replicator: lvchange implementation
  Replicator: man page update for lvchange
  Replicator: lvremove implementation
  Replicator: initial simple replicator testcase

 lib/activate/dev_manager.c       |   38 +-
 lib/config/defaults.h            |    9 +
 lib/locking/locking.h            |    2 +-
 lib/metadata/lv_manip.c          |  124 ++++
 lib/metadata/merge.c             |   22 +-
 lib/metadata/metadata-exported.h |   83 ++-
 lib/metadata/replicator_manip.c  | 1262 +++++++++++++++++++++++++++++++-------
 lib/metadata/segtype.h           |    4 +-
 lib/misc/lvm-globals.c           |   11 +
 lib/misc/lvm-globals.h           |    2 +
 lib/misc/lvm-string.c            |   18 +
 lib/replicator/replicator.c      |  363 +++++-------
 lib/report/columns.h             |    2 +
 lib/report/report.c              |   32 +
 libdm/libdevmapper.h             |   32 +-
 libdm/libdm-deptree.c            |   88 ++--
 man/lvchange.8.in                |   31 +
 man/lvcreate.8.in                |   75 +++
 man/lvm.8.in                     |    3 +-
 test/t-replicator-usage.sh       |   47 ++
 tools/args.h                     |   10 +
 tools/commands.h                 |   20 +-
 tools/lvchange.c                 |  195 ++++++-
 tools/lvcreate.c                 |  138 ++++-
 tools/lvmcmdline.c               |   71 +++
 tools/lvremove.c                 |   18 +-
 tools/toollib.c                  |  103 +++-
 tools/toollib.h                  |    3 +
 tools/tools.h                    |    3 +
 tools/vgchange.c                 |    6 +-
 30 files changed, 2245 insertions(+), 570 deletions(-)
 create mode 100755 test/t-replicator-usage.sh

--
1.7.2.1


