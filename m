From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 12 Feb 2010 19:51:50 -0500
Subject: [PATCH 3/3] Update pvchange to always obtain a vg handle for each pv to process.
In-Reply-To: <1266022310-19859-3-git-send-email-dwysocha@redhat.com>
References: <1266022310-19859-1-git-send-email-dwysocha@redhat.com>
	<1266022310-19859-2-git-send-email-dwysocha@redhat.com>
	<1266022310-19859-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1266022310-19859-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Earlier patches added some infrastructure to lookup a vgname from
a pvname.  We now can cleanup some of the pvchange and other code
by requiring callers that want to modify some pv property:
1) lookup the vgname by the pvname
2) use the vgname to obtain a vg handle
3) get the pv handle from the vg handle

This should work going forward and be a much cleaner interface,
as we move away from pvs as standalone objects.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/pvchange.c |  116 +++++++++++++++++++++--------------------------------
 1 files changed, 46 insertions(+), 70 deletions(-)

diff --git a/tools/pvchange.c b/tools/pvchange.c
index cba9dd2..0cf1c98 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -17,13 +17,10 @@
 
 /* FIXME Locking.  PVs in VG. */
 
-static int _pvchange_single(struct cmd_context *cmd, struct physical_volume *pv,
+static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
+			    struct physical_volume *pv,
 			    void *handle __attribute((unused)))
 {
-	struct volume_group *vg = NULL;
-	const char *vg_name = NULL;
-	struct pv_list *pvl;
-	uint64_t sector;
 	uint32_t orig_pe_alloc_count;
 	/* FIXME Next three only required for format1. */
 	uint32_t orig_pe_count, orig_pe_size;
@@ -53,21 +50,6 @@ static int _pvchange_single(struct cmd_context *cmd, struct physical_volume *pv,
 
 	/* If in a VG, must change using volume group. */
 	if (!is_orphan(pv)) {
-		vg_name = pv_vg_name(pv);
-
-		log_verbose("Finding volume group %s of physical volume %s",
-			    vg_name, pv_name);
-		vg = vg_read_for_update(cmd, vg_name, NULL, 0);
-		if (vg_read_error(vg)) {
-			vg_release(vg);
-			return_0;
-		}
-
-		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
-			log_error("Unable to find \"%s\" in volume group \"%s\"",
-				  pv_name, vg->name);
-			goto out;
-		}
 		if (tagarg && !(vg->fid->fmt->features & FMT_TAGS)) {
 			log_error("Volume group containing %s does not "
 				  "support tags", pv_name);
@@ -78,7 +60,6 @@ static int _pvchange_single(struct cmd_context *cmd, struct physical_volume *pv,
 				  "logical volumes", pv_name);
 			goto out;
 		}
-		pv = pvl->pv;
 		if (!archive(vg))
 			goto out;
 	} else {
@@ -87,19 +68,6 @@ static int _pvchange_single(struct cmd_context *cmd, struct physical_volume *pv,
 				  "in volume group", pv_name);
 			return 0;
 		}
-
-		vg_name = VG_ORPHANS;
-
-		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
-			log_error("Can't get lock for orphans");
-			return 0;
-		}
-
-		if (!(pv = pv_read(cmd, pv_name, NULL, &sector, 1, 0))) {
-			unlock_vg(cmd, vg_name);
-			log_error("Unable to read PV \"%s\"", pv_name);
-			return 0;
-		}
 	}
 
 	if (arg_count(cmd, allocatable_ARG)) {
@@ -201,7 +169,6 @@ static int _pvchange_single(struct cmd_context *cmd, struct physical_volume *pv,
 	log_print("Physical volume \"%s\" changed", pv_name);
 	r = 1;
 out:
-	unlock_and_release_vg(cmd, vg, vg_name);
 	return r;
 
 }
@@ -212,12 +179,12 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 	int done = 0;
 	int total = 0;
 
-	struct physical_volume *pv;
-	char *pv_name;
+	struct volume_group *vg;
+	const char *pv_name, *vg_name;
 
 	struct pv_list *pvl;
-	struct dm_list *pvslist;
-	struct dm_list mdas;
+	struct dm_list *vgnames;
+	struct str_list *sll;
 
 	if (arg_count(cmd, allocatable_ARG) + arg_count(cmd, addtag_ARG) +
 	    arg_count(cmd, deltag_ARG) + arg_count(cmd, uuid_ARG) != 1) {
@@ -240,47 +207,56 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 		log_verbose("Using physical volume(s) on command line");
 		for (; opt < argc; opt++) {
 			pv_name = argv[opt];
-			dm_list_init(&mdas);
-			if (!(pv = pv_read(cmd, pv_name, &mdas, NULL, 1, 0))) {
+			vg_name = find_vgname_from_pvname(cmd, pv_name);
+			if (!vg_name) {
 				log_error("Failed to read physical volume %s",
 					  pv_name);
 				continue;
 			}
-			/*
-			 * If a PV has no MDAs it may appear to be an
-			 * orphan until the metadata is read off
-			 * another PV in the same VG.  Detecting this
-			 * means checking every VG by scanning every
-			 * PV on the system.
-			 */
-			if (is_orphan(pv) && !dm_list_size(&mdas)) {
-				if (!scan_vgs_for_pvs(cmd)) {
-					log_error("Rescan for PVs without "
-						  "metadata areas failed.");
-					continue;
-				}
-				if (!(pv = pv_read(cmd, pv_name,
-						   NULL, NULL, 1, 0))) {
-					log_error("Failed to read "
-						  "physical volume %s",
-						  pv_name);
-					continue;
-				}
+			vg = vg_read_for_update(cmd, vg_name, NULL, 0);
+			if (vg_read_error(vg)) {
+				vg_release(vg);
+				stack;
+				continue;
+			}
+			pvl = find_pv_in_vg(vg, pv_name);
+			if (!pvl || !pvl->pv) {
+				log_error("Unable to find %s in %s",
+					  pv_name, vg_name);
+				continue;
 			}
 
 			total++;
-			done += _pvchange_single(cmd, pv, NULL);
+			done += _pvchange_single(cmd, vg,
+						 pvl->pv, NULL);
+			/* FIXME: we should be using #orphans_lvm2 everwhere */
+			if (is_orphan_vg(vg->name))
+				vg_name = VG_ORPHANS;
+			unlock_and_release_vg(cmd, vg, vg_name);
 		}
 	} else {
 		log_verbose("Scanning for physical volume names");
-		if (!(pvslist = get_pvs(cmd))) {
-			stack;
-			return ECMD_FAILED;
-		}
-
-		dm_list_iterate_items(pvl, pvslist) {
-			total++;
-			done += _pvchange_single(cmd, pvl->pv, NULL);
+		/* FIXME: share code with toollib */
+		if ((vgnames = get_vgnames(cmd, 0, 1)) &&
+		    !dm_list_empty(vgnames)) {
+			dm_list_iterate_items(sll, vgnames) {
+				vg = vg_read_for_update(cmd, sll->str, NULL, 0);
+				if (vg_read_error(vg)) {
+					vg_release(vg);
+					stack;
+					continue;
+				}
+				dm_list_iterate_items(pvl, &vg->pvs) {
+					total++;
+					done += _pvchange_single(cmd, vg,
+								 pvl->pv,
+								 NULL);
+				}
+				/* FIXME: we should be using #orphans_lvm2 everwhere */
+				if (is_orphan_vg(vg->name))
+					vg_name = VG_ORPHANS;
+				unlock_and_release_vg(cmd, vg, vg_name);
+			}
 		}
 	}
 
-- 
1.6.0.6


