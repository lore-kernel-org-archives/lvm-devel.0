From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri,  7 May 2021 21:15:12 +0000 (GMT)
Subject: main - pre-release
Message-ID: <20210507211512.2B5C33890426@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=01b05cf51dd547354b4ad70e7f8f4ff7ff0bb152
Commit:        01b05cf51dd547354b4ad70e7f8f4ff7ff0bb152
Parent:        64719861ec094607162cd4faa4a0b2f1d8a3421c
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri May 7 22:34:45 2021 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri May 7 23:09:09 2021 +0200

pre-release

---
 VERSION      |  2 +-
 VERSION_DM   |  2 +-
 WHATS_NEW    | 16 ++++++++++------
 WHATS_NEW_DM |  4 ++--
 4 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/VERSION b/VERSION
index 5723491c3..d9c3e2336 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.03.12(2)-git (2021-01-08)
+2.03.12(2) (2021-05-07)
diff --git a/VERSION_DM b/VERSION_DM
index 380bd1ed5..6105a0ff1 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.177-git (2021-01-08)
+1.02.177 (2021-05-07)
diff --git a/WHATS_NEW b/WHATS_NEW
index 7917c2690..6f339a509 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,10 +1,13 @@
-Version 2.03.12 - 
-===================================
+Version 2.03.12 - 07th May 2021
+===============================
+  Allow attaching cache to thin data volume.
   Fix memleak when generating list of outdated pvs.
   Better hyphenation usage in man pages.
   Replace use of deprecated security_context_t with char*.
   Configure supports AIO_LIBS and AIO_CFLAGS.
   Improve build process for static builds.
+  New --setautoactivation option to modify LV or VG auto activation.
+  New metadata based autoactivation property for LVs and VGs.
   Improve signal handling with lvmpolld.
   Signal handler can interrupt command also for SIGTERM.
   Lvreduce --yes support.
@@ -20,6 +23,7 @@ Version 2.03.12 -
   Merge polling does not fail, when LV is found to be already merged.
   Poll volumes with at least 100ms delays.
   Do not flush dm cache when cached LV is going to be removed.
+  New lvmlockctl_kill_command configuration option.
   Support interruption while waiting on device close before deactivation.
   Flush thin-pool messages before removing more thin volumes.
   Improve hash function with less collisions and make it faster.
@@ -33,6 +37,7 @@ Version 2.03.12 -
   Add devices file feature, off by default for now.
   Support extension of writecached volumes.
   Fix problem with unbound variable usage within fsadm.
+  Fix IMSM MD RAID detection on 4k devices.
   Check for presence of VDO target before starting any conversion.
   Support metatadata profiles with volume VDO pool conversions.
   Support -Zn for conversion of already formated VDO pools.
@@ -49,11 +54,11 @@ Version 2.03.12 -
   Allocation prints better error when metadata cannot fit on a single PV.
   Pvmove can better resolve full thin-pool tree move.
   Limit pool metadata spare to 16GiB.
-  Improves convertsion and allocation of pool metadata.
+  Improves conversion and allocation of pool metadata.
   Support thin pool metadata 15.88GiB, adds 64MiB, thin_pool_crop_metadata=0.
-  Enhance lvdisplay to report raid availiable/partial.
+  Enhance lvdisplay to report raid available/partial.
   Support online rename of VDO pools.
-  Imporove removal of pmspare when last pool is removed.
+  Improve removal of pmspare when last pool is removed.
   Fix problem with wiping of converted LVs.
   Fix memleak in scanning  (2.03.11).
   Fix corner case allocation for thin-pools.
@@ -256,7 +261,6 @@ Version 2.03.00 - 10th October 2018
   Remove clvmd
   Remove lvmlib (api)
   Remove lvmetad
-  lvconvert: provide possible layouts between linear and striped/raid
   Use versionsort to fix archive file expiry beyond 100000 files.
 
 Version 2.02.178-rc1 - 24th May 2018
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 8d070ed1f..fe4310509 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.177 - 
-====================================
+Version 1.02.177 - 07th May 2021
+================================
   Configure proceeds without libaio to allow build of device-mapper only.
   Fix symbol versioning build with -O2 -flto.
   Add dm_tree_node_add_thin_pool_target_v1 with crop_metadata support.


