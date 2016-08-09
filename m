From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  9 Aug 2016 17:39:56 +0000 (UTC)
Subject: master - refactor: modify original _check_profile fn and rename to config_force_check for general use
Message-ID: <20160809173956.5AED46072F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=54bf15555be1808eb292cfc3edeece236a1c9744
Commit:        54bf15555be1808eb292cfc3edeece236a1c9744
Parent:        785e2c31f553b0d2e98eb2a0d2087c942da81be7
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Aug 8 12:55:15 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 9 18:49:11 2016 +0200

refactor: modify original _check_profile fn and rename to config_force_check for general use

---
 lib/config/config.c |    9 ++++-----
 lib/config/config.h |    3 +++
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 784c4b0..a569444 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -2113,7 +2113,7 @@ bad:
 	return NULL;
 }
 
-static int _check_profile(struct cmd_context *cmd, struct profile *profile)
+int config_force_check(struct cmd_context *cmd, config_source_t source, struct dm_config_tree *cft)
 {
 	struct cft_check_handle *handle;
 	int r;
@@ -2124,9 +2124,8 @@ static int _check_profile(struct cmd_context *cmd, struct profile *profile)
 	}
 
 	handle->cmd = cmd;
-	handle->cft = profile->cft;
-	handle->source = profile->source;
-	/* the check is compulsory - allow only profilable items in a profile config! */
+	handle->cft = cft;
+	handle->source = source;
 	handle->force_check = 1;
 	/* provide warning messages only if config/checks=1 */
 	handle->suppress_messages = !find_config_tree_bool(cmd, config_checks_CFG, NULL);
@@ -2252,7 +2251,7 @@ int load_profile(struct cmd_context *cmd, struct profile *profile) {
 	 * messages to be suppressed, but the check itself is always done
 	 * for profiles!
 	 */
-	if (!_check_profile(cmd, profile)) {
+	if (!config_force_check(cmd, profile->source, profile->cft)) {
 		log_error("Ignoring invalid %s %s.",
 			  _config_source_names[profile->source], profile->name);
 		config_destroy(profile->cft);
diff --git a/lib/config/config.h b/lib/config/config.h
index 157cfeb..659b8b0 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -216,7 +216,10 @@ struct cft_check_handle {
 };
 
 int config_def_get_path(char *buf, size_t buf_size, int id);
+/* Checks config using given handle - the handle may be reused. */
 int config_def_check(struct cft_check_handle *handle);
+/* Forces config check and automatically creates a new handle inside with defaults and discards the handle after the check. */
+int config_force_check(struct cmd_context *cmd, config_source_t source, struct dm_config_tree *cft);
 
 int override_config_tree_from_string(struct cmd_context *cmd, const char *config_settings);
 int override_config_tree_from_profile(struct cmd_context *cmd, struct profile *profile);


