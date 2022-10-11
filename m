From: David Teigland <teigland@sourceware.org>
Date: Tue, 11 Oct 2022 17:49:44 +0000 (GMT)
Subject: main - lvreduce: require active LV when no fs option is used
Message-ID: <20221011174944.08F073858D39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f6f2737015746b1b6c7fbd0d297a4596c584749b
Commit:        f6f2737015746b1b6c7fbd0d297a4596c584749b
Parent:        fc52e87f06959f542ea78b75df104bc6c85fd973
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Oct 11 11:50:47 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Oct 11 12:48:31 2022 -0500

lvreduce: require active LV when no fs option is used

Without an --fs option set, make lvreduce of an inactive LV
fail and report that the LV must be active.
---
 lib/metadata/lv_manip.c   | 4 ++++
 test/shell/lvresize-fs.sh | 7 ++++---
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d6452e849..db97a019c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6873,6 +6873,10 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 	is_active = lv_is_active(lv_top);
 
 	if (is_reduce && !is_active && !strcmp(lp->fsopt, "checksize")) {
+		if (!lp->user_set_fs) {
+			log_error("The LV must be active to safely reduce, or use --fs checksize.");
+			goto out;
+		}
 		lv_top->status |= LV_TEMPORARY;
 		if (!activate_lv(cmd, lv_top)) {
 			log_error("Failed to activate %s to check for fs.", display_lvname(lv_top));
diff --git a/test/shell/lvresize-fs.sh b/test/shell/lvresize-fs.sh
index d4b6484c0..0be6911a0 100644
--- a/test/shell/lvresize-fs.sh
+++ b/test/shell/lvresize-fs.sh
@@ -473,7 +473,8 @@ lvremove $vg/$lv
 lvcreate -n $lv -L 456M $vg
 aux wipefs_a "$DM_DEV_DIR/$vg/$lv"
 lvchange -an $vg/$lv
-lvreduce -L-200M $vg/$lv
+not lvreduce -L-200M $vg/$lv
+lvreduce --fs checksize -L-200M $vg/$lv
 check lv_field $vg/$lv lv_size "256.00m"
 lvremove $vg/$lv
 
@@ -1145,7 +1146,7 @@ df --output=size "$mount_dir" |tee df1
 umount "$mount_dir"
 lvchange -an $vg/$lv
 # no fs reduce is needed
-lvreduce -L200M $vg/$lv
+lvreduce --fs checksize -L200M $vg/$lv
 check lv_field $vg/$lv lv_size "200.00m"
 lvchange -ay $vg/$lv
 mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"
@@ -1167,7 +1168,7 @@ df --output=size "$mount_dir" |tee df1
 umount "$mount_dir"
 lvchange -an $vg/$lv
 # fs is 200M, reduced size is 216M, so no fs reduce is needed
-lvreduce -L216M $vg/$lv
+lvreduce --fs checksize -L216M $vg/$lv
 check lv_field $vg/$lv lv_size "216.00m"
 lvchange -ay $vg/$lv
 mount "$DM_DEV_DIR/$vg/$lv" "$mount_dir"

