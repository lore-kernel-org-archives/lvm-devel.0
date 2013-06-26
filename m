From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 26 Jun 2013 14:56:15 +0000 (UTC)
Subject: dev-peter-config-profiles - config: add validation for configuration profiles
Message-ID: <20130626145615.A29AB61556@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0156ffe1469e0d3685ca37356e5b06cde4605220
Commit:        0156ffe1469e0d3685ca37356e5b06cde4605220
Parent:        28e644fa11ff2101ea20e0842055d0c26bb8ede6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 26 16:27:28 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 26 16:53:51 2013 +0200

config: add validation for configuration profiles

Besides the classical configuration checks (type checking and
checking whether the item is recognized by lvm tools) for profiles,
do an extra check whether the configuration setting is customizable
by a profile at all. Give a warning message if not.
---
 lib/commands/toolcontext.c   |   21 +++++++++++++++++++++
 lib/config/config.c          |   13 +++++++++++++
 lib/config/config.h          |    5 ++++-
 lib/config/config_settings.h |    1 +
 4 files changed, 39 insertions(+), 1 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index cee5ed9..db8b8cb 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -617,6 +617,25 @@ static int _load_config_file(struct cmd_context *cmd, const char *tag)
 	return 1;
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
+
+	r = config_def_check(cmd, handle);
+
+	dm_pool_free(cmd->libmem, handle);
+	return r;
+}
+
 struct profile *load_profile(struct cmd_context *cmd, const char *profile_name)
 {
 	static char profile_path[PATH_MAX];
@@ -657,6 +676,8 @@ struct profile *load_profile(struct cmd_context *cmd, const char *profile_name)
 		return_NULL;
 	}
 
+	(void) _check_profile(cmd, profile);
+
 	dm_list_add(&cmd->profile_params->profiles, &profile->list);
 
 	return profile;
diff --git a/lib/config/config.c b/lib/config/config.c
index c66dd9b..eb9ee17 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -613,6 +613,19 @@ static int _config_def_check_node(struct cft_check_handle *handle,
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
+		return 1;
+	}
+
 	handle->status[def->id] |= CFG_VALID;
 	return 1;
 }
diff --git a/lib/config/config.h b/lib/config/config.h
index 5b402d7..7134621 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -77,8 +77,10 @@ typedef union {
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
@@ -131,6 +133,7 @@ enum {
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


