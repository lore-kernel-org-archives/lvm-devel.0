From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 26 Feb 2010 16:04:19 -0500
Subject: [PATCH 0/3] shared snapshot removal fix and cleanups
Message-ID: <1267218262-23954-1-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Mikulas,

These patches apply at the end of the quilt series I published here:
http://people.redhat.com/msnitzer/patches/multisnap/lvm2/LVM2-2.02.62/

Please make sure you have udev_sync enabled when testing; otherwise
the shared exception store (-cow and -real) device removal will be
unreliable (racing with udev).

Mike Snitzer (3):
  Use the origin's uuid as the basis for the shared cow's uuid.
  Introduce find_shared_cow() and lv_is_shared_cow() wrappers.
  Eliminate 'shared_snapshot' from 'struct logical_volume'.

 lib/activate/dev_manager.c       |   37 ++++++++++++++++-----------
 lib/format_text/flags.c          |    1 +
 lib/metadata/lv_alloc.h          |    2 +-
 lib/metadata/lv_manip.c          |    3 +-
 lib/metadata/metadata-exported.h |   10 ++++----
 lib/metadata/snapshot_manip.c    |   50 ++++++++++++++++++++++++++++++-------
 lib/report/report.c              |    8 +++---
 tools/lvresize.c                 |    3 +-
 8 files changed, 75 insertions(+), 39 deletions(-)


