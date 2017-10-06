From: Alasdair Kergon <agk@sourceware.org>
Date: Fri, 6 Oct 2017 17:29:43 -0400
Subject: master - pre-release
Message-ID: <201710062129.v96LThgp026907@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=73b72b8331949a1af778ad34491de3c7663c107f
Commit:        73b72b8331949a1af778ad34491de3c7663c107f
Parent:        486ed108481cfbe4336f0fa590cbae251188ecc6
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Oct 6 22:10:48 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Oct 6 22:10:48 2017 +0100

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    9 +++++++--
 WHATS_NEW_DM |    4 ++--
 4 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index eda932e..9611e66 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.175(2)-git (2017-09-13)
+2.02.175(2)-git (2017-10-06)
diff --git a/VERSION_DM b/VERSION_DM
index 8a32c45..c5894b6 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.144-git (2017-09-13)
+1.02.144-git (2017-10-06)
diff --git a/WHATS_NEW b/WHATS_NEW
index bba813d..ded5335 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,12 +1,17 @@
-Version 2.02.175 - 
-======================================
+Version 2.02.175 - 6th October 2017
+===================================
   Use --help with blockdev when checking for --getsize64 support in fsadm.
+  Dump lvmdbusd debug information with SIGUSR1.
   Fix metadata corruption in vgsplit and vgmerge intermediate states.
   Add PV_MOVED_VG PV status flag to mark PVs moving between VGs.
+  Fix lvmdbus hang and recognise unknown VG correctly.
+  Improve error messages when command rules fail.
   Require LV name with pvmove in a shared VG.
   Allow shared active mirror LVs with lvmlockd, dlm, and cmirrord.
   Support lvconvert --repair with cache and cachepool volumes.
   lvconvert --repair respects --poolmetadataspare option.
+  Mark that we don't plan to develop liblvm2app and python bindings any further.
+  Fix thin pool creation in shared VG. (2.02.173)
 
 Version 2.02.174 - 13th September 2017
 ======================================
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index ea01089..e8035d1 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.144 - 
-======================================
+Version 1.02.144 - 6th October 2017
+===================================
   Schedule exit when received SIGTERM in dmeventd.
   Also try to unmount /boot on blkdeactivate -u if on top of supported device.
   Use blkdeactivate -r wait in blk-availability systemd service/initscript.


