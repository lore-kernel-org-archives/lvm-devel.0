From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  7 Oct 2014 15:46:19 +0000 (UTC)
Subject: master - vgremove: Use process_each_lv_in_vg.
Message-ID: <20141007154619.1D479610C9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f3bb1c018f7b6e38f0351a9994760bae7d9f00e3
Commit:        f3bb1c018f7b6e38f0351a9994760bae7d9f00e3
Parent:        d623034e62a5fe0ba541e6d1e543f43ae90a834f
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Oct 7 16:45:45 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Oct 7 16:45:45 2014 +0100

vgremove: Use process_each_lv_in_vg.

---
 WHATS_NEW                        |    1 +
 lib/metadata/metadata-exported.h |    5 -----
 lib/metadata/metadata.c          |   16 ----------------
 tools/lvremove.c                 |   17 -----------------
 tools/toollib.c                  |   23 ++++++++++++++++++++++-
 tools/toollib.h                  |   11 ++++++-----
 tools/tools.h                    |    1 +
 tools/vgdisplay.c                |    2 +-
 tools/vgremove.c                 |    8 ++++++--
 9 files changed, 37 insertions(+), 47 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fa4ff65..8511a45 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Change vgremove to use process_each_lv_in_vg.
   Introduce WARN_ flags to control some metadata warning messages.
   Use process_each_pv in vgreduce.
   Refactor process_each_pv in toollib.
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index ae9996d..0d8db7d 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -661,11 +661,6 @@ int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
 void add_pvl_to_vgs(struct volume_group *vg, struct pv_list *pvl);
 void del_pvl_from_vgs(struct volume_group *vg, struct pv_list *pvl);
 
-/* FIXME: refactor / unexport when lvremove liblvm refactoring dones */
-int remove_lvs_in_vg(struct cmd_context *cmd,
-		     struct volume_group *vg,
-		     force_t force);
-
 /*
  * free_pv_fid() must be called on every struct physical_volume allocated
  * by pv_create, pv_read, find_pv_by_name or to free it when no longer required.
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 5c154bd..9308cb7 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -518,22 +518,6 @@ int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	return 1;
 }
 
-int remove_lvs_in_vg(struct cmd_context *cmd,
-		     struct volume_group *vg,
-		     force_t force)
-{
-	struct dm_list *lst;
-	struct lv_list *lvl;
-
-	while ((lst = dm_list_first(&vg->lvs))) {
-		lvl = dm_list_item(lst, struct lv_list);
-		if (!lv_remove_with_dependencies(cmd, lvl->lv, force, 0))
-			return_0;
-	}
-
-	return 1;
-}
-
 int vg_remove_check(struct volume_group *vg)
 {
 	unsigned lv_count;
diff --git a/tools/lvremove.c b/tools/lvremove.c
index 7d2fec1..1005218 100644
--- a/tools/lvremove.c
+++ b/tools/lvremove.c
@@ -15,23 +15,6 @@
 
 #include "tools.h"
 
-static int lvremove_single(struct cmd_context *cmd, struct logical_volume *lv,
-			   void *handle __attribute__((unused)))
-{
-	/*
-	 * Single force is equivalent to sinle --yes
-	 * Even multiple --yes are equivalent to single --force
-	 * When we require -ff it cannot be replaces with -f -y
-	 */
-	force_t force = (force_t) arg_count(cmd, force_ARG)
-		? : (arg_is_set(cmd, yes_ARG) ? DONT_PROMPT : PROMPT);
-
-	if (!lv_remove_with_dependencies(cmd, lv, force, 0))
-		return_ECMD_FAILED;
-
-	return ECMD_PROCESSED;
-}
-
 int lvremove(struct cmd_context *cmd, int argc, char **argv)
 {
 	if (!argc) {
diff --git a/tools/toollib.c b/tools/toollib.c
index 3b1b00f..8b92968 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1569,6 +1569,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 
 int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			  struct dm_list *arg_lvnames, const struct dm_list *tags_in,
+			  int stop_on_error,
 			  void *handle, process_single_lv_fn_t process_single_lv)
 {
 	int ret_max = ECMD_PROCESSED;
@@ -1640,6 +1641,9 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 
 		if (ret > ret_max)
 			ret_max = ret;
+
+		if (stop_on_error && ret != ECMD_PROCESSED)
+			return ret_max;
 	}
 
 	if (lvargs_supplied) {
@@ -1826,7 +1830,7 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 			continue;
 		}
 
-		ret = process_each_lv_in_vg(cmd, vg, &lvnames, tags_arg,
+		ret = process_each_lv_in_vg(cmd, vg, &lvnames, tags_arg, 0,
 					    handle, process_single_lv);
 		unlock_and_release_vg(cmd, vg, vg_name);
 
@@ -2254,3 +2258,20 @@ int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 
 	return ret_max;
 }
+
+int lvremove_single(struct cmd_context *cmd, struct logical_volume *lv,
+		    void *handle __attribute__((unused)))
+{
+	/*
+	 * Single force is equivalent to single --yes
+	 * Even multiple --yes are equivalent to single --force
+	 * When we require -ff it cannot be replaced with -f -y
+	 */
+	force_t force = (force_t) arg_count(cmd, force_ARG)
+		? : (arg_is_set(cmd, yes_ARG) ? DONT_PROMPT : PROMPT);
+
+	if (!lv_remove_with_dependencies(cmd, lv, force, 0))
+		return_ECMD_FAILED;
+
+	return ECMD_PROCESSED;
+}
diff --git a/tools/toollib.h b/tools/toollib.h
index 5b42f28..037b7d7 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -74,11 +74,9 @@ int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			  void *handle, process_single_pv_fn_t process_single_pv);
 
 
-int process_each_lv_in_vg(struct cmd_context *cmd,
-			  struct volume_group *vg,
-			  struct dm_list *arg_lvnames,
-			  const struct dm_list *tagsl,
-			  void *handle,
+int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
+			  struct dm_list *arg_lvnames, const struct dm_list *tagsl,
+			  int stop_on_error, void *handle,
 			  process_single_lv_fn_t process_single_lv);
 
 const char *extract_vgname(struct cmd_context *cmd, const char *lv_name);
