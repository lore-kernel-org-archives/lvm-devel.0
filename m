From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  7 Jul 2010 14:34:34 +0200
Subject: [PATCH 00/22] Replicator 100707
Message-ID: <cover.1278505885.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patchset enhances lvm with replicator metadata construction.
It 'should not' influence other commands.

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

lvcreate --replicatordev -L10M -n L1 --replicator my/rep
lvcreate --replicatordev -L20M -n L2 --replicator my/rep

lvcreate --replicator rep -L20M my || exit 1
lvcreate --replicatordev -L10M -n L1 --replicator my/rep

lvremove my/L1

Note: after removing 'L1'  LV  'L1_rimage' and '_slog' devices
are left in VG Ideally user should use  own 'VG'
and for removal just run:

vgremove my

lvchange --site Berlin --replicator my/rep  -ay
== lvchange --site Berlin my/L1  -ay
== lvchange --site Berlin my/rep  -ay


Zdenek Kabelac (22):
  Add units to passed parameters data & timeout     Use size
  Allow the user to not specify a size when creating snapshot.
  Skip check missing rem.VGs for non-activate locks
  Replicator: check for active replicator
  Replicator: add reserved names
  Replicator: man page update for lvm
  Replicator: add _replicator_in_sync
  Replicator: add report for replicator targets
  Replicator: improve detection of replicator-dev
  Replicator: new defaults
  Replicator: metadata update
  Replicator: replicator_manip changes
  Replicator: replicator.c changes
  Replicator: add new command option read functions
  Replicator: new args
  Replicator: read site_params
  Replicator: lv_manip - create replicator
  Replicator: lvcreate implementation
  Replicator: man page update for lvcreate
  Replicator: lvchange implementation
  Replicator: man page update for lvchange
  Replicator: lvremove implementation

 lib/config/defaults.h            |    9 +
 lib/locking/locking.h            |    2 +-
 lib/metadata/lv_manip.c          |  126 ++++-
 lib/metadata/merge.c             |   18 +-
 lib/metadata/metadata-exported.h |   59 ++-
 lib/metadata/replicator_manip.c  | 1211 +++++++++++++++++++++++++++++++-------
 lib/misc/lvm-globals.c           |   11 +
 lib/misc/lvm-globals.h           |    2 +
 lib/misc/lvm-string.c            |   18 +
 lib/replicator/replicator.c      |  178 ++----
 lib/report/columns.h             |    2 +
 lib/report/report.c              |   32 +
 libdm/libdm-deptree.c            |    4 +-
 man/lvchange.8.in                |   31 +
 man/lvcreate.8.in                |   76 +++
 man/lvm.8.in                     |    3 +-
 tools/args.h                     |   10 +
 tools/commands.h                 |   18 +-
 tools/lvchange.c                 |  195 ++++++-
 tools/lvcreate.c                 |  137 +++++-
 tools/lvmcmdline.c               |   24 +
 tools/lvremove.c                 |   19 +-
 tools/toollib.c                  |  111 ++++
 tools/toollib.h                  |    3 +
 tools/tools.h                    |    2 +
 tools/vgchange.c                 |    2 +-
 26 files changed, 1942 insertions(+), 361 deletions(-)


