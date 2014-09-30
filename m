From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 30 Sep 2014 11:32:19 +0000 (UTC)
Subject: master - filters: use usable device filter and separate lvmetad filter chain so it's not reevaluated for any lvmetad response
Message-ID: <20140930113219.9D37860E56@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c2981cf921c5808b6e9b21d72a988e9b22f2d4a7
Commit:        c2981cf921c5808b6e9b21d72a988e9b22f2d4a7
Parent:        8a843d0d97c66aae1872c05b0f6cf4bda176aae2
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Sep 23 12:50:09 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Sep 30 13:22:11 2014 +0200

filters: use usable device filter and separate lvmetad filter chain so it's not reevaluated for any lvmetad response

With this change, the filter chains used look like this now:

  A) When *lvmetad is not used*:
    - persistent filter -> regex filter -> sysfs filter ->
      global regex filter -> type filter ->
      usable device filter(FILTER_MODE_NO_LVMETAD) ->
      mpath component filter -> partitioned filter ->
      md component filter

  B) When *lvmetad is used* (two separate filter chains):
     - the lvmetad filter chain used when scanning devs for lvmetad update:
       sysfs filter -> global regex filter -> type filter ->
       usable device filter(FILTER_MODE_PRE_LVMETAD) ->
       mpath component filter -> partitioned filter ->
       md component filter

     - the filter chain used for lvmetad responses:
       persistent filter -> usable device filter(FILTER_MODE_POST_LVMETAD) ->
       regex filter
---
 lib/cache/lvmetad.c             |    6 +--
 lib/commands/toolcontext.c      |  141 ++++++++++++++++++++++++++++++++-------
 lib/filters/filter-persistent.c |    9 ---
 3 files changed, 117 insertions(+), 39 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index ef1d01a..5589cfd 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -293,11 +293,7 @@ static struct lvmcache_info *_pv_populate_lvmcache(struct cmd_context *cmd,
 		dev = dev_cache_get_by_devt(fallback, cmd->filter);
 
 	if (!dev) {
-		dev = dev_cache_get_by_devt(devt, cmd->lvmetad_filter);
-		if (!dev)
-			log_error("No device found for PV %s.", pvid_txt);
-		else
-			log_warn("WARNING: Device %s for PV %s rejected by a filter.", dev_name(dev), pvid_txt);
+		log_warn("WARNING: Device for PV %s not found or rejected by a filter.", pvid_txt);
 		return NULL;
 	}
 
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index c3afae4..7c77e54 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -835,9 +835,9 @@ static int _init_dev_cache(struct cmd_context *cmd)
 	return 1;
 }
 
-#define MAX_FILTERS 6
+#define MAX_FILTERS 7
 
-static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
+static struct dev_filter *_init_lvmetad_filter_chain(struct cmd_context *cmd)
 {
 	int nr_filt = 0;
 	const struct dm_config_node *cn;
@@ -876,6 +876,15 @@ static struct dev_filter *_init_filter_components(struct cmd_context *cmd)
 	}
 	nr_filt++;
 
+	/* usable device filter. Required. */
+	if (!(filters[nr_filt] = usable_filter_create(cmd->dev_types,
+						      lvmetad_used() ? FILTER_MODE_PRE_LVMETAD
+								     : FILTER_MODE_NO_LVMETAD))) {
+		log_error("Failed to create usabled device filter");
+		goto bad;
+	}
+	nr_filt++;
+
 	/* mpath component filter. Optional, non-critical. */
 	if (find_config_tree_bool(cmd, devices_multipath_component_detection_CFG, NULL)) {
 		if ((filters[nr_filt] = mpath_filter_create(cmd->dev_types)))
@@ -908,39 +917,85 @@ bad:
 	return NULL;
 }
 
