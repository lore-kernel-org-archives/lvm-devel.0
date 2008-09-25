From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 25 Sep 2008 13:15:39 -0400
Subject: [PATCH 1/2] Add 'flags' parameter to process_each_lv and process_each_lv_in_vg.
Message-ID: <1222362940-4580-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

No functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/lvchange.c  |    2 +-
 tools/lvdisplay.c |    2 +-
 tools/lvremove.c  |    2 +-
 tools/lvscan.c    |    2 +-
 tools/reporter.c  |    8 ++++----
 tools/toollib.c   |    8 +++++---
 tools/toollib.h   |    6 ++++--
 tools/vgdisplay.c |    3 ++-
 tools/vgmknodes.c |    2 +-
 9 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 4016c8f..299abd8 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -732,5 +732,5 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	return process_each_lv(cmd, argc, argv, LCK_VG_WRITE, NULL,
-			       &lvchange_single);
+			       &lvchange_single, 0);
 }
diff --git a/tools/lvdisplay.c b/tools/lvdisplay.c
index 16e7052..b896b4b 100644
--- a/tools/lvdisplay.c
+++ b/tools/lvdisplay.c
@@ -55,5 +55,5 @@ int lvdisplay(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	return process_each_lv(cmd, argc, argv, LCK_VG_READ, NULL,
-			       &_lvdisplay_single);
+			       &_lvdisplay_single, 0);
 }
diff --git a/tools/lvremove.c b/tools/lvremove.c
index 24278b2..c219d54 100644
--- a/tools/lvremove.c
+++ b/tools/lvremove.c
@@ -34,5 +34,5 @@ int lvremove(struct cmd_context *cmd, int argc, char **argv)
 	cmd->handles_missing_pvs = 1;
 
 	return process_each_lv(cmd, argc, argv, LCK_VG_WRITE, NULL,
-			       &lvremove_single);
+			       &lvremove_single, 0);
 }
diff --git a/tools/lvscan.c b/tools/lvscan.c
index f63d05f..a493112 100644
--- a/tools/lvscan.c
+++ b/tools/lvscan.c
@@ -81,5 +81,5 @@ int lvscan(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	return process_each_lv(cmd, argc, argv, LCK_VG_READ, NULL,
-			       &lvscan_single);
+			       &lvscan_single, 0);
 }
diff --git a/tools/reporter.c b/tools/reporter.c
index 5c35a0c..518c649 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -349,8 +349,8 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 
 	switch (report_type) {
 	case LVS:
-		r = process_each_lv(cmd, argc, argv, LCK_VG_READ, report_handle,
-				    &_lvs_single);
+		r = process_each_lv(cmd, argc, argv, LCK_VG_READ,
+				    report_handle, &_lvs_single, 0);
 		break;
 	case VGS:
 		r = process_each_vg(cmd, argc, argv, LCK_VG_READ, 0,
@@ -365,8 +365,8 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 					    report_handle, &_pvs_in_vg);
 		break;
 	case SEGS:
-		r = process_each_lv(cmd, argc, argv, LCK_VG_READ, report_handle,
-				    &_lvsegs_single);
+		r = process_each_lv(cmd, argc, argv, LCK_VG_READ,
+				    report_handle, &_lvsegs_single, 0);
 		break;
 	case PVSEGS:
 		if (args_are_pvs)
diff --git a/tools/toollib.c b/tools/toollib.c
index 4d11b9b..e0b7f2f 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -143,7 +143,8 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 			  const struct list *arg_lvnames,
 			  const struct list *tags,
 			  void *handle,
-			  process_single_lv_fn_t process_single)
+			  process_single_lv_fn_t process_single,
+	                  const uint32_t flags)
 {
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
@@ -220,7 +221,8 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 		    uint32_t lock_type, void *handle,
 		    int (*process_single) (struct cmd_context * cmd,
 					   struct logical_volume * lv,
-					   void *handle))
+					   void *handle),
+	            const uint32_t flags)
 {
 	int opt = 0;
 	int ret_max = ECMD_PROCESSED;
@@ -399,7 +401,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 		}
 
 		ret = process_each_lv_in_vg(cmd, vg, &lvnames, tags_arg,
-					    handle, process_single);
+					    handle, process_single, flags);
 		unlock_vg(cmd, vgname);
 		if (ret > ret_max)
 			ret_max = ret;
diff --git a/tools/toollib.h b/tools/toollib.h
index ef2b9db..44c5fbd 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -52,7 +52,8 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 		    uint32_t lock_type, void *handle,
 		    int (*process_single) (struct cmd_context * cmd,
 					   struct logical_volume * lv,
-					   void *handle));
+					   void *handle),
+		    const uint32_t flags);
 
 int process_each_segment_in_lv(struct cmd_context *cmd,
 			       struct logical_volume *lv, void *handle,
@@ -78,7 +79,8 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 			  const struct list *arg_lvnames,
 			  const struct list *tags,
 			  void *handle,
-			  process_single_lv_fn_t process_single);
+			  process_single_lv_fn_t process_single,
+			  const uint32_t flags);
 
 char *default_vgname(struct cmd_context *cmd);
 const char *extract_vgname(struct cmd_context *cmd, const char *lv_name);
diff --git a/tools/vgdisplay.c b/tools/vgdisplay.c
index 532cc18..6cfc1ed 100644
--- a/tools/vgdisplay.c
+++ b/tools/vgdisplay.c
@@ -46,7 +46,8 @@ static int vgdisplay_single(struct cmd_context *cmd, const char *vg_name,
 		vgdisplay_extents(vg);
 
 		process_each_lv_in_vg(cmd, vg, NULL, NULL, NULL,
-				      (process_single_lv_fn_t)lvdisplay_full);
+				      (process_single_lv_fn_t)lvdisplay_full,
+				      0);
 
 		log_print("--- Physical volumes ---");
 		process_each_pv_in_vg(cmd, vg, NULL, NULL,
diff --git a/tools/vgmknodes.c b/tools/vgmknodes.c
index cb5b279..2d1f37e 100644
--- a/tools/vgmknodes.c
+++ b/tools/vgmknodes.c
@@ -29,7 +29,7 @@ int vgmknodes(struct cmd_context *cmd, int argc, char **argv)
 	int r;
 
 	r = process_each_lv(cmd, argc, argv, LCK_VG_READ, NULL,
-			    &_vgmknodes_single);
+			    &_vgmknodes_single, 0);
 
 	if (!lv_mknodes(cmd, NULL) && (r < ECMD_FAILED))
 		r = ECMD_FAILED;
-- 
1.5.5.1


