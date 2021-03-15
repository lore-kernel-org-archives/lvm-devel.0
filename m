From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Mar 2021 10:14:26 +0000 (GMT)
Subject: main - WHATS_NEW: updates
Message-ID: <20210315101426.5B8B33858039@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e6912cc61cd33e040dcab326b3ea7c292ff3f699
Commit:        e6912cc61cd33e040dcab326b3ea7c292ff3f699
Parent:        b4a74d1008e114d5976a235b3a6f793181bc5745
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 15 10:58:00 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 15 11:13:24 2021 +0100

WHATS_NEW: updates

---
 WHATS_NEW | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index 568a7df90..e4ccd1b0d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,10 @@
 Version 2.03.12 - 
 ===================================
+  Merge polling does not fail, when LV is found to be already merged.
+  Poll volumes with at least 100ms delays.
+  Do not flush dm cache when cached LV is going to be removed.
+  Support interruption while waiting on device close before deactivation.
+  Flush thin-pool messages before removing more thin volumes.
   Improve hash function with less collisions and make it faster.
   Reduce ioctl count when deactivating volumes.
   Reduce number of metadata parsing.


