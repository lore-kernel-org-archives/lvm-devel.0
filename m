From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  1 Feb 2021 13:38:26 +0000 (GMT)
Subject: stable-2.02 - WHATS_NEW: updates
Message-ID: <20210201133826.42543382E071@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1728f411834c20a93f465e99dedad5afbca45ea1
Commit:        1728f411834c20a93f465e99dedad5afbca45ea1
Parent:        1282e9e2984a6ad48e9ee09a15dce7f3aab3e833
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 1 12:12:23 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 1 14:35:53 2021 +0100

WHATS_NEW: updates

---
 WHATS_NEW | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index 311923204..a50762703 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,10 @@
 Version 2.02.188 - 
 ==================================
+  Allocation prints better error when metadata cannot fit on a single PV.
+  Pvmove can better resolve full thin-pool tree move.
+  Limit pool metadata spare to 16GiB.
+  Improves convertsion and allocation of pool metadata.
+  Support thin pool metadata 15.88GiB, adds 64MiB, thin_pool_crop_metadata=0.
   Enhance lvdisplay to report raid availiable/partial.
   Enhance error handling for fsadm and hanled correct fsck result.
   Stop logging rename errors from persintent filter.


