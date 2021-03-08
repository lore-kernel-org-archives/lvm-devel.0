From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Mar 2021 14:46:45 +0000 (GMT)
Subject: main - deactivation: reduce ioctl count
Message-ID: <20210308144645.6B08B3952035@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dceef4709d7ee5d06fb61120cc15fc29feb3e6b8
Commit:        dceef4709d7ee5d06fb61120cc15fc29feb3e6b8
Parent:        936c7b5104e4fb6fb489845b87d9ba2cd1a69d0a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 7 01:54:50 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 8 15:30:18 2021 +0100

deactivation: reduce ioctl count

When LV is deactivativate, we check for presence, and later
for some LV types also for being in use.

We can however do this check in 1 step for them a remove extra ioctl.

Add return value '2' to lv_check_not_in_use() to recognize LV is not
present.

Existing users were just testing for 0, so no change for them.
---
 lib/activate/activate.c | 70 ++++++++++++++++++++++++++-----------------------
 1 file changed, 37 insertions(+), 33 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 75248aa63..a56227118 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -828,13 +828,14 @@ int lv_info_with_seg_status(struct cmd_context *cmd,
 #define OPEN_COUNT_CHECK_USLEEP_DELAY 200000
 
 /* Only report error if error_if_used is set */
+/* Returns 0 if in use,  1 if it is unused, 2 when it is not present in table */
 int lv_check_not_in_use(const struct logical_volume *lv, int error_if_used)
 {
 	struct lvinfo info;
 	unsigned int open_count_check_retries;
 
 	if (!lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) || !info.exists || !info.open_count)
-		return 1;
+		return !info.exists ? 2 : 1;
 
 	/* If sysfs is not used, use open_count information only. */
 	if (dm_sysfs_dir()) {
@@ -2408,44 +2409,47 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, const struct logi
 
 	log_debug_activation("Deactivating %s.", display_lvname(lv));
 
-	if (!lv_info(cmd, lv, 0, &info, 0, 0))
-		goto_out;
-
-	if (!info.exists) {
-		r = 1;
-		/* Check attached snapshot segments are also inactive */
-		dm_list_iterate(snh, &lv->snapshot_segs) {
-			if (!lv_info(cmd, dm_list_struct_base(snh, struct lv_segment, origin_list)->cow,
-				     0, &info, 0, 0))
-				goto_out;
-			if (info.exists) {
-				r = 0; /* Snapshot left in table? */
-				break;
-			}
+	if (lv_is_visible(lv) || lv_is_virtual_origin(lv) ||
+	    lv_is_merging_thin_snapshot(lv)) {
+		switch (lv_check_not_in_use(lv, 1)) {
+		case 0: goto_out;
+		case 2: goto no_exists;
 		}
 
-		if (lv_is_vdo_pool(lv)) {
-			/* If someone has remove 'linear' mapping over VDO device
-			 * we may still be able to deactivate the rest of the tree
-			 * i.e. in test-suite we simulate this via 'dmsetup remove' */
-			if (!lv_info(cmd, lv, 1, &info, 1, 0))
-				goto_out;
+		if (lv_is_origin(lv) && _lv_has_open_snapshots(lv))
+			goto_out;
+	} else {
+		if (!lv_info(cmd, lv, 0, &info, 0, 0))
+			goto_out;
 
-			if (info.exists && !info.open_count)
-				r = 0; /* Unused VDO device left in table? */
-		}
+		if (!info.exists) {
+	no_exists:
+			r = 1;
+			/* Check attached snapshot segments are also inactive */
+			dm_list_iterate(snh, &lv->snapshot_segs) {
+				if (!lv_info(cmd, dm_list_struct_base(snh, struct lv_segment, origin_list)->cow,
+					     0, &info, 0, 0))
+					goto_out;
+				if (info.exists) {
+					r = 0; /* Snapshot left in table? */
+					break;
+				}
+			}
 
-		if (r)
-			goto out;
-	}
+			if (lv_is_vdo_pool(lv)) {
+				/* If someone has remove 'linear' mapping over VDO device
+				 * we may still be able to deactivate the rest of the tree
+				 * i.e. in test-suite we simulate this via 'dmsetup remove' */
+				if (!lv_info(cmd, lv, 1, &info, 1, 0))
+					goto_out;
 
-	if (lv_is_visible(lv) || lv_is_virtual_origin(lv) ||
-	    lv_is_merging_thin_snapshot(lv)) {
-		if (!lv_check_not_in_use(lv, 1))
-			goto_out;
+				if (info.exists && !info.open_count)
+					r = 0; /* Unused VDO device left in table? */
+			}
 
-		if (lv_is_origin(lv) && _lv_has_open_snapshots(lv))
-			goto_out;
+			if (r)
+				goto out;
+		}
 	}
 
 	if (!monitor_dev_for_events(cmd, lv, &laopts, 0))


