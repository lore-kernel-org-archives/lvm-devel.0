From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 17 Oct 2012 13:43:21 +0000 (UTC)
Subject: master - cleanup: swap return values
Message-ID: <20121017134321.64B221F38@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b89963a7c3aea97ff11083a13dff718b5895ccc9
Commit:        b89963a7c3aea97ff11083a13dff718b5895ccc9
Parent:        10ba799ab08001d5435425e65f039f20cadd306e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 16 10:07:27 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 17 15:37:26 2012 +0200

cleanup: swap return values

Use lvm standard return code for success/fail  1/0.
---
 lib/config/config.c     |    4 ++--
 lib/metadata/metadata.c |   10 +++++-----
 liblvm/lvm_base.c       |    2 +-
 tools/lvmcmdline.c      |    2 +-
 tools/toollib.c         |   10 +++++-----
 tools/vgcreate.c        |    4 ++--
 tools/vgsplit.c         |    4 ++--
 7 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 00bfcab..0820594 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -177,12 +177,12 @@ int override_config_tree_from_string(struct cmd_context *cmd,
 
 	if (!(cft_new = dm_config_from_string(config_settings))) {
 		log_error("Failed to set overridden configuration entries.");
-		return 1;
+		return 0;
 	}
 
 	cmd->cft = dm_config_insert_cascaded_tree(cft_new, cmd->cft);
 
-	return 0;
+	return 1;
 }
 
 int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index c210a63..0b3158a 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -822,18 +822,18 @@ int vgcreate_params_validate(struct cmd_context *cmd,
 	if (!validate_new_vg_name(cmd, vp->vg_name)) {
 		log_error("New volume group name \"%s\" is invalid",
 			  vp->vg_name);
-		return 1;
+		return 0;
 	}
 
 	if (vp->alloc == ALLOC_INHERIT) {
 		log_error("Volume Group allocation policy cannot inherit "
 			  "from anything");
-		return 1;
+		return 0;
 	}
 
 	if (!vp->extent_size) {
 		log_error("Physical extent size may not be zero");
-		return 1;
+		return 0;
 	}
 
 	if (!(cmd->fmt->features & FMT_UNLIMITED_VOLS)) {
@@ -843,11 +843,11 @@ int vgcreate_params_validate(struct cmd_context *cmd,
 			vp->max_pv = 255;
 		if (vp->max_lv > 255 || vp->max_pv > 255) {
 			log_error("Number of volumes may not exceed 255");
-			return 1;
+			return 0;
 		}
 	}
 
-	return 0;
+	return 1;
 }
 
 /*
diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index 01ea0d7..b4911df 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -89,7 +89,7 @@ int lvm_config_reload(lvm_t libh)
 int lvm_config_override(lvm_t libh, const char *config_settings)
 {
 	struct cmd_context *cmd = (struct cmd_context *)libh;
-	if (override_config_tree_from_string(cmd, config_settings))
+	if (!override_config_tree_from_string(cmd, config_settings))
 		return -1;
 	return 0;
 }
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 39a8c58..3720d7f 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1066,7 +1066,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	set_cmd_name(cmd->command->name);
 
 	if (arg_count(cmd, config_ARG))
-		if (override_config_tree_from_string(cmd, arg_str_value(cmd, config_ARG, ""))) {
+		if (!override_config_tree_from_string(cmd, arg_str_value(cmd, config_ARG, ""))) {
 			ret = EINVALID_CMD_LINE;
 			goto_out;
 		}
diff --git a/tools/toollib.c b/tools/toollib.c
index 3fe1c14..48b9a86 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1264,23 +1264,23 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 
 	if (arg_sign_value(cmd, physicalextentsize_ARG, SIGN_NONE) == SIGN_MINUS) {
 		log_error("Physical extent size may not be negative");
-		return 1;
+		return 0;
 	}
 
 	if (arg_uint64_value(cmd, physicalextentsize_ARG, 0) > MAX_EXTENT_SIZE) {
 		log_error("Physical extent size cannot be larger than %s",
 				  display_size(cmd, (uint64_t) MAX_EXTENT_SIZE));
-		return 1;
+		return 0;
 	}
 
 	if (arg_sign_value(cmd, maxlogicalvolumes_ARG, SIGN_NONE) == SIGN_MINUS) {
 		log_error("Max Logical Volumes may not be negative");
-		return 1;
+		return 0;
 	}
 
 	if (arg_sign_value(cmd, maxphysicalvolumes_ARG, SIGN_NONE) == SIGN_MINUS) {
 		log_error("Max Physical Volumes may not be negative");
-		return 1;
+		return 0;
 	}
 
 	if (arg_count(cmd, metadatacopies_ARG)) {
@@ -1295,7 +1295,7 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 						   DEFAULT_VGMETADATACOPIES);
 	}
 
-	return 0;
+	return 1;
 }
 
 int lv_refresh(struct cmd_context *cmd, struct logical_volume *lv)
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 2b9fb2f..8ce7803 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -43,10 +43,10 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 
 	vgcreate_params_set_defaults(&vp_def, NULL);
 	vp_def.vg_name = vg_name;
-	if (vgcreate_params_set_from_args(cmd, &vp_new, &vp_def))
+	if (!vgcreate_params_set_from_args(cmd, &vp_new, &vp_def))
 		return EINVALID_CMD_LINE;
 
-	if (vgcreate_params_validate(cmd, &vp_new))
+	if (!vgcreate_params_validate(cmd, &vp_new))
 	    return EINVALID_CMD_LINE;
 
 	lvmcache_seed_infos_from_lvmetad(cmd);
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 3bbb9fa..b52c2f8 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -383,12 +383,12 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 	} else {
 		vgcreate_params_set_defaults(&vp_def, vg_from);
 		vp_def.vg_name = vg_name_to;
-		if (vgcreate_params_set_from_args(cmd, &vp_new, &vp_def)) {
+		if (!vgcreate_params_set_from_args(cmd, &vp_new, &vp_def)) {
 			r = EINVALID_CMD_LINE;
 			goto_bad;
 		}
 
-		if (vgcreate_params_validate(cmd, &vp_new)) {
+		if (!vgcreate_params_validate(cmd, &vp_new)) {
 			r = EINVALID_CMD_LINE;
 			goto_bad;
 		}


