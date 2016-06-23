From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Jun 2016 13:01:32 +0000 (UTC)
Subject: master - locking: trace errors from dir creation
Message-ID: <20160623130132.EE0B5605CD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fa69ed0bc845df3d2c7ae68d03cdd4a3dec339d8
Commit:        fa69ed0bc845df3d2c7ae68d03cdd4a3dec339d8
Parent:        dc8c5c1886ea7c090a3bfa96de8f22ca060614ec
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 16 11:54:24 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 23 14:57:06 2016 +0200

locking: trace errors from dir creation

---
 WHATS_NEW                  |    1 +
 lib/locking/file_locking.c |    6 ++++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e61fbb2..5e2cb5a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.158 - 
 =================================
+  Log system error when locking dir cannot be accessed.
   Preserve monitoring status when updating thin-pool metadata.
   Rerurn 0 (inactive) when status cannot be queried in _lv_active().
   Switch to log_warn() for failing activation status query.
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 230303b..390f49f 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -158,11 +158,13 @@ int init_file_locking(struct locking_type *locking, struct cmd_context *cmd,
 	(void) dm_prepare_selinux_context(NULL, 0);
 
 	if (!r)
-		return 0;
+		return_0;
 
 	/* Trap a read-only file system */
-	if ((access(_lock_dir, R_OK | W_OK | X_OK) == -1) && (errno == EROFS))
+	if ((access(_lock_dir, R_OK | W_OK | X_OK) == -1) && (errno == EROFS)) {
+		log_sys_error("access", _lock_dir);
 		return 0;
+	}
 
 	return 1;
 }


