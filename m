From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 15 Jan 2008 22:56:31 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20080115225631.20712.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-01-15 22:56:30

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	tools          : toollib.c toollib.h vgcreate.c vgrename.c 
	                 vgsplit.c 
Added files:
	test           : t-vgrename-usage.sh 

Log message:
	Move more parameter validation into the library.
	Update vgrename to call validate_vg_rename_params().
	Fix vgcreate and vgsplit default arguments by adding defaults parameter to
	fill_vg_create_params().
	Add t-vgrename-usage.sh test.
	Bugzilla: bz251992
	---
	tools/toollib.c  |   32 ++++++++------------------------
	tools/toollib.h  |    5 ++---
	tools/vgcreate.c |   35 +++++++++++++++++++++--------------
	tools/vgrename.c |   35 ++++++-----------------------------
	tools/vgsplit.c  |   21 ++++++++++++++-------
	5 files changed, 51 insertions(+), 77 deletions(-)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.147&r2=1.148
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgrename-usage.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.124&r2=1.125
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45

--- LVM2/lib/metadata/metadata-exported.h	2008/01/14 21:07:58	1.32
+++ LVM2/lib/metadata/metadata-exported.h	2008/01/15 22:56:30	1.33
@@ -540,4 +540,7 @@
 int validate_vg_create_params(struct cmd_context *cmd,
 			      struct vgcreate_params *vp);
 
+int validate_vg_rename_params(struct cmd_context *cmd,
+			      const char *vg_name_old,
+			      const char *vg_name_new);
 #endif
--- LVM2/lib/metadata/metadata.c	2008/01/14 21:07:58	1.147
+++ LVM2/lib/metadata/metadata.c	2008/01/15 22:56:30	1.148
@@ -18,6 +18,7 @@
 #include "metadata.h"
 #include "toolcontext.h"
 #include "lvm-string.h"
+#include "lvm-file.h"
 #include "lvmcache.h"
 #include "memlock.h"
 #include "str_list.h"
@@ -227,6 +228,54 @@
 	return 0;
 }
 
+static int validate_new_vg_name(struct cmd_context *cmd, const char *vg_name)
+{
+	char vg_path[PATH_MAX];
+
+	if (!validate_name(vg_name))
+		return 0;
+
+	snprintf(vg_path, PATH_MAX, "%s%s", cmd->dev_dir, vg_name);
+	if (path_exists(vg_path)) {
+		log_error("%s: already exists in filesystem", vg_path);
+		return 0;
+	}
+
+	return 1;
+}
+
+
+int validate_vg_rename_params(struct cmd_context *cmd,
+			      const char *vg_name_old,
+			      const char *vg_name_new)
+{
+	unsigned length;
+	char *dev_dir;
+
+	dev_dir = cmd->dev_dir;
+	length = strlen(dev_dir);
+
+	/* Check sanity of new name */
+	if (strlen(vg_name_new) > NAME_LEN - length - 2) {
+		log_error("New volume group path exceeds maximum length "
+			  "of %d!", NAME_LEN - length - 2);
+		return 0;
+	}
+
+	if (!validate_new_vg_name(cmd, vg_name_new)) {
+		log_error("New volume group name \"%s\" is invalid",
+			  vg_name_new);
+		return 0;
+	}
+
+	if (!strcmp(vg_name_old, vg_name_new)) {
+		log_error("Old and new volume group names must differ");
+		return 0;
+	}
+
+	return 1;
+}
+
 int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name)
 {
/cvs/lvm2/LVM2/test/t-vgrename-usage.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-vgrename-usage.sh
+++ -	2008-01-15 22:56:31.402467000 +0000
@@ -0,0 +1,46 @@
+#!/bin/sh
+# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Exercise some vgrename diagnostics'
+privileges_required_=1
+
+. ./test-lib.sh
+
+cleanup_()
+{
+  test -n "$d1" && losetup -d "$d1"
+  test -n "$d2" && losetup -d "$d2"
+  test -n "$d3" && losetup -d "$d3"
+  test -n "$d4" && losetup -d "$d4"
+  rm -f "$f1" "$f2" "$f3" "$f4"
+}
+
+test_expect_success \
+  'set up temp files, loopback devices, PVs, vgnames' \
+  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
+   f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
+   f3=$(pwd)/3 && d3=$(loop_setup_ "$f3") &&
+   f4=$(pwd)/4 && d4=$(loop_setup_ "$f4") &&
+   vg1=$(this_test_)-1-$$          &&
+   vg2=$(this_test_)-2-$$          &&
+   pvcreate $d1 $d2 $d3 $d4'
+
+test_expect_success \
+  'vgrename normal operation - rename vg1 to vg2' \
+  'vgcreate $vg1 $d1 $d2 &&
+   vgrename $vg1 $vg2 &&
+   check_vg_field_ $vg2 vg_name $vg2 &&
+   vgremove $vg2'
+
+test_done
+# Local Variables:
+# indent-tabs-mode: nil
+# End:
--- LVM2/tools/toollib.c	2008/01/14 21:07:58	1.124
+++ LVM2/tools/toollib.c	2008/01/15 22:56:30	1.125
@@ -1218,23 +1218,6 @@
 	return 1;
 }
 
