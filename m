From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 7 Jun 2019 11:30:16 -0400
Subject: master - pre-release
Message-ID: <201906071530.x57FUGgc029628@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cb6277aa8a1f6d0dedf2082995b1673da1eb46f9
Commit:        cb6277aa8a1f6d0dedf2082995b1673da1eb46f9
Parent:        c315112a3b7d01e56cbd2ecb3d05f55d44a50e12
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Jun 7 16:32:02 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Jun 7 17:24:51 2019 +0200

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |   12 ++++++++----
 WHATS_NEW_DM |    6 +++++-
 4 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/VERSION b/VERSION
index 83eb504..d2f613b 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.03.02(2)-git (2018-10-31)
+2.03.03(2) (2019-06-07)
diff --git a/VERSION_DM b/VERSION_DM
index 4866208..78eb98d 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.155-git (2018-10-31)
+1.02.159 (2019-06-07)
diff --git a/WHATS_NEW b/WHATS_NEW
index b5deceb..1062c27 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.03.02 - 
-===================================
+Version 2.03.03 - 07th June 2019
+================================
   Report no_discard_passdown for cache LVs with lvs -o+kernel_discards.
   Add pvck --dump option to extract metadata.
   Fix signal delivery checking race in libdaemon (lvmetad).
@@ -35,10 +35,14 @@ Version 2.03.02 -
   Fix missing unlock on lvm2 dmeventd plugin error path initialization.
   Improve Makefile dependency tracking.
   Move VDO support towards V2 target (6.2) support.
+
+Version 2.03.02 - 18th December 2018
+====================================
   Fix missing proper initialization of pv_list struct when adding pv.
-  Fix (de)activation of RaidLVs with visible SubLVs
-  Prohibit mirrored 'mirror' log via lvcreate and lvconvert
+  Fix (de)activation of RaidLVs with visible SubLVs.
+  Prohibit mirrored 'mirror' log via lvcreate and lvconvert.
   Use sync io if async io_setup fails, or use_aio=0 is set in config.
+  Fix more issues reported by coverity scan.
 
 Version 2.03.01 - 31st October 2018
 ===================================
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 8a2146d..8edd76c 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,11 +1,15 @@
-Version 1.02.155 - 
+Version 1.02.159 - 07th June 2019
 ====================================
   Parsing of cache status understand no_discard_passdown.
   Ensure migration_threshold for cache is at least 8 chunks.
+
+Version 1.02.155 - 18th December 2018
+=====================================
   Include correct internal header inside libdm list.c.
   Enhance ioctl flattening and add parameters only when needed.
   Add DM_DEVICE_ARM_POLL for API completness matching kernel.
   Do not add parameters for RESUME with DM_DEVICE_CREATE dm task.
+  Fix dmstats report printing no output.
 
 Version 1.02.153 - 31st October 2018
 ====================================


