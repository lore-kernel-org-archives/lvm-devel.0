From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  8 Sep 2015 13:32:29 +0000 (UTC)
Subject: master - filters: make sure regex filter is evaluated before any filter that needs disk access
Message-ID: <20150908133229.E8E5560FE1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b77497cbd86a854add3ffa4ce09a35f165c0d2ba
Commit:        b77497cbd86a854add3ffa4ce09a35f165c0d2ba
Parent:        596ec5c74b604de42f105032b7e13065ea67d281
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Sep 8 15:03:15 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Sep 8 15:28:10 2015 +0200

filters: make sure regex filter is evaluated before any filter that needs disk access

The regex filter (controlled by devices/filter lvm.conf setting) was
evaluated as the very last filter. However, this is not optimal when
it comes to restricting disk access - users define devices/filter
as well as devices/global_filter to avoid this.

The devices/global_filter is already positioned at the beginning of the
filter chain. We need to do the same for devices/filter.

Filter chains before this patch:

  A: when lvmetad is not used:
       persistent_filter -> sysfs_filter -> global_regex_filter ->
       type_filter -> usable->filter -> mpath_component_filter ->
       partition_filter -> md_component_filter -> fw_raid_filter ->
       regex_filter

  B: when lvmetad is used:

    B1: to update lvmetad:
      sysfs_filter -> global_regex_filter -> type_filter ->
      usable_filter -> mpath_component_filter -> partition_filter ->
      md_component_filter -> fw_raid_filter

    B2: to retrieve info from lvmetad:
      persistent_filter -> usable_filter -> regex_filter

>From the chain list above we can see that particularly in case when
lvmetad is not used, the regex filter is the very last one that is
processed. If lvmetad is used, it doesn't matter much as there's
the global_regex_filter which is used instead when updating lvmetad
and when retrieving info from lvmetad, putting regex_filter in front
of usable_filter wouldn't change much since usabled_filter is not
reading disks directly.

This patch puts the regex filter to the front even in case lvmetad
is not used, hence reinstating the state as it was before commit
a7be3b12dfe7388d1648595e6cc4c7a1379bb8a7 (which moved the regex_filter
position in the chain). Still, the arguments for the commit
a7be3b12dfe7388d1648595e6cc4c7a1379bb8a7 still apply and they're
still satisfied since component filters (MD, mpath...) are evaluated
first just before updating lvmetad.

So with this patch, we end up with:

  A: when lvmetad is not used:
       persistent_filter -> sysfs_filter -> global_regex_filter ->
       regex_filter -> type_filter -> usable->filter ->
       mpath_component_filter -> partition_filter ->
       md_component_filter -> fw_raid_filter

  B: when lvmetad is used:

    B1: to update lvmetad:
      sysfs_filter -> global_regex_filter -> type_filter ->
      usable_filter -> mpath_component_filter -> partition_filter ->
      md_component_filter -> fw_raid_filter

    B2: to retrieve info from lvmetad:
      persistent_filter -> regex_filter -> usable_filter

This way, specifying the regex_filter in non-lvmetad case causes
the devices to be filtered based on regex first before processing
any other filters which can access disks (like md_component_filter).

This patch also streamlines the code for better readability.
---
 lib/commands/toolcontext.c |   64 ++++++++++++++++++++++++++------------------
 1 files changed, 38 insertions(+), 26 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 11affee..c8d96ca 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1069,7 +1069,7 @@ static struct dev_filter *_init_lvmetad_filter_chain(struct cmd_context *cmd)
 			nr_filt++;
 	}
 
