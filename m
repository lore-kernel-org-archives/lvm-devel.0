From: David Teigland <teigland@sourceware.org>
Date: Mon, 15 Apr 2019 12:30:39 -0400
Subject: master - pvscan: handle case of scanning PV without metadata last
Message-ID: <201904151630.x3FGUd93009158@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=aa75b31db54782fb24b6b7e3c681a61b3579117c
Commit:        aa75b31db54782fb24b6b7e3c681a61b3579117c
Parent:        41ba2b568b3d3ad1d1ee2a26cf9f44a2b2e77e8f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 15 11:27:49 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Apr 15 11:27:49 2019 -0500

pvscan: handle case of scanning PV without metadata last

Handle the case where pvscan --cache -aay (with no dev args)
gets to the final PV, completing the VG, but that final PV does not
have VG metadata.  In this case, we need to use VG metadata from a
previously scanned PV in the same VG, which we saved for this
possibility.  Using this saved metadata, we can find which VG
this PVID belongs to, and then check if that VG is now complete,
and if so add the VG name to the list of complete VGs to be
autoactivated.
---
 test/shell/pvscan-autoactivate.sh |   66 ++++++++++++++++++------
 tools/pvscan.c                    |   99 +++++++++++++++++++++++++++++++++++-
 2 files changed, 145 insertions(+), 20 deletions(-)

