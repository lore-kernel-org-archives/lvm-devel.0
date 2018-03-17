From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 17 Mar 2018 18:34:30 -0400
Subject: master - pools: skip checks when tools are missing
Message-ID: <201803172234.w2HMYUov011112@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=689af32313ac120dd67a16d73e78ede5295e308c
Commit:        689af32313ac120dd67a16d73e78ede5295e308c
Parent:        d68d71013fb261c87f1d3a26ebf098644055c6d1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 17 21:50:03 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 17 23:29:11 2018 +0100

pools: skip checks when tools are missing

If the tools for checking thin_pool or cache metadata are missing,
issue rather just a WARNING, but let the operation of activation
continue.

This has the advantage, the if user is missing those tools,
but he already started to use thinpool or cacheing, he can
access these volumes with a WARNING.

Also if the user is using too old tools i.e. for CacheV2 format
dmpd tool 0.7 is required - provide informative WARNING and
skip failure from older tool version which can't understand
new format V2.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |   64 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 65 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2ec7f7e..a974a6c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Allow activation of pools when thin/cache_check tool is missing.
   Remove RaidLV on creation failure when rmeta devices can't be activated.
   Add prioritized_section() to restore cookie boundaries (2.02.177).
   Enhance error messages when read error happens.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index ae3db80..32c737c 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1983,9 +1983,56 @@ struct pool_cb_data {
 	int skip_zero;  /* to skip zeroed device header (check first 64B) */
 	int exec;       /* which binary to call */
 	int opts;
+	struct {
+		unsigned maj;
+		unsigned min;
+		unsigned patch;
+	} version;
 	const char *global;
 };
 
+/*
+ * Simple version of check function calling 'tool -V'
+ *
+ * Returns 1 if the tool's version is equal or better to given.
+ * Otherwise it returns 0.
+ */
+static int _check_tool_version(struct cmd_context *cmd, const char *tool,
+			       unsigned maj, unsigned min, unsigned patch)
+{
+	const char *argv[] = { tool, "-V", NULL };
+	struct pipe_data pdata;
+	FILE *f;
+	char buf[128] = { 0 };
+	char *nl;
+	unsigned v_maj, v_min, v_patch;
+	int ret = 0;
+
+	if (!(f = pipe_open(cmd, argv, 0, &pdata))) {
+		log_warn("WARNING: Cannot read output from %s.", argv[0]);
+	} else {
+		if (fgets(buf, sizeof(buf) - 1, f) &&
+		    (sscanf(buf, "%u.%u.%u", &v_maj, &v_min, &v_patch) == 3)) {
+			if ((v_maj > maj) ||
+			    ((v_maj == maj) &&
+			     ((v_min > min) ||
+			      (v_min == min && v_patch >= patch))))
+				ret = 1;
+
+			if ((nl = strchr(buf, '\n')))
+				nl[0] = 0; /* cut newline away */
+
+			log_verbose("Found version of %s %s is %s then requested %u.%u.%u.",
+				    argv[0], buf, ret ? "better" : "older", maj, min, patch);
+		} else
+			log_warn("WARNING: Cannot parse output '%s' from %s.", buf, argv[0]);
+
+		(void) pipe_close(&pdata);
+	}
+
+	return ret;
+}
+
 static int _pool_callback(struct dm_tree_node *node,
 			  dm_node_callback_t type, void *cb_data)
 {
@@ -2061,6 +2108,19 @@ static int _pool_callback(struct dm_tree_node *node,
 
 	if (!(ret = exec_cmd(pool_lv->vg->cmd, (const char * const *)argv,
 			     &status, 0))) {
+		if (status == ENOENT) {
+			log_warn("WARNING: Check is skipped, please install recomended missing binary %s!",
+				 argv[0]);
+			return 1;
+		}
+
+		if ((data->version.maj || data->version.min || data->version.patch) &&
+		    !_check_tool_version(pool_lv->vg->cmd, argv[0],
+					 data->version.maj, data->version.min, data->version.patch)) {
+			log_warn("WARNING: Check is skipped, please upgrade installed version of %s!",
+				 argv[0]);
+			return 1;
+		}
 		switch (type) {
 		case DM_NODE_CALLBACK_PRELOADED:
 			log_err_once("Check of pool %s failed (status:%d). "
@@ -2118,6 +2178,10 @@ static int _pool_register_callback(struct dev_manager *dm,
 		data->exec = global_cache_check_executable_CFG;
 		data->opts = global_cache_check_options_CFG;
 		data->global = "cache";
+		if (first_seg(first_seg(lv)->pool_lv)->cache_metadata_format > 1) {
+			data->version.maj = 0;
+			data->version.min = 7;
+		}
 	} else {
 		log_error(INTERNAL_ERROR "Registering unsupported pool callback.");
 		return 0;