+/*
+ * The way the filtering is initialized depends on whether lvmetad is uesd or not.
+ *
+ * If lvmetad is used, there are two filter chains:
+ *
+ *   - the lvmetad filter chain used when scanning devs for lvmetad update:
+ *     sysfs filter -> global regex filter -> type filter ->
+ *     usable device filter(FILTER_MODE_PRE_LVMETAD) ->
+ *     mpath component filter -> partitioned filter ->
+ *     md component filter
+ *
+ *   - the filter chain used for lvmetad responses:
+ *     persistent filter -> usable device filter(FILTER_MODE_POST_LVMETAD) ->
+ *     regex filter
+ *
+ *
+ * If lvmetad isnot used, there's just one filter chain:
+ *
+ *   - persistent filter -> regex filter -> sysfs filter ->
+ *     global regex filter -> type filter ->
+ *     usable device filter(FILTER_MODE_NO_LVMETAD) ->
+ *     mpath component filter -> partitioned filter ->
+ *     md component filter
+ *
+ */
 static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache)
 {
 	const char *dev_cache;
-	struct dev_filter *f3 = NULL, *f4 = NULL, *toplevel_components[2] = { 0 };
+	struct dev_filter *filter = NULL, *filter_components[2] = {0};
 	struct stat st;
 	const struct dm_config_node *cn;
 
 	cmd->dump_filter = 0;
 
-	if (!(cmd->lvmetad_filter = _init_filter_components(cmd)))
+	cmd->lvmetad_filter = _init_lvmetad_filter_chain(cmd);
+	if (!cmd->lvmetad_filter)
 		goto_bad;
 
 	init_ignore_suspended_devices(find_config_tree_bool(cmd, devices_ignore_suspended_devices_CFG, NULL));
 	init_ignore_lvm_mirrors(find_config_tree_bool(cmd, devices_ignore_lvm_mirrors_CFG, NULL));
 
+	/*
+	 * If lvmetad is used, there's a separation between pre-lvmetad filter chain
+	 * ("cmd->lvmetad_filter") applied only if scanning for lvmetad update and
+	 * post-lvmetad filter chain ("filter") applied on each lvmetad response.
+	 * However, if lvmetad is not used, these two chains are not separated
+	 * and we use exactly one filter chain during device scanning ("filter"
+	 * that includes also "cmd->lvmetad_filter" chain).
+	 */
+	/* filter component 0 */
+	if (lvmetad_used()) {
+		if (!(filter_components[0] = usable_filter_create(cmd->dev_types, FILTER_MODE_POST_LVMETAD))) {
+			log_verbose("Failed to create usable device filter.");
+			goto bad;
+		}
+	} else
+		filter_components[0] = cmd->lvmetad_filter;
+
+	/* filter component 1 */
 	if ((cn = find_config_tree_node(cmd, devices_filter_CFG, NULL))) {
-		if (!(f3 = regex_filter_create(cn->v)))
+		if (!(filter_components[1] = regex_filter_create(cn->v)))
 			goto_bad;
-		toplevel_components[0] = cmd->lvmetad_filter;
-		toplevel_components[1] = f3;
-		if (!(f4 = composite_filter_create(2, toplevel_components)))
+		/* we have two filter components - create composite filter */
+		if (!(filter = composite_filter_create(2, filter_components)))
 			goto_bad;
 	} else
-		f4 = cmd->lvmetad_filter;
+		/* we have only one filter component - no need to create composite filter */
+		filter = filter_components[0];
 
 	if (!(dev_cache = find_config_tree_str(cmd, devices_cache_CFG, NULL)))
 		goto_bad;
 
-	if (!(cmd->filter = persistent_filter_create(cmd->dev_types, f4, dev_cache))) {
+	if (!(filter = persistent_filter_create(cmd->dev_types, filter, dev_cache))) {
 		log_verbose("Failed to create persistent device filter.");
 		goto bad;
 	}
 
+	cmd->filter = filter;
+
 	/* Should we ever dump persistent filter state? */
 	if (find_config_tree_bool(cmd, devices_write_cache_state_CFG, NULL))
 		cmd->dump_filter = 1;
@@ -963,14 +1018,27 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 
 	return 1;
 bad:
-	if (f4) /* kills both f3 and cmd->lvmetad_filter */
-		f4->destroy(f4);
-	else {
-		if (f3)
-			f3->destroy(f3);
-		if (cmd->lvmetad_filter)
-			cmd->lvmetad_filter->destroy(cmd->lvmetad_filter);
+	if (!filter) {
+		/*
+		 * composite filter not created - destroy
+		 * each component directly
+		 */
+		if (filter_components[0])
+			filter_components[0]->destroy(filter_components[0]);
+		if (filter_components[1])
+			filter_components[1]->destroy(filter_components[1]);
+	} else {
+		/*
+		 * composite filter created - destroy it - this
+		 * will also destroy any of its components
+		 */
+		filter->destroy(filter);
 	}
+
+	/* if lvmetad is used, the cmd->lvmetad_filter is separate */
+	if (lvmetad_used() && cmd->lvmetad_filter)
+		cmd->lvmetad_filter->destroy(cmd->lvmetad_filter);
+
 	return 0;
 }
 
@@ -1581,17 +1649,31 @@ static void _destroy_dev_types(struct cmd_context *cmd)
 	cmd->dev_types = NULL;
 }
 
-int refresh_filters(struct cmd_context *cmd)
+static void _destroy_filters(struct cmd_context *cmd)
 {
-	int r, saved_ignore_suspended_devices = ignore_suspended_devices();
-
+	/*
+	* If lvmetad is used, the cmd->lvmetad_filter is
+	* a separate filter chain than cmd->filter so
+	* we need to destroy it separately.
+	* Otherwise, if lvmetad is not used, cmd->lvmetad_filter
+	* is actually a part of cmd->filter and as such, it
+	* will be destroyed together with cmd->filter.
+	*/
+	if (lvmetad_used() && cmd->lvmetad_filter) {
+		cmd->lvmetad_filter->destroy(cmd->lvmetad_filter);
+		cmd->lvmetad_filter = NULL;
+	}
 	if (cmd->filter) {
 		cmd->filter->destroy(cmd->filter);
 		cmd->filter = NULL;
 	}
+}
 
-	cmd->lvmetad_filter = NULL;
+int refresh_filters(struct cmd_context *cmd)
+{
+	int r, saved_ignore_suspended_devices = ignore_suspended_devices();
 
+	_destroy_filters(cmd);
 	if (!(r = _init_filters(cmd, 0)))
                 stack;
 
@@ -1621,10 +1703,8 @@ int refresh_toolcontext(struct cmd_context *cmd)
 	label_exit();
 	_destroy_segtypes(&cmd->segtypes);
 	_destroy_formats(cmd, &cmd->formats);
-	if (cmd->filter) {
-		cmd->filter->destroy(cmd->filter);
-		cmd->filter = NULL;
-	}
+	_destroy_filters(cmd);
+
 	if (!dev_cache_exit())
 		stack;
 	_destroy_dev_types(cmd);
@@ -1737,6 +1817,17 @@ void destroy_toolcontext(struct cmd_context *cmd)
 	label_exit();
 	_destroy_segtypes(&cmd->segtypes);
 	_destroy_formats(cmd, &cmd->formats);
+
+	/*
+	* If lvmetad is used, the cmd->lvmetad_filter is
+	* a separate filter chain than cmd->filter so
+	* we need to destroy it separately.
+	* Otherwise, if lvmetad is not used, cmd->lvmetad_filter
+	* is actually a part of cmd->filter and as such, it
+	* will be destroyed together with cmd->filter.
+	*/
+	if (lvmetad_used() && cmd->lvmetad_filter)
+		cmd->lvmetad_filter->destroy(cmd->lvmetad_filter);
 	if (cmd->filter)
 		cmd->filter->destroy(cmd->filter);
 	if (cmd->mem)
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index ca3ad37..600fa38 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -288,15 +288,6 @@ static int _lookup_p(struct dev_filter *f, struct device *dev)
 					log_error("Failed to hash device to filter.");
 					return 0;
 				}
-		if (!device_is_usable(dev, (struct dev_usable_check_params)
-				      { .check_empty = 1,
-					.check_blocked = 1,
-					.check_suspended = ignore_suspended_devices(),
-					.check_error_target = 1,
-					.check_reserved = 1 })) {
-			log_debug_devs("%s: Skipping unusable device", dev_name(dev));
-			return 0;
-		}
 		return pf->real->passes_filter(pf->real, dev);
 	}
 


