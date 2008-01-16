From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 16 Jan 2008 19:54:40 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20080116195440.31609.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-01-16 19:54:39

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	test           : t-vgsplit-operation.sh 
	tools          : toollib.c vgmerge.c vgsplit.c 
Added files:
	test           : t-vgmerge-usage.sh 

Log message:
	Create vgs_are_compatible() fn to check whether vgs are compatible for merging.
	Add new vgmerge and vgsplit tests to check rejection of incompatible vgs.
	Cleanup comments.
	Bugzilla: bz251992
	
	---
	lib/metadata/metadata-exported.h |    3 +
	lib/metadata/metadata.c          |   89 +++++++++++++++++++++++++++++++++-
	test/t-vgmerge-usage.sh          |  101 +++++++++++++++++++++++++++++++++++++++
	test/t-vgsplit-operation.sh      |   20 +++++++
	tools/vgmerge.c                  |   69 --------------------------
	tools/vgsplit.c                  |    5 -
	6 files changed, 215 insertions(+), 72 deletions(-)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.149&r2=1.150
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgmerge-usage.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-operation.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.126&r2=1.127
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46

--- LVM2/lib/metadata/metadata-exported.h	2008/01/16 19:13:51	1.36
+++ LVM2/lib/metadata/metadata-exported.h	2008/01/16 19:54:39	1.37
@@ -317,6 +317,9 @@
 int is_pv(pv_t *pv);
 int is_orphan_vg(const char *vg_name);
 int is_orphan(pv_t *pv);
+int vgs_are_compatible(struct cmd_context *cmd,
+		       struct volume_group *vg_from,
+		       struct volume_group *vg_to);
 vg_t *vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
 		       const char *vgid,
 		       uint32_t lock_flags, uint32_t status_flags,
--- LVM2/lib/metadata/metadata.c	2008/01/16 18:15:26	1.149
+++ LVM2/lib/metadata/metadata.c	2008/01/16 19:54:39	1.150
@@ -429,8 +429,8 @@
 
 /*
  * Validate parameters to vg_create() before calling.
- * FIXME: move this inside the library, maybe inside vg_create
- * - TODO: resolve error codes
+ * FIXME: Move inside vg_create library function.
+ * FIXME: Change vgcreate_params struct to individual gets/sets
  */
 int validate_vg_create_params(struct cmd_context *cmd,
 			      struct vgcreate_params *vp)
@@ -1084,6 +1084,91 @@
 	return 1;
 }
 
