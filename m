From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:35:18 -0000
Subject: LVM2/lib format_text/format-text.c metadata/me ...
Message-ID: <20100628203518.16639.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:35:17

Modified files:
	lib/format_text: format-text.c 
	lib/metadata   : metadata.c 

Log message:
	Update _vg_read and _text_create_text_instance to use fid_add_mda[s].
	
	When we are constructing the vg, we may need to adjust the list of
	metadata_areas if there are ignored mdas.  At label read time, we
	do not read the metadata of ignored mdas, and as a result, they do
	not get placed on vg->fid->metadata_areas inside _text_create_text_instance
	since lvmcache does not have these areas attached to vginfo->infos.
	However, when we're checking the pvids inside _vg_read, after having
	read another metadata area from another PV, we do have the opportunity
	to update the metadata_area and metadata_areas_ignored lists based
	on the read metadata_area.  We need accurate mda lists for the reporting
	functions that count the ignored mdas, as well as general correctness
	of mda balancing.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.132&r2=1.133
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.354&r2=1.355

--- LVM2/lib/format_text/format-text.c	2010/06/28 20:33:23	1.132
+++ LVM2/lib/format_text/format-text.c	2010/06/28 20:35:17	1.133
@@ -1891,11 +1891,11 @@
 {
 	struct format_instance *fid;
 	struct text_fid_context *fidtc;
-	struct metadata_area *mda, *mda_new;
+	struct metadata_area *mda;
 	struct mda_context *mdac;
 	struct dir_list *dl;
 	struct raw_list *rl;
-	struct dm_list *dir_list, *raw_list, *mdas;
+	struct dm_list *dir_list, *raw_list;
 	char path[PATH_MAX];
 	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_info *info;
@@ -1923,7 +1923,7 @@
 			return_NULL;
 		mda->ops = &_metadata_text_file_backup_ops;
 		mda->metadata_locn = context;
-		dm_list_add(&fid->metadata_areas_in_use, &mda->list);
+		fid_add_mda(fid, mda);
 	} else {
 		dir_list = &((struct mda_lists *) fmt->private)->dirs;
 
@@ -1940,7 +1940,7 @@
 				return_NULL;
 			mda->ops = &_metadata_text_file_ops;
 			mda->metadata_locn = context;
-			dm_list_add(&fid->metadata_areas_in_use, &mda->list);
+			fid_add_mda(fid, mda);
 		}
 
 		raw_list = &((struct mda_lists *) fmt->private)->raws;
@@ -1960,7 +1960,7 @@
 			memcpy(&mdac->area, &rl->dev_area, sizeof(mdac->area));
 			mda->ops = &_metadata_text_raw_ops;
 			/* FIXME MISTAKE? mda->metadata_locn = context; */
-			dm_list_add(&fid->metadata_areas_in_use, &mda->list);
+			fid_add_mda(fid, mda);
 		}
 
 		/* Scan PVs in VG for any further MDAs */
@@ -1968,14 +1968,8 @@
 		if (!(vginfo = vginfo_from_vgname(vgname, vgid)))
 			goto_out;
 		dm_list_iterate_items(info, &vginfo->infos) {
-			mdas = &info->mdas;
-			dm_list_iterate_items(mda, mdas) {
-				/* FIXME Check it holds this VG */
-				mda_new = mda_copy(fmt->cmd->mem, mda);
-				if (!mda_new)
-					return_NULL;
-				dm_list_add(&fid->metadata_areas_in_use, &mda_new->list);
-			}
+			if (!fid_add_mdas(fid, &info->mdas))
+				return_NULL;
 		}
 		/* FIXME Check raw metadata area count - rescan if required */
 	}
--- LVM2/lib/metadata/metadata.c	2010/06/28 20:34:58	1.354
+++ LVM2/lib/metadata/metadata.c	2010/06/28 20:35:17	1.355
@@ -2723,7 +2723,8 @@
 	if (correct_vg) {
 		/*
 		 * If the VG has PVs without mdas, or ignored mdas, they may
-		 * still be orphans in the cache: update the cache state here.
+		 * still be orphans in the cache: update the cache state here,
+		 * and update the metadata lists in the vg.
 		 */
 		if (!inconsistent &&
 		    dm_list_size(&correct_vg->pvs) > dm_list_size(pvids)) {
@@ -2747,6 +2748,9 @@
 					inconsistent_pvs = 1;
 					break;
 				}
+				if (dm_list_size(&info->mdas) &&
+				    !fid_add_mdas(fid, &info->mdas))
+					return_NULL;
 			}
 
 			/* If the check passed, let's update VG and recalculate pvids */


