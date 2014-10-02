From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  2 Oct 2014 11:12:07 +0000 (UTC)
Subject: master - filters: add cmd->full_filter - composite of cmd->filter and cmd->lvmetad_filter
Message-ID: <20141002111207.DC77A61796@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5011cac9cfe2845c52f132feb78d72aaee60ff7b
Commit:        5011cac9cfe2845c52f132feb78d72aaee60ff7b
Parent:        d3fb69c3f39df1a60fa05ed25a7d270af996054d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Oct 2 12:00:57 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Oct 2 13:06:46 2014 +0200

filters: add cmd->full_filter - composite of cmd->filter and cmd->lvmetad_filter

There are actually three filter chains if lvmetad is used:
  - cmd->lvmetad_filter used when when scanning devices for lvmetad
  - cmd->filter used when processing lvmetad responses
  - cmd->full_fiilter (which is just cmd->lvmetad_filter + cmd->filter chained together) used
    for remaining situations

This patch adds the third one - "cmd->full_filter" - currently this is
used if device processing does not fall into any of the groups before,
for example, devices which does not have the PV label yet and we're just
creating a new one or we're processing the devices where the list of the
devices (PVs) is not returned by lvmetad initially.

Currently, the cmd->full_filter is used exactly in these functions:
  - lvmcache_label_scan
  - _pvcreate_check
  - pvcreate_vol
  - lvmdiskscan
  - pvscan
  - _process_each_label

If lvmetad is used, then simply cmd->full_filter == cmd->filter because
cmd->lvmetad_filter is NULL in this case.
---
 lib/cache/lvmcache.c       |    8 +++---
 lib/commands/toolcontext.c |   51 ++++++++++++++++---------------------------
 lib/commands/toolcontext.h |   17 +++++++++++++-
 lib/metadata/metadata.c    |    8 +++---
 tools/lvmdiskscan.c        |    4 +-
 tools/pvscan.c             |    4 +-
 tools/toollib.c            |    4 +-
 7 files changed, 49 insertions(+), 47 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 41bac8b..44f586b 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -693,10 +693,10 @@ int lvmcache_label_scan(struct cmd_context *cmd, int full_scan)
 		goto out;
 	}
 
-	if (full_scan == 2 && (cmd->filter && !cmd->filter->use_count) && !refresh_filters(cmd))
+	if (full_scan == 2 && (cmd->full_filter && !cmd->full_filter->use_count) && !refresh_filters(cmd))
 		goto_out;
 
-	if (!cmd->filter || !(iter = dev_iter_create(cmd->filter, (full_scan == 2) ? 1 : 0))) {
+	if (!cmd->full_filter || !(iter = dev_iter_create(cmd->full_filter, (full_scan == 2) ? 1 : 0))) {
 		log_error("dev_iter creation failed");
 		goto out;
 	}
@@ -719,8 +719,8 @@ int lvmcache_label_scan(struct cmd_context *cmd, int full_scan)
 	 * device cache for the benefit of short-lived processes.
 	 */
 	if (full_scan == 2 && cmd->is_long_lived &&
-	    cmd->dump_filter && cmd->filter && cmd->filter->dump &&
-	    !cmd->filter->dump(cmd->filter, 0))
+	    cmd->dump_filter && cmd->full_filter && cmd->full_filter->dump &&
+	    !cmd->full_filter->dump(cmd->full_filter, 0))
 		stack;
 
 	r = 1;
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index e72691d..e38aa56 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -920,22 +920,25 @@ bad:
 /*
  * The way the filtering is initialized depends on whether lvmetad is uesd or not.
  *
- * If lvmetad is used, there are two filter chains:
+ * If lvmetad is used, there are three filter chains:
  *
- *   - the lvmetad filter chain used when scanning devs for lvmetad update:
+ *   - cmd->lvmetad_filter - the lvmetad filter chain used when scanning devs for lvmetad update:
  *     sysfs filter -> global regex filter -> type filter ->
  *     usable device filter(FILTER_MODE_PRE_LVMETAD) ->
  *     mpath component filter -> partitioned filter ->
  *     md component filter
  *
- *   - the filter chain used for lvmetad responses:
+ *   - cmd->filter - the filter chain used for lvmetad responses:
  *     persistent filter -> usable device filter(FILTER_MODE_POST_LVMETAD) ->
  *     regex filter
  *
+ *   - cmd->full_filter - the filter chain used for all the remaining situations:
+ *     lvmetad_filter -> filter
  *
  * If lvmetad isnot used, there's just one filter chain:
  *
- *   - persistent filter -> regex filter -> sysfs filter ->
+ *   - cmd->filter == cmd->full_filter:
+ *     persistent filter -> regex filter -> sysfs filter ->
  *     global regex filter -> type filter ->
  *     usable device filter(FILTER_MODE_NO_LVMETAD) ->
  *     mpath component filter -> partitioned filter ->
@@ -998,6 +1001,14 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 
 	cmd->filter = filter;
 
+	if (lvmetad_used()) {
+		filter_components[0] = cmd->lvmetad_filter;
+		filter_components[1] = cmd->filter;
+		if (!(cmd->full_filter = composite_filter_create(2, filter_components)))
+			goto_bad;
+	} else
+		cmd->full_filter = filter;
+
 	/* Should we ever dump persistent filter state? */
 	if (find_config_tree_bool(cmd, devices_write_cache_state_CFG, NULL))
 		cmd->dump_filter = 1;
