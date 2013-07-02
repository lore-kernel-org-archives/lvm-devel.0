From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  2 Jul 2013 13:33:00 +0000 (UTC)
Subject: master - config: add validation for configuration profiles
Message-ID: <20130702133300.8003360DA8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e8832917f68f5d130f1f69e73d60f06f6f707363
Commit:        e8832917f68f5d130f1f69e73d60f06f6f707363
Parent:        f1c292cc38f4ba2e8d9b7272bc1a1ce17bd729a5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 26 16:27:28 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 2 15:22:11 2013 +0200

config: add validation for configuration profiles

Besides the classical configuration checks (type checking and
checking whether the item is recognized by lvm tools) for profiles,
do an extra check whether the configuration setting is customizable
by a profile at all. Give a warning message if not.
---
 lib/config/config.c          |   38 ++++++++++++++++++++++++++++++++++++++
 lib/config/config.h          |    5 ++++-
 lib/config/config_settings.h |    1 +
 3 files changed, 43 insertions(+), 1 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 2934b5a..59f9bb0 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -654,6 +654,19 @@ static int _config_def_check_node(struct cft_check_handle *handle,
 	if (!_config_def_check_node_value(handle, rp, cn->v, def))
 		return 0;
 
+	/*
+	 * Also check whether this configuration item is allowed
+	 * in certain types of configuration trees as in some
+	 * the use of configuration is restricted, e.g. profiles...
+	 */
+	if (handle->source == CONFIG_PROFILE &&
+	    !(def->flags & CFG_PROFILABLE)) {
+		log_warn_suppress(handle->suppress_messages,
+			"Configuration %s \"%s\" is not customizable by "
+			"a profile.", cn->v ? "option" : "section", rp);
+		return 0;
+	}
+
 	handle->status[def->id] |= CFG_VALID;
 	return 1;
 }
@@ -1405,6 +1418,29 @@ struct dm_config_tree *config_def_create_tree(struct config_def_tree_spec *spec)
 	return cft;
 }
 
+static int _check_profile(struct cmd_context *cmd, struct profile *profile)
+{
+	struct cft_check_handle *handle;
+	int r;
+
+	if (!(handle = dm_pool_zalloc(cmd->libmem, sizeof(*handle)))) {
+		log_debug("_check_profile: profile check handle allocation failed");
+		return 0;
+	}
+
+	handle->cft = profile->cft;
+	handle->source = CONFIG_PROFILE;
+	/* the check is compulsory - allow only profilable items in a profile config! */
+	handle->force_check = 1;
+	/* provide warning messages only if config/checks=1 */
+	handle->suppress_messages = !find_config_tree_bool(cmd, config_checks_CFG, NULL);
+
+	r = config_def_check(cmd, handle);
+
+	dm_pool_free(cmd->libmem, handle);
+	return r;
+}
+
 struct profile *add_profile(struct cmd_context *cmd, const char *profile_name)
 {
 	struct profile *profile;
@@ -1464,6 +1500,8 @@ int load_profile(struct cmd_context *cmd, struct profile *profile) {
 
 	dm_list_move(&cmd->profile_params->profiles, &profile->list);
 
+	(void) _check_profile(cmd, profile);
+
 	return 1;
 }
 
diff --git a/lib/config/config.h b/lib/config/config.h
index 51c777a..5109a23 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -78,8 +78,10 @@ typedef union {
 #define CFG_ALLOW_EMPTY		0x02
 /* whether the configuration item is for advanced use only */
 #define CFG_ADVANCED		0x04
-/* whether the configuraton item is not officially supported */
+/* whether the configuration item is not officially supported */
 #define CFG_UNSUPPORTED		0x08
+/* whether the configuration item is customizable by a profile */
+#define CFG_PROFILABLE		0x10
 
 /* configuration definition item structure */
 typedef struct cfg_def_item {
@@ -136,6 +138,7 @@ int load_pending_profiles(struct cmd_context *cmd);
 /* configuration check handle for each instance of the validation check */
 struct cft_check_handle {
 	struct dm_config_tree *cft;	/* the tree for which the check is done */
+	config_source_t source;		/* configuration source */
 	unsigned force_check:1;		/* force check even if disabled by config/checks setting */
 	unsigned skip_if_checked:1;	/* skip the check if already done before - return last state */
 	unsigned suppress_messages:1;	/* suppress messages during the check if config item is found invalid */
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 65d869b..a8d02be 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -31,6 +31,7 @@
  * 				CFG_ALLOW_EMPTY - node value can be emtpy
  * 				CFG_ADVANCED - this node belongs to advanced config set
  * 				CFG_UNSUPPORTED - this node belongs to unsupported config set
+ * 				CFG_PROFILABLE - this node is customizable by a profile
  * type:		allowed type for the value of simple configuation setting
  * types:		allowed types for the values of array configuration setting
  * 			(use logical "OR" to define more than one allowed type,


