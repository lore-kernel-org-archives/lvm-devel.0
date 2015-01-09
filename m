From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  9 Jan 2015 16:04:01 +0000 (UTC)
Subject: master - toollib: process_each_pv should match by device
Message-ID: <20150109160401.66BC36104F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1e4a4d48aeb1e56a8df19ba73425eb5f7632c9d2
Commit:        1e4a4d48aeb1e56a8df19ba73425eb5f7632c9d2
Parent:        6a77b6f43c7c9a90210bb90be55c4060e612106d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jan 7 14:04:12 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jan 9 10:03:31 2015 -0600

toollib: process_each_pv should match by device

When processing PVs specified on the command line, the arg
name was being matched against pv_dev_name, which will not
always work:

- The PV specified on the command line could be an alias,
  e.g. /dev/disk/by-id/...

- The PV specified on the command line could be any random
  path to the device, e.g. /dev/../dev/sdb

To fix this, first resolve the named PV args to struct device's,
then iterate through the devices for processing.
---
 tools/toollib.c |   96 +++++++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 72 insertions(+), 24 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 41e6f88..1b3883e 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2074,6 +2074,31 @@ static int _get_arg_pvnames(struct cmd_context *cmd,
 	return ret_max;
 }
 
+static int _get_arg_devices(struct cmd_context *cmd,
+			    struct dm_list *arg_pvnames,
+			    struct dm_list *arg_devices)
+{
+	struct dm_str_list *sl;
+	struct device_list *devl;
+	int ret_max = ECMD_PROCESSED;
+
+	dm_list_iterate_items(sl, arg_pvnames) {
+		if (!(devl = dm_pool_alloc(cmd->mem, sizeof(*devl)))) {
+			log_error("device_list alloc failed.");
+			return ECMD_FAILED;
+		}
+
+		if (!(devl->dev = dev_cache_get(sl->str, cmd->filter))) {
+			log_error("Failed to find physical volume \"%s\".", sl->str);
+			ret_max = ECMD_FAILED;
+		} else {
+			dm_list_add(arg_devices, &devl->list);
+		}
+	}
+
+	return ret_max;
+}
+
 static int _get_all_devices(struct cmd_context *cmd, struct dm_list *all_devices)
 {
 	struct dev_iter *iter;
@@ -2118,6 +2143,18 @@ static int _device_list_remove(struct dm_list *all_devices, struct device *dev)
 	return 0;
 }
 