-int validate_new_vg_name(struct cmd_context *cmd, const char *vg_name)
-{
-	char vg_path[PATH_MAX];
-
-	if (!validate_name(vg_name))
-		return 0;
-
-	snprintf(vg_path, PATH_MAX, "%s%s", cmd->dev_dir, vg_name);
-	if (path_exists(vg_path)) {
-		log_error("%s: already exists in filesystem", vg_path);
-		return 0;
-	}
-
-	return 1;
-}
-
-
 /*
  * Set members of struct vgcreate_params from cmdline.
  * Do preliminary validation with arg_*() interface.
@@ -1243,23 +1226,27 @@
  * validate_vgcreate_params() will be moved into the LVM library.
  */
 int fill_vg_create_params(struct cmd_context *cmd,
-			  char *vg_name, struct vgcreate_params *vp)
+			  char *vg_name, struct vgcreate_params *vp_new,
+			  struct vgcreate_params *vp_def)
 {
-	vp->vg_name = skip_dev_dir(cmd, vg_name, NULL);
-	vp->max_lv = arg_uint_value(cmd, maxlogicalvolumes_ARG, 0);
-	vp->max_pv = arg_uint_value(cmd, maxphysicalvolumes_ARG, 0);
-	vp->alloc = arg_uint_value(cmd, alloc_ARG, ALLOC_NORMAL);
+	vp_new->vg_name = skip_dev_dir(cmd, vg_name, NULL);
+	vp_new->max_lv = arg_uint_value(cmd, maxlogicalvolumes_ARG,
+					vp_def->max_lv);
+	vp_new->max_pv = arg_uint_value(cmd, maxphysicalvolumes_ARG,
+					vp_def->max_pv);
+	vp_new->alloc = arg_uint_value(cmd, alloc_ARG, vp_def->alloc);
 
 	/* Units of 512-byte sectors */
-	vp->extent_size =
-	    arg_uint_value(cmd, physicalextentsize_ARG, DEFAULT_PE_SIZE);
+	vp_new->extent_size =
+	    arg_uint_value(cmd, physicalextentsize_ARG, vp_def->extent_size);
 
 	if (arg_count(cmd, clustered_ARG))
-        	vp->clustered =
-			!strcmp(arg_str_value(cmd, clustered_ARG, "n"), "y");
+        	vp_new->clustered =
+			!strcmp(arg_str_value(cmd, clustered_ARG,
+					      vp_def->clustered ? "y":"n"), "y");
 	else
 		/* Default depends on current locking type */
-		vp->clustered = locking_is_clustered();
+		vp_new->clustered = locking_is_clustered();
 
 	if (arg_sign_value(cmd, physicalextentsize_ARG, 0) == SIGN_MINUS) {
 		log_error("Physical extent size may not be negative");
@@ -1278,4 +1265,3 @@
 
 	return 0;
 }
-
--- LVM2/tools/toollib.h	2008/01/14 21:07:58	1.55
+++ LVM2/tools/toollib.h	2008/01/15 22:56:30	1.56
@@ -96,8 +96,7 @@
 
 int apply_lvname_restrictions(const char *name);
 
-int validate_new_vg_name(struct cmd_context *cmd, const char *vg_name);
-
 int fill_vg_create_params(struct cmd_context *cmd,
-			  char *vg_name, struct vgcreate_params *vp);
+			  char *vg_name, struct vgcreate_params *vp_new,
+			  struct vgcreate_params *vp_def);
 #endif
