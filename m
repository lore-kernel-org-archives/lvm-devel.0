From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  8 Dec 2010 13:57:46 +0100
Subject: [PATCH 0/9] Udev latency
Message-ID: <cover.1291802397.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

WARNING  - Not a final patch - this is patch for discussion WARNING

Patch addresses udev latencies we may observe with commands
like 'vgchange -ay' when the command waits after dm table is created
also for udev to process its rules for each every created device.
This adds uncessary delays for larger LV sets.

Here are some basic numbers -

First number is taken on clean tree and (the second) is my own modified
code that has few more accelerations i.e. memlock & config parsing mods
which are however not yet in generably 'usable' form.
During tests - gvfs/gdu/udisk daemons were killed.

My testing vg contains 1708 linear devices.

vgchange -ay

Without udev in use (with current todays rawhide udev-164-6 package
which is in fact noticable slower) -   1:30.6 (55.2sec)
When latency patch is in use -         1:29  (44.8sec) (10sec diff - ~23%)

vgchange -an

Without udev latency patch -  2:35 (1:33.7)
With udev latency patch -     2:34 (1:31.4) (so only 2sec difference! ~3%)

NOTE:
 Tests've been repeated several times - times are relatively stable.
 Another interesting note - before today's udev upgrade - it's been 30%/5%.
 With older udev - thing were faster, and differences were bigger.
 
TODO:
 Release memlock & config parser patches - as they give big improvements.
 Though I want to discusse them first a bit - as the proper solution could
 be a bit tricky.

Zdenek Kabelac (9):
  Add get_lib_cookie
  Move fs_unlock
  Add lvm_do_unlock_fs
  Use internal cookie for dm_tree functions
  Stop calling fs_unlock() and dm_udev_wait()
  Add  LCK_UNLOCK_FS  and unlock_fs
  Add CLVMD_CMD_UNLOCK_FS command
  Locking with unlock_fs
  Wait for devices being created

 daemons/clvmd/clvm.h          |    1 +
 daemons/clvmd/clvmd-command.c |    6 ++
 daemons/clvmd/clvmd.c         |    3 +
 daemons/clvmd/lvm-functions.c |    7 +++
 daemons/clvmd/lvm-functions.h |    1 +
 lib/activate/activate.c       |    5 ++
 lib/activate/activate.h       |    2 +
 lib/activate/dev_manager.c    |   17 +------
 lib/activate/fs.c             |    1 +
 lib/activate/fs.h             |    1 -
 lib/locking/cluster_locking.c |    7 +++
 lib/locking/file_locking.c    |    6 ++
 lib/locking/locking.h         |    4 ++
 lib/metadata/lv_manip.c       |    3 +
 libdm/libdm-common.c          |   23 +++++++++
 libdm/libdm-common.h          |    1 +
 libdm/libdm-deptree.c         |  106 +++++++++++++++++++++++++++++++++++-----
 tools/lvmcmdline.c            |    3 +
 18 files changed, 166 insertions(+), 31 deletions(-)

--
1.7.3.3


