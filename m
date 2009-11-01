From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 1 Nov 2009 20:05:18 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20091101200518.17600.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-11-01 20:05:17

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : vgcreate.c vgsplit.c 

Log message:
	Rename validate_vg_create_params to vgcreate_params_validate.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.120&r2=1.121
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.294&r2=1.295
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.98&r2=1.99

--- LVM2/lib/metadata/metadata-exported.h	2009/11/01 19:51:54	1.120
+++ LVM2/lib/metadata/metadata-exported.h	2009/11/01 20:05:17	1.121
@@ -749,8 +749,8 @@
 	int clustered; /* FIXME: put this into a 'status' variable instead? */
 };
 
-int validate_vg_create_params(struct cmd_context *cmd,
-			      struct vgcreate_params *vp);
+int vgcreate_params_validate(struct cmd_context *cmd,
+			     struct vgcreate_params *vp);
 
 int validate_vg_rename_params(struct cmd_context *cmd,
 			      const char *vg_name_old,
--- LVM2/lib/metadata/metadata.c	2009/11/01 19:51:54	1.294
+++ LVM2/lib/metadata/metadata.c	2009/11/01 20:05:17	1.295
@@ -679,8 +679,8 @@
  * FIXME: Move inside vg_create library function.
  * FIXME: Change vgcreate_params struct to individual gets/sets
  */
-int validate_vg_create_params(struct cmd_context *cmd,
-			      struct vgcreate_params *vp)
+int vgcreate_params_validate(struct cmd_context *cmd,
+			     struct vgcreate_params *vp)
 {
 	if (!validate_new_vg_name(cmd, vp->vg_name)) {
 		log_error("New volume group name \"%s\" is invalid",
--- LVM2/tools/vgcreate.c	2009/11/01 20:03:24	1.74
+++ LVM2/tools/vgcreate.c	2009/11/01 20:05:17	1.75
@@ -50,7 +50,7 @@
 	if (vgcreate_params_set_from_args(cmd, &vp_new, &vp_def))
 		return EINVALID_CMD_LINE;
 
-	if (validate_vg_create_params(cmd, &vp_new))
+	if (vgcreate_params_validate(cmd, &vp_new))
 	    return EINVALID_CMD_LINE;
 
 	/* Create the new VG */
--- LVM2/tools/vgsplit.c	2009/11/01 20:03:24	1.98
+++ LVM2/tools/vgsplit.c	2009/11/01 20:05:17	1.99
@@ -373,7 +373,7 @@
 			goto_bad;
 		}
 
-		if (validate_vg_create_params(cmd, &vp_new)) {
+		if (vgcreate_params_validate(cmd, &vp_new)) {
 			r = EINVALID_CMD_LINE;
 			goto_bad;
 		}


