From: agk@sourceware.org <agk@sourceware.org>
Date: 7 Jul 2010 02:53:17 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c lib/m ...
Message-ID: <20100707025317.18198.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-07 02:53:17

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c metadata.h 

Log message:
	Adjust auto-metadata repair and caching logic to try to cope with empty mdas.
	
	- If a PV contained empty mdas, the auto-recovery code was not kicking in.
	- The 'inconsistent' state was getting lost when metadata was cached so
	recovery didn't kick in.  But leave the behaviour alone when using
	precommitted metadata because of a warning in a confusing FIXME.
	
	In my testing, pvs and vgs didn't repair inconsistent metadata like they
	used to do.  (How many other tools fail similarly now?)
	
	And there should be no need to cache inconsistent metadata because it is
	supposed to get repaired under the protection of a write lock immediately it is
	discovered.
	
	This code is in need of a redesign based on first principles.
	I still see bugs in this code and this commit is risky.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1656&r2=1.1657
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.383&r2=1.384
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.214&r2=1.215

--- LVM2/WHATS_NEW	2010/07/07 02:37:28	1.1656
+++ LVM2/WHATS_NEW	2010/07/07 02:53:16	1.1657
@@ -1,5 +1,6 @@
 Version 2.02.71 -
 ===============================
+  Adjust auto-metadata repair and caching logic to try to cope with empty mdas.
 
 Version 2.02.70 - 6th July 2010
 ===============================
--- LVM2/lib/metadata/metadata.c	2010/07/06 20:09:38	1.383
+++ LVM2/lib/metadata/metadata.c	2010/07/07 02:53:17	1.384
@@ -2899,6 +2899,7 @@
 	int inconsistent_vgid = 0;
 	int inconsistent_pvs = 0;
 	int inconsistent_seqno = 0;
+	int inconsistent_mdas = 0;
 	unsigned use_precommitted = precommitted;
 	unsigned saved_handles_missing_pvs = cmd->handles_missing_pvs;
 	struct dm_list *pvids;
@@ -2916,14 +2917,28 @@
 		return _vg_read_orphans(cmd, vgname);
 	}
 
-	if ((correct_vg = lvmcache_get_vg(vgid, precommitted))) {
+	/*
+	 * If cached metadata was inconsistent and *consistent is set
+	 * then repair it now.  Otherwise just return it.
+	 * Also return if use_precommitted is set due to the FIXME in
+	 * the missing PV logic below.
+	 */
+	if ((correct_vg = lvmcache_get_vg(vgid, precommitted)) &&
+	    (use_precommitted || !*consistent || !(correct_vg->status & INCONSISTENT_VG))) {
+		if (!(correct_vg->status & INCONSISTENT_VG))
+			*consistent = 1;
+		else	/* Inconsistent but we can't repair it */
+			correct_vg->status &= ~INCONSISTENT_VG;
+
 		if (vg_missing_pv_count(correct_vg)) {
 			log_verbose("There are %d physical volumes missing.",
 				    vg_missing_pv_count(correct_vg));
 			vg_mark_partial_lvs(correct_vg);
 		}
-		*consistent = 1;
 		return correct_vg;
+	} else {
+		vg_release(correct_vg);
+		correct_vg = NULL;
 	}
 
 	/* Find the vgname in the cache */
@@ -3009,14 +3024,29 @@
 				 * not ignored.
 				 */
 				if (!(info = info_from_pvid(pvl->pv->dev->pvid, 1)) ||
-				   !info->vginfo || !is_orphan_vg(info->vginfo->vgname) ||
-				   !mdas_empty_or_ignored(&info->mdas)) {
+				   !info->vginfo || !is_orphan_vg(info->vginfo->vgname)) {
 					inconsistent_pvs = 1;
 					break;
 				}
-				if (dm_list_size(&info->mdas) &&
-				    !fid_add_mdas(fid, &info->mdas))
-					return_NULL;
+				if (dm_list_size(&info->mdas)) {
+					if (!fid_add_mdas(fid, &info->mdas))
+						return_NULL;
+					 
+					log_debug("Empty mda found for VG %s.", vgname);
+
+					if (inconsistent_mdas)
+						continue;
+
+					/*
+					 * If any newly-added mdas are in-use then their
+					 * metadata needs updating.
+					 */
+					dm_list_iterate_items(mda, &info->mdas)
+						if (!mda_is_ignored(mda)) {
+							inconsistent_mdas = 1;
+							break;
+						}
+				}
 			}
 
 			/* If the check passed, let's update VG and recalculate pvids */
@@ -3056,6 +3086,11 @@
 				break;
 			}
 		}
+
+		if (correct_vg && inconsistent_mdas) {
+			vg_release(correct_vg);
+			correct_vg = NULL;
+		}
 	}
 
 	dm_list_init(&all_pvs);
@@ -3132,7 +3167,8 @@
 	 * If there is no precommitted metadata, committed metadata
 	 * is read and stored in the cache even if use_precommitted is set
 	 */
-	lvmcache_update_vg(correct_vg, correct_vg->status & PRECOMMITTED);
+	lvmcache_update_vg(correct_vg, correct_vg->status & PRECOMMITTED &
+			   (inconsistent ? INCONSISTENT_VG : 0));
 
 	if (inconsistent) {
 		/* FIXME Test should be if we're *using* precommitted metadata not if we were searching for it */
--- LVM2/lib/metadata/metadata.h	2010/06/30 13:51:13	1.214
+++ LVM2/lib/metadata/metadata.h	2010/07/07 02:53:17	1.215
@@ -76,6 +76,7 @@
 //#define CONVERTING		0x00400000U	/* LV */
 
 //#define MISSING_PV		0x00800000U	/* PV */
+#define INCONSISTENT_VG		0x00800000U	/* VG - internal use only */
 //#define PARTIAL_LV		0x01000000U	/* LV - derived flag, not
 //						   written out in metadata*/
 


