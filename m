From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 18 Mar 2021 18:15:12 +0000 (GMT)
Subject: main - WHATS_NEW: updates
Message-ID: <20210318181512.E5951386EC23@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b4ab2a10511cba2f7679cf12929438b6d2d6232d
Commit:        b4ab2a10511cba2f7679cf12929438b6d2d6232d
Parent:        26fb6b5e8d61e3d3097fccf4fca5bd9582fbbb4f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 18 16:55:20 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 18 19:12:35 2021 +0100

WHATS_NEW: updates

---
 WHATS_NEW | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index e4ccd1b0d..5d018ef36 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,11 @@
 Version 2.03.12 - 
 ===================================
+  Support lvconvert -Zn with thin-pool conversion.
+  Support error and zero segtype for thin-pool data for testing.
+  Support mixed extension for striped, error and zero segtypes.
+  Support resize also for stacked virtual volumes.
+  Skip dm-zero devices just like with dm-error target.
+  Reduce ioctl() calls when checking target status.
   Merge polling does not fail, when LV is found to be already merged.
   Poll volumes with at least 100ms delays.
   Do not flush dm cache when cached LV is going to be removed.


