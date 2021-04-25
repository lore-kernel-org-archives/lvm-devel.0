From: Leo Yan <leo.yan@linaro.org>
Date: Sun, 25 Apr 2021 10:22:36 +0800
Subject: [LVM2 RFCv1 0/5] Enable In-Drive-Mutex Locking scheme
Message-ID: <20210425022241.5055-1-leo.yan@linaro.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch set enables the In-Drive-Mutex (IDM) locking scheme.

The In-Drive-Mutex (IDM) offers an alternative to sanlock and DLM
barrier operations for lvmlockd controlled metadata updates.
This mechanism works differently from the two existing methods
in that it does not use a specific logical volume (LV) for lock leasing,
instead we rely on drives that implement new SCSI commands such that
every host can acquire and release locks from the drive firmware.
By managing the synchronization of metadata updates from multiple
servers within the drive creates a single point of truth which
removes potential state synchronization errors from drive hotswap and other
issues.  The reduction in complexity simplifies lvmlockd and increases
performance of metadata updates for shared volume groups.

For easier using IDM locking, the IDM locking manager and IDM lib are
provided.  The IDM lock manager runs as a daemon and it acts as a bridge
between lvmlockd and drive firmware; the IDM lib APIs is provided
for lvmlockd easily to invoke.  Therefore, the IDM locking manager and
IDM library are a good place to understand deeper for the locking scheme
and its algorithms, its code can be found on the github [1].

The patches in this set are arranged with the bottom-to-top approach.

The patch 01 presents the IDM wrapper layer for lvmlockd, it shows
the interface with IDM locking manager daemon.  By reading this patch,
especially for locking/unlocking/convert APIs, hope it can give out some
basic idea for the usages for IDM.  The patch 02 is to hook IDM
with lvmlockd core layer.

The latter two patches 03 and 04 are to enable Seagate IDM in the locking
lib; the locking lib is invoked by LVM commands, after enable the IDM
locking scheme, we need to ask locking lib to generate PV list for
VG/LV and pass the list from LVM command to lvmlockd.  As the result,
the PVs are the target for sending IDM SCSI commands which finally is
used by IDM lock manager.

The last patch is a minor enabling IDM locking scheme in tools.

This patch set has been tested with Seagate drives which has been
flashed firmware for supporting IDM.  The basic operations for VG/VL
creating/removing, activation/deactivation, and thin pool can pass the
testing with IDM.

It's planned to enable IDM testing with LVM testing framework, which
will be sent out later in a separate patch series.

[1] https://github.com/Seagate/propeller


Leo Yan (5):
  lvmlockd: idm: Introduce new locking scheme
  lvmlockd: idm: Hook Seagate IDM wrapper APIs
  lib: locking: Add new type "idm"
  lib: locking: Parse PV list for IDM locking
  tools: Add support for "idm" lock type

 configure                            | 173 ++++++
 configure.ac                         |  20 +
 daemons/lvmlockd/Makefile.in         |   5 +
 daemons/lvmlockd/lvmlockd-core.c     | 279 ++++++++-
 daemons/lvmlockd/lvmlockd-idm.c      | 837 +++++++++++++++++++++++++++
 daemons/lvmlockd/lvmlockd-internal.h | 110 ++++
 lib/display/display.c                |   4 +
 lib/locking/lvmlockd.c               | 356 +++++++++++-
 lib/metadata/metadata-exported.h     |   1 +
 lib/metadata/metadata.c              |  12 +-
 tools/lvconvert.c                    |   2 +
 tools/toollib.c                      |  11 +-
 12 files changed, 1756 insertions(+), 54 deletions(-)
 create mode 100644 daemons/lvmlockd/lvmlockd-idm.c

-- 
2.25.1