-	/* regex filter. Optional. */
+	/* global regex filter. Optional. */
 	if ((cn = find_config_tree_node(cmd, devices_global_filter_CFG, NULL))) {
 		if (!(filters[nr_filt] = regex_filter_create(cn->v))) {
 			log_error("Failed to create global regex device filter");
@@ -1078,6 +1078,17 @@ static struct dev_filter *_init_lvmetad_filter_chain(struct cmd_context *cmd)
 		nr_filt++;
 	}
 
+	/* regex filter. Optional. */
+	if (!lvmetad_used()) {
+		if ((cn = find_config_tree_node(cmd, devices_filter_CFG, NULL))) {
+			if (!(filters[nr_filt] = regex_filter_create(cn->v))) {
+				log_error("Failed to create regex device filter");
+				goto bad;
+			}
+			nr_filt++;
+		}
+	}
+
 	/* device type filter. Required. */
 	if (!(filters[nr_filt] = lvm_type_filter_create(cmd->dev_types))) {
 		log_error("Failed to create lvm type filter");
@@ -1145,26 +1156,24 @@ bad:
  *     md component filter -> fw raid filter
  *
  *   - cmd->filter - the filter chain used for lvmetad responses:
- *     persistent filter -> usable device filter(FILTER_MODE_POST_LVMETAD) ->
- *     regex filter
+ *     persistent filter -> regex_filter -> usable device filter(FILTER_MODE_POST_LVMETAD)
  *
  *   - cmd->full_filter - the filter chain used for all the remaining situations:
- *     lvmetad_filter -> filter
+ *     cmd->lvmetad_filter -> cmd->filter
  *
- * If lvmetad isnot used, there's just one filter chain:
+ * If lvmetad is not used, there's just one filter chain:
  *
  *   - cmd->filter == cmd->full_filter:
- *     persistent filter -> regex filter -> sysfs filter ->
- *     global regex filter -> type filter ->
- *     usable device filter(FILTER_MODE_NO_LVMETAD) ->
- *     mpath component filter -> partitioned filter ->
- *     md component filter -> fw raid filter
+ *     persistent filter -> sysfs filter -> global regex filter ->
+ *     regex_filter -> type filter -> usable device filter(FILTER_MODE_NO_LVMETAD) ->
+ *     mpath component filter -> partitioned filter -> md component filter -> fw raid filter
  *
  */
 int init_filters(struct cmd_context *cmd, unsigned load_persistent_cache)
 {
 	const char *dev_cache;
 	struct dev_filter *filter = NULL, *filter_components[2] = {0};
+	int nr_filt;
 	struct stat st;
 	const struct dm_config_node *cn;
 	struct timespec ts, cts;
@@ -1193,26 +1202,26 @@ int init_filters(struct cmd_context *cmd, unsigned load_persistent_cache)
 	 */
 	/* filter component 0 */
 	if (lvmetad_used()) {
-		if (!(filter_components[0] = usable_filter_create(cmd->dev_types, FILTER_MODE_POST_LVMETAD))) {
+		nr_filt = 0;
+		if ((cn = find_config_tree_array(cmd, devices_filter_CFG, NULL))) {
+			if (!(filter_components[nr_filt] = regex_filter_create(cn->v))) {
+				log_verbose("Failed to create regex device filter.");
+				goto bad;
+			}
+			nr_filt++;
+		}
+		if (!(filter_components[nr_filt] = usable_filter_create(cmd->dev_types, FILTER_MODE_POST_LVMETAD))) {
 			log_verbose("Failed to create usable device filter.");
 			goto bad;
 		}
+		nr_filt++;
+		if (!(filter = composite_filter_create(nr_filt, 0, filter_components)))
+			goto_bad;
 	} else {
-		filter_components[0] = cmd->lvmetad_filter;
+		filter = cmd->lvmetad_filter;
 		cmd->lvmetad_filter = NULL;
 	}
 
-	/* filter component 1 */
-	if ((cn = find_config_tree_array(cmd, devices_filter_CFG, NULL))) {
-		if (!(filter_components[1] = regex_filter_create(cn->v)))
-			goto_bad;
-		/* we have two filter components - create composite filter */
-		if (!(filter = composite_filter_create(2, 0, filter_components)))
-			goto_bad;
-	} else
-		/* we have only one filter component - no need to create composite filter */
-		filter = filter_components[0];
-
 	if (!(dev_cache = find_config_tree_str(cmd, devices_cache_CFG, NULL)))
 		goto_bad;
 
@@ -1224,9 +1233,12 @@ int init_filters(struct cmd_context *cmd, unsigned load_persistent_cache)
 	cmd->filter = filter;
 
 	if (lvmetad_used()) {
-		filter_components[0] = cmd->lvmetad_filter;
-		filter_components[1] = cmd->filter;
-		if (!(cmd->full_filter = composite_filter_create(2, 0, filter_components)))
+		nr_filt = 0;
+		filter_components[nr_filt] = cmd->lvmetad_filter;
+		nr_filt++;
+		filter_components[nr_filt] = cmd->filter;
+		nr_filt++;
+		if (!(cmd->full_filter = composite_filter_create(nr_filt, 0, filter_components)))
 			goto_bad;
 	} else
 		cmd->full_filter = filter;


