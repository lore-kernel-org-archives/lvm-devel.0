From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 30 Nov 2009 12:37:00 +0100
Subject: [PATCH 00/23] Replicator lvm support
Message-ID: <1259581043-15308-1-git-send-email-zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Set of patches to introduce LVM support for dm target replicator.
Patches without Replicator: prefix are generic simple patches 
or some minor code cleanups - they are here just to get accurate diffs.

Replicator part of this patch set first adds libdm support followed by
lvm support.

Tricky part is the usage of sorted vg_name_list.

This patch set doesn't yet contain functional lvm commands for creation
of replicator, so for activation and deactivation hand written meta-data
must be used.

Current code will activate also VGs from remote volume groups if they
are not yet active and work with already active remote VGs.
Deactivation will leave remove VGs active. 

So far only vgchange works for activation, lvchange is in the progress.

Zdenek Kabelac (23):
  Indent changes
  Skip cast of void* for assigment
  Simple indent changes to fit 80 chars per line
  Export outsz() and outhnt() for modules
  Export outfc() macro and out_text_with_comment()
  Use outsz macro
  Replicator: add libdm support
  Replicator: suspend/deactivate replicator
  Replicator: add lvm support
  Replicator: validation of replicator segments
  Replicator: extend _lv_each_dependency() rep. deps
  Replicator: add sorted vg_name_list
  Replicator: use vg_name_list for _process_one_vg()
  Replicator: update _create_partial_dtree()
  Replicator: using vgs_missed for error count
  Replicator: add vgs_print for message postponing
  Replicator: add replicator to dtree
  Replicator: do not remove of replicators' LVs
  Replicator: activate change for vgchange
  Replicator: add new options for replicator
  Replicator: update copyright dates
  Replicator: new variable in generated file
  Replicator: update of generated configure file

 configure                        |   34 ++-
 configure.in                     |   17 +
 lib/Makefile.in                  |    9 +
 lib/activate/dev_manager.c       |  172 ++++++++-
 lib/commands/toolcontext.c       |    5 +
 lib/commands/toolcontext.h       |    3 +
 lib/config/defaults.h            |    1 +
 lib/format_text/export.c         |   29 +-
 lib/format_text/flags.c          |    2 +
 lib/format_text/text_export.h    |    6 +
 lib/metadata/lv_manip.c          |   10 +
 lib/metadata/merge.c             |   14 +
 lib/metadata/metadata-exported.h |  112 +++++-
 lib/metadata/metadata.c          |   67 +++
 lib/metadata/replicator_manip.c  |  350 ++++++++++++++++
 lib/metadata/segtype.h           |   10 +-
 lib/mirror/mirrored.c            |    4 +-
 lib/misc/configure.h.in          |    8 +-
 lib/replicator/.exported_symbols |    1 +
 lib/replicator/Makefile.in       |   28 ++
 lib/replicator/replicator.c      |  820 ++++++++++++++++++++++++++++++++++++++
 lib/striped/striped.c            |    4 +-
 libdm/.exported_symbols          |    3 +
 libdm/libdevmapper.h             |   29 ++
 libdm/libdm-deptree.c            |  348 ++++++++++++++++-
 tools/args.h                     |    5 +
 tools/commands.h                 |   10 +-
 tools/lvcreate.c                 |   47 +++
 tools/lvmcmdline.c               |    9 +
 tools/toollib.c                  |   95 ++++-
 tools/tools.h                    |    1 +
 tools/vgchange.c                 |   15 +-
 32 files changed, 2200 insertions(+), 68 deletions(-)
 create mode 100644 lib/metadata/replicator_manip.c
 create mode 100644 lib/replicator/.exported_symbols
 create mode 100644 lib/replicator/Makefile.in
 create mode 100644 lib/replicator/replicator.c


