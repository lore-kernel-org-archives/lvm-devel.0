From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 21 Apr 2016 21:14:57 +0000 (UTC)
Subject: master - activate: Hide errors when snapshot merge delayed.
Message-ID: <20160421211457.2878B61BF3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=01181a299eb26121c963895e3443105eca1e1c60
Commit:        01181a299eb26121c963895e3443105eca1e1c60
Parent:        4d095c2fbb4383fc4830b9b714f8a7fd45b40fcd
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Apr 21 22:14:10 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Apr 21 22:14:10 2016 +0100

activate: Hide errors when snapshot merge delayed.

---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |   29 ++++++++++++++++++++---------
 lib/activate/activate.h |    2 +-
 lib/metadata/lv_manip.c |    2 +-
 tools/lvchange.c        |    2 +-
 tools/lvconvert.c       |   10 +++++-----
 tools/vgchange.c        |    2 +-
 7 files changed, 30 insertions(+), 18 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 65fefa1..9c15797 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.151 -
 =================================
+  Suppress errors when snapshot merge gets delayed because volume is in use.
   Avoid internal snapshot LV names in messages.
   Autodetect and use /run/lock dir when available instead of /var/lock.
   lvchange --refresh for merging thin origin will retry to deactivate snapshot.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index ac547ce..76afc3d 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -763,7 +763,8 @@ int lv_info_with_seg_status(struct cmd_context *cmd, const struct logical_volume
 #define OPEN_COUNT_CHECK_RETRIES 25
 #define OPEN_COUNT_CHECK_USLEEP_DELAY 200000
 
-int lv_check_not_in_use(const struct logical_volume *lv)
+/* Only report error if error_if_used is set */
+int lv_check_not_in_use(const struct logical_volume *lv, int error_if_used)
 {
 	struct lvinfo info;
 	unsigned int open_count_check_retries;
@@ -774,14 +775,22 @@ int lv_check_not_in_use(const struct logical_volume *lv)
 	/* If sysfs is not used, use open_count information only. */
 	if (dm_sysfs_dir()) {
 		if (dm_device_has_holders(info.major, info.minor)) {
-			log_error("Logical volume %s is used by another device.",
-				  display_lvname(lv));
+			if (error_if_used)
+				log_error("Logical volume %s is used by another device.",
+					  display_lvname(lv));
+			else
+				log_debug_activation("Logical volume %s is used by another device.",
+						     display_lvname(lv));
 			return 0;
 		}
 
 		if (dm_device_has_mounted_fs(info.major, info.minor)) {
-			log_error("Logical volume %s contains a filesystem in use.",
-				  display_lvname(lv));
+			if (error_if_used)
+				log_error("Logical volume %s contains a filesystem in use.",
+					  display_lvname(lv));
+			else
+				log_debug_activation("Logical volume %s contains a filesystem in use.",
+						     display_lvname(lv));
 			return 0;
 		}
 	}
@@ -789,8 +798,10 @@ int lv_check_not_in_use(const struct logical_volume *lv)
 	open_count_check_retries = retry_deactivation() ? OPEN_COUNT_CHECK_RETRIES : 1;
 	while (info.open_count > 0 && open_count_check_retries--) {
 		if (!open_count_check_retries) {
-			log_error("Logical volume %s in use.",
-				  display_lvname(lv));
+			if (error_if_used)
+				log_error("Logical volume %s in use.", display_lvname(lv));
+			else
+				log_debug_activation("Logical volume %s in use.", display_lvname(lv));
 			return 0;
 		}
 
@@ -2118,7 +2129,7 @@ static int _lv_has_open_snapshots(const struct logical_volume *lv)
 	int r = 0;
 
 	dm_list_iterate_items_gen(snap_seg, &lv->snapshot_segs, origin_list)
-		if (!lv_check_not_in_use(snap_seg->cow))
+		if (!lv_check_not_in_use(snap_seg->cow, 1))
 			r++;
 
 	if (r)
@@ -2172,7 +2183,7 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, const struct logi
 
 	if (lv_is_visible(lv) || lv_is_virtual_origin(lv) ||
 	    lv_is_merging_thin_snapshot(lv)) {
-		if (!lv_check_not_in_use(lv))
+		if (!lv_check_not_in_use(lv, 1))
 			goto_out;
 
 		if (lv_is_origin(lv) && _lv_has_open_snapshots(lv))
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 880689c..089355d 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -147,7 +147,7 @@ int lv_info_with_seg_status(struct cmd_context *cmd, const struct logical_volume
 			    struct lv_with_info_and_seg_status *status,
 			    int with_open_count, int with_read_ahead);
 
-int lv_check_not_in_use(const struct logical_volume *lv);
+int lv_check_not_in_use(const struct logical_volume *lv, int error_if_used);
 
 /*
  * Returns 1 if activate_lv has been set: 1 = activate; 0 = don't.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1baf548..4bce808 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5802,7 +5802,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 	if (!lv_is_cache_pool(lv) && /* cache pool cannot be active */
 	    lv_is_active(lv)) {
-		if (!lv_check_not_in_use(lv))
+		if (!lv_check_not_in_use(lv, 1))
 			return_0;
 
 		if ((force == PROMPT) &&
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 3a050e9..631d7f8 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -344,7 +344,7 @@ static int _lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 	}
 
 	if (lv_is_active_locally(lv)) {
-		if (!lv_check_not_in_use(lv)) {
+		if (!lv_check_not_in_use(lv, 1)) {
 			log_error("Can't resync open logical volume \"%s\"",
 				  lv->name);
 			return 0;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index f7a3df6..c544e36 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1876,7 +1876,7 @@ static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volu
 	}
 
 	if (lv_is_active_locally(cow)) {
-		if (!lv_check_not_in_use(cow))
+		if (!lv_check_not_in_use(cow, 1))
 			return_0;
 
 		if ((lp->force == PROMPT) && !lp->yes &&
@@ -2232,11 +2232,11 @@ static int _lvconvert_merge_old_snapshot(struct cmd_context *cmd,
 	 * being open.
 	 */
 	if (lv_is_active_locally(origin)) {
-		if (!lv_check_not_in_use(origin)) {
-			log_print_unless_silent("Can't merge over open origin volume.");
+		if (!lv_check_not_in_use(origin, 0)) {
+			log_print_unless_silent("Can't merge until origin volume is closed.");
 			merge_on_activate = 1;
-		} else if (!lv_check_not_in_use(lv)) {
-			log_print_unless_silent("Can't merge when snapshot is open.");
+		} else if (!lv_check_not_in_use(lv, 0)) {
+			log_print_unless_silent("Can't merge until snapshot is closed.");
 			merge_on_activate = 1;
 		}
 	} else if (vg_is_clustered(origin->vg) && lv_is_active(origin)) {
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 372f881..49c64b9 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -219,7 +219,7 @@ int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
 	if (!do_activate && (lv_open = lvs_in_vg_opened(vg))) {
 		dm_list_iterate_items(lvl, &vg->lvs)
 			if (lv_is_visible(lvl->lv) &&
-			    !lv_check_not_in_use(lvl->lv)) {
+			    !lv_check_not_in_use(lvl->lv, 1)) {
 				log_error("Can't deactivate volume group \"%s\" with %d open "
 					  "logical volume(s)", vg->name, lv_open);
 				return 0;


