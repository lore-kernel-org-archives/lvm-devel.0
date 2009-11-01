From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 1 Nov 2009 20:03:24 -0000
Subject: LVM2/tools toollib.c toollib.h vgcreate.c vgsp ...
Message-ID: <20091101200324.12374.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-11-01 20:03:24

Modified files:
	tools          : toollib.c toollib.h vgcreate.c vgsplit.c 

Log message:
	Rename fill_vg_create_params to vgcreate_params_set_from_args.
	
	Rename fill_vg_create_params to vgcreate_params_set_from_args and remove
	vg_name parameter from function (caller must set before calling function).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.177&r2=1.178
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.67&r2=1.68
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.97&r2=1.98

--- LVM2/tools/toollib.c	2009/11/01 20:02:32	1.177
+++ LVM2/tools/toollib.c	2009/11/01 20:03:24	1.178
@@ -1204,16 +1204,16 @@
 }
 
 /*
- * Set members of struct vgcreate_params from cmdline.
+ * Set members of struct vgcreate_params from cmdline arguments.
  * Do preliminary validation with arg_*() interface.
  * Further, more generic validation is done in validate_vgcreate_params().
  * This function is to remain in tools directory.
  */
-int fill_vg_create_params(struct cmd_context *cmd,
-			  char *vg_name, struct vgcreate_params *vp_new,
-			  struct vgcreate_params *vp_def)
+int vgcreate_params_set_from_args(struct cmd_context *cmd,
+				  struct vgcreate_params *vp_new,
+				  struct vgcreate_params *vp_def)
 {
-	vp_new->vg_name = skip_dev_dir(cmd, vg_name, NULL);
+	vp_new->vg_name = skip_dev_dir(cmd, vp_def->vg_name, NULL);
 	vp_new->max_lv = arg_uint_value(cmd, maxlogicalvolumes_ARG,
 					vp_def->max_lv);
 	vp_new->max_pv = arg_uint_value(cmd, maxphysicalvolumes_ARG,
--- LVM2/tools/toollib.h	2009/11/01 20:02:32	1.67
+++ LVM2/tools/toollib.h	2009/11/01 20:03:24	1.68
@@ -101,10 +101,9 @@
 
 void vgcreate_params_set_defaults(struct vgcreate_params *vp_def,
 				 struct volume_group *vg);
-int fill_vg_create_params(struct cmd_context *cmd,
-			  char *vg_name, struct vgcreate_params *vp_new,
-			  struct vgcreate_params *vp_def);
-
+int vgcreate_params_set_from_args(struct cmd_context *cmd,
+				  struct vgcreate_params *vp_new,
+				  struct vgcreate_params *vp_def);
 int lv_refresh(struct cmd_context *cmd, struct logical_volume *lv);
 int vg_refresh_visible(struct cmd_context *cmd, struct volume_group *vg);
 void lv_spawn_background_polling(struct cmd_context *cmd,
--- LVM2/tools/vgcreate.c	2009/11/01 20:02:32	1.73
+++ LVM2/tools/vgcreate.c	2009/11/01 20:03:24	1.74
@@ -46,7 +46,8 @@
 	}
 
 	vgcreate_params_set_defaults(&vp_def, NULL);
-	if (fill_vg_create_params(cmd, vg_name, &vp_new, &vp_def))
+	vp_def.vg_name = vg_name;
+	if (vgcreate_params_set_from_args(cmd, &vp_new, &vp_def))
 		return EINVALID_CMD_LINE;
 
 	if (validate_vg_create_params(cmd, &vp_new))
--- LVM2/tools/vgsplit.c	2009/11/01 20:02:32	1.97
+++ LVM2/tools/vgsplit.c	2009/11/01 20:03:24	1.98
@@ -367,7 +367,8 @@
 			goto_bad;
 	} else {
 		vgcreate_params_set_defaults(&vp_def, vg_from);
-		if (fill_vg_create_params(cmd, vg_name_to, &vp_new, &vp_def)) {
+		vp_def.vg_name = vg_name_to;
+		if (vgcreate_params_set_from_args(cmd, &vp_new, &vp_def)) {
 			r = EINVALID_CMD_LINE;
 			goto_bad;
 		}


