From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 1 Nov 2009 20:02:33 -0000
Subject: LVM2/tools toollib.c toollib.h vgcreate.c vgsp ...
Message-ID: <20091101200233.27147.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-11-01 20:02:32

Modified files:
	tools          : toollib.c toollib.h vgcreate.c vgsplit.c 

Log message:
	Add vgcreate_params_set_defaults().
	
	Add function to set default vgcreate parameters based on existing VG or
	internal defaults.  Should be no functional change.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.176&r2=1.177
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.66&r2=1.67
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.96&r2=1.97

--- LVM2/tools/toollib.c	2009/11/01 19:51:55	1.176
+++ LVM2/tools/toollib.c	2009/11/01 20:02:32	1.177
@@ -1183,6 +1183,26 @@
 	return rc;
 }
 
+void vgcreate_params_set_defaults(struct vgcreate_params *vp_def,
+				  struct volume_group *vg)
+{
+	if (vg) {
+		vp_def->vg_name = NULL;
+		vp_def->extent_size = vg->extent_size;
+		vp_def->max_pv = vg->max_pv;
+		vp_def->max_lv = vg->max_lv;
+		vp_def->alloc = vg->alloc;
+		vp_def->clustered = vg_is_clustered(vg);
+	} else {
+		vp_def->vg_name = NULL;
+		vp_def->extent_size = DEFAULT_EXTENT_SIZE * 2;
+		vp_def->max_pv = DEFAULT_MAX_PV;
+		vp_def->max_lv = DEFAULT_MAX_LV;
+		vp_def->alloc = DEFAULT_ALLOC_POLICY;
+		vp_def->clustered = DEFAULT_CLUSTERED;
+	}
+}
+
 /*
  * Set members of struct vgcreate_params from cmdline.
  * Do preliminary validation with arg_*() interface.
--- LVM2/tools/toollib.h	2009/11/01 19:51:55	1.66
+++ LVM2/tools/toollib.h	2009/11/01 20:02:32	1.67
@@ -99,6 +99,8 @@
 int apply_lvname_restrictions(const char *name);
 int is_reserved_lvname(const char *name);
 
+void vgcreate_params_set_defaults(struct vgcreate_params *vp_def,
+				 struct volume_group *vg);
 int fill_vg_create_params(struct cmd_context *cmd,
 			  char *vg_name, struct vgcreate_params *vp_new,
 			  struct vgcreate_params *vp_def);
--- LVM2/tools/vgcreate.c	2009/11/01 19:51:55	1.72
+++ LVM2/tools/vgcreate.c	2009/11/01 20:02:32	1.73
@@ -45,12 +45,7 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	vp_def.vg_name = NULL;
-	vp_def.extent_size = DEFAULT_EXTENT_SIZE * 2;
-	vp_def.max_pv = DEFAULT_MAX_PV;
-	vp_def.max_lv = DEFAULT_MAX_LV;
-	vp_def.alloc = DEFAULT_ALLOC_POLICY;
-	vp_def.clustered = DEFAULT_CLUSTERED;
+	vgcreate_params_set_defaults(&vp_def, NULL);
 	if (fill_vg_create_params(cmd, vg_name, &vp_new, &vp_def))
 		return EINVALID_CMD_LINE;
 
--- LVM2/tools/vgsplit.c	2009/10/31 17:43:57	1.96
+++ LVM2/tools/vgsplit.c	2009/11/01 20:02:32	1.97
@@ -366,13 +366,7 @@
 		if (!vgs_are_compatible(cmd, vg_from,vg_to))
 			goto_bad;
 	} else {
-		vp_def.vg_name = NULL;
-		vp_def.extent_size = vg_from->extent_size;
-		vp_def.max_pv = vg_from->max_pv;
-		vp_def.max_lv = vg_from->max_lv;
-		vp_def.alloc = vg_from->alloc;
-		vp_def.clustered = vg_is_clustered(vg_from);
-
+		vgcreate_params_set_defaults(&vp_def, vg_from);
 		if (fill_vg_create_params(cmd, vg_name_to, &vp_new, &vp_def)) {
 			r = EINVALID_CMD_LINE;
 			goto_bad;


