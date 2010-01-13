From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 13 Jan 2010 14:42:04 +0100
Subject: [PATCH 00/18] Replicator patch set
Message-ID: <cover.1263389894.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Rebased set of replicator patches.
Log creation code is still kept separately as many changes
are still on going in this code.

Zdenek Kabelac (18):
  Replicator: suspend/deactivate replicator
  Replicator: add lvm support
  Replicator: validation of replicator segments
  Replicator: extend _lv_each_dependency() rep. deps
  Replicator: add sorted vg_name_list
  Replicator: use vg_name_list for _process_one_vg()
  Replicator: use str_list for process_each_lv_in_vg
  Replicator: update _create_partial_dtree()
  Replicator: using vgs_missed for error count
  Replicator: add vgs_print for message postponing
  Replicator: add replicator to dtree
  Replicator: do not remove of replicators' LVs
  Replicator: no crash lvresize if area_count is 0
  Replicator: activate change for vgchange
  Replicator: add new options for replicator
  Replicator: update copyright dates
  Replicator: new variable in generated file
  Replicator: update of generated configure file

 configure                        |   34 ++-
 configure.in                     |   17 +
 lib/Makefile.in                  |    9 +
 lib/activate/dev_manager.c       |  160 ++++++++-
 lib/commands/toolcontext.c       |    7 +
 lib/commands/toolcontext.h       |    4 +
 lib/config/defaults.h            |    1 +
 lib/format_text/flags.c          |    2 +
 lib/metadata/lv_manip.c          |   15 +
 lib/metadata/merge.c             |   14 +
 lib/metadata/metadata-exported.h |  113 ++++++-
 lib/metadata/metadata.c          |   72 ++++
 lib/metadata/replicator_manip.c  |  361 +++++++++++++++++
 lib/metadata/segtype.h           |   10 +-
 lib/misc/configure.h.in          |    8 +-
 lib/replicator/.exported_symbols |    1 +
 lib/replicator/Makefile.in       |   28 ++
 lib/replicator/replicator.c      |  822 ++++++++++++++++++++++++++++++++++++++
 libdm/.exported_symbols          |    1 +
 libdm/libdevmapper.h             |    2 +
 libdm/libdm-deptree.c            |   65 +++-
 tools/args.h                     |    5 +
 tools/commands.h                 |   10 +-
 tools/lvcreate.c                 |   52 +++-
 tools/lvmcmdline.c               |    9 +
 tools/toollib.c                  |  170 +++++++--
 tools/tools.h                    |    1 +
 tools/vgchange.c                 |   16 +-
 28 files changed, 1973 insertions(+), 36 deletions(-)
 create mode 100644 lib/metadata/replicator_manip.c
 create mode 100644 lib/replicator/.exported_symbols
 create mode 100644 lib/replicator/Makefile.in
 create mode 100644 lib/replicator/replicator.c


