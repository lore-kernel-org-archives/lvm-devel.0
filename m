From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 23 Jun 2016 20:35:43 +0000 (UTC)
Subject: master - Revert "locking: trace errors from dir creation"
Message-ID: <20160623203543.B4A2860D1B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e99a31c9502a2081c6608a831b601081008cc3b0
Commit:        e99a31c9502a2081c6608a831b601081008cc3b0
Parent:        a67a5d465576d4a7c17b22a737725d6dee059e18
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jun 23 21:31:49 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jun 23 21:31:49 2016 +0100

Revert "locking: trace errors from dir creation"

This reverts commit fa69ed0bc845df3d2c7ae68d03cdd4a3dec339d8.

This code sometimes expects to be presented with a read-only filesystem
(during some boot sequences for example) and copes appropriately with
this and it should not lead to expected error messages that might cause
unnecessary alarm.
---
 WHATS_NEW                  |    3 +--
 lib/locking/file_locking.c |    6 ++----
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a24325f..7238568 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,9 +1,8 @@
 Version 2.02.158 - 
 =================================
   Pool metadata lvresize uses now same code as resize of normal volume.
-  Log system error when locking dir cannot be accessed.
   Preserve monitoring status when updating thin-pool metadata.
-  Rerurn 0 (inactive) when status cannot be queried in _lv_active().
+  Return 0 (inactive) when status cannot be queried in _lv_active().
   Switch to log_warn() for failing activation status query.
   Refactor lvconvert argument handling code.
   Add --logonly option to report only cmd log for a command, not other reports.
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 390f49f..230303b 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -158,13 +158,11 @@ int init_file_locking(struct locking_type *locking, struct cmd_context *cmd,
 	(void) dm_prepare_selinux_context(NULL, 0);
 
 	if (!r)
-		return_0;
+		return 0;
 
 	/* Trap a read-only file system */
-	if ((access(_lock_dir, R_OK | W_OK | X_OK) == -1) && (errno == EROFS)) {
-		log_sys_error("access", _lock_dir);
+	if ((access(_lock_dir, R_OK | W_OK | X_OK) == -1) && (errno == EROFS))
 		return 0;
-	}
 
 	return 1;
 }


