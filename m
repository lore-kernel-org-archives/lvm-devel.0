From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 21 Dec 2010 16:41:32 +0100
Subject: [PATCH 00/23] Static analyzis set
Message-ID: <cover.1292945707.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is mostly the last bigger patch sets for covering
issues reported by Coverity tool.

Few patches needs some closer looking,
Most of them are trivial, but as they may present
some forgotten tests or missing code I'm posting
them for review.


Zdenek Kabelac (23):
  Remove dead assignment to thisfd
  Remove dead assignment
  Remove dead assigment of mirr_state
  Remove dead assignment of lock_flags
  Remove dead assignment in vgconvert_single
  Log of pthread_join operation
  Move  lastfd handling into for()
  Fix memory leak in error path of restart_clvmd
  Add test for errors in _setup_task
  Fix memory leak of dev_filter on error path
  Add stack traces for archive
  Add tests for dm_task_set operations
  Make it obvious this code is not used
  Add stack trace for backup and backup_remove
  Add test check for find_config_str
  Remove check for vg != NULL
  Add check for dm_snprintf result
  Return PERCENT_INVALID for error case
  Warning - dead code problem elimination
  exit if lvmchache_init fails
  Add default error path for get_property
  Remove dead assignment in dm_event_get_registered_device
  Remove dead assignment in vg_split_mdas

 daemons/clvmd/clvmd-command.c         |    3 +-
 daemons/clvmd/clvmd.c                 |   25 ++++++++++---------
 daemons/dmeventd/dmeventd.c           |    3 +-
 daemons/dmeventd/libdevmapper-event.c |   41 +++++++++++++++++---------------
 lib/activate/dev_manager.c            |   21 ++++++++++------
 lib/commands/toolcontext.c            |    2 +
 lib/filters/filter-persistent.c       |   22 ++++++++++++-----
 lib/format_text/archiver.c            |    9 +++++--
 lib/format_text/import_vsn1.c         |   18 ++++++--------
 lib/locking/cluster_locking.c         |   14 ++++++-----
 lib/locking/file_locking.c            |   16 +++++++++---
 lib/metadata/metadata.c               |    8 +++---
 lib/mirror/mirrored.c                 |    3 --
 lib/report/properties.c               |   15 +++++++-----
 liblvm/lvm_misc.c                     |    4 +++
 tools/lvscan.c                        |    6 -----
 tools/polldaemon.c                    |    3 +-
 tools/vgconvert.c                     |    4 +--
 tools/vgrename.c                      |    6 +++-
 19 files changed, 125 insertions(+), 98 deletions(-)

--
1.7.3.4


