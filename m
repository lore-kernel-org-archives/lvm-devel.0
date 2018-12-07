From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 7 Dec 2018 09:15:32 -0500
Subject: 2018-06-01-stable - pre-release
Message-ID: <201812071415.wB7EFWug012655@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f5ea02ffee3269a77e295d2b186ca81481f592d7
Commit:        f5ea02ffee3269a77e295d2b186ca81481f592d7
Parent:        262a42025ffef8a0ccb02e13d60abf3707d7c832
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Dec 6 11:26:26 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Dec 7 15:12:34 2018 +0100

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    6 ++++--
 WHATS_NEW_DM |    5 +++--
 4 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index 46e7b87..3dc7946 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.183(2)-git (2018-10-30)
+2.02.183(2) (2018-12-07)
diff --git a/VERSION_DM b/VERSION_DM
index 9c3ba5f..2cf798e 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.154-git (2018-10-30)
+1.02.154 (2018-12-07)
diff --git a/WHATS_NEW b/WHATS_NEW
index b60612f..1bb2686 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
-Version 2.02.183 - 
-====================================
+Version 2.02.183 - 07th December 2018
+=====================================
+  Avoid disabling lvmetad when repair does nothing.
+  Fix component detection for md version 0.90.
   Use sync io if async io_setup fails, or use_aio=0 is set in config.
   Avoid opening devices to get block size by using existing open fd.
 
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index d219f3d..6fc667d 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,6 +1,7 @@
-Version 1.02.154 - 
-====================================
+Version 1.02.154 - 07th December 2018
+=====================================
   Do not add parameters for RESUME with DM_DEVICE_CREATE dm task.
+  Fix dmstats report printing no output.
 
 Version 1.02.152 - 30th October 2018
 ====================================


