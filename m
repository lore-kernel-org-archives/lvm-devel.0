From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 20 Jan 2009 19:26:39 -0500
Subject: [PATCH] Add flag to LV interators to indicate whether to process hidden LVs.
Message-ID: <1232497599-19893-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fixes rhbz 232499.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/lvchange.c  |    2 +-
 tools/lvdisplay.c |    2 +-
 tools/lvremove.c  |    2 +-
 tools/lvscan.c    |    2 +-
 tools/reporter.c  |    4 ++--
 tools/toollib.c   |   15 +++++++++++++--
 tools/toollib.h   |   12 +++++++++++-
 tools/vgdisplay.c |    2 +-
 tools/vgmknodes.c |    4 ++--
 9 files changed, 33 insertions(+), 12 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index cd0ff5a..fbf8dab 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -728,6 +728,6 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_lv(cmd, argc, argv, LCK_VG_WRITE, NULL,
+	return process_each_lv(cmd, argc, argv, LCK_VG_WRITE, 0, NULL,
 			       &lvchange_single);
 }
diff --git a/tools/lvdisplay.c b/tools/lvdisplay.c
index 5263e0d..28b9cea 100644
--- a/tools/lvdisplay.c
+++ b/tools/lvdisplay.c
@@ -54,6 +54,6 @@ int lvdisplay(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_lv(cmd, argc, argv, LCK_VG_READ, NULL,
+	return process_each_lv(cmd, argc, argv, LCK_VG_READ, 0, NULL,
 			       &_lvdisplay_single);
 }
diff --git a/tools/lvremove.c b/tools/lvremove.c
index 8b8401d..e3aaab9 100644
--- a/tools/lvremove.c
+++ b/tools/lvremove.c
@@ -33,6 +33,6 @@ int lvremove(struct cmd_context *cmd, int argc, char **argv)
 
 	cmd->handles_missing_pvs = 1;
 
-	return process_each_lv(cmd, argc, argv, LCK_VG_WRITE, NULL,
+	return process_each_lv(cmd, argc, argv, LCK_VG_WRITE, 0, NULL,
 			       &lvremove_single);
 }
diff --git a/tools/lvscan.c b/tools/lvscan.c
index 1186b3b..a667046 100644
--- a/tools/lvscan.c
+++ b/tools/lvscan.c
@@ -80,6 +80,6 @@ int lvscan(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	return process_each_lv(cmd, argc, argv, LCK_VG_READ, NULL,
+	return process_each_lv(cmd, argc, argv, LCK_VG_READ, 0, NULL,
 			       &lvscan_single);
 }
diff --git a/tools/reporter.c b/tools/reporter.c
index c62fc03..af372a8 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -352,7 +352,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 
 	switch (report_type) {
 	case LVS:
-		r = process_each_lv(cmd, argc, argv, LCK_VG_READ, report_handle,
+		r = process_each_lv(cmd, argc, argv, LCK_VG_READ, 0, report_handle,
 				    &_lvs_single);
 		break;
 	case VGS:
@@ -368,7 +368,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 					    report_handle, &_pvs_in_vg);
 		break;
 	case SEGS:
-		r = process_each_lv(cmd, argc, argv, LCK_VG_READ, report_handle,
+		r = process_each_lv(cmd, argc, argv, LCK_VG_READ, 0, report_handle,
 				    &_lvsegs_single);
 		break;
 	case PVSEGS:
diff --git a/tools/toollib.c b/tools/toollib.c
index a0494a1..db839a3 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -86,6 +86,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 			  const struct volume_group *vg,
 			  const struct dm_list *arg_lvnames,
 			  const struct dm_list *tags,
+			  uint32_t flags,
 			  void *handle,
 			  process_single_lv_fn_t process_single)
 {
@@ -121,6 +122,15 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		if (lvl->lv->status & SNAPSHOT)
 			continue;
+		/*
+		 * If no LVs given on the cmdline, and this is not
+		 * a visible LV, then skip the LV if we were told
+		 * to only process visible ones.
+		 */
+		if (!lvargs_supplied &&
+		    !lv_is_visible(lvl->lv) &&
+		    (flags & PROCESS_ONLY_VISIBLE_LVS))
+			continue;
 
 		/* Should we process this LV? */
 		if (process_all)
@@ -161,7 +171,8 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 }
 
 int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
-		    uint32_t lock_type, void *handle,
+		    uint32_t lock_type, uint32_t flags,
+		    void *handle,
 		    int (*process_single) (struct cmd_context * cmd,
 					   struct logical_volume * lv,
 					   void *handle))
@@ -343,7 +354,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 		}
 
 		ret = process_each_lv_in_vg(cmd, vg, &lvnames, tags_arg,
-					    handle, process_single);
+					    flags, handle, process_single);
 		unlock_vg(cmd, vgname);
 		if (ret > ret_max)
 			ret_max = ret;
diff --git a/tools/toollib.h b/tools/toollib.h
index 915e3f3..5a20d12 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -47,9 +47,18 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 						      struct volume_group * vg,
 						      struct pv_segment * pvseg,
 						      void *handle));
+/*
+ * Indicates whether we should process only visible LVs when looping
+ * through a list of LVs on a VG.
+ * NOTE: This does not apply if a hidden/non-visible LV is given on the
+ * commandline for a tool, only if another option is given (e.g. a VG) that
+ * implies a list of LVs and the tools need to make a decision.
+ */
+#define PROCESS_ONLY_VISIBLE_LVS 0x1
 
 int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
-		    uint32_t lock_type, void *handle,
+		    uint32_t lock_type, uint32_t flags,
+		    void *handle,
 		    int (*process_single) (struct cmd_context * cmd,
 					   struct logical_volume * lv,
 					   void *handle));
@@ -77,6 +86,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 			  const struct volume_group *vg,
 			  const struct dm_list *arg_lvnames,
 			  const struct dm_list *tags,
+			  uint32_t flags,
 			  void *handle,
 			  process_single_lv_fn_t process_single);
 
diff --git a/tools/vgdisplay.c b/tools/vgdisplay.c
index 02fdc19..562fdf8 100644
--- a/tools/vgdisplay.c
+++ b/tools/vgdisplay.c
@@ -45,7 +45,7 @@ static int vgdisplay_single(struct cmd_context *cmd, const char *vg_name,
 	if (arg_count(cmd, verbose_ARG)) {
 		vgdisplay_extents(vg);
 
-		process_each_lv_in_vg(cmd, vg, NULL, NULL, NULL,
+		process_each_lv_in_vg(cmd, vg, NULL, NULL, 0, NULL,
 				      (process_single_lv_fn_t)lvdisplay_full);
 
 		log_print("--- Physical volumes ---");
diff --git a/tools/vgmknodes.c b/tools/vgmknodes.c
index fce925b..6e57a14 100644
--- a/tools/vgmknodes.c
+++ b/tools/vgmknodes.c
@@ -33,6 +33,6 @@ int vgmknodes(struct cmd_context *cmd, int argc, char **argv)
 	if (!lv_mknodes(cmd, NULL))
 		return ECMD_FAILED;
 
-	return process_each_lv(cmd, argc, argv, LCK_VG_READ, NULL,
-			    &_vgmknodes_single);
+	return process_each_lv(cmd, argc, argv, LCK_VG_READ, 0, NULL,
+			       &_vgmknodes_single);
 }
-- 
1.6.0.5