@@ -1653,21 +1664,9 @@ static void _destroy_dev_types(struct cmd_context *cmd)
 
 static void _destroy_filters(struct cmd_context *cmd)
 {
-	/*
-	* If lvmetad is used, the cmd->lvmetad_filter is
-	* a separate filter chain than cmd->filter so
-	* we need to destroy it separately.
-	* Otherwise, if lvmetad is not used, cmd->lvmetad_filter
-	* is actually a part of cmd->filter and as such, it
-	* will be destroyed together with cmd->filter.
-	*/
-	if (cmd->lvmetad_filter) {
-		cmd->lvmetad_filter->destroy(cmd->lvmetad_filter);
-		cmd->lvmetad_filter = NULL;
-	}
-	if (cmd->filter) {
-		cmd->filter->destroy(cmd->filter);
-		cmd->filter = NULL;
+	if (cmd->full_filter) {
+		cmd->full_filter->destroy(cmd->full_filter);
+		cmd->lvmetad_filter = cmd->filter = cmd->full_filter = NULL;
 	}
 }
 
@@ -1819,19 +1818,7 @@ void destroy_toolcontext(struct cmd_context *cmd)
 	label_exit();
 	_destroy_segtypes(&cmd->segtypes);
 	_destroy_formats(cmd, &cmd->formats);
-
-	/*
-	* If lvmetad is used, the cmd->lvmetad_filter is
-	* a separate filter chain than cmd->filter so
-	* we need to destroy it separately.
-	* Otherwise, if lvmetad is not used, cmd->lvmetad_filter
-	* is actually a part of cmd->filter and as such, it
-	* will be destroyed together with cmd->filter.
-	*/
-	if (cmd->lvmetad_filter)
-		cmd->lvmetad_filter->destroy(cmd->lvmetad_filter);
-	if (cmd->filter)
-		cmd->filter->destroy(cmd->filter);
+	_destroy_filters(cmd);
 	if (cmd->mem)
 		dm_pool_destroy(cmd->mem);
 	dev_cache_exit();
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 57c51d2..d99cc28 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -97,8 +97,23 @@ struct cmd_context {
 	unsigned independent_metadata_areas:1;	/* Active formats have MDAs outside PVs */
 
 	struct dev_types *dev_types;
-	struct dev_filter *filter;
+
+	/*
+	 * Use of filters depends on whether lvmetad is used or not:
+	 *
+	 *   - if lvmetad is used:
+	 *   	- cmd->lvmetad_filter used when scanning devices for lvmetad
+	 *   	- cmd->filter used when processing lvmetad responses
+	 *   	- cmd->full_filter used for remaining situations
+	 *
+	 *   - if lvmetad is not used:
+	 *   	- cmd->lvmetad_filter is NULL
+	 *   	- cmd->filter == cmd->full_filter used for all situations
+	 *
+	 */
 	struct dev_filter *lvmetad_filter;
+	struct dev_filter *filter;
+	struct dev_filter *full_filter;
 	int dump_filter;	/* Dump filter when exiting? */
 
 	struct dm_list config_files; /* master lvm config + any existing tag configs */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 353db25..6719fe4 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1405,7 +1405,7 @@ static int _pvcreate_check(struct cmd_context *cmd, const char *name,
 	if (sigint_caught())
 		goto_out;
 
-	dev = dev_cache_get(name, cmd->filter);
+	dev = dev_cache_get(name, cmd->full_filter);
 
 	/* Is there an md superblock here? */
 	if (!dev && md_filtering()) {
@@ -1413,7 +1413,7 @@ static int _pvcreate_check(struct cmd_context *cmd, const char *name,
 			goto_out;
 
 		init_md_filtering(0);
-		dev = dev_cache_get(name, cmd->filter);
+		dev = dev_cache_get(name, cmd->full_filter);
 		init_md_filtering(1);
 
 		scan_needed = 1;
@@ -1591,7 +1591,7 @@ struct physical_volume *pvcreate_vol(struct cmd_context *cmd, const char *pv_nam
 
 	if (pp->rp.idp) {
 		if ((dev = lvmcache_device_from_pvid(cmd, pp->rp.idp, NULL, NULL)) &&
-		    (dev != dev_cache_get(pv_name, cmd->filter))) {
+		    (dev != dev_cache_get(pv_name, cmd->full_filter))) {
 			if (!id_write_format((const struct id*)&pp->rp.idp->uuid,
 			    buffer, sizeof(buffer)))
 				goto_bad;
@@ -1607,7 +1607,7 @@ struct physical_volume *pvcreate_vol(struct cmd_context *cmd, const char *pv_nam
 	if (sigint_caught())
 		goto_bad;
 
-	if (!(dev = dev_cache_get(pv_name, cmd->filter))) {
+	if (!(dev = dev_cache_get(pv_name, cmd->full_filter))) {
 		log_error("%s: Couldn't find device.  Check your filters?",
 			  pv_name);
 		goto bad;
diff --git a/tools/lvmdiskscan.c b/tools/lvmdiskscan.c
index df3f072..0320a76 100644
--- a/tools/lvmdiskscan.c
+++ b/tools/lvmdiskscan.c
@@ -111,9 +111,9 @@ int lvmdiskscan(struct cmd_context *cmd, int argc __attribute__((unused)),
 	if (arg_count(cmd, lvmpartition_ARG))
 		log_warn("WARNING: only considering LVM devices");
 
-	max_len = _get_max_dev_name_len(cmd->filter);
+	max_len = _get_max_dev_name_len(cmd->full_filter);
 
-	if (!(iter = dev_iter_create(cmd->filter, 0))) {
+	if (!(iter = dev_iter_create(cmd->full_filter, 0))) {
 		log_error("dev_iter_create failed");
 		return ECMD_FAILED;
 	}
diff --git a/tools/pvscan.c b/tools/pvscan.c
index d161ba0..10e08ba 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -360,8 +360,8 @@ int pvscan(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	if (cmd->filter->wipe)
-		cmd->filter->wipe(cmd->filter);
+	if (cmd->full_filter->wipe)
+		cmd->full_filter->wipe(cmd->full_filter);
 	lvmcache_destroy(cmd, 1, 0);
 
 	/* populate lvmcache */
diff --git a/tools/toollib.c b/tools/toollib.c
index ec9a95c..c5395ba 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1846,7 +1846,7 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv, void *han
 
 	if (argc) {
 		for (; opt < argc; opt++) {
-			if (!(dev = dev_cache_get(argv[opt], cmd->filter))) {
+			if (!(dev = dev_cache_get(argv[opt], cmd->full_filter))) {
 				log_error("Failed to find device "
 					  "\"%s\"", argv[opt]);
 				ret_max = ECMD_FAILED;
@@ -1872,7 +1872,7 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv, void *han
 		return ret_max;
 	}
 
-	if (!(iter = dev_iter_create(cmd->filter, 1))) {
+	if (!(iter = dev_iter_create(cmd->full_filter, 1))) {
 		log_error("dev_iter creation failed");
 		return ECMD_FAILED;
 	}