--- LVM2/tools/vgcreate.c	2008/01/14 21:07:58	1.54
+++ LVM2/tools/vgcreate.c	2008/01/15 22:56:30	1.55
@@ -17,7 +17,8 @@
 
 int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 {
-	struct vgcreate_params vp;
+	struct vgcreate_params vp_new;
+	struct vgcreate_params vp_def;
 	struct volume_group *vg;
 	const char *tag;
 
@@ -32,23 +33,29 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	if (fill_vg_create_params(cmd, argv[0], &vp))
+	vp_def.vg_name = NULL;
+	vp_def.extent_size = DEFAULT_PE_SIZE;
+	vp_def.max_pv = 0;
+	vp_def.max_lv = 0;
+	vp_def.alloc = ALLOC_NORMAL;
+	vp_def.clustered = 0;
+	if (fill_vg_create_params(cmd, argv[0], &vp_new, &vp_def))
 		return EINVALID_CMD_LINE;
 
-	if (validate_vg_create_params(cmd, &vp))
+	if (validate_vg_create_params(cmd, &vp_new))
 	    return EINVALID_CMD_LINE;
 
 	/* Create the new VG */
-	if (!(vg = vg_create(cmd, vp.vg_name, vp.extent_size, vp.max_pv,
-			     vp.max_lv, vp.alloc,
+	if (!(vg = vg_create(cmd, vp_new.vg_name, vp_new.extent_size,
+			     vp_new.max_pv, vp_new.max_lv, vp_new.alloc,
 			     argc - 1, argv + 1)))
 		return ECMD_FAILED;
 
-	if (vp.max_lv != vg->max_lv)
+	if (vp_new.max_lv != vg->max_lv)
 		log_warn("WARNING: Setting maxlogicalvolumes to %d "
 			 "(0 means unlimited)", vg->max_lv);
 
-	if (vp.max_pv != vg->max_pv)
+	if (vp_new.max_pv != vg->max_pv)
 		log_warn("WARNING: Setting maxphysicalvolumes to %d "
 			 "(0 means unlimited)", vg->max_pv);
 
@@ -65,13 +72,13 @@
 
 		if (!str_list_add(cmd->mem, &vg->tags, tag)) {
 			log_error("Failed to add tag %s to volume group %s",
-				  tag, vp.vg_name);
+				  tag, vp_new.vg_name);
 			return ECMD_FAILED;
 		}
 	}
 
 	/* FIXME: move this inside vg_create? */
-	if (vp.clustered)
+	if (vp_new.clustered)
 		vg->status |= CLUSTERED;
 	else
 		vg->status &= ~CLUSTERED;
@@ -81,26 +88,26 @@
 		return ECMD_FAILED;
 	}
 
-	if (!lock_vol(cmd, vp.vg_name, LCK_VG_WRITE | LCK_NONBLOCK)) {
-		log_error("Can't get lock for %s", vp.vg_name);
+	if (!lock_vol(cmd, vp_new.vg_name, LCK_VG_WRITE | LCK_NONBLOCK)) {
+		log_error("Can't get lock for %s", vp_new.vg_name);
 		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
 	}
 
 	if (!archive(vg)) {
-		unlock_vg(cmd, vp.vg_name);
+		unlock_vg(cmd, vp_new.vg_name);
 		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
 	}
 
 	/* Store VG on disk(s) */
 	if (!vg_write(vg) || !vg_commit(vg)) {
-		unlock_vg(cmd, vp.vg_name);
+		unlock_vg(cmd, vp_new.vg_name);
 		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
 	}
 
-	unlock_vg(cmd, vp.vg_name);
+	unlock_vg(cmd, vp_new.vg_name);
 	unlock_vg(cmd, VG_ORPHANS);
 
 	backup(vg);
--- LVM2/tools/vgrename.c	2007/11/02 20:40:05	1.48
+++ LVM2/tools/vgrename.c	2008/01/15 22:56:30	1.49
@@ -19,7 +19,6 @@
 			  const char *new_vg_path)
 {
 	char *dev_dir;
-	unsigned length;
 	struct id id;
 	int consistent = 1;
 	int match = 0;
@@ -35,25 +34,9 @@
 	vg_name_new = skip_dev_dir(cmd, new_vg_path, NULL);
 
 	dev_dir = cmd->dev_dir;
-	length = strlen(dev_dir);
 
-	/* Check sanity of new name */
-	if (strlen(vg_name_new) > NAME_LEN - length - 2) {
-		log_error("New volume group path exceeds maximum length "
-			  "of %d!", NAME_LEN - length - 2);
+	if (!validate_vg_rename_params(cmd, vg_name_old, vg_name_new))
 		return 0;
-	}
-
-	if (!validate_new_vg_name(cmd, vg_name_new)) {
-		log_error("New volume group name \"%s\" is invalid",
-			  vg_name_new);
-		return 0;
-	}
-
-	if (!strcmp(vg_name_old, vg_name_new)) {
-		log_error("Old and new volume group names must differ");
-		return 0;
-	}
 
 	log_verbose("Checking for existing volume group \"%s\"", vg_name_old);
 
--- LVM2/tools/vgsplit.c	2008/01/14 21:07:58	1.44
+++ LVM2/tools/vgsplit.c	2008/01/15 22:56:30	1.45
@@ -212,7 +212,8 @@
 
 int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 {
-	struct vgcreate_params vp;
+	struct vgcreate_params vp_new;
+	struct vgcreate_params vp_def;
 	char *vg_name_from, *vg_name_to;
 	struct volume_group *vg_to, *vg_from;
 	int opt;
@@ -260,18 +261,24 @@
 		/* FIXME: need some common logic */
 		cmd->fmt = vg_from->fid->fmt;
 
-		/* FIXME: original code took defaults from vg_from */
-		if (fill_vg_create_params(cmd, vg_name_to, &vp))
+		vp_def.vg_name = NULL;
+		vp_def.extent_size = vg_from->extent_size;
+		vp_def.max_pv = vg_from->max_pv;
+		vp_def.max_lv = vg_from->max_lv;
+		vp_def.alloc = vg_from->alloc;
+		vp_def.clustered = 0;
+
+		if (fill_vg_create_params(cmd, vg_name_to, &vp_new, &vp_def))
 			return EINVALID_CMD_LINE;
 
-		if (validate_vg_create_params(cmd, &vp))
+		if (validate_vg_create_params(cmd, &vp_new))
 			return EINVALID_CMD_LINE;
 
 		/* Create new VG structure */
 		/* FIXME: allow user input same params as to vgcreate tool */
-		if (!(vg_to = vg_create(cmd, vg_name_to, vp.extent_size,
-					vp.max_pv, vp.max_lv,
-					vp.alloc, 0, NULL)))
+		if (!(vg_to = vg_create(cmd, vg_name_to, vp_new.extent_size,
+					vp_new.max_pv, vp_new.max_lv,
+					vp_new.alloc, 0, NULL)))
 			goto error;
 
 		if (vg_from->status & CLUSTERED)


