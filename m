From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:51:02 -0400
Subject: master - vgchange: invalidate bcache for stacked LVs when deactivating
Message-ID: <201804231351.w3NDp2A9032067@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0da296003d3af3f505213a25783dda534af2d9d6
Commit:        0da296003d3af3f505213a25783dda534af2d9d6
Parent:        34fd818caf89f39dab58ef2ce7c60c193db02cf0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 16 14:18:55 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:47 2018 -0500

vgchange: invalidate bcache for stacked LVs when deactivating

An LV with a stacked PV will be open in bcache and needs to be
invalidated to close the fd before attempting to deactivate.
---
 lib/label/label.c |   19 +++++++++++++++++++
 lib/label/label.h |    1 +
 tools/toollib.c   |   11 ++---------
 tools/vgchange.c  |   17 +++++++++++------
 4 files changed, 33 insertions(+), 15 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index c35818a..dfd3e37 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -20,6 +20,7 @@
 #include "lvmcache.h"
 #include "bcache.h"
 #include "toolcontext.h"
+#include "activate.h"
 
 #include <sys/stat.h>
 #include <fcntl.h>
@@ -726,6 +727,24 @@ void label_scan_invalidate(struct device *dev)
 }
 
 /*
+ * If a PV is stacked on an LV, then the LV is kept open
+ * in bcache, and needs to be closed so the open fd doesn't
+ * interfere with processing the LV.
+ */
+
+void label_scan_invalidate_lv(struct cmd_context *cmd, struct logical_volume *lv)
+{
+	struct lvinfo lvinfo;
+	struct device *dev;
+	dev_t devt;
+
+	lv_info(cmd, lv, 0, &lvinfo, 0, 0);
+	devt = MKDEV(lvinfo.major, lvinfo.minor);
+	if ((dev = dev_cache_get_by_devt(devt, cmd->filter)))
+		label_scan_invalidate(dev);
+}
+
+/*
  * Undo label_scan()
  *
  * Close devices that are open because bcache is holding blocks for them.
diff --git a/lib/label/label.h b/lib/label/label.h
index 107bd30..bf6e926 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -106,6 +106,7 @@ int label_scan(struct cmd_context *cmd);
 int label_scan_devs(struct cmd_context *cmd, struct dm_list *devs);
 int label_scan_devs_excl(struct dm_list *devs);
 void label_scan_invalidate(struct device *dev);
+void label_scan_invalidate_lv(struct cmd_context *cmd, struct logical_volume *lv);
 void label_scan_destroy(struct cmd_context *cmd);
 int label_read(struct device *dev, struct label **labelp, uint64_t unused_sector);
 int label_read_sector(struct device *dev, struct label **labelp, uint64_t scan_sector);
diff --git a/tools/toollib.c b/tools/toollib.c
index 0b8823b..623bfbb 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3009,7 +3009,6 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	log_report_t saved_log_report_state = log_get_report_state();
 	char lv_uuid[64] __attribute__((aligned(8)));
 	char vg_uuid[64] __attribute__((aligned(8)));
-	struct lvinfo lvinfo;
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
 	int whole_selected = 0;
@@ -3026,8 +3025,6 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	struct lv_list *final_lvl;
 	struct dm_list found_arg_lvnames;
 	struct glv_list *glvl, *tglvl;
-	struct device *dev;
-	dev_t devt;
 	int do_report_ret_code = 1;
 
 	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_LV);
@@ -3170,12 +3167,8 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	 * in bcache, and needs to be closed so the open fd doesn't
 	 * interfere with processing the LV.
 	 */
-	dm_list_iterate_items(lvl, &final_lvs) {
-		lv_info(cmd, lvl->lv, 0, &lvinfo, 0, 0);
-		devt = MKDEV(lvinfo.major, lvinfo.minor);
-		if ((dev = dev_cache_get_by_devt(devt, cmd->filter)))
-			label_scan_invalidate(dev);
-	}
+	dm_list_iterate_items(lvl, &final_lvs)
+		label_scan_invalidate_lv(cmd, lvl->lv);
 
 	dm_list_iterate_items(lvl, &final_lvs) {
 		lv_uuid[0] = '\0';
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 7cfaab6..61b78df 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -209,14 +209,19 @@ int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
         cmd->handles_missing_pvs = 1;
 
 	/* FIXME: Force argument to deactivate them? */
-	if (!do_activate && (lv_open = lvs_in_vg_opened(vg))) {
+	if (!do_activate) {
 		dm_list_iterate_items(lvl, &vg->lvs)
-			if (lv_is_visible(lvl->lv) &&
-			    !lv_check_not_in_use(lvl->lv, 1)) {
-				log_error("Can't deactivate volume group \"%s\" with %d open "
-					  "logical volume(s)", vg->name, lv_open);
-				return 0;
+			label_scan_invalidate_lv(cmd, lvl->lv);
+
+	       	if ((lv_open = lvs_in_vg_opened(vg))) {
+			dm_list_iterate_items(lvl, &vg->lvs) {
+				if (lv_is_visible(lvl->lv) && !lv_check_not_in_use(lvl->lv, 1)) {
+					log_error("Can't deactivate volume group \"%s\" with %d open logical volume(s)",
+						  vg->name, lv_open);
+					return 0;
+				}
 			}
+		}
 	}
 
 	/* FIXME Move into library where clvmd can use it */


