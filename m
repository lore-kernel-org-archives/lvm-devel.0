From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 26 Jun 2013 14:55:48 +0000 (UTC)
Subject: dev-peter-config-profiles - config: add override_config_tree_from_profile fn to add the profile to a configuration cascade
Message-ID: <20130626145548.581AE60F23@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=99707bf75efc1afcad23739b907f2fd7e38d5c74
Commit:        99707bf75efc1afcad23739b907f2fd7e38d5c74
Parent:        070ffe7822089eefac9c4ed867ada0ee45634536
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 25 12:27:37 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 26 16:53:49 2013 +0200

config: add override_config_tree_from_profile fn to add the profile to a configuration cascade

When placing the profile in a configuration cascade, this sequence is
used exactly:

CONFIG_STRING -> CONFIG_PROFILE -> CONFIG_FILE/MERGED_FILES

So if the profile is used, it overloads the lvm.conf (and any
existing tag configs). However, if "--config" is used to define
a custom configuration on command line, this overloads even the
profile config!
---
 lib/config/config.c |   32 +++++++++++++++++++++++++++++++-
 lib/config/config.h |    1 +
 tools/lvmcmdline.c  |    4 ++++
 3 files changed, 36 insertions(+), 1 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 177f373..a4c45b7 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -263,7 +263,7 @@ int override_config_tree_from_string(struct cmd_context *cmd,
 
 	/*
 	 * Follow this sequence:
-	 * CONFIG_STRING -> CONFIG_FILE/CONFIG_MERGED_FILES
+	 * CONFIG_STRING -> CONFIG_PROFILE -> CONFIG_FILE/CONFIG_MERGED_FILES
 	 */
 
 	if (cs->type == CONFIG_STRING) {
@@ -291,6 +291,36 @@ int override_config_tree_from_string(struct cmd_context *cmd,
 	return 1;
 }
 
+int override_config_tree_from_profile(struct cmd_context *cmd,
+				      struct profile *profile)
+{
+	struct dm_config_tree *cft = cmd->cft, *cft_string = NULL;
+	struct config_source *cs = dm_config_get_custom(cft);
+
+	/*
+	 * Follow this sequence:
+	 * CONFIG_STRING -> CONFIG_PROFILE -> CONFIG_FILE/CONFIG_MERGED_FILES
+	 */
+
+	if (cs->type == CONFIG_STRING) {
+		cft_string = cft;
+		cft = cft->cascade;
+		cs = dm_config_get_custom(cft);
+		if (cs->type == CONFIG_PROFILE) {
+			log_error(INTERNAL_ERROR "override_config_tree_from_profile: "
+				  "config cascade already contains a profile config.");
+			return 0;
+		}
+		dm_config_insert_cascaded_tree(cft_string, profile->cft);
+	}
+
+	cmd->cft = dm_config_insert_cascaded_tree(profile->cft, cft);
+
+	cmd->cft = cft_string ? : profile->cft;
+
+	return 1;
+}
+
 int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
 			off_t offset, size_t size, off_t offset2, size_t size2,
 			checksum_fn_t checksum_fn, uint32_t checksum)
diff --git a/lib/config/config.h b/lib/config/config.h
index 93811fb..a09382e 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -132,6 +132,7 @@ int config_def_get_path(char *buf, size_t buf_size, int id);
 int config_def_check(struct cmd_context *cmd, int force, int skip, int suppress_messages);
 
 int override_config_tree_from_string(struct cmd_context *cmd, const char *config_settings);
+int override_config_tree_from_profile(struct cmd_context *cmd, struct profile *profile);
 struct dm_config_tree *remove_config_tree_by_source(struct cmd_context *cmd, config_source_t source);
 config_source_t config_get_source_type(struct dm_config_tree *cft);
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 9bf3d93..e41fea6 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1100,6 +1100,10 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		}
 		log_debug("Setting global configuration profile \"%s\".", profile->name);
 		cmd->profile_params->global_profile = profile;
+		if (!override_config_tree_from_profile(cmd, profile)) {
+			log_error("Failed to apply configuration profile.");
+			return ECMD_FAILED;
+		}
 	}
 
 	if ((ret = _get_settings(cmd)))


