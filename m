From: Leo Yan <leo.yan@linaro.org>
Date: Fri,  7 May 2021 10:25:11 +0800
Subject: [LVM2 RFCv2 0/5] Enable In-Drive-Mutex Locking scheme
Message-ID: <20210507022516.143385-1-leo.yan@linaro.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch set enables the In-Drive-Mutex (IDM) locking scheme.  The
previous patch series [1] have given a briefly introduction for IDM and
it's associated locking manager and lib.

This series follows up Dave's comments and refines the patches.

And this patch series has been tested with IDM/sanlock/DLM locking
schemes for VG and LV creating, removing, activating and deactivating,
these operations can work as expected for all of these three locking
schemes.

[1] https://listman.redhat.com/archives/lvm-devel/2021-April/msg00111.html

Changes from RFCv1:
* Updated commit log for LVB (Dave);
* Refined the change to only pass PV list for IDM lock type (Dave);
* Refined retriving PV list with function lv_is_on_pv() (Dave);
* Added condition checking for passing PV list in lvmlockd after found
  a regression on sanlock locking scheme.


Leo Yan (5):
  lvmlockd: idm: Introduce new locking scheme
  lvmlockd: idm: Hook Seagate IDM wrapper APIs
  lib: locking: Add new type "idm"
  lib: locking: Parse PV list for IDM locking
  tools: Add support for "idm" lock type

 configure                            | 173 ++++++
 configure.ac                         |  20 +
 daemons/lvmlockd/Makefile.in         |   5 +
 daemons/lvmlockd/lvmlockd-core.c     | 281 ++++++++-
 daemons/lvmlockd/lvmlockd-idm.c      | 837 +++++++++++++++++++++++++++
 daemons/lvmlockd/lvmlockd-internal.h | 110 ++++
 lib/display/display.c                |   4 +
 lib/locking/lvmlockd.c               | 330 ++++++++++-
 lib/metadata/metadata-exported.h     |   1 +
 lib/metadata/metadata.c              |  12 +-
 tools/lvconvert.c                    |   2 +
 tools/toollib.c                      |  11 +-
 12 files changed, 1726 insertions(+), 60 deletions(-)
 create mode 100644 daemons/lvmlockd/lvmlockd-idm.c

-- 
2.25.1