diff --git a/test/shell/pvscan-autoactivate.sh b/test/shell/pvscan-autoactivate.sh
index 52258f4..6ed35db 100644
--- a/test/shell/pvscan-autoactivate.sh
+++ b/test/shell/pvscan-autoactivate.sh
@@ -27,7 +27,7 @@ _clear_online_files() {
 
 . lib/inittest
 
-aux prepare_pvs 3
+aux prepare_pvs 8
 
 vgcreate $vg1 "$dev1" "$dev2"
 lvcreate -n $lv1 -l 4 -a n $vg1
@@ -59,6 +59,19 @@ pvscan --cache -aay "$dev1" "$dev2"
 check lv_field $vg1/$lv1 lv_active "active"
 lvchange -an $vg1
 
+# check that a cache command without aay will
+# just record online state, and that a following
+# pvscan cache aay that does not record any new
+# online files will activate the vg
+_clear_online_files
+pvscan --cache "$dev1"
+check lv_field $vg1/$lv1 lv_active ""
+pvscan --cache "$dev2"
+check lv_field $vg1/$lv1 lv_active ""
+pvscan --cache -aay
+check lv_field $vg1/$lv1 lv_active "active"
+lvchange -an $vg1
+
 # Set up tests where one dev has no metadata
 
 vgchange -an $vg1
@@ -94,22 +107,6 @@ lvchange -an $vg1
 # is online without the -aay option to
 # activate until after they are online
 
-# This part is disabled because it doesn't work if the
-# 'pvscan --cache -aay' without args ends up scanning
-# dev1 (without metadata) after dev2.
-
-#_clear_online_files
-
-#pvscan --cache "$dev1"
-#check lv_field $vg1/$lv1 lv_active ""
-#pvscan --cache "$dev2"
-#check lv_field $vg1/$lv1 lv_active ""
-#pvscan --cache -aay
-#check lv_field $vg1/$lv1 lv_active "active"
-#lvchange -an $vg1
-
-# like previous
-
 _clear_online_files
 
 pvscan --cache "$dev1"
@@ -172,4 +169,39 @@ grep $lv2 tmp
 check lv_field $vg2/$lv2 lv_active "" --foreign
 
 
+# Test the case where pvscan --cache -aay (with no devs)
+# gets the final PV to complete the VG, where that final PV
+# does not hold VG metadata.  In this case it needs to rely
+# on VG metadata that has been saved from a previously
+# scanned PV from the same VG.
+#
+# We can't control which order of devices pvscan will see,
+# so create several PVs without metadata surrounding one
+# PV with metadata, to make it likely that pvscan will
+# get a final PV without metadata.
+
+pvcreate --metadatacopies 0 "$dev4"
+pvcreate --metadatacopies 0 "$dev5"
+pvcreate --metadatacopies 1 "$dev6"
+pvcreate --metadatacopies 0 "$dev7"
+pvcreate --metadatacopies 0 "$dev8"
+vgcreate $vg3 "$dev4" "$dev5" "$dev6" "$dev7" "$dev8"
+lvcreate -n $lv1 -l 4 -a n $vg3
+
+_clear_online_files
+
+check lv_field $vg3/$lv1 lv_active ""
+pvscan --cache "$dev4"
+check lv_field $vg3/$lv1 lv_active ""
+pvscan --cache "$dev5"
+check lv_field $vg3/$lv1 lv_active ""
+pvscan --cache "$dev6"
+check lv_field $vg3/$lv1 lv_active ""
+pvscan --cache "$dev7"
+check lv_field $vg3/$lv1 lv_active ""
+pvscan --cache "$dev8"
+check lv_field $vg3/$lv1 lv_active ""
+pvscan --cache -aay
+check lv_field $vg3/$lv1 lv_active "active"
+lvchange -an $vg3
 
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 75c1a2b..a3786c4 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -547,10 +547,12 @@ static int _online_pvscan_single(struct metadata_area *mda, void *baton)
 static int _online_pvscan_one(struct cmd_context *cmd, struct device *dev,
 			      struct dm_list *dev_args,
 			      struct dm_list *found_vgnames,
+			      struct dm_list *all_vgs,
 			      int disable_remove,
 			      const char **pvid_without_metadata)
 {
 	struct lvmcache_info *info;
+	struct vg_list *vgl;
 	struct _pvscan_baton baton;
 	const struct format_type *fmt;
 	/* Create a dummy instance. */
@@ -656,12 +658,89 @@ static int _online_pvscan_one(struct cmd_context *cmd, struct device *dev,
 
 	ret = _online_pv_found(cmd, dev, dev_args, baton.vg, found_vgnames);
 
-	release_vg(baton.vg);
+	/*
+	 * Save vg's in case they need to be used at the end for checking PVs
+	 * without metadata (in _check_vg_with_pvid_complete).
+	 */
+	if (all_vgs && baton.vg) {
+		int found = 0;
+		dm_list_iterate_items(vgl, all_vgs) {
+			if (!strcmp(baton.vg->name, vgl->vg->name)) {
+				found = 1;
+				break;
+			}
+		}
+		if (!found) {
+	       		if ((vgl = malloc(sizeof(struct vg_list)))) {
+				vgl->vg = baton.vg;
+				baton.vg = NULL;
+				dm_list_add(all_vgs, &vgl->list);
+			}
+		}
+	}
+
+	if (baton.vg)
+		release_vg(baton.vg);
 out:
 	return ret;
 }
 
 /*
+ * This is to handle the case where pvscan --cache -aay (with no dev args)
+ * gets to the final PV, completing the VG, but that final PV does not
+ * have VG metadata.  In this case, we need to use VG metadata from a
+ * previously scanned PV in the same VG, which we saved in the all_vgs
+ * list.  Using this saved metadata, we can find which VG this PVID
+ * belongs to, and then check if that VG is now complete, and if so
+ * add the VG name to the list of complete VGs to be autoactivated.
+ *
+ * The "pvid" arg here is the PVID of the PV that has just been scanned
+ * and didn't have metadata.  We look through previously scanned VG
+ * metadata to find the VG this PVID belongs to, and then check that VG
+ * metadata to see if all the PVs are now online.
+ */
+static void _check_vg_with_pvid_complete(struct cmd_context *cmd,
+				         struct dm_list *found_vgnames,
+					 struct dm_list *all_vgs,
+					 const char *pvid)
+{
+	struct vg_list *vgl;
+	struct pv_list *pvl;
+	struct volume_group *vg;
+	int pvids_not_online = 0;
+	int found;
+
+	dm_list_iterate_items(vgl, all_vgs) {
+		vg = vgl->vg;
+		found = 0;
+
+		dm_list_iterate_items(pvl, &vg->pvs) {
+			if (strcmp((const char *)&pvl->pv->id.uuid, pvid))
+				continue;
+			found = 1;
+			break;
+		}
+		if (!found)
+			continue;
+
+		dm_list_iterate_items(pvl, &vg->pvs) {
+			if (!_online_pvid_file_exists((const char *)&pvl->pv->id.uuid)) {
+				pvids_not_online++;
+				break;
+			}
+		}
+
+		if (!pvids_not_online) {
+			log_debug("pvid %s makes complete VG %s", pvid, vg->name);
+			if (!str_list_add(cmd->mem, found_vgnames, dm_pool_strdup(cmd->mem, vg->name)))
+				stack;
+		} else
+			log_debug("pvid %s incomplete VG %s", pvid, vg->name);
+		break;
+	}
+}
+
+/*
  * dev_args is the list of devices that were specified on the
  * pvscan command line.
  *
@@ -676,8 +755,13 @@ static void _online_pvscan_all_devs(struct cmd_context *cmd,
 				    struct dm_list *found_vgnames,
 				    struct dm_list *dev_args)
 {
+	struct dm_list all_vgs;
 	struct dev_iter *iter;
+	struct vg_list *vgl;
 	struct device *dev;
+	const char *pvid_without_metadata;
+
+	dm_list_init(&all_vgs);
 
 	label_scan(cmd);
 
@@ -692,12 +776,21 @@ static void _online_pvscan_all_devs(struct cmd_context *cmd,
 			break;
 		}
 
-		if (!_online_pvscan_one(cmd, dev, dev_args, found_vgnames, 1, NULL)) {
+		pvid_without_metadata = NULL;
+
+		if (!_online_pvscan_one(cmd, dev, dev_args, found_vgnames, &all_vgs, 1, &pvid_without_metadata)) {
 			stack;
 			break;
 		}
+
+		/* This PV without metadata may complete a VG. */
+		if (pvid_without_metadata)
+			_check_vg_with_pvid_complete(cmd, found_vgnames, &all_vgs, pvid_without_metadata);
 	}
 
+	dm_list_iterate_items(vgl, &all_vgs)
+		release_vg(vgl->vg);
+
 	dev_iter_destroy(iter);
 }
 
@@ -1034,7 +1127,7 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 
 			add_single_count++;
 
-			if (!_online_pvscan_one(cmd, dev, NULL, complete_vgnames, 0, &pvid_without_metadata))
+			if (!_online_pvscan_one(cmd, dev, NULL, complete_vgnames, NULL, 0, &pvid_without_metadata))
 				add_errors++;
 		}
 	}


