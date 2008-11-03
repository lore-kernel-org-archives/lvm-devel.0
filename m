From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Nov 2008 16:26:28 -0000
Subject: LVM2 ./WHATS_NEW lib/format1/disk-rep.c
Message-ID: <20081103162628.8163.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-11-03 16:26:27

Modified files:
	.              : WHATS_NEW 
	lib/format1    : disk-rep.c 

Log message:
	Rename a couple of variables that matched function names.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.988&r2=1.989
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/disk-rep.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77

--- LVM2/WHATS_NEW	2008/11/01 20:48:09	1.988
+++ LVM2/WHATS_NEW	2008/11/03 16:26:26	1.989
@@ -1,5 +1,6 @@
 Version 2.02.43 -
 ===================================
+  Rename a couple of variables that matched function names.
   Use simplified x.y.z version number in libdevmapper.pc.
   Merge device-mapper into the lvm2 tree.
   Remove ancient debian directory.
--- LVM2/lib/format1/disk-rep.c	2008/09/19 07:03:23	1.76
+++ LVM2/lib/format1/disk-rep.c	2008/11/03 16:26:27	1.77
@@ -277,12 +277,12 @@
 
 static int _read_lvs(struct disk_list *data)
 {
-	unsigned int i, read = 0;
+	unsigned int i, lvs_read = 0;
 	uint64_t pos;
 	struct lvd_list *ll;
 	struct vg_disk *vgd = &data->vgd;
 
-	for (i = 0; (i < vgd->lv_max) && (read < vgd->lv_cur); i++) {
+	for (i = 0; (i < vgd->lv_max) && (lvs_read < vgd->lv_cur); i++) {
 		pos = data->pvd.lv_on_disk.base + (i * sizeof(struct lv_disk));
 		ll = dm_pool_alloc(data->mem, sizeof(*ll));
 
@@ -295,7 +295,7 @@
 		if (!_check_lvd(&ll->lvd))
 			continue;
 
-		read++;
+		lvs_read++;
 		list_add(&data->lvds, &ll->list);
 	}
 


