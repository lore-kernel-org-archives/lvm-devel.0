From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  2 Feb 2011 14:07:56 +0100
Subject: [PATCH 0/5] Fixes for relase
Message-ID: <cover.1296651808.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Contains minimal consistent patchset for a release.

1st patch might need  very simply 'hack' to make it work properly.
But currently I fail to see how :(

Others are fixes releated to multiple stacked operations.

As we have had still left fs_unlock with every lv_resume()
these were not really a big problem - but once this is removed
the lv_info() check showed as the best place for checking 
udev sychronization and making sure there are no operations in 
progress. (This is very quick one the cookie is 0)


Zdenek Kabelac (5):
  Fix clustered and no-lock locking with HOTFIX
  Move add_dev_node to DM_DEVICE_RESUME
  Fix operation node stacking
  lv_info handle udev_sync
  Remove  open_count read from some lv_info calls

 daemons/clvmd/clvmd-command.c |    5 ++-
 daemons/clvmd/clvmd.c         |    3 ++
 daemons/clvmd/lvm-functions.c |    9 ++++-
 daemons/clvmd/lvm-functions.h |    2 +-
 lib/activate/activate.c       |   15 +++++++-
 lib/activate/fs.c             |   66 ++++++++++++++++++++++++++++++++++++--
 lib/activate/fs.h             |    1 +
 lib/locking/cluster_locking.c |    6 ++--
 lib/locking/locking.c         |    7 ++--
 lib/locking/locking.h         |   22 +++++++++++-
 libdm/ioctl/libdm-iface.c     |    8 ++--
 libdm/libdm-common.c          |   71 ++++++++++++++++++++++++++++++++++++-----
 liblvm/lvm_lv.c               |    4 +-
 tools/lvconvert.c             |    2 +-
 tools/lvscan.c                |    2 +-
 15 files changed, 190 insertions(+), 33 deletions(-)

-- 
1.7.3.5


