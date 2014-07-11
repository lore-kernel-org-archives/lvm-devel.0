From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Jul 2014 11:34:32 +0000 (UTC)
Subject: master - cleanup: indent changes
Message-ID: <20140711113432.AD07160EC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d5d883d91ba132bd601fb27d44191d3a9c9f64f1
Commit:        d5d883d91ba132bd601fb27d44191d3a9c9f64f1
Parent:        f7d661406196568abce68abb66a45b27177b4379
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 11 12:25:18 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 11 13:32:21 2014 +0200

cleanup: indent changes

---
 tools/lvconvert.c |   34 +++++++++++++++++-----------------
 tools/toollib.c   |    4 ++--
 2 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 2892d00..95ca245 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -553,9 +553,9 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 		}
 
 		/*
-	 	 * --regionsize is only valid if converting an LV into a mirror.
-	 	 * Checked when we know the state of the LV being converted.
-	 	 */
+		 * --regionsize is only valid if converting an LV into a mirror.
+		 * Checked when we know the state of the LV being converted.
+		 */
 
 		if (arg_count(cmd, regionsize_ARG)) {
 			if (arg_sign_value(cmd, regionsize_ARG, SIGN_NONE) ==
@@ -715,7 +715,7 @@ static int _finish_lvconvert_mirror(struct cmd_context *cmd,
 
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
 
-	if (!(_reload_lv(cmd, vg, lv)))
+	if (!_reload_lv(cmd, vg, lv))
 		return_0;
 
 	log_print_unless_silent("Logical volume %s converted.", lv->name);
@@ -1026,7 +1026,7 @@ static struct dm_list *_failed_pv_list(struct volume_group *vg)
 		if (!is_missing_pv(pvl->pv))
 			continue;
 
-		/* 
+		/*
 		 * Finally, --repair will remove empty PVs.
 		 * But we only want remove these which are output of repair,
 		 * Do not count these which are already empty here.
@@ -1992,20 +1992,20 @@ static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volu
 		return ECMD_FAILED;
 	}
 
-        if (lv_info(cmd, cow, 0, &info, 1, 0)) {
-                if (!lv_check_not_in_use(cmd, cow, &info))
+	if (lv_info(cmd, cow, 0, &info, 1, 0)) {
+		if (!lv_check_not_in_use(cmd, cow, &info))
 			return_ECMD_FAILED;
 
-                if ((lp->force == PROMPT) &&
-                    lv_is_visible(cow) &&
-                    lv_is_active(cow)) {
-                        if (yes_no_prompt("Do you really want to split off active "
-                                          "logical volume %s? [y/n]: ", cow->name) == 'n') {
-                                log_error("Logical volume %s not split.", cow->name);
-                                return ECMD_FAILED;
-                        }
-                }
-        }
+		if ((lp->force == PROMPT) &&
+		    lv_is_visible(cow) &&
+		    lv_is_active(cow)) {
+			if (yes_no_prompt("Do you really want to split off active "
+					  "logical volume %s? [y/n]: ", cow->name) == 'n') {
+				log_error("Logical volume %s not split.", cow->name);
+				return ECMD_FAILED;
+			}
+		}
+	}
 
 	if (!archive(vg))
 		return_ECMD_FAILED;
diff --git a/tools/toollib.c b/tools/toollib.c
index 34db90c..7cd6e60 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -106,7 +106,7 @@ int become_daemon(struct cmd_context *cmd, int skip_lvm)
  * Strip dev_dir if present
  */
 const char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
-		   unsigned *dev_dir_found)
+			 unsigned *dev_dir_found)
 {
 	const char *dmdir = dm_dir();
 	size_t dmdir_len = strlen(dmdir), vglv_sz;
@@ -1773,7 +1773,7 @@ int get_stripe_params(struct cmd_context *cmd, uint32_t *stripes, uint32_t *stri
 			return 0;
 		}
 
-		if(arg_uint64_value(cmd, stripesize_ARG, 0) > STRIPE_SIZE_LIMIT * 2) {
+		if (arg_uint64_value(cmd, stripesize_ARG, 0) > STRIPE_SIZE_LIMIT * 2) {
 			log_error("Stripe size cannot be larger than %s",
 				  display_size(cmd, (uint64_t) STRIPE_SIZE_LIMIT));
 			return 0;