+static int _device_list_match(struct dm_list *devices, struct device *dev)
+{
+	struct device_list *devl;
+
+	dm_list_iterate_items(devl, devices) {
+		if (devl->dev == dev)
+			return 1;
+	}
+
+	return 0;
+}
+
 static int _process_device_list(struct cmd_context *cmd, struct dm_list *all_devices,
 				void *handle, process_single_pv_fn_t process_single_pv)
 {
@@ -2155,7 +2192,7 @@ static int _process_device_list(struct cmd_context *cmd, struct dm_list *all_dev
 static int _process_pvs_in_vg(struct cmd_context *cmd,
 			      struct volume_group *vg,
 			      struct dm_list *all_devices,
-			      struct dm_list *arg_pvnames,
+			      struct dm_list *arg_devices,
 			      struct dm_list *arg_tags,
 			      int process_all,
 			      int skip,
@@ -2179,11 +2216,12 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 
 		process_pv = process_all;
 
-		/* Remove each pvname as it is processed. */
-		if (!process_pv && !dm_list_empty(arg_pvnames) &&
-		    str_list_match_item(arg_pvnames, pv_name)) {
+		/* Remove each arg_devices entry as it is processed. */
+
+		if (!process_pv && !dm_list_empty(arg_devices) &&
+		    _device_list_match(arg_devices, pv->dev)) {
 			process_pv = 1;
-			str_list_del(arg_pvnames, pv_name);
+			_device_list_remove(arg_devices, pv->dev);
 		}
 
 		if (!process_pv && !dm_list_empty(arg_tags) &&
@@ -2222,10 +2260,9 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 		}
 
 		/*
-		 * When processing only specific PV names, we can quit
-		 * once they've all been found.
+		 * When processing only specific PVs, we can quit once they've all been found.
 	 	 */
-		if (!process_all && dm_list_empty(arg_tags) && dm_list_empty(arg_pvnames))
+		if (!process_all && dm_list_empty(arg_tags) && dm_list_empty(arg_devices))
 			break;
 	}
 
@@ -2234,19 +2271,19 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 
 /*
  * Iterate through all PVs in each listed VG.  Process a PV if
- * the name or tag matches arg_pvnames or arg_tags.  If both
- * arg_pvnames and arg_tags are empty, then process all PVs.
+ * its dev or tag matches arg_devices or arg_tags.  If both
+ * arg_devices and arg_tags are empty, then process all PVs.
  * No PV should be processed more than once.
  *
- * Each PV is removed from arg_pvnames and all_devices when it is
- * processed.  Any names remaining in arg_pvnames were not found, and
+ * Each PV is removed from arg_devices and all_devices when it is
+ * processed.  Any names remaining in arg_devices were not found, and
  * should produce an error.  Any devices remaining in all_devices were
  * not found and should be processed by process_all_devices().
  */
 static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
 			       struct dm_list *all_vgnameids,
 			       struct dm_list *all_devices,
-			       struct dm_list *arg_pvnames,
+			       struct dm_list *arg_devices,
 			       struct dm_list *arg_tags,
 			       int process_all,
 			       void *handle,
@@ -2254,7 +2291,6 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
 {
 	struct volume_group *vg;
 	struct vgnameid_list *vgnl;
-	struct dm_str_list *sl;
 	const char *vg_name;
 	const char *vg_uuid;
 	int ret_max = ECMD_PROCESSED;
@@ -2282,7 +2318,7 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
 		 * vg->pvs entries from devices list.
 		 */
 		
-		ret = _process_pvs_in_vg(cmd, vg, all_devices, arg_pvnames, arg_tags,
+		ret = _process_pvs_in_vg(cmd, vg, all_devices, arg_devices, arg_tags,
 					 process_all, skip, handle, process_single_pv);
 		if (ret != ECMD_PROCESSED)
 			stack;
@@ -2295,16 +2331,10 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
 			unlock_and_release_vg(cmd, vg, vg->name);
 
 		/* Quit early when possible. */
-		if (!process_all && dm_list_empty(arg_tags) && dm_list_empty(arg_pvnames))
+		if (!process_all && dm_list_empty(arg_tags) && dm_list_empty(arg_devices))
 			return ret_max;
 	}
 
-	/* Return an error if a pvname arg was not found. */
-	dm_list_iterate_items(sl, arg_pvnames) {
-		log_error("Failed to find physical volume \"%s\".", sl->str);
-		ret_max = ECMD_FAILED;
-	}
-
 	return ret_max;
 }
 
@@ -2317,8 +2347,10 @@ int process_each_pv(struct cmd_context *cmd,
 {
 	struct dm_list arg_tags;	/* str_list */
 	struct dm_list arg_pvnames;	/* str_list */
+	struct dm_list arg_devices;	/* device_list */
 	struct dm_list all_vgnameids;	/* vgnameid_list */
 	struct dm_list all_devices;	/* device_list */
+	struct device_list *devl;
 	int process_all_pvs;
 	int process_all_devices;
 	int ret_max = ECMD_PROCESSED;
@@ -2326,6 +2358,7 @@ int process_each_pv(struct cmd_context *cmd,
 
 	dm_list_init(&arg_tags);
 	dm_list_init(&arg_pvnames);
+	dm_list_init(&arg_devices);
 	dm_list_init(&all_vgnameids);
 	dm_list_init(&all_devices);
 
@@ -2333,9 +2366,14 @@ int process_each_pv(struct cmd_context *cmd,
 	 * Create two lists from argv:
 	 * arg_pvnames: pvs explicitly named in argv
 	 * arg_tags: tags explicitly named in argv
+	 *
+	 * Then convert arg_pvnames, which are free-form, user-specified,
+	 * names/paths into arg_devices which can be used to match below.
 	 */
-	if ((ret = _get_arg_pvnames(cmd, argc, argv, &arg_pvnames, &arg_tags)) != ECMD_PROCESSED)
+	if ((ret = _get_arg_pvnames(cmd, argc, argv, &arg_pvnames, &arg_tags)) != ECMD_PROCESSED) {
+		stack;
 		return ret;
+	}
 
 	process_all_pvs = dm_list_empty(&arg_pvnames) && dm_list_empty(&arg_tags);
 
@@ -2343,6 +2381,11 @@ int process_each_pv(struct cmd_context *cmd,
 			   (cmd->command->flags & ENABLE_ALL_DEVS) &&
 			   arg_count(cmd, all_ARG);
 
+	if ((ret = _get_arg_devices(cmd, &arg_pvnames, &arg_devices) != ECMD_PROCESSED)) {
+		/* get_arg_devices reports the error for any PV names not found. */
+		ret_max = ECMD_FAILED;
+	}
+
 	/*
 	 * If the caller wants to process all devices (not just PVs), then all PVs
 	 * from all VGs are processed first, removing them from all_devices.  Then
@@ -2359,13 +2402,18 @@ int process_each_pv(struct cmd_context *cmd,
 	}
 
 	ret = _process_pvs_in_vgs(cmd, flags, &all_vgnameids, &all_devices,
-				  &arg_pvnames, &arg_tags, process_all_pvs,
+				  &arg_devices, &arg_tags, process_all_pvs,
 				  handle, process_single_pv);
 	if (ret != ECMD_PROCESSED)
 		stack;
 	if (ret > ret_max)
 		ret_max = ret;
 
+	dm_list_iterate_items(devl, &arg_devices) {
+		log_error("Failed to find physical volume \"%s\".", dev_name(devl->dev));
+		ret_max = ECMD_FAILED;
+	}
+
 	if (!process_all_devices)
 		goto out;
 