@@ -135,4 +133,7 @@ int get_and_validate_major_minor(const struct cmd_context *cmd,
 int validate_lvname_param(struct cmd_context *cmd, const char **vg_name,
 			  const char **lv_name);
 
+int lvremove_single(struct cmd_context *cmd, struct logical_volume *lv,
+                    void *handle __attribute__((unused)));
+
 #endif
diff --git a/tools/tools.h b/tools/tools.h
index 134e584..5fa1ab6 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -177,4 +177,5 @@ int mirror_remove_missing(struct cmd_context *cmd,
 
 int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
 		       activation_change_t activate);
+
 #endif
diff --git a/tools/vgdisplay.c b/tools/vgdisplay.c
index 95a5ebd..6e068aa 100644
--- a/tools/vgdisplay.c
+++ b/tools/vgdisplay.c
@@ -39,7 +39,7 @@ static int vgdisplay_single(struct cmd_context *cmd, const char *vg_name,
 	if (arg_count(cmd, verbose_ARG)) {
 		vgdisplay_extents(vg);
 
-		process_each_lv_in_vg(cmd, vg, NULL, NULL, NULL,
+		process_each_lv_in_vg(cmd, vg, NULL, NULL, 0, NULL,
 				      (process_single_lv_fn_t)lvdisplay_full);
 
 		log_print("--- Physical volumes ---");
diff --git a/tools/vgremove.c b/tools/vgremove.c
index 0bbca76..1dce41f 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -27,6 +27,7 @@ static int vgremove_single(struct cmd_context *cmd, const char *vg_name,
 	force_t force = (force_t) arg_count(cmd, force_ARG)
 		? : (arg_is_set(cmd, yes_ARG) ? DONT_PROMPT : PROMPT);
 	unsigned lv_count, missing;
+	int ret;
 
 	if (!vg_check_status(vg, EXPORTED_VG))
 		return_ECMD_FAILED;
@@ -46,8 +47,11 @@ static int vgremove_single(struct cmd_context *cmd, const char *vg_name,
 				return ECMD_FAILED;
 			}
 		}
-		if (!remove_lvs_in_vg(cmd, vg, force))
-			return_ECMD_FAILED;
+		if ((ret = process_each_lv_in_vg(cmd, vg, NULL, NULL, 1, NULL,
+						 (process_single_lv_fn_t)lvremove_single)) != ECMD_PROCESSED) {
+			stack;
+			return ret;
+		}
 	}
 
 	if (!force && !vg_remove_check(vg))


