From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Feb 2021 10:54:50 +0000 (GMT)
Subject: main - WHATS_NEW: updates
Message-ID: <20210217105450.6912C3854819@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=26a09c84c9498b187eec776150cd1eeafeda6ce7
Commit:        26a09c84c9498b187eec776150cd1eeafeda6ce7
Parent:        2c5e034cd3cb480d79ac4cc23a6d5079bb053f28
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 17 11:27:57 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 17 11:53:19 2021 +0100

WHATS_NEW: updates

---
 WHATS_NEW | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index 01ee40dc4..21684992d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,12 @@
 Version 2.03.12 - 
 ===================================
+  Check for presence of VDO target before starting any conversion.
+  Support metatadata profiles with volume VDO pool conversions.
+  Support -Zn for conversion of already formated VDO pools.
+  Avoid removing LVs on error path of lvconvert during creation volumes.
+  Fix crashing lvdisplay when thin volume was waiting for merge.
+  Support option --errorwhenfull when converting volume to thin-pool.
+  Improve thin-performance profile support conversion to thin-pool.
   Add workaround to avoid read of internal 'converted' devices.
   Prohibit merging snapshot into the read-only thick snapshot origin.
   Restore support for flipping rw/r permissions for thin snapshot origin.


