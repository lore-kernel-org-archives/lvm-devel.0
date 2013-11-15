From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 15 Nov 2013 16:00:03 +0100
Subject: [PATCH 0/6] Wiping for newly created LVs, support for blkid_wiping (configurable)
Message-ID: <528636F3.9010905@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patchset reuses existing signature recognition and wiping
that is already used during pvcreate. This refactor makes it possible
to use it for lvcreate and it's also bound to a new -W/--wipesignatures {y/n}
option for lvcreate.

The aim here is to wipe those signatures before any event-based scanning
happens. If those signatures are not properly wiped, we could possibly end
up with unwanted activation or mount of some old block device subsystem or
filesystem that just fits the newly created LV data area and which is then
recognized after event-based scans.

Also, this patchset adds a new configure option --enable-blkid_wiping
with which we link with libblkid to reuse the "wipefs" functionality
(that is much richer in signature/filesystem recognition).

Peter Rajnoha (6):
  device: add wipe_known_sbs wrapper fn
  lvcreate: recognize --wipesignatures arg
  lv_manip: rename set_lv -> wipe_lv and include signature wiping capability
  man: lvcreate -W/--wipesignatures {y/n}
  configure: add --enable-blkid_wiping
  wiping: add support for blkid wiping

 configure                        | 126 ++++++++++++++++++++++++++++++++++
 configure.in                     |  21 ++++++
 lib/device/dev-type.c            | 143 +++++++++++++++++++++++++++++++++++++++
 lib/device/dev-type.h            |   4 ++
 lib/metadata/lv_manip.c          |  98 +++++++++++++++++++--------
 lib/metadata/metadata-exported.h |  19 +++++-
 lib/metadata/metadata.c          |  46 ++-----------
 lib/metadata/mirror.c            |  18 +++--
 lib/metadata/raid_manip.c        |  11 ++-
 lib/metadata/thin_manip.c        |  12 +++-
 lib/misc/configure.h.in          |   3 +
 liblvm/lvm_lv.c                  |   1 +
 make.tmpl.in                     |   5 +-
 man/lvcreate.8.in                |  14 +++-
 tools/Makefile.in                |   2 +-
 tools/args.h                     |   1 +
 tools/commands.h                 |   4 +-
 tools/lvchange.c                 |  13 +++-
 tools/lvconvert.c                |  27 +++++++-
 tools/lvcreate.c                 |  15 ++--
 20 files changed, 488 insertions(+), 95 deletions(-)

-- 
1.8.4.2


