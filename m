From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 1 Nov 2009 19:51:56 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20091101195156.24908.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-11-01 19:51:55

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	liblvm         : lvm_vg.c 
	tools          : pvcreate.c toollib.c toollib.h vgcreate.c 
	                 vgextend.c 

Log message:
	Rename pvcreate_params processing functions to better match <object><action>.
	
	Rename fill_default_pvcreate_params to pvcreate_params_set_defaults.
	Rename pvcreate_validate_restore_params to pvcreate_restore_params_validate.
	Rename pvcreate_validate_params to pvcreate_params_validate.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.119&r2=1.120
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.293&r2=1.294
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.87&r2=1.88
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.175&r2=1.176
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55

--- LVM2/lib/metadata/metadata-exported.h	2009/10/31 17:30:52	1.119
+++ LVM2/lib/metadata/metadata-exported.h	2009/11/01 19:51:54	1.120
@@ -372,7 +372,7 @@
 struct physical_volume *pvcreate_single(struct cmd_context *cmd,
 					const char *pv_name,
 					struct pvcreate_params *pp);
-void fill_default_pvcreate_params(struct pvcreate_params *pp);
+void pvcreate_params_set_defaults(struct pvcreate_params *pp);
 
 /*
 * Utility functions
--- LVM2/lib/metadata/metadata.c	2009/10/31 17:30:52	1.293
+++ LVM2/lib/metadata/metadata.c	2009/11/01 19:51:54	1.294
@@ -1314,7 +1314,7 @@
 	return 1;
 }
 
-void fill_default_pvcreate_params(struct pvcreate_params *pp)
+void pvcreate_params_set_defaults(struct pvcreate_params *pp)
 {
 	memset(pp, 0, sizeof(*pp));
 	pp->zero = 1;
@@ -1354,7 +1354,7 @@
 	struct pvcreate_params default_pp;
 	char buffer[64] __attribute((aligned(8)));
 
-	fill_default_pvcreate_params(&default_pp);
+	pvcreate_params_set_defaults(&default_pp);
 	if (!pp)
 		pp = &default_pp;
 
--- LVM2/liblvm/lvm_vg.c	2009/10/05 20:03:08	1.32
+++ LVM2/liblvm/lvm_vg.c	2009/11/01 19:51:55	1.33
@@ -54,7 +54,7 @@
 		return -1;
 	}
 
-	fill_default_pvcreate_params(&pp);
+	pvcreate_params_set_defaults(&pp);
 	if (!vg_extend(vg, 1, (char **) &device, &pp)) {
 		unlock_vg(vg->cmd, VG_ORPHANS);
 		return -1;
--- LVM2/tools/pvcreate.c	2009/10/05 20:03:54	1.87
+++ LVM2/tools/pvcreate.c	2009/11/01 19:51:55	1.88
@@ -23,7 +23,7 @@
  * Output arguments:
  * pp: structure allocated by caller, fields written / validated here
  */
-static int pvcreate_validate_restore_params(struct cmd_context *cmd,
+static int pvcreate_restore_params_validate(struct cmd_context *cmd,
 					    int argc, char **argv,
 					    struct pvcreate_params *pp)
 {
@@ -84,12 +84,12 @@
 	int ret = ECMD_PROCESSED;
 	struct pvcreate_params pp;
 
-	fill_default_pvcreate_params(&pp);
+	pvcreate_params_set_defaults(&pp);
 
-	if (!pvcreate_validate_restore_params(cmd, argc, argv, &pp)) {
+	if (!pvcreate_restore_params_validate(cmd, argc, argv, &pp)) {
 		return EINVALID_CMD_LINE;
 	}
-	if (!pvcreate_validate_params(cmd, argc, argv, &pp)) {
+	if (!pvcreate_params_validate(cmd, argc, argv, &pp)) {
 		return EINVALID_CMD_LINE;
 	}
 
--- LVM2/tools/toollib.c	2009/10/06 16:00:38	1.175
+++ LVM2/tools/toollib.c	2009/11/01 19:51:55	1.176
@@ -1278,7 +1278,7 @@
  * Output arguments:
  * pp: structure allocated by caller, fields written / validated here
  */
-int pvcreate_validate_params(struct cmd_context *cmd,
+int pvcreate_params_validate(struct cmd_context *cmd,
 			     int argc, char **argv,
 			     struct pvcreate_params *pp)
 {
--- LVM2/tools/toollib.h	2009/10/05 20:03:55	1.65
+++ LVM2/tools/toollib.h	2009/11/01 19:51:55	1.66
@@ -107,7 +107,7 @@
 int vg_refresh_visible(struct cmd_context *cmd, struct volume_group *vg);
 void lv_spawn_background_polling(struct cmd_context *cmd,
 				 struct logical_volume *lv);
-int pvcreate_validate_params(struct cmd_context *cmd,
+int pvcreate_params_validate(struct cmd_context *cmd,
 			     int argc, char **argv,
 			     struct pvcreate_params *pp);
 
--- LVM2/tools/vgcreate.c	2009/10/31 17:39:22	1.71
+++ LVM2/tools/vgcreate.c	2009/11/01 19:51:55	1.72
@@ -40,8 +40,8 @@
 			  "use --pvmetadatacopies instead.");
 		return EINVALID_CMD_LINE;
 	}
-	fill_default_pvcreate_params(&pp);
-	if (!pvcreate_validate_params(cmd, argc, argv, &pp)) {
+	pvcreate_params_set_defaults(&pp);
+	if (!pvcreate_params_validate(cmd, argc, argv, &pp)) {
 		return EINVALID_CMD_LINE;
 	}
 
--- LVM2/tools/vgextend.c	2009/10/05 20:55:57	1.54
+++ LVM2/tools/vgextend.c	2009/11/01 19:51:55	1.55
@@ -37,8 +37,8 @@
 			  "use --pvmetadatacopies instead.");
 		return EINVALID_CMD_LINE;
 	}
-	fill_default_pvcreate_params(&pp);
-	if (!pvcreate_validate_params(cmd, argc, argv, &pp)) {
+	pvcreate_params_set_defaults(&pp);
+	if (!pvcreate_params_validate(cmd, argc, argv, &pp)) {
 		return EINVALID_CMD_LINE;
 	}
 


