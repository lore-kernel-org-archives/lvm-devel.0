From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 14 Jan 2015 17:57:46 +0000 (UTC)
Subject: master - toollib: handle duplicate pvs in process_in_pv
Message-ID: <20150114175746.C548E6110C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c1f246fedfc349c25749da501e68a7f70bd122b0
Commit:        c1f246fedfc349c25749da501e68a7f70bd122b0
Parent:        eac4e1e939c6fe7eba0d2c3865e25b8ed43fe6d9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jan 9 14:55:16 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jan 14 11:57:29 2015 -0600

toollib: handle duplicate pvs in process_in_pv

Processes a PV once for each time a device with its PV ID
exists on the command line.

This fixes a regression in the case where:

. devices /dev/sdA and /dev/sdB where clones (same PV ID)

. the cached VG references /dev/sdA

. before the regression, the command: pvs /dev/sdB
  would display the cached device clone /dev/sdA

. after the regression, pvs /dev/sdB would display nothing,
  causing vgimportclone /dev/sdB to fail.

. with this fix, pvs /dev/sdB displays /dev/sdA

Also, pvs /dev/sdA /dev/sdB will report two lines, one for each
device on the command line, but /dev/sdA is displayed for each.

This only works without lvmetad.
---
 lib/cache/lvmcache.c |    2 +-
 tools/toollib.c      |  139 ++++++++++++++++++++++++++++++++++++--------------
 2 files changed, 101 insertions(+), 40 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 416907e..932b1ca 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1539,7 +1539,7 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 			//else if (dm_is_dm_major(MAJOR(existing->dev->dev)) &&
 				 //dm_is_dm_major(MAJOR(dev->dev)))
 				 //
-			else if (!strcmp(pvid_s, existing->dev->pvid)) 
+			else if (!strcmp(pvid_s, existing->dev->pvid))
 				log_error("Found duplicate PV %s: using %s not "
 					  "%s", pvid, dev_name(dev),
 					  dev_name(existing->dev));
diff --git a/tools/toollib.c b/tools/toollib.c
index 1b3883e..c534e89 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -18,6 +18,12 @@
 #include <signal.h>
 #include <sys/wait.h>
 
