From: David Teigland <teigland@sourceware.org>
Date: Tue, 4 Dec 2018 15:10:57 -0500
Subject: master - remove unused lvmetad filter
Message-ID: <201812042010.wB4KAvXu024218@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=89c11a2b49182f6858629857b8c6b3ba126c5970
Commit:        89c11a2b49182f6858629857b8c6b3ba126c5970
Parent:        c1b2de936cf231c753c4c9f325d33ad5c746709e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Dec 4 12:44:43 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Dec 4 12:44:43 2018 -0600

remove unused lvmetad filter

---
 lib/commands/toolcontext.c |   54 +++++++++++++-------------------------------
 lib/commands/toolcontext.h |    1 -
 2 files changed, 16 insertions(+), 39 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 754be86..8b2ab4e 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1034,7 +1034,7 @@ static int _init_dev_cache(struct cmd_context *cmd)
 
 #define MAX_FILTERS 10
 
-static struct dev_filter *_init_lvmetad_filter_chain(struct cmd_context *cmd)
+static struct dev_filter *_init_filter_chain(struct cmd_context *cmd)
 {
 	int nr_filt = 0;
 	const struct dm_config_node *cn;
@@ -1143,27 +1143,9 @@ bad:
 }
 
 /*
- * The way the filtering is initialized depends on whether lvmetad is uesd or not.
- *
- * If lvmetad is used, there are three filter chains:
- *
- *   - cmd->lvmetad_filter - the lvmetad filter chain used when scanning devs for lvmetad update:
- *     sysfs filter -> internal filter -> global regex filter -> type filter ->
- *     usable device filter(FILTER_MODE_PRE_LVMETAD) ->
- *     mpath component filter -> partitioned filter ->
- *     md component filter -> fw raid filter
- *
- *   - cmd->filter - the filter chain used for lvmetad responses:
- *     persistent filter -> regex_filter -> usable device filter(FILTER_MODE_POST_LVMETAD)
- *
- *   - cmd->full_filter - the filter chain used for all the remaining situations:
- *     cmd->lvmetad_filter -> cmd->filter
- *
- * If lvmetad is not used, there's just one filter chain:
- *
- *   - cmd->filter == cmd->full_filter:
- *     persistent filter -> sysfs filter -> internal filter -> global regex filter ->
- *     regex_filter -> type filter -> usable device filter(FILTER_MODE_NO_LVMETAD) ->
+ *   cmd->filter == 
+ *     persistent(cache) filter -> sysfs filter -> internal filter -> global regex filter ->
+ *     regex_filter -> type filter -> usable device filter ->
  *     mpath component filter -> partitioned filter -> md component filter -> fw raid filter
  *
  */
@@ -1176,24 +1158,24 @@ int init_filters(struct cmd_context *cmd, unsigned load_persistent_cache)
 		return 0;
 	}
 
-	cmd->lvmetad_filter = _init_lvmetad_filter_chain(cmd);
-	if (!cmd->lvmetad_filter)
+	filter = _init_filter_chain(cmd);
+	if (!filter)
 		goto_bad;
 
 	init_ignore_suspended_devices(find_config_tree_bool(cmd, devices_ignore_suspended_devices_CFG, NULL));
 	init_ignore_lvm_mirrors(find_config_tree_bool(cmd, devices_ignore_lvm_mirrors_CFG, NULL));
 
 	/*
-	 * If lvmetad is used, there's a separation between pre-lvmetad filter chain
-	 * ("cmd->lvmetad_filter") applied only if scanning for lvmetad update and
-	 * post-lvmetad filter chain ("filter") applied on each lvmetad response.
-	 * However, if lvmetad is not used, these two chains are not separated
-	 * and we use exactly one filter chain during device scanning ("filter"
-	 * that includes also "cmd->lvmetad_filter" chain).
+	 * persisent filter is a cache of the previous result real filter result.
+	 * If a dev is found in persistent filter, the pass/fail result saved by
+	 * the pfilter is used.  If a dev does not existing in the persistent
+	 * filter, the dev is passed on to the real filter, and when the result
+	 * of the real filter is saved in the persistent filter.
+	 *
+	 * FIXME: we should apply the filter once at the start of the command,
+	 * and not call the filters repeatedly.  In that case we would not need
+	 * the persistent/caching filter layer.
 	 */
-	filter = cmd->lvmetad_filter;
-	cmd->lvmetad_filter = NULL;
-
 	if (!(pfilter = persistent_filter_create(cmd->dev_types, filter))) {
 		log_verbose("Failed to create persistent device filter.");
 		goto bad;
@@ -1223,10 +1205,6 @@ bad:
 		filter->destroy(filter);
 	}
 
-	/* if lvmetad is used, the cmd->lvmetad_filter is separate */
-	if (cmd->lvmetad_filter)
-		cmd->lvmetad_filter->destroy(cmd->lvmetad_filter);
-
 	cmd->initialized.filters = 0;
 	return 0;
 }
@@ -1858,7 +1836,7 @@ static void _destroy_filters(struct cmd_context *cmd)
 {
 	if (cmd->full_filter) {
 		cmd->full_filter->destroy(cmd->full_filter);
-		cmd->lvmetad_filter = cmd->filter = cmd->full_filter = NULL;
+		cmd->filter = cmd->full_filter = NULL;
 	}
 	cmd->initialized.filters = 0;
 }
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 2ac7a1e..f820ba1 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -176,7 +176,6 @@ struct cmd_context {
 	/*
 	 * Filtering.
 	 */
-	struct dev_filter *lvmetad_filter;	/* pre-lvmetad filter chain */
 	struct dev_filter *filter;		/* post-lvmetad filter chain */
 	struct dev_filter *full_filter;		/* lvmetad_filter + filter */
 


