From: David Teigland <teigland@sourceware.org>
Date: Tue, 15 Oct 2019 17:05:44 -0400
Subject: master - writecache: add cvol suffix to attached cachevol
Message-ID: <201910152105.x9FL5i8w012846@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=998e7b107513697b3ea966ba49aeef3fe115d908
Commit:        998e7b107513697b3ea966ba49aeef3fe115d908
Parent:        81fe0457141d74e20a7fda45a69164405fc9f151
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Oct 15 16:03:34 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Oct 15 16:03:34 2019 -0500

writecache: add cvol suffix to attached cachevol

When an LV is used as a writecache cachevol, give
it the LV name a _cvol suffix.  Remove the suffix
when the cachevol is detached, restoring the
original LV name.
---
 test/shell/writecache.sh |    4 ++--
 tools/lvconvert.c        |   44 +++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 45 insertions(+), 3 deletions(-)

diff --git a/test/shell/writecache.sh b/test/shell/writecache.sh
index 94fa459..6cd4665 100644
--- a/test/shell/writecache.sh
+++ b/test/shell/writecache.sh
@@ -52,7 +52,7 @@ lvconvert --yes --type writecache --cachevol $lv2 $vg/$lv1
 
 check lv_field $vg/$lv1 segtype writecache
 
-lvs -a $vg/$lv2 --noheadings -o segtype >out
+lvs -a $vg/${lv2}_cvol --noheadings -o segtype >out
 grep linear out
 
 lvchange -ay $vg/$lv1
@@ -94,7 +94,7 @@ lvconvert --yes --type writecache --cachevol $lv2 $vg/$lv1
 
 check lv_field $vg/$lv1 segtype writecache
 
-lvs -a $vg/$lv2 --noheadings -o segtype >out
+lvs -a $vg/${lv2}_cvol --noheadings -o segtype >out
 grep linear out
 
 lvchange -ay $vg/$lv1
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 9ab362b..5a3c1c4 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4259,7 +4259,11 @@ static int _lvconvert_cachevol_attach_single(struct cmd_context *cmd,
 	if (_raid_split_image_conversion(lv))
 		goto_out;
 
-	/* Attach the cache to the main LV. */
+	/*
+	 * The lvm tradition is to rename an LV with a special role-specific
+	 * suffix when it becomes hidden.  Here the _cvol suffix is added to
+	 * the fast LV name.  When the cache is detached, it's renamed back.
+	 */
 	if (dm_snprintf(cvol_name, sizeof(cvol_name), "%s_cvol", cachevol_lv->name) < 0) {
 		log_error("Can't prepare new metadata name for %s.", display_lvname(cachevol_lv));
 		return 0;
@@ -4278,6 +4282,8 @@ static int _lvconvert_cachevol_attach_single(struct cmd_context *cmd,
 
 	cachevol_lv->status |= LV_CACHE_VOL;
 
+	/* Attach the cache to the main LV. */
+
 	if (!_cache_vol_attach(cmd, lv, cachevol_lv))
 		goto_out;
 
@@ -5278,6 +5284,8 @@ static int _lvconvert_detach_writecache(struct cmd_context *cmd,
 					struct logical_volume *lv,
 					struct logical_volume *lv_fast)
 {
+	char cvol_name[NAME_LEN];
+	char *c;
 	int noflush = 0;
 
 	/*
@@ -5315,6 +5323,27 @@ static int _lvconvert_detach_writecache(struct cmd_context *cmd,
 	if (!lv_detach_writecache_cachevol(lv, noflush))
 		return_0;
 
+	/*
+	 * Rename lv_fast back to its original name, without the _cvol
+	 * suffix that was added when lv_fast was attached for caching.
+	 */
+	if (!dm_strncpy(cvol_name, lv_fast->name, sizeof(cvol_name)) ||
+	    !(c = strstr(cvol_name, "_cvol"))) {
+		log_debug("LV %s has no suffix for cachevol (skipping rename).",
+			display_lvname(lv_fast));
+	} else {
+		*c = 0;
+		/* If the name is in use, generate new lvol%d */
+		if (lv_name_is_used_in_vg(lv->vg, cvol_name, NULL) &&
+		    !generate_lv_name(lv->vg, "lvol%d", cvol_name, sizeof(cvol_name))) {
+			log_error("Failed to generate unique name for unused logical volume.");
+			return 0;
+		}
+
+		if (!lv_rename_update(cmd, lv_fast, cvol_name, 0))
+			return_0;
+	}
+
 	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 		return_0;
 
@@ -5546,6 +5575,7 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 	char *lockd_fast_args = NULL;
 	char *lockd_fast_name = NULL;
 	struct id lockd_fast_id;
+	char cvol_name[NAME_LEN];
 
 	fast_name = arg_str_value(cmd, cachevol_ARG, "");
 
@@ -5602,6 +5632,18 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 		return ECMD_FAILED;
 	}
 
+	/*
+	 * The lvm tradition is to rename an LV with a special role-specific
+	 * suffix when it becomes hidden.  Here the _cvol suffix is added to
+	 * the fast LV name.  When the cache is detached, it's renamed back.
+	 */
+	if (dm_snprintf(cvol_name, sizeof(cvol_name), "%s_cvol", lv_fast->name) < 0) {
+		log_error("Can't prepare new metadata name for %s.", display_lvname(lv_fast));
+		return ECMD_FAILED;
+	}
+	if (!lv_rename_update(cmd, lv_fast, cvol_name, 0))
+		return_ECMD_FAILED;
+
 	lv_fast->status |= LV_CACHE_VOL;
 
 	/*


