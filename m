From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 Apr 2010 17:26:04 -0000
Subject: LVM2 lib/format_pool/import_export.c lib/metad ...
Message-ID: <20100413172604.11666.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-04-13 17:26:03

Modified files:
	lib/format_pool: import_export.c 
	lib/metadata   : metadata.c 
	tools          : lvconvert.c vgmerge.c vgreduce.c 

Log message:
	Call add_pvl_to_vgs() and del_pvl_from_vgs() from more places.
	
	Now that we have library functions to add/delete a pv from the vg->pvs
	list, call them from everywhere.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/import_export.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.333&r2=1.334
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.126&r2=1.127
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.100&r2=1.101

--- LVM2/lib/format_pool/import_export.c	2010/04/13 17:25:26	1.31
+++ LVM2/lib/format_pool/import_export.c	2010/04/13 17:26:03	1.32
@@ -119,8 +119,7 @@
 		pl->pv = pvl->pv;
 		pvl->mdas = NULL;
 		pvl->pe_ranges = NULL;
-		vg->pv_count++;
-		dm_list_add(&vg->pvs, &pvl->list);
+		add_pvl_to_vgs(vg, pvl);
 	}
 
 	return 1;
--- LVM2/lib/metadata/metadata.c	2010/04/13 17:25:44	1.333
+++ LVM2/lib/metadata/metadata.c	2010/04/13 17:26:03	1.334
@@ -347,10 +347,8 @@
 	    _vg_bad_status_bits(vg_to, RESIZEABLE_VG))
 		return 0;
 
-	dm_list_move(&vg_to->pvs, &pvl->list);
-
-	vg_from->pv_count--;
-	vg_to->pv_count++;
+	del_pvl_from_vgs(vg_from, pvl);
+	add_pvl_to_vgs(vg_to, pvl);
 
 	pv = pvl->pv;
 
@@ -517,7 +515,7 @@
 		return 0;
 
 	dm_list_iterate_items_safe(pvl, tpvl, &vg->pvs) {
-		dm_list_del(&pvl->list);
+		del_pvl_from_vgs(vg, pvl);
 		dm_list_add(&vg->removed_pvs, &pvl->list);
 	}
 	return 1;
@@ -2510,8 +2508,7 @@
 			goto bad;
 		}
 		pvl->pv = pv;
-		dm_list_add(&vg->pvs, &pvl->list);
-		vg->pv_count++;
+		add_pvl_to_vgs(vg, pvl);
 	}
 
 	return vg;
--- LVM2/tools/lvconvert.c	2010/04/13 01:54:34	1.126
+++ LVM2/tools/lvconvert.c	2010/04/13 17:26:03	1.127
@@ -751,8 +751,7 @@
 			/* FIXME: duplication of vgreduce code, move this to library */
 			vg->free_count -= pvl_vg->pv->pe_count;
 			vg->extent_count -= pvl_vg->pv->pe_count;
-			vg->pv_count--;
-			dm_list_del(&pvl_vg->list);
+			del_pvl_from_vgs(vg, pvl_vg);
 
 			removed++;
 		}
--- LVM2/tools/vgmerge.c	2009/09/14 22:47:50	1.65
+++ LVM2/tools/vgmerge.c	2010/04/13 17:26:03	1.66
@@ -31,6 +31,7 @@
 static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 			   const char *vg_name_from)
 {
+	struct pv_list *pvl, *tpvl;
 	struct volume_group *vg_to, *vg_from;
 	struct lv_list *lvl1, *lvl2;
 	int r = ECMD_FAILED;
@@ -82,16 +83,11 @@
 	drop_cached_metadata(vg_from);
 
 	/* Merge volume groups */
-	while (!dm_list_empty(&vg_from->pvs)) {
-		struct dm_list *pvh = vg_from->pvs.n;
-		struct physical_volume *pv;
-
-		dm_list_move(&vg_to->pvs, pvh);
-
-		pv = dm_list_item(pvh, struct pv_list)->pv;
-		pv->vg_name = dm_pool_strdup(cmd->mem, vg_to->name);
+	dm_list_iterate_items_safe(pvl, tpvl, &vg_from->pvs) {
+		del_pvl_from_vgs(vg_from, pvl);
+		add_pvl_to_vgs(vg_to, pvl);
+		pvl->pv->vg_name = dm_pool_strdup(cmd->mem, vg_to->name);
 	}
-	vg_to->pv_count += vg_from->pv_count;
 
 	/* Fix up LVIDs */
 	dm_list_iterate_items(lvl1, &vg_to->lvs) {
--- LVM2/tools/vgreduce.c	2010/03/16 14:37:39	1.100
+++ LVM2/tools/vgreduce.c	2010/04/13 17:26:03	1.101
@@ -39,9 +39,7 @@
 
 	vg->free_count -= pvl->pv->pe_count;
 	vg->extent_count -= pvl->pv->pe_count;
-	vg->pv_count--;
-
-	dm_list_del(&pvl->list);
+	del_pvl_from_vgs(vg, pvl);
 
 	return 1;
 }


