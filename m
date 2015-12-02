From: David Teigland <teigland@fedoraproject.org>
Date: Wed,  2 Dec 2015 00:08:26 +0000 (UTC)
Subject: master - lvrename: use process_each_vg
Message-ID: <20151202000826.7E02D60AC7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5bbbd37f414bdbf31776d09af1c937635205ab2d
Commit:        5bbbd37f414bdbf31776d09af1c937635205ab2d
Parent:        f7571eb287ff3810d93485f6be7d5e1fad2bb250
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Dec 1 09:54:33 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Dec 1 09:54:33 2015 -0600

lvrename: use process_each_vg

No functional change.
---
 tools/lvrename.c |   93 +++++++++++++++++++++++++++++++++---------------------
 1 files changed, 57 insertions(+), 36 deletions(-)

diff --git a/tools/lvrename.c b/tools/lvrename.c
index 7b0791a..18b02d2 100644
--- a/tools/lvrename.c
+++ b/tools/lvrename.c
@@ -15,20 +15,61 @@
 
 #include "tools.h"
 
+struct lvrename_params {
+	const char *lv_name_old;
+	const char *lv_name_new;
+};
+
+static int _lvrename_single(struct cmd_context *cmd, const char *vg_name,
+			    struct volume_group *vg, struct processing_handle *handle)
+{
+	struct lvrename_params *lp = (struct lvrename_params *) handle->custom_handle;
+	struct lv_list *lvl;
+	int ret = ECMD_FAILED;
+
+	if (!(lvl = find_lv_in_vg(vg, lp->lv_name_old))) {
+		log_error("Existing logical volume \"%s\" not found in "
+			  "volume group \"%s\"", lp->lv_name_old, vg_name);
+		goto bad;
+	}
+
+	if (lv_is_raid_image(lvl->lv) || lv_is_raid_metadata(lvl->lv)) {
+		log_error("Cannot rename a RAID %s directly",
+			  lv_is_raid_image(lvl->lv) ? "image" :
+			  "metadata area");
+		goto bad;
+	}
+
+	if (lv_is_raid_with_tracking(lvl->lv)) {
+		log_error("Cannot rename %s while it is tracking a split image",
+			  lvl->lv->name);
+		goto bad;
+	}
+
+	if (!lv_rename(cmd, lvl->lv, lp->lv_name_new))
+		goto_bad;
+
+	log_print_unless_silent("Renamed \"%s\" to \"%s\" in volume group \"%s\"",
+				lp->lv_name_old, lp->lv_name_new, vg_name);
+
+	ret = ECMD_PROCESSED;
+bad:
+	return ret;
+}
+
 /*
  * lvrename command implementation.
  * Check arguments and call lv_rename() to execute the request.
  */
 int lvrename(struct cmd_context *cmd, int argc, char **argv)
 {
+	struct processing_handle *handle = NULL;
+	struct lvrename_params lp = { 0 };
 	size_t maxlen;
 	char *lv_name_old, *lv_name_new;
 	const char *vg_name, *vg_name_new, *vg_name_old;
 	char *st;
-	struct volume_group *vg;
-	struct lv_list *lvl;
-	uint32_t lockd_state = 0;
-	int r = ECMD_FAILED;
+	int ret = ECMD_FAILED;
 
 	if (argc == 3) {
 		vg_name = skip_dev_dir(cmd, argv[0], NULL);
@@ -99,43 +140,23 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (!lockd_vg(cmd, vg_name, "ex", 0, &lockd_state))
-		return_ECMD_FAILED;
+	if (!(lp.lv_name_old = dm_pool_strdup(cmd->mem, lv_name_old)))
+		return ECMD_FAILED;
 
-	log_verbose("Checking for existing volume group \"%s\"", vg_name);
-	vg = vg_read_for_update(cmd, vg_name, NULL, 0, lockd_state);
-	if (vg_read_error(vg)) {
-		release_vg(vg);
-		return_ECMD_FAILED;
-	}
+	if (!(lp.lv_name_new = dm_pool_strdup(cmd->mem, lv_name_new)))
+		return ECMD_FAILED;
 
-	if (!(lvl = find_lv_in_vg(vg, lv_name_old))) {
-		log_error("Existing logical volume \"%s\" not found in "
-			  "volume group \"%s\"", lv_name_old, vg_name);
-		goto bad;
+	if (!(handle = init_processing_handle(cmd))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
 	}
 
-	if (lv_is_raid_image(lvl->lv) || lv_is_raid_metadata(lvl->lv)) {
-		log_error("Cannot rename a RAID %s directly",
-			  lv_is_raid_image(lvl->lv) ? "image" :
-			  "metadata area");
-		goto bad;
-	}
+	handle->custom_handle = &lp;
 
-	if (lv_is_raid_with_tracking(lvl->lv)) {
-		log_error("Cannot rename %s while it is tracking a split image",
-			  lvl->lv->name);
-		goto bad;
-	}
+	ret = process_each_vg(cmd, 0, NULL, vg_name, READ_FOR_UPDATE, handle,
+			      _lvrename_single);
 
-	if (!lv_rename(cmd, lvl->lv, lv_name_new))
-		goto_bad;
+	destroy_processing_handle(cmd, handle);
+	return ret;
 
-	log_print_unless_silent("Renamed \"%s\" to \"%s\" in volume group \"%s\"",
-				lv_name_old, lv_name_new, vg_name);
-
-	r = ECMD_PROCESSED;
-bad:
-	unlock_and_release_vg(cmd, vg, vg_name);
-	return r;
 }


