From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 11 Feb 2020 05:01:12 -0500
Subject: master - pre-release
Message-ID: <21932.120021105010500679@us-mta-223.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b9752d719ce533c10eff9e6dbad560da33f50b65
Commit:        b9752d719ce533c10eff9e6dbad560da33f50b65
Parent:        3716aa848efef716ba8596d585a312fdb61850d3
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Feb 11 10:50:50 2020 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Feb 11 10:51:57 2020 +0100

pre-release

---
 VERSION      | 2 +-
 VERSION_DM   | 2 +-
 WHATS_NEW    | 6 +++++-
 WHATS_NEW_DM | 2 +-
 4 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/VERSION b/VERSION
index 51f8e6909..c5cc2e463 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.03.08(2)-git (2019-11-30)
+2.03.08(2) (2020-02-11)
diff --git a/VERSION_DM b/VERSION_DM
index 933e2d397..f90962518 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.169-git (2019-11-30)
+1.02.169 (2020-02-11)
diff --git a/WHATS_NEW b/WHATS_NEW
index b03eb9732..50a00452a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,9 +1,13 @@
-Version 2.03.08 - 
+Version 2.03.08 - 11th February 2020
 ====================================
+  Prevent problematic snapshots of writecache volumes.
   Add error handling for failing allocation in _reserve_area().
   Fix memleak in syncing of internal cache.
   Fix pvck dump_current_text memleak.
   Fix lvmlockd result code on error path for _query_lock_lv().
+  Update pvck man page and help output.
+  Reject invalid writecache high/low_watermark setting.
+  Report writecache status.
   Accept more output lines from vdo_format.
   Prohibit reshaping of stacked raid LVs.
   Avoid running cache input arg validation when creating vdo pool.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index a1e233e67..eb8b84c36 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,4 +1,4 @@
-Version 1.02.169 - 
+Version 1.02.169 - 11th February 2020
 =====================================
   Enhance error messages for device creation.
 



