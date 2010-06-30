From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Jun 2010 18:03:54 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20100630180354.3592.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-30 18:03:53

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	liblvm         : lvm_vg.c 
	tools          : vgremove.c 

Log message:
	Refactor vg_remove_check to place pv removal into separate function.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.161&r2=1.162
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.374&r2=1.375
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgremove.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61

--- LVM2/lib/metadata/metadata-exported.h	2010/06/30 12:17:24	1.161
+++ LVM2/lib/metadata/metadata-exported.h	2010/06/30 18:03:52	1.162
@@ -540,6 +540,7 @@
 struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name);
 int vg_remove_mdas(struct volume_group *vg);
 int vg_remove_check(struct volume_group *vg);
+void vg_remove_pvs(struct volume_group *vg);
 int vg_remove(struct volume_group *vg);
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name);
--- LVM2/lib/metadata/metadata.c	2010/06/30 17:13:06	1.374
+++ LVM2/lib/metadata/metadata.c	2010/06/30 18:03:52	1.375
@@ -510,7 +510,6 @@
 int vg_remove_check(struct volume_group *vg)
 {
 	unsigned lv_count;
-	struct pv_list *pvl, *tpvl;
 
 	if (vg_read_error(vg) || vg_missing_pv_count(vg)) {
 		log_error("Volume group \"%s\" not found, is inconsistent "
@@ -534,11 +533,17 @@
 	if (!archive(vg))
 		return 0;
 
+	return 1;
+}
+
+void vg_remove_pvs(struct volume_group *vg)
+{
+	struct pv_list *pvl, *tpvl;
+
 	dm_list_iterate_items_safe(pvl, tpvl, &vg->pvs) {
 		del_pvl_from_vgs(vg, pvl);
 		dm_list_add(&vg->removed_pvs, &pvl->list);
 	}
-	return 1;
 }
 
 int vg_remove(struct volume_group *vg)
--- LVM2/liblvm/lvm_vg.c	2010/04/19 15:22:24	1.40
+++ LVM2/liblvm/lvm_vg.c	2010/06/30 18:03:53	1.41
@@ -180,6 +180,8 @@
 	if (!vg_remove_check(vg))
 		return -1;
 
+	vg_remove_pvs(vg);
+
 	return 0;
 }
 
--- LVM2/tools/vgremove.c	2010/06/30 14:01:40	1.60
+++ LVM2/tools/vgremove.c	2010/06/30 18:03:53	1.61
@@ -54,6 +54,8 @@
 		return ECMD_FAILED;
 	}
 
+	vg_remove_pvs(vg);
+
 	if (!vg_remove(vg)) {
 		stack;
 		return ECMD_FAILED;


