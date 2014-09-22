From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:40:11 +0000 (UTC)
Subject: dev-dct-process-latest - toollib: process_each_pv workaround for no mda pvs
Message-ID: <20140922154011.D01B160D27@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=57d65e0681aeba46f221cea7e5686d531f4f53ae
Commit:        57d65e0681aeba46f221cea7e5686d531f4f53ae
Parent:        b141a65e668de93784a2e8afc0e16ed35faf6960
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 18 15:25:46 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 22 10:32:24 2014 -0500

toollib: process_each_pv workaround for no mda pvs

Add a workaround for a bug somewhere that can cause
a pv with no mda to appear in both its real vg and
in the orphan vg when not using lvmetad.
---
 tools/toollib.c |   39 ++++++++++++++++++++++++++-------------
 1 files changed, 26 insertions(+), 13 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index bc5e5e1..903ea19 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1865,17 +1865,17 @@ static int get_all_devs(struct cmd_context *cmd, struct dm_list *all_devs)
 	return ECMD_PROCESSED;
 }
 
-static void device_list_remove(struct dm_list *all_devs, struct device *dev)
+static int device_list_remove(struct dm_list *all_devs, struct device *dev)
 {
 	struct device_list *devl;
 
 	dm_list_iterate_items(devl, all_devs) {
 		if (devl->dev == dev) {
 			dm_list_del(&devl->list);
-			return;
+			return 1;
 		}
 	}
-	log_error(INTERNAL_ERROR "device_list_remove %s not found", dev_name(dev));
+	return 0;
 }
 
 static int process_dev_list(struct cmd_context *cmd, struct dm_list *all_devs,
@@ -1921,6 +1921,7 @@ static int process_pvs_in_vg(struct cmd_context *cmd,
 	struct pv_list *pvl;
 	const char *pv_name;
 	int process_pv;
+	int dev_found;
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
 
@@ -1955,8 +1956,23 @@ static int process_pvs_in_vg(struct cmd_context *cmd,
 			else
 				log_very_verbose("Processing PV %s in VG %s", pv_name, vg->name);
 
-			if (all_devs)
-				device_list_remove(all_devs, pv->dev);
+			dev_found = device_list_remove(all_devs, pv->dev);
+
+			/*
+			 * There's a bug somewhere that can cause pvs with no mdas
+			 * to appear in both their real vg and the orphan vg when
+			 * not using lvmetad.
+			 *
+			 * These pvs are not missing and they will not be found in
+			 * all_devs the second time they are encountered here.
+			 *
+			 * Missing pvs will also not be found in all_devs, but we
+			 * do want to process missing pvs.
+			 */
+			if (!dev_found && !is_missing_pv(pv)) {
+				log_verbose("Skipping PV %s in VG %s not in device list", pv_name, vg->name);
+				continue;
+			}
 
 			if (!skip)
 				ret = process_single_pv(cmd, vg, pv, handle);
@@ -2091,18 +2107,15 @@ int process_each_pv(struct cmd_context *cmd,
 	 * from all vgs are processed first, removing each from all_devs.  Then
 	 * any devs remaining in all_devs are processed.
 	 */
-	if (process_all_devs) {
-		ret = get_all_devs(cmd, &all_devs);
-		if (ret != ECMD_PROCESSED)
-			return ret;
-	}
+	ret = get_all_devs(cmd, &all_devs);
+	if (ret != ECMD_PROCESSED)
+		return ret;
 
 	ret = get_all_vgnames(cmd, &all_vgnames, vg_name, 1);
 	if (ret != ECMD_PROCESSED)
 		return ret;
 
-	ret = process_pvs_in_vgs(cmd, flags, &all_vgnames,
-				 process_all_devs ? &all_devs : NULL,
+	ret = process_pvs_in_vgs(cmd, flags, &all_vgnames, &all_devs,
 				 &arg_pvnames, &arg_tags, process_all_pvs,
 				 handle, process_single_pv);
 	if (ret > ret_max)
@@ -2111,7 +2124,7 @@ int process_each_pv(struct cmd_context *cmd,
 	if (sigint_caught())
 		goto out;
 
-	if (dm_list_empty(&all_devs))
+	if (!process_all_devs)
 		goto out;
 
 	ret = process_dev_list(cmd, &all_devs, handle, process_single_pv);


