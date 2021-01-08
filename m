From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri,  8 Jan 2021 09:11:17 +0000 (GMT)
Subject: main - pre-release
Message-ID: <20210108091117.51837386F419@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3e8bd8d1bd70691f09a170785836aeb4f83154e6
Commit:        3e8bd8d1bd70691f09a170785836aeb4f83154e6
Parent:        e9503f257ad2e61742b0cfe2780b72739d1d3978
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Jan 7 17:22:29 2021 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Jan 8 10:07:25 2021 +0100

pre-release

---
 VERSION      | 2 +-
 VERSION_DM   | 2 +-
 WHATS_NEW    | 9 +++++++--
 WHATS_NEW_DM | 4 ++--
 4 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index a6ba8f65a..55f5caa3f 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.03.11(2)-git (2020-08-09)
+2.03.11(2) (2021-01-08)
diff --git a/VERSION_DM b/VERSION_DM
index f44bc5f06..6b83c6cee 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.175-git (2020-08-09)
+1.02.175 (2021-01-08)
diff --git a/WHATS_NEW b/WHATS_NEW
index 452a6317e..18f503202 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
-Version 2.03.11 - 
-==================================
+Version 2.03.11 - 08th January 2021
+===================================
+  Fix pvck handling MDA at offset different from 4096.
+  Partial or degraded activation of writecache is not allowed.
   Enhance error handling for fsadm and hanled correct fsck result.
   Dmeventd lvm plugin ignores higher reserved_stack lvm.conf values.
   Support using BLKZEROOUT for clearing devices.
@@ -20,6 +22,9 @@ Version 2.03.11 -
   Enhance --use-policy percentage rounding.
   Configure --with-vdo and --with-writecache as internal segments.
   Improving VDO man page examples.
+  Allow pvmove of writecache origin.
+  Report integrity fields.
+  Integrity volumes defaults to journal mode.
   Switch code base to use flexible array syntax.
   Fix 64bit math when calculation cachevol size.
   Preserve uint32_t for seqno handling.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 9624c0d78..1ba361d3a 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.175 - 
-===================================
+Version 1.02.175 - 08th January 2021
+====================================
 
 Version 1.02.173 - 09th August 2020
 ===================================


