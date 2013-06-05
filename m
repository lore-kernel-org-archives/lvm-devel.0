From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:06:05 +0000 (UTC)
Subject: dev-mornfall-lvmcache - toollib: Drop the bogus pv_read optimisation.
Message-ID: <20130605120605.BCFEF61057@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d838501c446bccd1fbe6b4f4ad9ee2c78b5f8668
Commit:        d838501c446bccd1fbe6b4f4ad9ee2c78b5f8668
Parent:        db59f5661cd425b1a0fc1c075ec1af19d25eb69f
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Feb 19 00:12:30 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Jun 5 12:37:36 2013 +0200

toollib: Drop the bogus pv_read optimisation.

The toollib code for processing PVs given on commandline tried to be smart and
use pv_read, avoiding real metadata scanning. The premise of the optimisation
was that if there is an active MDA on the PV, it can be reliably used to
establish VG membership. This assumption is however wrong, since it's entirely
possible that this particular MDA is simply out of date, and the PV is not
actually in any VG. While this is a subtle and rare bug, it's still a bug. One
way to trigger it would be to hotplug an old disk which at some point was a PV
in an existing VG, having a seemingly valid MDA but with an old sequence
number. All commands that use normal scanning realize that this PV does not
belong into the VG anymore, but anything based on pv_read alone will believe it
does.
---
 tools/toollib.c |   91 +++++++++++++++++++++++++-----------------------------
 1 files changed, 42 insertions(+), 49 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 6e004f3..6291cbf 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -646,6 +646,8 @@ int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 static int _process_all_devs(struct cmd_context *cmd, void *handle,
 			     process_single_pv_fn_t process_single_pv)
 {
+	struct pv_list *pvl;
+	struct dm_list *pvslist;
 	struct physical_volume *pv;
 	struct physical_volume pv_dummy;
 	struct dev_iter *iter;
@@ -654,7 +656,8 @@ static int _process_all_devs(struct cmd_context *cmd, void *handle,
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
 
-	if (!scan_vgs_for_pvs(cmd, 1)) {
+	lvmcache_seed_infos_from_lvmetad(cmd);
+	if (!(pvslist = get_pvs(cmd))) {
 		stack;
 		return ECMD_FAILED;
 	}
@@ -664,14 +667,19 @@ static int _process_all_devs(struct cmd_context *cmd, void *handle,
 		return ECMD_FAILED;
 	}
 
-	while ((dev = dev_iter_get(iter))) {
-		if (!(pv = pv_read(cmd, dev_name(dev), 0, 0))) {
-			memset(&pv_dummy, 0, sizeof(pv_dummy));
-			dm_list_init(&pv_dummy.tags);
-			dm_list_init(&pv_dummy.segments);
-			pv_dummy.dev = dev;
-			pv = &pv_dummy;
-		}
+	while ((dev = dev_iter_get(iter)))
+	{
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
 		ret = process_single_pv(cmd, NULL, pv, handle);
 
 		free_pv_fid(pv);
@@ -704,11 +712,11 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 
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
 
@@ -750,52 +758,34 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
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
-				    !dm_list_size(&pv->fid->metadata_areas_in_use)) {
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
 
-			/*
-			 * Free PV only if we called pv_read before,
-			 * otherwise the PV structure is part of the VG.
-			 */
-			if (!vg)
-				free_pv_fid(pv);
-
 			if (ret > ret_max)
 				ret_max = ret;
 			if (sigint_caught())
@@ -850,7 +840,6 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 			dm_list_iterate_items(pvl, pvslist) {
 				ret = process_single_pv(cmd, NULL, pvl->pv,
 						     handle);
-				free_pv_fid(pvl->pv);
 				if (ret > ret_max)
 					ret_max = ret;
 				if (sigint_caught())
@@ -859,6 +848,10 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
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


