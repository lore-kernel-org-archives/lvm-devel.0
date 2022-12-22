From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 22 Dec 2022 15:11:42 +0000 (GMT)
Subject: main - WHATS_NEW: update
Message-ID: <20221222151142.8CF883858D1E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2772d299174c25f054b4e5ceb0e86aec661b12f6
Commit:        2772d299174c25f054b4e5ceb0e86aec661b12f6
Parent:        edd6d84159f4d540c8283771da6702971518ccd7
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Dec 22 16:06:04 2022 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Dec 22 16:06:04 2022 +0100

WHATS_NEW: update

---
 WHATS_NEW | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index 613acfa86..bfa33aa7a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,9 @@
 Version 2.03.18 - 
 ====================================
+  Fix issues reported by coverity scan.
+  Fix warning for thin pool overprovisioning on lvextend (2.03.17).
+  Add support for writecache metadata_only and pause_writeback settings.
+  Fix missing error messages in lvmdbusd.
 
 Version 2.03.17 - 10th November 2022
 ====================================

