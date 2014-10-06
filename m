From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon,  6 Oct 2014 14:23:14 +0000 (UTC)
Subject: master - toollib: Remove unused functions from header file.
Message-ID: <20141006142314.E503860DCE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1115a9ea51a3302ede188073f94a42f4b38867da
Commit:        1115a9ea51a3302ede188073f94a42f4b38867da
Parent:        fa517221a19751b93a5b94f8b379919b9c1c0226
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Oct 6 15:22:01 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Oct 6 15:22:01 2014 +0100

toollib: Remove unused functions from header file.

---
 tools/toollib.c |   52 ++++++++++++++++++++++++++--------------------------
 tools/toollib.h |    9 ---------
 2 files changed, 26 insertions(+), 35 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index ddd669a..195f47a 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -541,6 +541,29 @@ static const char *_extract_vgname(struct cmd_context *cmd, const char *lv_name,
 	return vg_name;
 }
 /*
+ * Extract default volume group name from environment
+ */
+static const char *_default_vgname(struct cmd_context *cmd)
+{
+	const char *vg_path;
+
+	/* Take default VG from environment? */
+	vg_path = getenv("LVM_VG_NAME");
+	if (!vg_path)
+		return 0;
+
+	vg_path = skip_dev_dir(cmd, vg_path, NULL);
+
+	if (strchr(vg_path, '/')) {
+		log_error("Environment Volume Group in LVM_VG_NAME invalid: "
+			  "\"%s\"", vg_path);
+		return 0;
+	}
+
+	return dm_pool_strdup(cmd->mem, vg_path);
+}
+
+/*
  * Determine volume group name from a logical volume name
  */
 const char *extract_vgname(struct cmd_context *cmd, const char *lv_name)
@@ -555,7 +578,7 @@ const char *extract_vgname(struct cmd_context *cmd, const char *lv_name)
 		return vg_name;
 	}
 
-	if (!(vg_name = default_vgname(cmd))) {
+	if (!(vg_name = _default_vgname(cmd))) {
 		if (lv_name)
 			log_error("Path required for Logical Volume \"%s\"",
 				  lv_name);
@@ -566,29 +589,6 @@ const char *extract_vgname(struct cmd_context *cmd, const char *lv_name)
 }
 
 /*
- * Extract default volume group name from environment
- */
-char *default_vgname(struct cmd_context *cmd)
-{
-	const char *vg_path;
-
-	/* Take default VG from environment? */
-	vg_path = getenv("LVM_VG_NAME");
-	if (!vg_path)
-		return 0;
-
-	vg_path = skip_dev_dir(cmd, vg_path, NULL);
-
-	if (strchr(vg_path, '/')) {
-		log_error("Environment Volume Group in LVM_VG_NAME invalid: "
-			  "\"%s\"", vg_path);
-		return 0;
-	}
-
-	return dm_pool_strdup(cmd->mem, vg_path);
-}
-
-/*
  * Process physical extent range specifiers
  */
 static int _add_pe_range(struct dm_pool *mem, const char *pvname,
@@ -1907,7 +1907,7 @@ static int _get_arg_lvnames(struct cmd_context *cmd,
 	const char *vgname;
 	const char *lv_name;
 	const char *tmp_lv_name;
-	char *vgname_def;
+	const char *vgname_def;
 	unsigned dev_dir_found;
 
 	log_verbose("Using logical volume(s) on command line");
@@ -1956,7 +1956,7 @@ static int _get_arg_lvnames(struct cmd_context *cmd,
 				continue;
 			}
 		} else if (!dev_dir_found &&
-			   (vgname_def = default_vgname(cmd)))
+			   (vgname_def = _default_vgname(cmd)))
 			vgname = vgname_def;
 		else
 			lv_name = NULL;
diff --git a/tools/toollib.h b/tools/toollib.h
index 1a14d60..ae4b21e 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -20,16 +20,8 @@
 
 int become_daemon(struct cmd_context *cmd, int skip_lvm);
 
-int autobackup_set(void);
-int autobackup_init(const char *backup_dir, int keep_days, int keep_number,
-		    int autobackup);
-int autobackup(struct volume_group *vg);
-
 int ignore_vg(struct volume_group *vg, const char *vg_name, int allow_inconsistent, int *ret);
 
-struct volume_group *recover_vg(struct cmd_context *cmd, const char *vgname,
-				uint32_t lock_type);
-
 typedef int (*process_single_vg_fn_t) (struct cmd_context * cmd,
 				       const char *vg_name,
 				       struct volume_group * vg,
@@ -91,7 +83,6 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 			  void *handle,
 			  process_single_lv_fn_t process_single_lv);
 
-char *default_vgname(struct cmd_context *cmd);
 const char *extract_vgname(struct cmd_context *cmd, const char *lv_name);
 const char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
 			 unsigned *dev_dir_found);


