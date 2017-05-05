From: David Teigland <teigland@sourceware.org>
Date: Fri, 5 May 2017 11:00:53 -0400
Subject: master - lvcreate: cachemode writeback and cachepolicy cleaner is invalid
Message-ID: <201705051500.v45F0rlE025614@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=df5fd5ae8843e6bbbe7f61c4919a594693639a60
Commit:        df5fd5ae8843e6bbbe7f61c4919a594693639a60
Parent:        7fbeea30e5ce4dbb4877910877575ed6c37dfb8c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 5 09:59:12 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 5 09:59:12 2017 -0500

lvcreate: cachemode writeback and cachepolicy cleaner is invalid

Return an error if lvconvert is used to create a cache pool
with that combination.
---
 tools/toollib.c |   18 +++++++++++++-----
 1 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index f3cf4ca..e5a854f 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1335,9 +1335,17 @@ int get_stripe_params(struct cmd_context *cmd, const struct segment_type *segtyp
 	return _validate_stripe_params(cmd, segtype, stripes, stripe_size);
 }
 
-static int _validate_cachepool_params(const char *name,
-				      const struct dm_config_tree *settings)
+static int _validate_cachepool_params(const char *policy_name, cache_mode_t cache_mode)
 {
+	/*
+	 * FIXME: it might be nice if cmd def rules could check option values,
+	 * then a rule could do this.
+	 */
+	if ((cache_mode == CACHE_MODE_WRITEBACK) && policy_name && !strcmp(policy_name, "cleaner")) {
+		log_error("Cache mode \"writeback\" is not compatible with cache policy \"cleaner\".");
+		return 0;
+	}
+
 	return 1;
 }
 
@@ -1371,6 +1379,9 @@ int get_cache_params(struct cmd_context *cmd,
 
 	*name = arg_str_value(cmd, cachepolicy_ARG, NULL);
 
+	if (!_validate_cachepool_params(*name, *cache_mode))
+		goto_out;
+
 	dm_list_iterate_items(group, &cmd->arg_value_groups) {
 		if (!grouped_arg_is_set(group->arg_values, cachesettings_ARG))
 			continue;
@@ -1401,9 +1412,6 @@ int get_cache_params(struct cmd_context *cmd,
 			cn->child = result->root;
 			result->root = cn;
 		}
-
-		if (!_validate_cachepool_params(*name, result))
-			goto_out;
 	}
 
 	ok = 1;


