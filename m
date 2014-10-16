From: David Teigland <teigland@redhat.com>
Date: Thu, 16 Oct 2014 16:41:31 -0500
Subject: [PATCH] pvchange: use process_each_pv
Message-ID: <20141016214130.GA13251@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The summary output at the end has been removed.
A similar counter method could be added to the
various process_each functions if we want to
retain this sort of summary reporting.

---
 tools/pvchange.c | 112 +++++++++++--------------------------------------------
 1 file changed, 22 insertions(+), 90 deletions(-)

diff --git a/tools/pvchange.c b/tools/pvchange.c
index c2adc34309c5..e10da609f3c5 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -40,20 +40,20 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 		if (tagargs && !(vg->fid->fmt->features & FMT_TAGS)) {
 			log_error("Volume group containing %s does not "
 				  "support tags", pv_name);
-			return 0;
+			return ECMD_FAILED;
 		}
 		if (arg_count(cmd, uuid_ARG) && lvs_in_vg_activated(vg)) {
 			log_error("Volume group containing %s has active "
 				  "logical volumes", pv_name);
-			return 0;
+			return ECMD_FAILED;
 		}
 		if (!archive(vg))
-			return 0;
+			return ECMD_FAILED;
 	} else {
 		if (tagargs) {
 			log_error("Can't change tag on Physical Volume %s not "
 				  "in volume group", pv_name);
-			return 0;
+			return ECMD_FAILED;
 		}
 	}
 
@@ -62,20 +62,20 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 		    !(pv->fmt->features & FMT_ORPHAN_ALLOCATABLE)) {
 			log_error("Allocatability not supported by orphan "
 				  "%s format PV %s", pv->fmt->name, pv_name);
-			return 0;
+			return ECMD_FAILED;
 		}
 
 		/* change allocatability for a PV */
 		if (allocatable && (pv_status(pv) & ALLOCATABLE_PV)) {
 			log_warn("Physical volume \"%s\" is already "
 				 "allocatable.", pv_name);
-			return 1;
+			return ECMD_PROCESSED;
 		}
 
 		if (!allocatable && !(pv_status(pv) & ALLOCATABLE_PV)) {
 			log_warn("Physical volume \"%s\" is already "
 				 "unallocatable.", pv_name);
-			return 1;
+			return ECMD_PROCESSED;
 		}
 
 		if (allocatable) {
@@ -92,10 +92,10 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 	if (tagargs) {
 		/* tag or deltag */
 		if (arg_count(cmd, addtag_ARG) && !change_tag(cmd, NULL, NULL, pv, addtag_ARG))
-			return_0;
+			return_ECMD_FAILED;
 
 		if (arg_count(cmd, deltag_ARG) && !change_tag(cmd, NULL, NULL, pv, deltag_ARG))
-			return_0;
+			return_ECMD_FAILED;
  
 	}
 
@@ -106,10 +106,10 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 				  "of VG %s metadata? [y/n]: ",
 				  pv_vg_name(pv)) == 'n') {
 			log_error("Physical volume %s not changed", pv_name);
-			return 0;
+			return ECMD_FAILED;
 		}
 		if (!pv_change_metadataignore(pv, mda_ignore))
-			return_0;
+			return_ECMD_FAILED;
 	} 
 
 	if (arg_count(cmd, uuid_ARG)) {
@@ -118,15 +118,15 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 		if (!id_create(&pv->id)) {
 			log_error("Failed to generate new random UUID for %s.",
 				  pv_name);
-			return 0;
+			return ECMD_FAILED;
 		}
 		if (!id_write_format(&pv->id, uuid, sizeof(uuid)))
-			return 0;
+			return ECMD_FAILED;
 		log_verbose("Changing uuid of %s to %s.", pv_name, uuid);
 		if (!is_orphan(pv) && (!pv_write(cmd, pv, 1))) {
 			log_error("pv_write with new uuid failed "
 				  "for %s.", pv_name);
-			return 0;
+			return ECMD_FAILED;
 		}
 	}
 