+
+/*
+ * Determine whether two vgs are compatible for merging.
+ */
+int vgs_are_compatible(struct cmd_context *cmd,
+		       struct volume_group *vg_from,
+		       struct volume_group *vg_to)
+{
+	struct lv_list *lvl1, *lvl2;
+	struct pv_list *pvl;
+
+	if (lvs_in_vg_activated(vg_from)) {
+		log_error("Logical volumes in \"%s\" must be inactive",
+			  vg_from->name);
+		goto error;
+	}
+
+	/* Check compatibility */
+	if (vg_to->extent_size != vg_from->extent_size) {
+		log_error("Extent sizes differ: %d (%s) and %d (%s)",
+			  vg_to->extent_size, vg_to->name,
+			  vg_from->extent_size, vg_from->name);
+		goto error;
+	}
+
+	if (vg_to->max_pv &&
+	    (vg_to->max_pv < vg_to->pv_count + vg_from->pv_count)) {
+		log_error("Maximum number of physical volumes (%d) exceeded "
+			  " for \"%s\" and \"%s\"", vg_to->max_pv, vg_to->name,
+			  vg_from->name);
+		goto error;
+	}
+
+	if (vg_to->max_lv &&
+	    (vg_to->max_lv < vg_to->lv_count + vg_from->lv_count)) {
+		log_error("Maximum number of logical volumes (%d) exceeded "
+			  " for \"%s\" and \"%s\"", vg_to->max_lv, vg_to->name,
+			  vg_from->name);
+		goto error;
+	}
+
+	/* Check no conflicts with LV names */
+	list_iterate_items(lvl1, &vg_to->lvs) {
+		char *name1 = lvl1->lv->name;
+
+		list_iterate_items(lvl2, &vg_from->lvs) {
+			char *name2 = lvl2->lv->name;
+
+			if (!strcmp(name1, name2)) {
+				log_error("Duplicate logical volume "
+					  "name \"%s\" "
+					  "in \"%s\" and \"%s\"",
+					  name1, vg_to->name, vg_from->name);
+				goto error;
+			}
+		}
+	}
+
+	/* Check no PVs are constructed from either VG */
+	list_iterate_items(pvl, &vg_to->pvs) {
+		if (pv_uses_vg(pvl->pv, vg_from)) {
+			log_error("Physical volume %s might be constructed "
+				  "from same volume group %s.",
+				  pv_dev_name(pvl->pv), vg_from->name);
+			goto error;
+		}
+	}
+
+	list_iterate_items(pvl, &vg_from->pvs) {
+		if (pv_uses_vg(pvl->pv, vg_to)) {
+			log_error("Physical volume %s might be constructed "
+				  "from same volume group %s.",
+				  pv_dev_name(pvl->pv), vg_to->name);
+			goto error;
+		}
+	}
+
+	return 1;
+
+error:
+	return 0;
+}
+
+
+
 int vg_validate(struct volume_group *vg)
 {
 	struct pv_list *pvl, *pvl2;
/cvs/lvm2/LVM2/test/t-vgmerge-usage.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-vgmerge-usage.sh
+++ -	2008-01-16 19:54:39.725157000 +0000
@@ -0,0 +1,101 @@
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
+test_description='Exercise some vgmerge diagnostics'
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
+   vg1=$(this_test_)-test-vg1-$$          &&
+   vg2=$(this_test_)-test-vg2-$$          &&
+   pvcreate $d1 $d2 $d3 $d4'
+
+test_expect_success \
+  'vgmerge normal operation' \
+  'vgcreate $vg1 $d1 $d2 &&
+   vgcreate $vg2 $d3 $d4 &&
+   vgmerge $vg1 $vg2 &&
+   vgremove $vg1'
+
+test_expect_success \
+  'vgmerge rejects duplicate vg name' \
+  'vgcreate $vg1 $d1 $d2 &&
+   vgcreate $vg2 $d3 $d4 &&
+   vgmerge $vg1 $vg1 2>err;
+   status=$?; echo status=$?; test $status = 5 &&
+   grep "^  Duplicate volume group name \"$vg1\"\$" err &&
+   vgremove $vg2 &&
+   vgremove $vg1'
+
+test_expect_success \
+  'vgmerge rejects vgs with incompatible extent_size' \
+  'vgcreate --physicalextentsize 4M $vg1 $d1 $d2 &&
+   vgcreate --physicalextentsize 8M $vg2 $d3 $d4 &&
+   vgmerge $vg1 $vg2 2>err;
+   status=$?; echo status=$?; test $status = 5 &&
+   grep "^  Extent sizes differ" err &&
+   vgremove $vg2 &&
+   vgremove $vg1'
+
+test_expect_success \
+  'vgmerge rejects vgmerge because max_pv is exceeded' \
+  'vgcreate --maxphysicalvolumes 2 $vg1 $d1 $d2 &&
+   vgcreate --maxphysicalvolumes 2 $vg2 $d3 $d4 &&
+   vgmerge $vg1 $vg2 2>err;
+   status=$?; echo status=$?; test $status = 5 &&
+   grep "^  Maximum number of physical volumes (2) exceeded" err &&
+   vgremove $vg2 &&
+   vgremove $vg1'
+
+# FIXME: error with device mapper
+#test_expect_success \
+#  'vgmerge rejects vgmerge because max_lv is exceeded' \
+#  'vgcreate --maxlogicalvolumes 2 $vg1 $d1 $d2 &&
+#   vgcreate --maxlogicalvolumes 2 $vg2 $d3 $d4 &&
+#   lvcreate -l 4 -n lv1 $vg1 &&
+#   lvcreate -l 4 -n lv2 $vg1 &&
+#   lvcreate -l 4 -n lv3 $vg2 &&
+#   vgmerge $vg1 $vg2 2>err;
+#   status=$?; echo status=$?; test $status = 5 &&
+#   grep "^  Maximum number of logical volumes (2) exceeded" err &&
+#   vgremove $vg2 &&
+#   vgremove $vg1'
+
+#test_expect_success \
+#  'vgmerge rejects vg with active lv' \
+#  'vgcreate $vg1 $d1 $d2 &&
+#   vgcreate $vg2 $d3 $d4 &&
+#   lvcreate -l 64 -n lv1 $vg1 &&
+#   vgmerge $vg1 $vg1 2>err;
+#   status=$?; echo status=$?; test $status = 5 &&
+#   grep "^  Logical volumes in \"$vg1\" must be inactive\$" err &&
+#   vgremove -f $vg2 &&
+#   vgremove -f $vg1'
+
+test_done
+# Local Variables:
+# indent-tabs-mode: nil
+# End:
--- LVM2/test/t-vgsplit-operation.sh	2008/01/14 21:07:58	1.2
+++ LVM2/test/t-vgsplit-operation.sh	2008/01/16 19:54:39	1.3
@@ -78,6 +78,26 @@
    vgremove $vg1 &&
    vgremove $vg2'
 
+test_expect_success \
+  'vgsplit rejects vgs with incompatible extent_size' \
+  'vgcreate --physicalextentsize 4M $vg1 $d1 $d2 &&
+   vgcreate --physicalextentsize 8M $vg2 $d3 $d4 &&
+   vgsplit $vg1 $vg2 $d1 2>err;
+   status=$?; echo status=$?; test $status = 5 &&
+   grep "^  Extent sizes differ" err &&
+   vgremove $vg2 &&
+   vgremove $vg1'
+
+test_expect_success \
+  'vgsplit rejects split because max_pv of destination would be exceeded' \
+  'vgcreate --maxphysicalvolumes 2 $vg1 $d1 $d2 &&
+   vgcreate --maxphysicalvolumes 2 $vg2 $d3 $d4 &&
+   vgsplit $vg1 $vg2 $d1 2>err;
+   status=$?; echo status=$?; test $status = 5 &&
+   grep "^  Maximum number of physical volumes (2) exceeded" err &&
+   vgremove $vg2 &&
+   vgremove $vg1'
+
 test_done
 # Local Variables:
 # indent-tabs-mode: nil
--- LVM2/tools/toollib.c	2008/01/16 18:15:26	1.126
+++ LVM2/tools/toollib.c	2008/01/16 19:54:39	1.127
@@ -1247,8 +1247,7 @@
  * Set members of struct vgcreate_params from cmdline.
  * Do preliminary validation with arg_*() interface.
  * Further, more generic validation is done in validate_vgcreate_params().
- * This function is to remain in tools directory, while
- * validate_vgcreate_params() will be moved into the LVM library.
+ * This function is to remain in tools directory.
  */
 int fill_vg_create_params(struct cmd_context *cmd,
 			  char *vg_name, struct vgcreate_params *vp_new,
--- LVM2/tools/vgmerge.c	2007/11/15 02:20:03	1.42
+++ LVM2/tools/vgmerge.c	2008/01/16 19:54:39	1.43
@@ -20,8 +20,6 @@
 {
 	struct volume_group *vg_to, *vg_from;
 	struct lv_list *lvl1, *lvl2;
-	struct pv_list *pvl;
-	int active;
 
 	if (!strcmp(vg_name_to, vg_name_from)) {
 		log_error("Duplicate volume group name \"%s\"", vg_name_from);
@@ -43,71 +41,8 @@
 		return ECMD_FAILED;
 	}
 
-	if ((active = lvs_in_vg_activated(vg_from))) {
-		log_error("Logical volumes in \"%s\" must be inactive",
-			  vg_name_from);
-		goto error;
-	}
-
-	/* Check compatibility */
-	if (vg_to->extent_size != vg_from->extent_size) {
-		log_error("Extent sizes differ: %d (%s) and %d (%s)",
-			  vg_to->extent_size, vg_to->name,
-			  vg_from->extent_size, vg_from->name);
-		goto error;
-	}
-
-	if (vg_to->max_pv &&
-	    (vg_to->max_pv < vg_to->pv_count + vg_from->pv_count)) {
-		log_error("Maximum number of physical volumes (%d) exceeded "
-			  " for \"%s\" and \"%s\"", vg_to->max_pv, vg_to->name,
-			  vg_from->name);
-		goto error;
-	}
-
-	if (vg_to->max_lv &&
-	    (vg_to->max_lv < vg_to->lv_count + vg_from->lv_count)) {
-		log_error("Maximum number of logical volumes (%d) exceeded "
-			  " for \"%s\" and \"%s\"", vg_to->max_lv, vg_to->name,
-			  vg_from->name);
-		goto error;
-	}
-
-	/* Check no conflicts with LV names */
-	list_iterate_items(lvl1, &vg_to->lvs) {
-		char *name1 = lvl1->lv->name;
-
-		list_iterate_items(lvl2, &vg_from->lvs) {
-			char *name2 = lvl2->lv->name;
-
-			if (!strcmp(name1, name2)) {
-				log_error("Duplicate logical volume "
-					  "name \"%s\" "
-					  "in \"%s\" and \"%s\"",
-					  name1, vg_to->name, vg_from->name);
-				goto error;
-			}
-		}
-	}
-
-	/* Check no PVs are constructed from either VG */
-	list_iterate_items(pvl, &vg_to->pvs) {
-		if (pv_uses_vg(pvl->pv, vg_from)) {
-			log_error("Physical volume %s might be constructed "
-				  "from same volume group %s.",
-				  pv_dev_name(pvl->pv), vg_from->name);
-			goto error;
-		}
-	}
-
-	list_iterate_items(pvl, &vg_from->pvs) {
-		if (pv_uses_vg(pvl->pv, vg_to)) {
-			log_error("Physical volume %s might be constructed "
-				  "from same volume group %s.",
-				  pv_dev_name(pvl->pv), vg_to->name);
-			goto error;
-		}
-	}
+	if (!vgs_are_compatible(cmd, vg_from, vg_to))
+	    goto error;
 
 	/* FIXME List arg: vg_show_with_pv_and_lv(vg_to); */
 
--- LVM2/tools/vgsplit.c	2008/01/15 22:56:30	1.45
+++ LVM2/tools/vgsplit.c	2008/01/16 19:54:39	1.46
@@ -254,7 +254,8 @@
 				      LCK_VG_WRITE | LCK_NONBLOCK,
 				      0, 0))) {
 		log_warn("Volume group \"%s\" already exists", vg_name_to);
-		/* FIXME: check compatibility with existing vg, esp attribs */
+		if (!vgs_are_compatible(cmd, vg_from,vg_to))
+			goto error;
 	} else {
 
 		/* Set metadata format of original VG */
@@ -274,8 +275,6 @@
 		if (validate_vg_create_params(cmd, &vp_new))
 			return EINVALID_CMD_LINE;
 
-		/* Create new VG structure */
-		/* FIXME: allow user input same params as to vgcreate tool */
 		if (!(vg_to = vg_create(cmd, vg_name_to, vp_new.extent_size,
 					vp_new.max_pv, vp_new.max_lv,
 					vp_new.alloc, 0, NULL)))


