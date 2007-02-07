From: agk@sourceware.org <agk@sourceware.org>
Date: 7 Feb 2007 13:29:52 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c lib/m ...
Message-ID: <20070207132952.21726.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-02-07 13:29:52

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c metadata.h 

Log message:
	If a PV reappears after it was removed from its VG, make it an orphan.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.569&r2=1.570
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.102&r2=1.103
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.152&r2=1.153

--- LVM2/WHATS_NEW	2007/01/31 16:26:22	1.569
+++ LVM2/WHATS_NEW	2007/02/07 13:29:51	1.570
@@ -1,5 +1,7 @@
 Version 2.02.22 - 
 ===================================
+  If a PV reappears after it was removed from its VG, make it an orphan.
+  Don't update metadata automatically if VGIDs don't match.
   Fix some vgreduce --removemissing command line validation.
 
 Version 2.02.21 - 30th January 2007
--- LVM2/lib/metadata/metadata.c	2006/11/30 23:11:42	1.102
+++ LVM2/lib/metadata/metadata.c	2007/02/07 13:29:52	1.103
@@ -963,6 +963,30 @@
 	return vg;
 }
 
+static int _update_pv_list(struct list *all_pvs, struct volume_group *vg)
+{
+	struct pv_list *pvl, *pvl2;
+
+	list_iterate_items(pvl, &vg->pvs) {
+		list_iterate_items(pvl2, all_pvs) {
+			if (pvl->pv->dev == pvl2->pv->dev)
+				goto next_pv;
+		}
+		/* PV is not on list so add it.  Note that we don't copy it. */
+       		if (!(pvl2 = dm_pool_zalloc(vg->cmd->mem, sizeof(*pvl2)))) {
+			log_error("pv_list allocation for '%s' failed",
+				  dev_name(pvl->pv->dev));
+			return 0;
+		}
+		pvl2->pv = pvl->pv;
+		list_add(all_pvs, &pvl2->list);
+  next_pv:
+		;
+	}
+
+	return 1;
+}
+
 /* Caller sets consistent to 1 if it's safe for vg_read to correct
  * inconsistent metadata on disk (i.e. the VG write lock is held).
  * This guarantees only consistent metadata is returned unless PARTIAL_VG.
@@ -982,9 +1006,12 @@
 	struct volume_group *vg, *correct_vg = NULL;
 	struct metadata_area *mda;
 	int inconsistent = 0;
+	int inconsistent_vgid = 0;
 	int use_precommitted = precommitted;
 	struct list *pvids;
-	struct pv_list *pvl;
+	struct pv_list *pvl, *pvl2;
+	struct list all_pvs;
+	char uuid[64] __attribute((aligned(8)));
 
 	if (!*vgname) {
 		if (use_precommitted) {
@@ -1069,6 +1096,8 @@
 		}
 	}
 
+	list_init(&all_pvs);
+
 	/* Failed to find VG where we expected it - full scan and retry */
 	if (!correct_vg) {
 		inconsistent = 0;
@@ -1104,13 +1133,25 @@
 			}
 			if (!correct_vg) {
 				correct_vg = vg;
+				if (!_update_pv_list(&all_pvs, correct_vg))
+					return_NULL;
 				continue;
 			}
+
+			if (strncmp((char *)vg->id.uuid,
+			    (char *)correct_vg->id.uuid, ID_LEN)) {
+				inconsistent = 1;
+				inconsistent_vgid = 1;
+			}
+
 			/* FIXME Also ensure contents same - checksums same? */
 			if (correct_vg->seqno != vg->seqno) {
 				inconsistent = 1;
-				if (vg->seqno > correct_vg->seqno)
+				if (vg->seqno > correct_vg->seqno) {
+					if (!_update_pv_list(&all_pvs, vg))
+						return_NULL;
 					correct_vg = vg;
+				}
 			}
 		}
 
@@ -1143,17 +1184,42 @@
 			return correct_vg;
 		}
 
-		log_print("Inconsistent metadata copies found - updating "
-			  "to use version %u", correct_vg->seqno);
+		/* Don't touch if vgids didn't match */
+		if (inconsistent_vgid) {
+			log_error("Inconsistent metadata UUIDs found for "
+				  "volume group %s", vgname);
+			*consistent = 0;
+			return correct_vg;
+		}
+
+		log_print("Inconsistent metadata found for VG %s - updating "
+			  "to use version %u", vgname, correct_vg->seqno);
+
 		if (!vg_write(correct_vg)) {
 			log_error("Automatic metadata correction failed");
 			return NULL;
 		}
+
 		if (!vg_commit(correct_vg)) {
 			log_error("Automatic metadata correction commit "
 				  "failed");
 			return NULL;
 		}
+
+		list_iterate_items(pvl, &all_pvs) {
+			list_iterate_items(pvl2, &correct_vg->pvs) {
+				if (pvl->pv->dev == pvl2->pv->dev)
+					goto next_pv;
+			}
+			if (!id_write_format(&pvl->pv->id, uuid, sizeof(uuid)))
+				return_NULL;
+			log_error("Removing PV %s (%s) that no longer belongs to VG %s",
+				  dev_name(pvl->pv->dev), uuid, correct_vg->name);
+			if (!pv_write_orphan(cmd, pvl->pv))
+				return_NULL;
+      next_pv:
+			;
+		}
 	}
 
 	if ((correct_vg->status & PVMOVE) && !pvmove_mode()) {
@@ -1433,3 +1499,25 @@
 
 	return 1;
 }
+
+int pv_write_orphan(struct cmd_context *cmd, struct physical_volume *pv)
+{
+	const char *old_vg_name = pv->vg_name;
+
+	pv->vg_name = ORPHAN;
+	pv->status = ALLOCATABLE_PV;
+
+	if (!dev_get_size(pv->dev, &pv->size)) {
+		log_error("%s: Couldn't get size.", dev_name(pv->dev));
+		return 0;
+	}
+
+	if (!pv_write(cmd, pv, NULL, INT64_C(-1))) {
+		log_error("Failed to clear metadata from physical "
+			  "volume \"%s\" after removal from \"%s\"",
+			  dev_name(pv->dev), old_vg_name);
+		return 0;
+	}
+
+	return 1;
+}
--- LVM2/lib/metadata/metadata.h	2006/12/13 03:39:58	1.152
+++ LVM2/lib/metadata/metadata.h	2007/02/07 13:29:52	1.153
@@ -423,6 +423,7 @@
 
 int pv_write(struct cmd_context *cmd, struct physical_volume *pv,
 	     struct list *mdas, int64_t label_sector);
+int pv_write_orphan(struct cmd_context *cmd, struct physical_volume *pv);
 
 /* pe_start and pe_end relate to any existing data so that new metadata
  * areas can avoid overlap */


