From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 20 Nov 2009 17:35:40 -0500
Subject: [PATCH 00/15] lvm2 support for snapshot-merge
Message-ID: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patchset adds libdm and lvm support for snapshot-merge target.
It also adds --merge flag to lvconvert; lvconvert is the command that
one will use to merge a snapshot in its origin device.  The lvconvert
manpage has been updated accordingly.

For more details please see the individual patch headers.

The LVM2 snapshot-merge quilt tree has been maintained here:
http://people.redhat.com/msnitzer/patches/snapshot-merge/lvm2/LVM2-2.02.55/

* Aside from snapshot-merge specific testing, these patches have
  survived 75+ iterations of lvm2's testsuite without any failures.
  The test kernel was 2.6.32-rc8 and lvm2 was 2.0.55 (with udev_sync
  enabled and dmeventd disabled).

Mike Snitzer (5):
  use snapshot metadata usage to determine if snapshot is empty
  Add support for "snapshot-merge" target.
  device-mapper-merging-store-needs-cow-suffix
  lvm-merge-onactivate
  lvm-merge-man-lvconvert

Mikulas Patocka (10):
  lvm-merge-metadata
  device-mapper-merge-activation
  lvm-merge-lvconvert
  lvm-merge-check-for-mounted-lv
  lvm-merge-reporting
  lvm-merge-origin-report-progress
  lvm-merge-background-poll
  lvm-merge-background-poll-on-lvvgchange
  lvm-merge-reload-if-stopped-merging
  lvm-merge-reload-proper-order

 lib/activate/activate.c          |    2 +-
 lib/activate/dev_manager.c       |   94 +++++++++++++++--
 lib/format_text/flags.c          |    1 +
 lib/metadata/lv_manip.c          |   31 ++++--
 lib/metadata/metadata-exported.h |    6 +-
 lib/metadata/snapshot_manip.c    |   13 ++-
 lib/report/report.c              |   31 ++++--
 lib/snapshot/snapshot.c          |   41 +++++---
 libdm/.exported_symbols          |    1 +
 libdm/libdevmapper.h             |    6 +
 libdm/libdm-deptree.c            |   72 +++++++++++--
 man/lvconvert.8.in               |   29 +++++-
 tools/args.h                     |    1 +
 tools/commands.h                 |   11 ++-
 tools/lvconvert.c                |  214 ++++++++++++++++++++++++++++++++++++--
 tools/toollib.c                  |   14 +++-
 tools/vgchange.c                 |    3 +-
 17 files changed, 505 insertions(+), 65 deletions(-)


