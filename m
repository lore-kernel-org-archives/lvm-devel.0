From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 13 May 2009 21:24:13 -0000
Subject: LVM2/lib/format1 disk-rep.h import-export.c
Message-ID: <20090513212413.27092.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-05-13 21:24:12

Modified files:
	lib/format1    : disk-rep.h import-export.c 

Log message:
	Tidy format1 import LV function.
	
	Later patch initializes lv->vg after the LV structure is prepared,
	so pass through cmd context and do not use vg->cmd here.
	Also move LV id calculation (which uses lv->vg too).
	
	Also properly free memory pool if operation fails.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/disk-rep.h.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.103&r2=1.104

--- LVM2/lib/format1/disk-rep.h	2008/11/03 22:14:28	1.53
+++ LVM2/lib/format1/disk-rep.h	2009/05/13 21:24:12	1.54
@@ -215,7 +215,8 @@
 	      struct volume_group *vg, struct disk_list *dl);
 int export_vg(struct vg_disk *vgd, struct volume_group *vg);
 
-int import_lv(struct dm_pool *mem, struct logical_volume *lv, struct lv_disk *lvd);
+int import_lv(struct cmd_context *cmd, struct dm_pool *mem,
+	      struct logical_volume *lv, struct lv_disk *lvd);
 
 int import_extents(struct cmd_context *cmd, struct volume_group *vg,
 		   struct dm_list *pvds);
--- LVM2/lib/format1/import-export.c	2009/05/13 21:22:57	1.103
+++ LVM2/lib/format1/import-export.c	2009/05/13 21:24:12	1.104
@@ -294,10 +294,9 @@
 	return 1;
 }
 
-int import_lv(struct dm_pool *mem, struct logical_volume *lv, struct lv_disk *lvd)
+int import_lv(struct cmd_context *cmd, struct dm_pool *mem,
+	      struct logical_volume *lv, struct lv_disk *lvd)
 {
-	lvid_from_lvnum(&lv->lvid, &lv->vg->id, lvd->lv_number);
-
 	if (!(lv->name = _create_lv_name(mem, (char *)lvd->lv_name)))
 		return_0;
 
@@ -331,7 +330,7 @@
 		lv->alloc = ALLOC_NORMAL;
 
 	if (!lvd->lv_read_ahead)
-		lv->read_ahead = lv->vg->cmd->default_settings.read_ahead;
+		lv->read_ahead = cmd->default_settings.read_ahead;
 	else
 		lv->read_ahead = lvd->lv_read_ahead;
 
@@ -465,8 +464,12 @@
 	lv = ll->lv;
 	lv->vg = vg;
 
-	if (!import_lv(mem, lv, lvd))
+	lvid_from_lvnum(&lv->lvid, &vg->id, lvd->lv_number);
+
+	if (!import_lv(vg->cmd, mem, lv, lvd)) {
+		dm_pool_free(mem, ll);
 		return_NULL;
+	}
 
 	dm_list_add(&vg->lvs, &ll->list);
 


