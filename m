From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Feb 2018 10:46:28 -0500
Subject: master - locking: move cache dropping to primary locking code
Message-ID: <201802191546.w1JFkSq6026202@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c3bb2b29d441f27d7e1d88f71d934ba8c955b26d
Commit:        c3bb2b29d441f27d7e1d88f71d934ba8c955b26d
Parent:        e87fa7c9cef53013efa46033ad037822c70c1bb9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 19 16:31:52 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 19 16:45:05 2018 +0100

locking: move cache dropping to primary locking code

While 'file-locking' code always dropped cached VG before
lock was taken - other locking types actually missed this.

So while the cache dropping has been implement for i.e. clvmd,
actually running command in cluster keept using cache even
when the lock has been i.e. dropped and taken again.

This rather 'hard-to-hit' error was noticable in some
tests running in cluster where content of PV has been
changed (metadata-balance.sh)

Fix the code by moving cache dropping directly lock_vol() function.

TODO: it's kind of strange we should ever need drop_cached_metadata()
used in several places - this all should happen automatically
this some futher thinking here is likely needed.
---
 WHATS_NEW                  |    1 +
 lib/locking/file_locking.c |    5 +----
 lib/locking/locking.c      |    7 +++++++
 3 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b11de8c..5791930 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Ensure cluster commands drop their device cache before locking VG.
   Do not report LV as remotely active when it's locally exclusive in cluster.
   Add deprecate messages for usage of mirrors with mirrorlog.
   Separate reporting of monitoring status and error status.
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 245892e..517a64f 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -60,11 +60,8 @@ static int _file_lock_resource(struct cmd_context *cmd, const char *resource,
 			return_0;
 		break;
 	case LCK_VG:
-		if (!strcmp(resource, VG_SYNC_NAMES)) {
+		if (!strcmp(resource, VG_SYNC_NAMES))
 			fs_unlock();
-		} else if (strcmp(resource, VG_GLOBAL))
-			/* Skip cache refresh for VG_GLOBAL - the caller handles it */
-			lvmcache_drop_metadata(resource, 0);
 
 		/* LCK_CACHE does not require a real lock */
 		if (flags & LCK_CACHE)
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 1a3ce9d..d61aa35 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -336,6 +336,13 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags, const str
 		    !lvmcache_verify_lock_order(vol))
 			return_0;
 
+		if ((flags == LCK_VG_DROP_CACHE) ||
+		    (strcmp(vol, VG_GLOBAL) && strcmp(vol, VG_SYNC_NAMES))) {
+			/* Skip dropping cache for internal VG names #global, #sync_names */
+			log_debug_locking("Dropping cache for %s.", vol);
+			lvmcache_drop_metadata(vol, 0);
+		}
+
 		/* Lock VG to change on-disk metadata. */
 		/* If LVM1 driver knows about the VG, it can't be accessed. */
 		if (!check_lvm1_vg_inactive(cmd, vol))