+struct device_id_list {
+	struct dm_list list;
+	struct device *dev;
+	char pvid[ID_LEN + 1];
+};
+
 const char *command_name(struct cmd_context *cmd)
 {
 	return cmd->command->name;
@@ -2079,20 +2085,21 @@ static int _get_arg_devices(struct cmd_context *cmd,
 			    struct dm_list *arg_devices)
 {
 	struct dm_str_list *sl;
-	struct device_list *devl;
+	struct device_id_list *dil;
 	int ret_max = ECMD_PROCESSED;
 
 	dm_list_iterate_items(sl, arg_pvnames) {
-		if (!(devl = dm_pool_alloc(cmd->mem, sizeof(*devl)))) {
-			log_error("device_list alloc failed.");
+		if (!(dil = dm_pool_alloc(cmd->mem, sizeof(*dil)))) {
+			log_error("device_id_list alloc failed.");
 			return ECMD_FAILED;
 		}
 
-		if (!(devl->dev = dev_cache_get(sl->str, cmd->filter))) {
-			log_error("Failed to find physical volume \"%s\".", sl->str);
+		if (!(dil->dev = dev_cache_get(sl->str, cmd->filter))) {
+			log_error("Failed to find device for physical volume \"%s\".", sl->str);
 			ret_max = ECMD_FAILED;
 		} else {
-			dm_list_add(arg_devices, &devl->list);
+			strncpy(dil->pvid, dil->dev->pvid, ID_LEN);
+			dm_list_add(arg_devices, &dil->list);
 		}
 	}
 
@@ -2103,7 +2110,7 @@ static int _get_all_devices(struct cmd_context *cmd, struct dm_list *all_devices
 {
 	struct dev_iter *iter;
 	struct device *dev;
-	struct device_list *devl;
+	struct device_id_list *dil;
 	int r = ECMD_FAILED;
 
 	lvmcache_seed_infos_from_lvmetad(cmd);
@@ -2114,13 +2121,13 @@ static int _get_all_devices(struct cmd_context *cmd, struct dm_list *all_devices
 	}
 
 	while ((dev = dev_iter_get(iter))) {
-		if (!(devl = dm_pool_alloc(cmd->mem, sizeof(*devl)))) {
-			log_error("device_list alloc failed.");
+		if (!(dil = dm_pool_alloc(cmd->mem, sizeof(*dil)))) {
+			log_error("device_id_list alloc failed.");
 			goto out;
 		}
 
-		devl->dev = dev;
-		dm_list_add(all_devices, &devl->list);
+		dil->dev = dev;
+		dm_list_add(all_devices, &dil->list);
 	}
 
 	r = ECMD_PROCESSED;
@@ -2129,13 +2136,13 @@ out:
 	return r;
 }
 
-static int _device_list_remove(struct dm_list *all_devices, struct device *dev)
+static int _device_list_remove(struct dm_list *devices, struct device *dev)
 {
-	struct device_list *devl;
+	struct device_id_list *dil;
 
-	dm_list_iterate_items(devl, all_devices) {
-		if (devl->dev == dev) {
-			dm_list_del(&devl->list);
+	dm_list_iterate_items(dil, devices) {
+		if (dil->dev == dev) {
+			dm_list_del(&dil->list);
 			return 1;
 		}
 	}
@@ -2143,16 +2150,28 @@ static int _device_list_remove(struct dm_list *all_devices, struct device *dev)
 	return 0;
 }
 
-static int _device_list_match(struct dm_list *devices, struct device *dev)
+static struct device_id_list *_device_list_find_dev(struct dm_list *devices, struct device *dev)
 {
-	struct device_list *devl;
+	struct device_id_list *dil;
 
-	dm_list_iterate_items(devl, devices) {
-		if (devl->dev == dev)
-			return 1;
+	dm_list_iterate_items(dil, devices) {
+		if (dil->dev == dev)
+			return dil;
 	}
 
-	return 0;
+	return NULL;
+}
+
+static struct device_id_list *_device_list_find_pvid(struct dm_list *devices, struct physical_volume *pv)
+{
+	struct device_id_list *dil;
+
+	dm_list_iterate_items(dil, devices) {
+		if (id_equal((struct id *) dil->pvid, &pv->id))
+			return dil;
+	}
+
+	return NULL;
 }
 
 static int _process_device_list(struct cmd_context *cmd, struct dm_list *all_devices,
@@ -2160,7 +2179,7 @@ static int _process_device_list(struct cmd_context *cmd, struct dm_list *all_dev
 {
 	struct physical_volume pv_dummy;
 	struct physical_volume *pv;
-	struct device_list *devl;
+	struct device_id_list *dil;
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
 
@@ -2168,17 +2187,17 @@ static int _process_device_list(struct cmd_context *cmd, struct dm_list *all_dev
 	 * Pretend that each device is a PV with dummy values.
 	 * FIXME Formalise this extension or find an alternative.
 	 */
-	dm_list_iterate_items(devl, all_devices) {
+	dm_list_iterate_items(dil, all_devices) {
 		if (sigint_caught())
 			return_ECMD_FAILED;
 
 		memset(&pv_dummy, 0, sizeof(pv_dummy));
 		dm_list_init(&pv_dummy.tags);
 		dm_list_init(&pv_dummy.segments);
-		pv_dummy.dev = devl->dev;
+		pv_dummy.dev = dil->dev;
 		pv = &pv_dummy;
 
-		log_very_verbose("Processing device %s.", dev_name(devl->dev));
+		log_very_verbose("Processing device %s.", dev_name(dil->dev));
 
 		ret = process_single_pv(cmd, NULL, pv, handle);
 
@@ -2201,6 +2220,7 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 {
 	struct physical_volume *pv;
 	struct pv_list *pvl;
+	struct device_id_list *dil;
 	const char *pv_name;
 	int process_pv;
 	int dev_found;
@@ -2219,9 +2239,17 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 		/* Remove each arg_devices entry as it is processed. */
 
 		if (!process_pv && !dm_list_empty(arg_devices) &&
-		    _device_list_match(arg_devices, pv->dev)) {
+		    (dil = _device_list_find_dev(arg_devices, pv->dev))) {
 			process_pv = 1;
-			_device_list_remove(arg_devices, pv->dev);
+			_device_list_remove(arg_devices, dil->dev);
+		}
+
+		/* Select the PV if the device arg has the same pvid. */
+
+		if (!process_pv && !dm_list_empty(arg_devices) &&
+		    (dil = _device_list_find_pvid(arg_devices, pv))) {
+			process_pv = 1;
+			_device_list_remove(arg_devices, dil->dev);
 		}
 
 		if (!process_pv && !dm_list_empty(arg_tags) &&
@@ -2257,6 +2285,35 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 				if (ret > ret_max)
 					ret_max = ret;
 			}
+
+			/*
+			 * This is a very rare and obscure case where multiple
+			 * duplicate devices are specified on the command line
+			 * referring to this PV.  In this case we want to
+			 * process this PV once for each specified device.
+			 */
+
+			if (!skip && !dm_list_empty(arg_devices)) {
+				while ((dil = _device_list_find_pvid(arg_devices, pv))) {
+					_device_list_remove(arg_devices, dil->dev);
+
+					/*
+					 * This will simply display the same PV
+					 * multiple times.  Further changes would
+					 * be needed to make this display the details
+					 * of dil->dev instead of pv->dev.
+					 */
+
+					log_very_verbose("Processing PV %s device %s in VG %s.",
+							 pv_name, dev_name(dil->dev), vg->name);
+
+					ret = process_single_pv(cmd, vg, pv, handle);
+					if (ret != ECMD_PROCESSED)
+						stack;
+					if (ret > ret_max)
+						ret_max = ret;
+				}
+			}
 		}
 
 		/*
@@ -2278,7 +2335,7 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
  * Each PV is removed from arg_devices and all_devices when it is
  * processed.  Any names remaining in arg_devices were not found, and
  * should produce an error.  Any devices remaining in all_devices were
- * not found and should be processed by process_all_devices().
+ * not found and should be processed by process_device_list().
  */
 static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
 			       struct dm_list *all_vgnameids,
@@ -2347,10 +2404,10 @@ int process_each_pv(struct cmd_context *cmd,
 {
 	struct dm_list arg_tags;	/* str_list */
 	struct dm_list arg_pvnames;	/* str_list */
-	struct dm_list arg_devices;	/* device_list */
+	struct dm_list arg_devices;	/* device_id_list */
 	struct dm_list all_vgnameids;	/* vgnameid_list */
-	struct dm_list all_devices;	/* device_list */
-	struct device_list *devl;
+	struct dm_list all_devices;	/* device_id_list */
+	struct device_id_list *dil;
 	int process_all_pvs;
 	int process_all_devices;
 	int ret_max = ECMD_PROCESSED;
@@ -2363,6 +2420,15 @@ int process_each_pv(struct cmd_context *cmd,
 	dm_list_init(&all_devices);
 
 	/*
+	 * Read all the vgs first because this has the effect of initializing
+	 * other device/lvmcache info that is needed when creating device lists.
+	 */
+	if ((ret = _get_vgnameids_on_system(cmd, &all_vgnameids, only_this_vgname, 1) != ECMD_PROCESSED)) {
+		stack;
+		return ret;
+	}
+
+	/*
 	 * Create two lists from argv:
 	 * arg_pvnames: pvs explicitly named in argv
 	 * arg_tags: tags explicitly named in argv
@@ -2396,11 +2462,6 @@ int process_each_pv(struct cmd_context *cmd,
 		return ret;
 	}
 
-	if ((ret = _get_vgnameids_on_system(cmd, &all_vgnameids, only_this_vgname, 1) != ECMD_PROCESSED)) {
-		stack;
-		return ret;
-	}
-
 	ret = _process_pvs_in_vgs(cmd, flags, &all_vgnameids, &all_devices,
 				  &arg_devices, &arg_tags, process_all_pvs,
 				  handle, process_single_pv);
@@ -2409,8 +2470,8 @@ int process_each_pv(struct cmd_context *cmd,
 	if (ret > ret_max)
 		ret_max = ret;
 
-	dm_list_iterate_items(devl, &arg_devices) {
-		log_error("Failed to find physical volume \"%s\".", dev_name(devl->dev));
+	dm_list_iterate_items(dil, &arg_devices) {
+		log_error("Failed to find physical volume \"%s\".", dev_name(dil->dev));
 		ret_max = ECMD_FAILED;
 	}
 


