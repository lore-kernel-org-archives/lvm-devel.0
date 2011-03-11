From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 11 Mar 2011 15:06:14 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20110311150614.24103.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-03-11 15:06:13

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Call destroy_instance for any PVs found in VG structure during vg_free call.
	
	This is necessary for proper format instance ref_count support. We iterate
	over vg->pvs and vg->removed_pvs list and the ref_count is decremented and
	then it is destroyed if not referenced anymore.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1949&r2=1.1950
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.445&r2=1.446

--- LVM2/WHATS_NEW	2011/03/11 14:56:56	1.1949
+++ LVM2/WHATS_NEW	2011/03/11 15:06:13	1.1950
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Call destroy_instance for any PVs found in VG structure during vg_free call.
   Add new free_pv_fid fn and use it throughout to free all attached fids.
   Use only vg_set_fid and new pv_set_fid fn to assign the format instance.
   Make create_text_context fn static and move it inside create_instance fn.
--- LVM2/lib/metadata/metadata.c	2011/03/11 14:56:56	1.445
+++ LVM2/lib/metadata/metadata.c	2011/03/11 15:06:13	1.446
@@ -3243,9 +3243,20 @@
 
 void free_vg(struct volume_group *vg)
 {
+	struct pv_list *pvl;
+
 	if (!vg)
 		return;
 
+	dm_list_iterate_items(pvl, &vg->pvs)
+		pvl->pv->fid->fmt->ops->destroy_instance(pvl->pv->fid);
+
+	dm_list_iterate_items(pvl, &vg->removed_pvs)
+		pvl->pv->fid->fmt->ops->destroy_instance(pvl->pv->fid);
+
+	if (vg->fid)
+		vg->fid->fmt->ops->destroy_instance(vg->fid);
+
 	if (vg->cmd && vg->vgmem == vg->cmd->mem) {
 		log_error(INTERNAL_ERROR "global memory pool used for VG %s",
 			  vg->name);


