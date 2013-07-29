From: Petr Rockai <prockai@redhat.com>
Date: Mon, 29 Jul 2013 21:19:06 +0200
Subject: [PATCH 02/20] toollib: Drop the pv_read optimisation.
In-Reply-To: <1375125564-1188-1-git-send-email-prockai@redhat.com>
References: <1375125564-1188-1-git-send-email-prockai@redhat.com>
Message-ID: <1375125564-1188-2-git-send-email-prockai@redhat.com>
	(sfid-20130729_211925_714162_4FB48356)
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Only reading a single PV works correctly only in very limited circumstances.
Moreover, we can't rely on the MDA available on the PV either, since it may be
out of date in some circumstances (until now, we believed that PVs that have an
empty MDA are always orphans, but this is not 100% reliable either).
---
 tools/toollib.c | 93 ++++++++++++++++++++++++++++-----------------------------
 1 file changed, 46 insertions(+), 47 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index ce449e7..24d8cbf 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -644,6 +644,8 @@ int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 static int _process_all_devs(struct cmd_context *cmd, void *handle,
 			     process_single_pv_fn_t process_single_pv)
 {
+	struct pv_list *pvl;
+	struct dm_list *pvslist;
 	struct physical_volume *pv;
 	struct physical_volume pv_dummy;
 	struct dev_iter *iter;
@@ -652,7 +654,8 @@ static int _process_all_devs(struct cmd_context *cmd, void *handle,
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 
-	if (!scan_vgs_for_pvs(cmd, 1))
+	lvmcache_seed_infos_from_lvmetad(cmd);
+	if (!(pvslist = get_pvs(cmd)))
 		return_ECMD_FAILED;
 
 	if (!(iter = dev_iter_create(cmd->filter, 1))) {
@@ -660,20 +663,28 @@ static int _process_all_devs(struct cmd_context *cmd, void *handle,
 		return ECMD_FAILED;
 	}
 
-	while ((dev = dev_iter_get(iter))) {
+	while ((dev = dev_iter_get(iter)))
+	{
 		if (sigint_caught()) {
 			ret_max = ECMD_FAILED;
 			stack;
 			break;
 		}
 
-		if (!(pv = pv_read(cmd, dev_name(dev), 0, 0))) {
-			memset(&pv_dummy, 0, sizeof(pv_dummy));
-			dm_list_init(&pv_dummy.tags);
-			dm_list_init(&pv_dummy.segments);
-			pv_dummy.dev = dev;
-			pv = &pv_dummy;
-		}
+		memset(&pv_dummy, 0, sizeof(pv_dummy));
+		dm_list_init(&pv_dummy.tags);
+		dm_list_init(&pv_dummy.segments);
+		pv_dummy.dev = dev;
+		pv = &pv_dummy;
+
+		/* TODO use a device-indexed hash here */
+		dm_list_iterate_items(pvl, pvslist)
+			if (pvl->pv->dev == dev)
+				pv = pvl->pv;
+
+		ret = process_single_pv(cmd, NULL, pv, handle);
+
+		free_pv_fid(pv);
 
 		ret = process_single_pv(cmd, NULL, pv, handle);
 		if (ret > ret_max)
@@ -704,11 +715,11 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 
 	struct pv_list *pvl;
 	struct physical_volume *pv;
-	struct dm_list *pvslist, *vgnames;
+	struct dm_list *pvslist = NULL, *vgnames;
 	struct dm_list tags;
 	struct str_list *sll;
 	char *at_sign, *tagname;
-	int scanned = 0;
+	struct device *dev;
 
 	dm_list_init(&tags);
 
@@ -754,52 +765,36 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 				}
 				pv = pvl->pv;
 			} else {
-				if (!(pv = pv_read(cmd, argv[opt],
-						   1, scan_label_only))) {
-					log_error("Failed to read physical "
-						  "volume \"%s\"", argv[opt]);
+				if (!pvslist) {
+					lvmcache_seed_infos_from_lvmetad(cmd);
+					if (!(pvslist = get_pvs(cmd)))
+						goto bad;
+				}
+
+				if (!(dev = dev_cache_get(argv[opt], cmd->filter))) {
+					log_error("Failed to find device "
+						  "\"%s\"", argv[opt]);
 					ret_max = ECMD_FAILED;
 					continue;
 				}
 
-				/*
-				 * If a PV has no MDAs it may appear to be an
-				 * orphan until the metadata is read off
-				 * another PV in the same VG.  Detecting this
-				 * means checking every VG by scanning every
-				 * PV on the system.
-				 */
-				if (!scanned && is_orphan(pv) &&
-				    dm_list_empty(&pv->fid->metadata_areas_in_use)) {
-					if (!scan_label_only &&
-					    !scan_vgs_for_pvs(cmd, 1)) {
-						stack;
-						ret_max = ECMD_FAILED;
-						continue;
-					}
-					scanned = 1;
-					free_pv_fid(pv);
-					if (!(pv = pv_read(cmd, argv[opt],
-							   1,
-							   scan_label_only))) {
-						log_error("Failed to read "
-							  "physical volume "
-							  "\"%s\"", argv[opt]);
-						ret_max = ECMD_FAILED;
-						continue;
-					}
+				pv = NULL;
+				dm_list_iterate_items(pvl, pvslist)
+					if (pvl->pv->dev == dev)
+						pv = pvl->pv;
+
+				if (!pv) {
+					log_error("Failed to find physical volume "
+						  "\"%s\"", argv[opt]);
+					ret_max = ECMD_FAILED;
+					continue;
 				}
 			}
 
 			ret = process_single_pv(cmd, vg, pv, handle);
+
 			if (ret > ret_max)
 				ret_max = ret;
-			/*
-			 * Free PV only if we called pv_read before,
-			 * otherwise the PV structure is part of the VG.
-			 */
-			if (!vg)
-				free_pv_fid(pv);
 		}
 		if (!dm_list_empty(&tags) && (vgnames = get_vgnames(cmd, 1)) &&
 			   !dm_list_empty(vgnames)) {
@@ -855,6 +850,10 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 		}
 	}
 out:
+	if (pvslist)
+		dm_list_iterate_items(pvl, pvslist)
+			free_pv_fid(pvl->pv);
+
 	if (lock_global)
 		unlock_vg(cmd, VG_GLOBAL);
 	return ret_max;
-- 
1.8.2


