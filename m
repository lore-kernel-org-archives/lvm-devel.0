From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 29 Jun 2010 18:26:00 +0200
Subject: [PATCH 00/12] Replicator 100629
Message-ID: <cover.1277828149.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patchset enhances lvm with replicator metadata construction.
It should not influence other commands thus should be safe to insert to
source tree.

At this moment patch doesn't contain lvchange (not yet cleaned)
Idea is to enable replicator with

lvchange --site Berlin --replicator my/rep  -ay
or 
lvchange --site Berlin my/L1  -ay
(still undecided??)

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


Zdenek Kabelac (12):
  Allow the user to not specify a size when creating snapshot.
  Replicator: check for active replicator
  Replicator: reserved names
  Replicator: add _replicator_in_sync
  Replicator: improve detection of replicator-dev
  Replicator: lvcreate, lvm  man pages
  Replicator: add new options for replicator
  Replicator: lv_manip - create replicator
  Replicator: add report for replicator targets
  Replicator: replicator_manip changes
  Replicator: replicator.c changes
  Replicator: man pages for lvchange.8

 lib/config/defaults.h            |    8 +
 lib/metadata/lv_manip.c          |  126 ++++++-
 lib/metadata/merge.c             |   18 +-
 lib/metadata/metadata-exported.h |   46 ++-
 lib/metadata/replicator_manip.c  |  806 +++++++++++++++++++++++++++++++++++---
 lib/misc/lvm-globals.c           |   11 +
 lib/misc/lvm-globals.h           |    2 +
 lib/misc/lvm-string.c            |   18 +
 lib/replicator/replicator.c      |  124 +++----
 lib/report/columns.h             |    2 +
 lib/report/report.c              |   32 ++
 man/lvchange.8.in                |   37 ++
 man/lvcreate.8.in                |   66 +++
 man/lvm.8.in                     |    3 +-
 tools/args.h                     |   10 +
 tools/commands.h                 |   15 +
 tools/lvcreate.c                 |  138 +++++++-
 tools/lvmcmdline.c               |   10 +
 tools/tools.h                    |    1 +
 tools/vgchange.c                 |    2 +-
 20 files changed, 1312 insertions(+), 163 deletions(-)


