From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 24 Mar 2021 15:41:58 +0000 (GMT)
Subject: main - WHATS_NEW: updates
Message-ID: <20210324154158.04F8D384B061@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=73710b87fb567e3d6d72b475afe9f95ccc0afad6
Commit:        73710b87fb567e3d6d72b475afe9f95ccc0afad6
Parent:        c1f5ca6751eeda5925638447b561b05bdf8a250c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 24 16:30:23 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 24 16:41:08 2021 +0100

WHATS_NEW: updates

---
 WHATS_NEW | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index 80e16d880..3e086f951 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.03.12 - 
 ===================================
+  Report error when the filesystem is missing on fsadm resized volume.
+  Handle better blockdev with --getsize64 support for fsadm.
   Do not include editline/history.h when using editline library.
   Support lvconvert -Zn with thin-pool conversion.
   Support error and zero segtype for thin-pool data for testing.


