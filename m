From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  1 Feb 2021 11:47:38 +0000 (GMT)
Subject: main - WHATS_NEW: updates
Message-ID: <20210201114738.7A9B23836C6F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8f5695fa71e0b293e774cfbaf7af7985896cd47a
Commit:        8f5695fa71e0b293e774cfbaf7af7985896cd47a
Parent:        be0bf43d742a127435962d7075608519f18d4cdc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 1 12:12:23 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 1 12:13:49 2021 +0100

WHATS_NEW: updates

---
 WHATS_NEW | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index ef1afaabd..c6be9b481 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,10 @@
 Version 2.03.12 - 
 ===================================
+  Allocation prints better error when metadata cannot fit on a single PV.
+  Pvmove can better resolve full thin-pool tree move.
+  Limit pool metadata spare to 16GiB.
+  Improves convertsion and allocation of pool metadata.
+  Support thin pool metadata 15.88GiB, adds 64MiB, thin_pool_crop_metadata=0.
   Enhance lvdisplay to report raid availiable/partial.
   Support online rename of VDO pools.
   Imporove removal of pmspare when last pool is removed.


