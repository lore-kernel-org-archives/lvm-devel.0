From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  8 Jul 2013 12:04:07 +0000 (UTC)
Subject: master - locking: unlock memory on error path
Message-ID: <20130708120407.8BA606034E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=985251c8f385d2611dde44d1bf6824223f073749
Commit:        985251c8f385d2611dde44d1bf6824223f073749
Parent:        edf5cae6799549827d4031f472451bd96d2f0f47
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jul 6 10:58:56 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 8 14:02:49 2013 +0200

locking: unlock memory on error path

Unlock memory and unblock signals on error path.
---
 WHATS_NEW             |    1 +
 lib/locking/locking.c |    8 ++++----
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e389a36..567441a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Relase memory and unblock signals in lock_vol error path.
   Define LVM2_* command errors in lvm2cmd.h and use in dmeventd plugins.
   Move errors.h to tools dir.
   Add man page entries for profile configuration and related options.
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 34e8bd9..9183ee6 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -368,18 +368,18 @@ static int _lock_vol(struct cmd_context *cmd, const char *resource,
 
 	if (!*resource) {
 		log_error(INTERNAL_ERROR "Use of P_orphans is deprecated.");
-		return 0;
+		goto out;
 	}
 
 	if ((is_orphan_vg(resource) || is_global_vg(resource)) && (flags & LCK_CACHE)) {
 		log_error(INTERNAL_ERROR "P_%s referenced", resource);
-		return 0;
+		goto out;
 	}
 
 	if (cmd->metadata_read_only && lck_type == LCK_WRITE &&
 	    strcmp(resource, VG_GLOBAL)) {
 		log_error("Operation prohibited while global/metadata_read_only is set.");
-		return 0;
+		goto out;
 	}
 
 	if ((ret = _locking.lock_resource(cmd, resource, flags, lv))) {
@@ -399,7 +399,7 @@ static int _lock_vol(struct cmd_context *cmd, const char *resource,
 		if (!ret)
 			_update_vg_lock_count(resource, flags);
 	}
-
+out:
 	_unlock_memory(cmd, lv_op);
 	_unblock_signals();
 


