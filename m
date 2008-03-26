From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Mar 2008 17:26:33 -0000
Subject: LVM2 lib/metadata/metadata.c tools/vgmerge.c t ...
Message-ID: <20080326172633.17787.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-03-26 17:26:32

Modified files:
	lib/metadata   : metadata.c 
	tools          : vgmerge.c vgsplit.c 

Log message:
	Use list_move() in applicable places.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.161&r2=1.162
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52

--- LVM2/lib/metadata/metadata.c	2008/03/26 16:48:10	1.161
+++ LVM2/lib/metadata/metadata.c	2008/03/26 17:26:32	1.162
@@ -708,10 +708,8 @@
 			continue;
 		}
 
-		if (!mda->ops->mda_in_vg(vg_from->fid, vg_from, mda)) {
-			list_del(&mda->list);
-			list_add(mdas_to, &mda->list);
-		}
+		if (!mda->ops->mda_in_vg(vg_from->fid, vg_from, mda))
+			list_move(&mda->list, mdas_to);
 	}
 
 	if (list_empty(mdas_from) || list_empty(mdas_to))
--- LVM2/tools/vgmerge.c	2008/01/30 14:00:02	1.45
+++ LVM2/tools/vgmerge.c	2008/03/26 17:26:32	1.46
@@ -54,8 +54,7 @@
 		struct list *pvh = vg_from->pvs.n;
 		struct physical_volume *pv;
 
-		list_del(pvh);
-		list_add(&vg_to->pvs, pvh);
+		list_move(pvh, &vg_to->pvs);
 
 		pv = list_item(pvh, struct pv_list)->pv;
 		pv->vg_name = dm_pool_strdup(cmd->mem, vg_to->name);
@@ -90,15 +89,13 @@
 	while (!list_empty(&vg_from->lvs)) {
 		struct list *lvh = vg_from->lvs.n;
 
-		list_del(lvh);
-		list_add(&vg_to->lvs, lvh);
+		list_move(lvh, &vg_to->lvs);
 	}
 
 	while (!list_empty(&vg_from->fid->metadata_areas)) {
 		struct list *mdah = vg_from->fid->metadata_areas.n;
 
-		list_del(mdah);
-		list_add(&vg_to->fid->metadata_areas, mdah);
+		list_move(mdah, &vg_to->fid->metadata_areas);
 	}
 
 	vg_to->lv_count += vg_from->lv_count;
--- LVM2/tools/vgsplit.c	2008/02/29 00:13:48	1.51
+++ LVM2/tools/vgsplit.c	2008/03/26 17:26:32	1.52
@@ -20,8 +20,7 @@
 {
 	struct physical_volume *pv;
 
-	list_del(&pvl->list);
-	list_add(&vg_to->pvs, &pvl->list);
+	list_move(&pvl->list, &vg_to->pvs);
 
 	vg_from->pv_count--;
 	vg_to->pv_count++;


