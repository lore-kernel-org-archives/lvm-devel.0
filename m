From: David Teigland <teigland@sourceware.org>
Date: Tue,  2 Feb 2021 20:31:40 +0000 (GMT)
Subject: main - cachevol: allow forced detaching of damaged or invalid cachevol
Message-ID: <20210202203140.15B0B386EC32@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cb54d0801d776205788f8f46b31dd9e487833343
Commit:        cb54d0801d776205788f8f46b31dd9e487833343
Parent:        ae2af1d5eda8fa4e082e67429758f731ca6fcef6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 12 11:53:02 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 2 14:31:23 2021 -0600

cachevol: allow forced detaching of damaged or invalid cachevol

A cachevol can be forcibly detached when it's missing devices.
Also allow this if it's damaged/invalid and unrepairable.
This would be needed to recover data from the origin LV after
a cachevol is lost or damaged beyond repair.
---
 test/shell/writecache-split.sh | 34 ++++++++++++++++++++++++++++++++++
 tools/lvconvert.c              | 27 ++++++++++++++++++++-------
 2 files changed, 54 insertions(+), 7 deletions(-)

diff --git a/test/shell/writecache-split.sh b/test/shell/writecache-split.sh
index 5723f7aab..f6d2d9aec 100644
--- a/test/shell/writecache-split.sh
+++ b/test/shell/writecache-split.sh
@@ -153,6 +153,40 @@ vgextend --restoremissing $vg "$dev3"
 
 vgremove -ff $vg
 
+#
+# split while cachevol is damaged
+#
+
+vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4"
+
+lvcreate -n $lv1 -l 16 -an $vg "$dev1" "$dev4"
+lvcreate -n $lv2 -l 4 -an $vg "$dev2"
+
+lvchange -ay $vg/$lv1
+
+mkfs_mount_umount $lv1
+
+lvconvert -y --type writecache --cachevol $lv2 $vg/$lv1
+
+mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
+diff pattern1 "$mount_dir/pattern1"
+cp pattern1 "$mount_dir/pattern2"
+umount "$mount_dir"
+lvchange -an $vg/$lv1
+
+dd if=/dev/zero of="$dev2" seek=1 bs=1M count=16
+
+lvconvert --splitcache --force --yes $vg/$lv1
+
+lvchange -ay $vg/$lv1
+
+mount "$DM_DEV_DIR/$vg/$lv1" "$mount_dir"
+diff pattern1 "$mount_dir/pattern1"
+umount "$mount_dir"
+lvchange -an $vg/$lv1
+
+vgremove -ff $vg
+
 #
 # splitcache when origin is raid
 #
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 3457cd08a..a72126bf4 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1882,12 +1882,22 @@ static int _lvconvert_split_and_keep_cachevol(struct cmd_context *cmd,
 	char cvol_name[NAME_LEN];
 	struct lv_segment *cache_seg = first_seg(lv);
 	int cache_mode = cache_seg->cache_mode;
+	int direct_detach = 0;
 
 	if (!archive(lv->vg))
 		return_0;
 
 	log_debug("Detaching cachevol %s from LV %s.", display_lvname(lv_fast), display_lvname(lv));
 
+	/*
+	 * Allow forcible detach without activating or flushing
+	 * in case the cache is corrupt/damaged/invalid.
+	 * This would generally be done to rescue data from
+	 * the origin if the cache could not be repaired.
+	 */
+	if (!lv_is_active(lv) && arg_count(cmd, force_ARG))
+		direct_detach = 1;
+
 	/*
 	 * Detaching a writeback cache generally requires flushing;
 	 * doing otherwise can mean data loss/corruption.
@@ -1902,7 +1912,10 @@ static int _lvconvert_split_and_keep_cachevol(struct cmd_context *cmd,
 			log_error("Conversion aborted.");
 			return 0;
 		}
+		direct_detach = 1;
+	}
 
+	if (direct_detach) {
 		log_warn("WARNING: Data may be lost by detaching writeback cache without flushing.");
 
 		if (!arg_count(cmd, yes_ARG) &&
@@ -5554,7 +5567,13 @@ static int _lvconvert_detach_writecache(struct cmd_context *cmd,
 	if (!archive(lv->vg))
 		return_0;
 
-	if (lv_is_partial(lv_fast)) {
+	/*
+	 * If the LV is inactive when we begin, then we want to
+	 * deactivate the LV at the end.
+	 */
+	active_begin = lv_is_active(lv);
+
+	if (lv_is_partial(lv_fast) || (!active_begin && arg_count(cmd, force_ARG))) {
 		if (!arg_count(cmd, force_ARG)) {
 			log_warn("WARNING: writecache on %s is not complete and cannot be flushed.", display_lvname(lv_fast));
 			log_warn("WARNING: cannot detach writecache from %s without --force.", display_lvname(lv));
@@ -5574,12 +5593,6 @@ static int _lvconvert_detach_writecache(struct cmd_context *cmd,
 		noflush = 1;
 	}
 
-	/*
-	 * If the LV is inactive when we begin, then we want to
-	 * deactivate the LV at the end.
-	 */
-	active_begin = lv_is_active(lv);
-
 	if (!noflush) {
 		/*
 		 * --cachesettings cleaner=0 means to skip the use of the cleaner


