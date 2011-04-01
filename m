From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 1 Apr 2011 14:54:21 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20110401145421.8740.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-04-01 14:54:21

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Cleanup fid finalization code in free_vg and allow exactly the same fid to be set again for a PV/VG.
	
	Actually, we can call vg_set_fid(vg, NULL) instead of calling
	destroy_instance for all PV structs and a VG struct - it's the same
	code we already have in the vg_set_fid.
	
	Also, allow exactly the same fid to be set again for the same PV/VG
	Before, this could end up with the fid destroyed because we destroyed
	existing fid first and then we used the new one and we didn't care
	whether existing one == new one by chance.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.452&r2=1.453

--- LVM2/lib/metadata/metadata.c	2011/03/30 13:35:51	1.452
+++ LVM2/lib/metadata/metadata.c	2011/04/01 14:54:20	1.453
@@ -3243,19 +3243,10 @@
 
 void free_vg(struct volume_group *vg)
 {
-	struct pv_list *pvl;
-
 	if (!vg)
 		return;
 
-	dm_list_iterate_items(pvl, &vg->pvs)
-		pvl->pv->fid->fmt->ops->destroy_instance(pvl->pv->fid);
-
-	dm_list_iterate_items(pvl, &vg->removed_pvs)
-		pvl->pv->fid->fmt->ops->destroy_instance(pvl->pv->fid);
-
-	if (vg->fid)
-		vg->fid->fmt->ops->destroy_instance(vg->fid);
+	vg_set_fid(vg, NULL);
 
 	if (vg->cmd && vg->vgmem == vg->cmd->mem) {
 		log_error(INTERNAL_ERROR "global memory pool used for VG %s",
@@ -4048,12 +4039,13 @@
 void pv_set_fid(struct physical_volume *pv,
 		struct format_instance *fid)
 {
+	if (fid)
+		fid->ref_count++;
+
 	if (pv->fid)
 		pv->fid->fmt->ops->destroy_instance(pv->fid);
 
 	pv->fid = fid;
-	if (fid)
-		fid->ref_count++;
 }
 
 void vg_set_fid(struct volume_group *vg,
@@ -4061,15 +4053,19 @@
 {
 	struct pv_list *pvl;
 
-	if (vg->fid)
-		vg->fid->fmt->ops->destroy_instance(vg->fid);
-
-	vg->fid = fid;
 	if (fid)
 		fid->ref_count++;
 
 	dm_list_iterate_items(pvl, &vg->pvs)
 		pv_set_fid(pvl->pv, fid);
+
+	dm_list_iterate_items(pvl, &vg->removed_pvs)
+		pv_set_fid(pvl->pv, fid);
+
+	if (vg->fid)
+		vg->fid->fmt->ops->destroy_instance(vg->fid);
+
+	vg->fid = fid;
 }
 
 static int _convert_key_to_string(const char *key, size_t key_len,


