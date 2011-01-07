From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  7 Jan 2011 12:17:28 +0100
Subject: [PATCH 0/8] Fixes and speedups
Message-ID: <cover.1294398815.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patchset combines few fixes from the last review.
Hopefully they should be now in the 'acceptable' state.

And also fix for ocfdir and its selection is added.

I hope it'll hit 2.02.80 version.

Zdenek Kabelac (8):
  Add support for OCF dir selection
  Add default error path for get_property
  Change import_vg_from_buffer to use config_tree
  Cache config_tree
  Define DM_COOKIE_AUTO_CREATE
  Add internal fs cookie
  Stop calling fs_unlock() and dm_udev_wait()
  Add fs_unlock calls

 configure.in                  |    5 +++++
 daemons/clvmd/clvmd-command.c |    1 +
 daemons/clvmd/lvm-functions.c |    8 ++++++++
 daemons/clvmd/lvm-functions.h |    1 +
 include/.symlinks.in          |    1 +
 lib/activate/activate.c       |    2 --
 lib/activate/dev_manager.c    |   25 ++++++++-----------------
 lib/activate/fs.c             |   22 +++++++++++++++++++++-
 lib/activate/fs.h             |    2 ++
 lib/cache/lvmcache.c          |   19 +++++++++++++++++--
 lib/cache/lvmcache.h          |    3 +++
 lib/format_text/import.c      |    9 ++-------
 lib/locking/file_locking.c    |    2 ++
 lib/metadata/lv_manip.c       |    3 +++
 lib/metadata/metadata.h       |    3 +++
 libdm/libdevmapper.h          |    5 +++++
 liblvm/lvm_misc.c             |   26 +++++++++++---------------
 make.tmpl.in                  |    2 +-
 18 files changed, 94 insertions(+), 45 deletions(-)

-- 
1.7.3.4


