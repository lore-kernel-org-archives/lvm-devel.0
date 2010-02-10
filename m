From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 10 Feb 2010 15:56:46 +0100
Subject: [PATCH 00/19] Replicator patch set
Message-ID: <cover.1265813098.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Rebased set of replicator patches.
Log creation code is still kept separately as many changes
are still on going in this code.

Updated parts:
Using common typedef between dm and lvm part for operation mode
cmd_context now contains separate replicator_info structure
with 'hack' content and fixme to make this better in future
Some other minor code reoganization based on review
Extended validation code.
Added manpages updates to patches to document API
still this is ongoing task to make all the options working


Zdenek Kabelac (19):
  Replicator: add libdm support
  Replicator: suspend/deactivate replicator
  Replicator: add lvm support
  Replicator: validation of replicator segments
  Replicator: extend _lv_each_dependency() rep. deps
  Replicator: add sorted vg_name_list
  Replicator: use vg_name_list for _process_one_vg()
  Replicator: use str_list for process_each_lv_in_vg
  Replicator: update _create_partial_dtree()
  Replicator: using vgs_missed for error count
  Replicator: add replicator to dtree
  Replicator: do not remove of replicators' LVs
  Replicator: no crash lvresize if area_count is 0
  Replicator: activate change for vgchange
  Replicator: add new options for replicator
  Replicator: update copyright dates
  Replicator: man pages for lvcreate, lvchange
  Replicator: new variable in generated file
  Replicator: update of generated configure file

 configure                        |   34 ++-
 configure.in                     |   17 +
 lib/Makefile.in                  |    9 +
 lib/activate/dev_manager.c       |  160 ++++++++-
 lib/commands/toolcontext.c       |    7 +
 lib/commands/toolcontext.h       |   14 +
 lib/config/defaults.h            |    1 +
 lib/format_text/flags.c          |    2 +
 lib/metadata/lv_manip.c          |   15 +
 lib/metadata/merge.c             |   14 +
 lib/metadata/metadata-exported.h |  105 +++++-
 lib/metadata/metadata.c          |  161 ++++++++
 lib/metadata/replicator_manip.c  |  361 +++++++++++++++++
 lib/metadata/segtype.h           |   10 +-
 lib/misc/configure.h.in          |    8 +-
 lib/replicator/.exported_symbols |    1 +
 lib/replicator/Makefile.in       |   28 ++
 lib/replicator/replicator.c      |  806 ++++++++++++++++++++++++++++++++++++++
 libdm/.exported_symbols          |    3 +
 libdm/libdevmapper.h             |   33 ++
 libdm/libdm-deptree.c            |  362 +++++++++++++++++-
 man/lvchange.8.in                |   60 +++-
 man/lvcreate.8.in                |   56 +++
 tools/args.h                     |    5 +
 tools/commands.h                 |   10 +-
 tools/lvcreate.c                 |   52 +++-
 tools/lvmcmdline.c               |    9 +
 tools/toollib.c                  |  170 +++++++--
 tools/tools.h                    |    1 +
 tools/vgchange.c                 |   16 +-
 30 files changed, 2488 insertions(+), 42 deletions(-)
 create mode 100644 lib/metadata/replicator_manip.c
 create mode 100644 lib/replicator/.exported_symbols
 create mode 100644 lib/replicator/Makefile.in
 create mode 100644 lib/replicator/replicator.c


