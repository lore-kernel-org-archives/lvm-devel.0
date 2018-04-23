From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:51:05 -0400
Subject: master - scan: drop bcache and close fd for LV with stacked PV
Message-ID: <201804231351.w3NDp50n032084@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=34fd818caf89f39dab58ef2ce7c60c193db02cf0
Commit:        34fd818caf89f39dab58ef2ce7c60c193db02cf0
Parent:        c2b10daf694bea490044b752209a416f886373ea
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 16 10:37:09 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:47 2018 -0500

scan: drop bcache and close fd for LV with stacked PV

When a PV is stacked on an LV, the LV will be kept in
bcache, and the open fd on the LV may interfere with
processing the LV.  So, drop/close a bcache fd for
an LV before processing the LV.
---
 tools/toollib.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 807e34c..0b8823b 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3009,6 +3009,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	log_report_t saved_log_report_state = log_get_report_state();
 	char lv_uuid[64] __attribute__((aligned(8)));
 	char vg_uuid[64] __attribute__((aligned(8)));
+	struct lvinfo lvinfo;
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
 	int whole_selected = 0;
@@ -3025,6 +3026,8 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	struct lv_list *final_lvl;
 	struct dm_list found_arg_lvnames;
 	struct glv_list *glvl, *tglvl;
+	struct device *dev;
+	dev_t devt;
 	int do_report_ret_code = 1;
 
 	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_LV);
@@ -3162,6 +3165,18 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	}
 	log_set_report_object_name_and_id(NULL, NULL);
 
+	/*
+	 * If a PV is stacked on an LV, then the LV is kept open
+	 * in bcache, and needs to be closed so the open fd doesn't
+	 * interfere with processing the LV.
+	 */
+	dm_list_iterate_items(lvl, &final_lvs) {
+		lv_info(cmd, lvl->lv, 0, &lvinfo, 0, 0);
+		devt = MKDEV(lvinfo.major, lvinfo.minor);
+		if ((dev = dev_cache_get_by_devt(devt, cmd->filter)))
+			label_scan_invalidate(dev);
+	}
+
 	dm_list_iterate_items(lvl, &final_lvs) {
 		lv_uuid[0] = '\0';
 		if (!id_write_format(&lvl->lv->lvid.id[1], lv_uuid, sizeof(lv_uuid)))


