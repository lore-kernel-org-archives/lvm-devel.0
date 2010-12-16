From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 16 Dec 2010 11:56:18 +0100
Subject: [PATCH 0/3] Udev latency II
Message-ID: <cover.1292496056.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Second version of 'udev' latency patch.

Addresses issues from last week call.

Patch set doesn't modify libdm cookie handling
and only change liblvm cookie handling to work with one
persistent cookie for all dm_tree operations.

For now 'set_lv()' looks like the only other place which
needs to wait of udev before vg lock is released so
currently fs_unlock() is called only from them.

No cluster command is then needed as wait happens automaticaly
before vg unlock operation.


Zdenek Kabelac (3):
  Add internal fs cookie
  Stop calling fs_unlock() and dm_udev_wait()
  Add fs_unlock calls

 daemons/clvmd/clvmd-command.c |    1 +
 daemons/clvmd/lvm-functions.c |    8 ++++++++
 daemons/clvmd/lvm-functions.h |    1 +
 include/.symlinks.in          |    1 +
 lib/activate/activate.c       |    5 +++++
 lib/activate/dev_manager.c    |   23 ++++++-----------------
 lib/activate/fs.c             |   15 +++++++++++++++
 lib/activate/fs.h             |    2 ++
 lib/locking/file_locking.c    |    2 ++
 lib/metadata/lv_manip.c       |    4 ++++
 10 files changed, 45 insertions(+), 17 deletions(-)

-- 
1.7.3.3