@@ -135,33 +135,23 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 		if (!vg_write(vg) || !vg_commit(vg)) {
 			log_error("Failed to store physical volume \"%s\" in "
 				  "volume group \"%s\"", pv_name, vg->name);
-			return 0;
+			return ECMD_FAILED;
 		}
 		backup(vg);
 	} else if (!(pv_write(cmd, pv, 0))) {
 		log_error("Failed to store physical volume \"%s\"",
 			  pv_name);
-		return 0;
+		return ECMD_FAILED;
 	}
 
 	log_print_unless_silent("Physical volume \"%s\" changed", pv_name);
 
-	return 1;
+	return ECMD_PROCESSED;
 }
 
 int pvchange(struct cmd_context *cmd, int argc, char **argv)
 {
-	int opt = 0;
-	int done = 0;
-	int total = 0;
-
-	struct volume_group *vg;
-	const char *vg_name;
-	char *pv_name;
-
-	struct pv_list *pvl;
-	struct dm_list *vgnames;
-	struct dm_str_list *sll;
+	int ret;
 
 	if (!(arg_count(cmd, allocatable_ARG) + arg_is_set(cmd, addtag_ARG) +
 	    arg_is_set(cmd, deltag_ARG) + arg_count(cmd, uuid_ARG) +
@@ -181,39 +171,7 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (argc) {
-		log_verbose("Using physical volume(s) on command line");
-		for (; opt < argc; opt++) {
-			total++;
-			pv_name = argv[opt];
-			dm_unescape_colons_and_at_signs(pv_name, NULL, NULL);
-			vg_name = find_vgname_from_pvname(cmd, pv_name);
-			if (!vg_name) {
-				log_error("Failed to read physical volume %s",
-					  pv_name);
-				continue;
-			}
-			vg = vg_read_for_update(cmd, vg_name, NULL, 0);
-			if (vg_read_error(vg)) {
-				release_vg(vg);
-				stack;
-				continue;
-			}
-			pvl = find_pv_in_vg(vg, pv_name);
-			if (!pvl || !pvl->pv) {
-				unlock_and_release_vg(cmd, vg, vg_name);
-				log_error("Unable to find %s in %s",
-					  pv_name, vg_name);
-				continue;
-			}
-
-			done += _pvchange_single(cmd, vg,
-						 pvl->pv, NULL);
-			unlock_and_release_vg(cmd, vg, vg_name);
-		}
-	} else {
-		log_verbose("Scanning for physical volume names");
-		/* FIXME: share code with toollib */
+	if (!argc) {
 		/*
 		 * Take the global lock here so the lvmcache remains
 		 * consistent across orphan/non-orphan vg locks.  If we don't
@@ -224,36 +182,10 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 			log_error("Unable to obtain global lock.");
 			return ECMD_FAILED;
 		}
-
-		/* populate lvmcache */
-		if (!lvmetad_vg_list_to_lvmcache(cmd))
-			stack;
-
-		if ((vgnames = get_vgnames(cmd, 1)) &&
-		    !dm_list_empty(vgnames)) {
-			dm_list_iterate_items(sll, vgnames) {
-				vg = vg_read_for_update(cmd, sll->str, NULL, 0);
-				if (vg_read_error(vg)) {
-					release_vg(vg);
-					stack;
-					continue;
-				}
-				dm_list_iterate_items(pvl, &vg->pvs) {
-					total++;
-					done += _pvchange_single(cmd, vg,
-								 pvl->pv,
-								 NULL);
-				}
-				unlock_and_release_vg(cmd, vg, sll->str);
-			}
-		}
-		unlock_vg(cmd, VG_GLOBAL);
 	}
 
-	log_print_unless_silent("%d physical volume%s changed / %d physical volume%s "
-				"not changed",
-				done, done == 1 ? "" : "s",
-				total - done, (total - done) == 1 ? "" : "s");
+	ret = process_each_pv(cmd, argc, argv, NULL, READ_FOR_UPDATE, NULL,
+			      _pvchange_single);
 
-	return (total == done) ? ECMD_PROCESSED : ECMD_FAILED;
+	return ret;
 }
-- 
1.8.3.1


