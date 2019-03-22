From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 22 Mar 2019 06:17:10 -0400
Subject: stable-2.02 - pre_release
Message-ID: <201903221017.x2MAHA3i011419@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7cbee7e9cf5445ee5c50898e20536734cbb0f4a6
Commit:        7cbee7e9cf5445ee5c50898e20536734cbb0f4a6
Parent:        717957ddc5bcca529a4fe830e272c678a935e2ee
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Mar 22 11:04:15 2019 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Mar 22 11:04:15 2019 +0100

pre_release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    4 ++--
 WHATS_NEW_DM |    4 ++--
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index 9ae261d..37f89d5 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.184(2)-git (2018-12-07)
+2.02.184(2) (2019-03-22)
diff --git a/VERSION_DM b/VERSION_DM
index 0ccad6e..f874e31 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.156-git (2018-12-07)
+1.02.156 (2019-03-22)
diff --git a/WHATS_NEW b/WHATS_NEW
index 0488a50..ffdd5aa 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.02.184 - 
-=====================================
+Version 2.02.184 - 22nd March 2019
+==================================
   Fix (de)activation of RaidLVs with visible SubLVs
   Change scan_lvs default to 0 so LVs are not scanned for PVs.
   Add scan_lvs config setting to control if lvm scans LVs for PVs.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 5d3c9db..4e245fb 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.156 - 
-=====================================
+Version 1.02.156 - 22nd March 2019
+==================================
   Ensure migration_threshold for cache is at least 8 chunks.
   Enhance ioctl flattening and add parameters only when needed.
   Add DM_DEVICE_ARM_POLL for API completness matching kernel.


