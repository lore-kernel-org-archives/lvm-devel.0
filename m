From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 6 Dec 2017 04:44:28 -0500
Subject: master - Update WHATS_NEW
Message-ID: <201712060944.vB69iSvP025444@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9e4dc8324117165358f2e329e5f9a5b9f27b1e0a
Commit:        9e4dc8324117165358f2e329e5f9a5b9f27b1e0a
Parent:        b910c34f09f45987fe56f0e90455a166e047144c
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Dec 6 10:41:14 2017 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Dec 6 10:41:14 2017 +0100

Update WHATS_NEW

---
 WHATS_NEW |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 674e7f1..a5ec3e7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,7 +1,12 @@
 Version 2.02.177 -
 ====================================
+  Fix lvmlockd to use pool lock when accessing _tmeta volume.
+  Report expected sanlock_convert errors only when retries fail.
+  Avoid blocking in sanlock_convert on SH to EX lock conversion.
+  Deactivate missing raid LV legs (_rimage_X-missing_Y_Z) on decativation.
   Skip read-modify-write when entire block is replaced.
   Categorise I/O with reason annotations in debug messages.
+  Allow extending of raid LVs created with --nosync after a failed repair.
   Command will lock memory only when suspending volumes.
   Merge segments when pvmove is finished.
   Remove label_verify that has never been used.


