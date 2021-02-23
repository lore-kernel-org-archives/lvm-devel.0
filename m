From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 23 Feb 2021 14:04:22 +0000 (GMT)
Subject: main - WHATS_NEW: updates
Message-ID: <20210223140422.1F1C0393A422@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f7d9542aed2615c2a3737ec055a15b79877ac7fc
Commit:        f7d9542aed2615c2a3737ec055a15b79877ac7fc
Parent:        5d820b02012bbadb07990ee20034145ab8e2fb0e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 23 15:00:17 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 15:01:05 2021 +0100

WHATS_NEW: updates

---
 WHATS_NEW | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 21684992d..ff4120a47 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.03.12 - 
 ===================================
+  Support extension of writecached volumes.
+  Fix problem with unbound variable usage within fsadm.
   Check for presence of VDO target before starting any conversion.
   Support metatadata profiles with volume VDO pool conversions.
   Support -Zn for conversion of already formated VDO pools.
@@ -29,7 +31,7 @@ Version 2.03.11 - 08th January 2021
 ===================================
   Fix pvck handling MDA at offset different from 4096.
   Partial or degraded activation of writecache is not allowed.
-  Enhance error handling for fsadm and hanled correct fsck result.
+  Enhance error handling for fsadm and handle correct fsck result.
   Dmeventd lvm plugin ignores higher reserved_stack lvm.conf values.
   Support using BLKZEROOUT for clearing devices.
   Support interruption when wipping LVs.


