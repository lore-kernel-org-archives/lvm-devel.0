From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 31 Oct 2017 20:02:17 -0400
Subject: master - cleanup: pvmove messages
Message-ID: <201711010002.vA102Hgc010623@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7a28b243faf4fc57466beb138fe1017608bfa7b2
Commit:        7a28b243faf4fc57466beb138fe1017608bfa7b2
Parent:        373372c8ab3749bc76ced37cec04b00aae6e5979
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 31 20:50:51 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 1 00:58:31 2017 +0100

cleanup: pvmove messages

Just add some dots to messages and remove unneeded
stack trace from return after log_error.
---
 tools/pvmove.c |   58 ++++++++++++++++++++++++++++---------------------------
 1 files changed, 30 insertions(+), 28 deletions(-)

diff --git a/tools/pvmove.c b/tools/pvmove.c
index aa06d02..0f54a50 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -88,18 +88,18 @@ static const char *_extract_lvname(struct cmd_context *cmd, const char *vgname,
 	while (*lvname == '/')
 		lvname++;
 	if (!strchr(lvname, '/')) {
-		log_error("--name takes a logical volume name");
+		log_error("--name takes a logical volume name.");
 		return NULL;
 	}
 	if (strncmp(vgname, lvname, strlen(vgname)) ||
 	    (lvname += strlen(vgname), *lvname != '/')) {
-		log_error("Named LV and old PV must be in the same VG");
+		log_error("Named LV and old PV must be in the same VG.");
 		return NULL;
 	}
 	while (*lvname == '/')
 		lvname++;
 	if (!*lvname) {
-		log_error("Incomplete LV name supplied with --name");
+		log_error("Incomplete LV name supplied with --name.");
 		return NULL;
 	}
 	return lvname;
@@ -137,7 +137,7 @@ static struct dm_list *_get_allocatable_pvs(struct cmd_context *cmd, int argc,
 	}
 
 	if (dm_list_empty(allocatable_pvs)) {
-		log_error("No extents available for allocation");
+		log_error("No extents available for allocation.");
 		return NULL;
 	}
 
@@ -169,8 +169,10 @@ static int _remove_sibling_pvs_from_trim_list(struct logical_volume *lv,
 
 	dm_list_init(&untrim_list);
 
-	if (!(suffix = first_substring(lv_name, "_rimage_", "_rmeta_", NULL)))
+	if (!(suffix = first_substring(lv_name, "_rimage_", "_rmeta_", NULL))) {
+		log_error("Can't find rimage or rmeta suffix.");
 		return 0;
+	}
 
 	if (!(idx = strchr(suffix + 1, '_'))) {
 		log_error("Can't find '_' after suffix %s.", suffix);
@@ -186,12 +188,12 @@ static int _remove_sibling_pvs_from_trim_list(struct logical_volume *lv,
 	}
 
 	if (!(sublv = find_lv(lv->vg, sublv_name))) {
-		log_error("Can't find sub LV %s?", sublv_name);
+		log_error("Can't find sub LV %s.", sublv_name);
 		return 0;
 	}
 
 	if (!get_pv_list_for_lv(lv->vg->cmd->mem, sublv, &untrim_list)) {
-		log_error("Can't find PVs for sub LV %s?", sublv_name);
+		log_error("Can't find PVs for sub LV %s.", sublv_name);
 		return 0;
 	}
 
@@ -202,7 +204,7 @@ static int _remove_sibling_pvs_from_trim_list(struct logical_volume *lv,
 			pvl2 = dm_list_item(pvh2, struct pv_list);
 
 			if (pvl1->pv == pvl2->pv) {
-				log_debug("Removing PV %s from trim list",
+				log_debug("Removing PV %s from trim list.",
 					  pvl2->pv->dev->pvid);
 				dm_list_del(&pvl2->list);
 				break;
@@ -230,7 +232,7 @@ static int _trim_allocatable_pvs(struct dm_list *alloc_list,
 	struct pv_list *pvl, *trim_pvl;
 
 	if (!alloc_list) {
-		log_error(INTERNAL_ERROR "alloc_list is NULL");
+		log_error(INTERNAL_ERROR "alloc_list is NULL.");
 		return 0;
 	}
 
@@ -280,9 +282,9 @@ static int _insert_pvmove_mirrors(struct cmd_context *cmd,
 	if (lv_mirr->le_count - prev_le_count) {
 		lv->status |= LOCKED;
 
-		log_verbose("Moving %u extents of logical volume %s/%s",
+		log_verbose("Moving %u extents of logical volume %s.",
 			    lv_mirr->le_count - prev_le_count,
-			    lv->vg->name, lv->name);
+			    display_lvname(lv));
 	}
 
 	return 1;
@@ -361,14 +363,14 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 	if (!(lv_mirr = lv_create_empty("pvmove%d", NULL,
 					LVM_READ | LVM_WRITE,
 					ALLOC_CONTIGUOUS, vg))) {
-		log_error("Creation of temporary pvmove LV failed");
+		log_error("Creation of temporary pvmove LV failed.");
 		return NULL;
 	}
 
 	lv_mirr->status |= (PVMOVE | LOCKED);
 
 	if (!(*lvs_changed = dm_pool_alloc(cmd->mem, sizeof(**lvs_changed)))) {
-		log_error("lvs_changed list struct allocation failed");
+		log_error("lvs_changed list struct allocation failed.");
 		return NULL;
 	}
 
@@ -410,7 +412,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 			continue;
 
 		if (lv_is_converting(lv) || lv_is_merging(lv)) {
-			log_error("Unable to pvmove when %s volumes are present",
+			log_error("Unable to pvmove when %s volumes are present.",
 				  lv_is_converting(lv) ?
 				  "converting" : "merging");
 			return NULL;
@@ -460,7 +462,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 			continue;
 
 		if (lv_is_cache_type(lv)) {
-			log_print_unless_silent("Skipping %s LV, %s",
+			log_print_unless_silent("Skipping %s LV, %s.",
 						lv_is_cache(lv) ? "cache" :
 						lv_is_cache_pool(lv) ?
 						"cache-pool" : "cache-related",
@@ -471,7 +473,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 
 		if (_parent_lv_is_cache_type(lv)) {
 			log_print_unless_silent("Skipping %s because a parent"
-						" is of cache type", lv->name);
+						" is of cache type.", lv->name);
 			lv_skipped = 1;
 			continue;
 		}
@@ -483,7 +485,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 		if ((vg_is_clustered(vg) || is_lockd_type(vg->lock_type)) &&
 		    (lv_is_origin(lv) || lv_is_cow(lv) ||
 		     lv_is_thin_type(lv) || lv_is_raid_type(lv))) {
-			log_print_unless_silent("Skipping %s LV %s",
+			log_print_unless_silent("Skipping %s LV %s.",
 						lv_is_origin(lv) ? "origin" :
 						lv_is_cow(lv) ?
 						"snapshot-related" :
@@ -513,7 +515,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 
 		if (lv_is_locked(lv)) {
 			lv_skipped = 1;
-			log_print_unless_silent("Skipping locked LV %s", lv->name);
+			log_print_unless_silent("Skipping locked LV %s.", lv->name);
 			continue;
 		}
 
@@ -549,7 +551,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 			log_error("All data on source PV skipped. "
 				  "It contains locked, hidden or "
 				  "non-top level LVs only.");
-		log_error("No data to move for %s", vg->name);
+		log_error("No data to move for %s.", vg->name);
 		return NULL;
 	}
 
@@ -576,13 +578,13 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 			    allocatable_pvs, alloc,
 			    (arg_is_set(cmd, atomic_ARG)) ?
 			    MIRROR_BY_SEGMENTED_LV : MIRROR_BY_SEG)) {
-		log_error("Failed to convert pvmove LV to mirrored");
-		return_NULL;
+		log_error("Failed to convert pvmove LV to mirrored.");
+		return NULL;
 	}
 
 	if (!split_parent_segments_for_layer(cmd, lv_mirr)) {
-		log_error("Failed to split segments being moved");
-		return_NULL;
+		log_error("Failed to split segments being moved.");
+		return NULL;
 	}
 
 	return lv_mirr;
@@ -710,7 +712,7 @@ static int _pvmove_setup_single(struct cmd_context *cmd,
 		}
 
 		if (!validate_name(lv_name)) {
-			log_error("Logical volume name %s is invalid", lv_name);
+			log_error("Logical volume name %s is invalid.", lv_name);
 			pp->setup_result = EINVALID_CMD_LINE;
 			return ECMD_FAILED;
 		}
@@ -746,12 +748,12 @@ static int _pvmove_setup_single(struct cmd_context *cmd,
 	exclusive = _pvmove_is_exclusive(cmd, vg);
 
 	if ((lv_mirr = find_pvmove_lv(vg, pv_dev(pv), PVMOVE))) {
-		log_print_unless_silent("Detected pvmove in progress for %s", pv_name);
+		log_print_unless_silent("Detected pvmove in progress for %s.", pv_name);
 		if (pp->pv_count || lv_name)
-			log_error("Ignoring remaining command line arguments");
+			log_warn("WARNING: Ignoring remaining command line arguments.");
 
 		if (!(lvs_changed = lvs_using_lv(cmd, vg, lv_mirr))) {
-			log_error("ABORTING: Failed to generate list of moving LVs");
+			log_error("ABORTING: Failed to generate list of moving LVs.");
 			goto out;
 		}
 
@@ -898,7 +900,7 @@ int pvmove(struct cmd_context *cmd, int argc, char **argv)
 	/* dm raid1 target must be present in every case */
 	if (!_pvmove_target_present(cmd, 0)) {
 		log_error("Required device-mapper target(s) not "
-			  "detected in your kernel");
+			  "detected in your kernel.");
 		return ECMD_FAILED;
 	}
 


