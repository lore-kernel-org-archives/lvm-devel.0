From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 12 May 2009 18:53:14 -0400
Subject: [PATCH] Remove LOCK_KEEP from new vg_read() interface.
Message-ID: <1242168794-29204-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Simplify the new vg_read() interface by removing LOCK_KEEP.
Always unlock the vg upon failure of vg_read().  In this case the
error handling needs fixed up but other than that it should be
fine.

Note: vgsplit released locks in the opposite order to acquiring
them.  This patch fixes that too release in opposite
order of acquiring.

Should apply on top of Petr's vg_read() patches plus my previous
patch to cleanup LOCK_NONBLOCK.
Should be no functional change but only compile tested.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    3 ---
 lib/metadata/metadata.c          |    4 ++--
 tools/vgrename.c                 |   12 ++++++++----
 tools/vgsplit.c                  |   12 +++++++-----
 4 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 8116f16..fe8de79 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -107,9 +107,6 @@ struct pv_segment;
 #define READ_REQUIRE_RESIZEABLE	0x00040000U
 #define READ_CHECK_EXISTENCE	0x00080000U	/* Also used in vg->read_status */
 
-/* FIXME Deduce these next requirements internally instead of having caller specify. */
-#define LOCK_KEEP		0x00000200U	/* Do not unlock upon read failure. */
-
 /* A meta-flag, useful with toollib for_each_* functions. */
 #define READ_FOR_UPDATE 	0x00100000U
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 7b4c512..b6bb397 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2684,7 +2684,7 @@ static vg_t *_vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
 
 bad:
 	if (failure != (FAILED_NOTFOUND | READ_CHECK_EXISTENCE) &&
-	    !(misc_flags & LOCK_KEEP) && !already_locked)
+	    !already_locked)
 		unlock_vg(cmd, lock_name);
 
 	return _vg_make_handle(cmd, vg, failure);
@@ -2702,7 +2702,7 @@ bad:
  *    FAILED_RESIZEABLE
  *  - locking failed: FAILED_LOCKING
  *
- * On failures, all locks are released, unless LOCK_KEEP has been supplied.
+ * On failures, all locks are released.
  *
  * Volume groups are opened read-only unless flags contains READ_FOR_UPDATE.
  *
diff --git a/tools/vgrename.c b/tools/vgrename.c
index ea9c17e..786ee72 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -85,16 +85,19 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 
 	log_verbose("Checking for new volume group \"%s\"", vg_name_new);
 
-	vg_new = vg_read_for_update(cmd, vg_name_new, NULL, LOCK_KEEP |
+	vg_new = vg_read_for_update(cmd, vg_name_new, NULL,
 				    READ_CHECK_EXISTENCE);
 
-	if (vg_read_error(vg_new))
-		goto error;
+	if (vg_read_error(vg_new)) {
+		vg_release(vg);
+		goto error_new;
+	}
 
 	if (vg_might_exist(vg_new)) {
 		log_error("New volume group \"%s\" already exists",
 			  vg_name_new);
-		goto error;
+		vg_release(vg);
+		goto error_new;
 	}
 
 	if (!archive(vg))
@@ -149,6 +152,7 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 
       error:
 	unlock_release_vg(cmd, vg_new, vg_name_new);
+      error_new:
 	unlock_release_vg(cmd, vg, vg_name_old);
 	return 0;
 }
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 0334d7a..55de281 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -329,18 +329,19 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	log_verbose("Checking for new volume group \"%s\"", vg_name_to);
 	vg_to = vg_read_for_update(cmd, vg_name_to, NULL,
 				   READ_REQUIRE_RESIZEABLE |
-				   LOCK_KEEP |
 				   READ_CHECK_EXISTENCE);
 
-	if (vg_read_error(vg_to))
-		goto_bad;
+	if (vg_read_error(vg_to)) {
+		stack;
+		goto bad_to;
+	}
 
 	if (vg_might_exist(vg_to)) {
 		existing_vg = 1;
 		if (new_vg_option_specified(cmd)) {
 			log_error("Volume group \"%s\" exists, but new VG "
 				    "option specified", vg_name_to);
-			goto_bad;
+			goto bad_to;
 		}
 		if (!vgs_are_compatible(cmd, vg_from,vg_to))
 			goto_bad;
@@ -472,7 +473,8 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	r = ECMD_PROCESSED;
 
 bad:
-	unlock_release_vg(cmd, vg_from, vg_name_from);
 	unlock_release_vg(cmd, vg_to, vg_name_to);
+bad_to:
+	unlock_release_vg(cmd, vg_from, vg_name_from);
 	return r;
 }
-- 
1.6.0.6


