From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  2 Jul 2013 13:32:33 +0000 (UTC)
Subject: master - config: add override_config_tree_from_profile fn to add the profile to a configuration cascade
Message-ID: <20130702133233.3A1E760DA8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bfde83eb345621821332a8daeaa3aa6b82da69ea
Commit:        bfde83eb345621821332a8daeaa3aa6b82da69ea
Parent:        ebc236d085116e869b5873e2b5409674c2cd2a8d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 25 12:27:37 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 2 15:19:08 2013 +0200

config: add override_config_tree_from_profile fn to add the profile to a configuration cascade

When placing the profile in a configuration cascade, this sequence is
used exactly:

CONFIG_STRING -> CONFIG_PROFILE -> CONFIG_FILE/MERGED_FILES

So if the profile is used, it overloads the lvm.conf (and any
existing tag configs). However, if "--config" is used to define
a custom configuration on command line, this overloads even the
profile config!
---
 lib/config/config.c |   35 ++++++++++++++++++++++++++++++++++-
 lib/config/config.h |    1 +
 tools/lvmcmdline.c  |    4 ++++
 3 files changed, 39 insertions(+), 1 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 5711ead..1a14a38 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -301,7 +301,7 @@ int override_config_tree_from_string(struct cmd_context *cmd,
 
 	/*
 	 * Follow this sequence:
-	 * CONFIG_STRING -> CONFIG_FILE/CONFIG_MERGED_FILES
+	 * CONFIG_STRING -> CONFIG_PROFILE -> CONFIG_FILE/CONFIG_MERGED_FILES
 	 */
 
 	if (cs->type == CONFIG_STRING) {
@@ -329,6 +329,39 @@ int override_config_tree_from_string(struct cmd_context *cmd,
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
+	if (!profile->cft && !load_profile(cmd, profile))
+		return_0;
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
index ef75580..0e4c0d5 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -135,6 +135,7 @@ int config_def_get_path(char *buf, size_t buf_size, int id);
 int config_def_check(struct cmd_context *cmd, int force, int skip, int suppress_messages);
 
 int override_config_tree_from_string(struct cmd_context *cmd, const char *config_settings);
+int override_config_tree_from_profile(struct cmd_context *cmd, struct profile *profile);
 struct dm_config_tree *remove_config_tree_by_source(struct cmd_context *cmd, config_source_t source);
 config_source_t config_get_source_type(struct dm_config_tree *cft);
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 1111df6..c50ea90 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1099,6 +1099,10 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		log_debug("Setting global configuration profile \"%s\".", profile->name);
 		/* This profile will override any VG/LV-based profile if present */
 		cmd->profile_params->global_profile = profile;
+		if (!override_config_tree_from_profile(cmd, profile)) {
+			log_error("Failed to apply configuration profile.");
+			return ECMD_FAILED;
+		}
 	}
 
 	if ((ret = _get_settings(cmd)))


