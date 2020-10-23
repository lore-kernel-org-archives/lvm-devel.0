From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Oct 2020 23:43:30 +0000 (GMT)
Subject: master - WHATS_NEW: update
Message-ID: <20201023234330.F1B00384A881@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2183af62e56ff68e77eb29c7da9fcf2445b30eba
Commit:        2183af62e56ff68e77eb29c7da9fcf2445b30eba
Parent:        edb55b767a45d6c7eb5194dea23c11b5ae5f71d3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 24 01:40:55 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Oct 24 01:42:16 2020 +0200

WHATS_NEW: update

---
 WHATS_NEW | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index 16a8baf34..452a6317e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.03.11 - 
 ==================================
+  Enhance error handling for fsadm and hanled correct fsck result.
+  Dmeventd lvm plugin ignores higher reserved_stack lvm.conf values.
   Support using BLKZEROOUT for clearing devices.
   Support interruption when wipping LVs.
   Support interruption for bcache waiting.


