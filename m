From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 11 Jan 2008 07:02:35 -0000
Subject: LVM2 ./WHATS_NEW tools/vgcreate.c test/t-vgcre ...
Message-ID: <20080111070235.17096.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-01-11 07:02:35

Modified files:
	.              : WHATS_NEW 
	tools          : vgcreate.c 
Added files:
	test           : t-vgcreate-usage.sh 

Log message:
	Refactor vgcreate for parameter validation and add tests

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.757&r2=1.758
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgcreate-usage.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

--- LVM2/WHATS_NEW	2008/01/10 22:21:44	1.757
+++ LVM2/WHATS_NEW	2008/01/11 07:02:34	1.758
@@ -1,5 +1,6 @@
 Version 2.02.30 -
 ===================================
+  Refactor vgcreate for parameter validation and add tests.
   Add new convert_lv field to lvs output.
   Print warning when lvm tools are running as non-root.
   Add snapshot dmeventd library (enables dmeventd snapshot monitoring).
--- LVM2/tools/vgcreate.c	2007/11/14 00:08:25	1.52
+++ LVM2/tools/vgcreate.c	2008/01/11 07:02:34	1.53
@@ -17,6 +17,43 @@
 
 #define DEFAULT_EXTENT 4096	/* In KB */
 
+static int validate_vg_create_params(struct cmd_context *cmd,
+				     const char *vg_name,
+				     const uint32_t extent_size,
+				     size_t *max_pv,
+				     size_t *max_lv,
+				     const alloc_policy_t alloc)
+{
+	if (!validate_new_vg_name(cmd, vg_name)) {
+		log_error("New volume group name \"%s\" is invalid", vg_name);
+		return 0;
+	}
+
+	if (alloc == ALLOC_INHERIT) {
+		log_error("Volume Group allocation policy cannot inherit "
+			  "from anything");
+		return 0;
+	}
+
+	if (!extent_size) {
+		log_error("Physical extent size may not be zero");
+		return 0;
+	}
+
+	if (!(cmd->fmt->features & FMT_UNLIMITED_VOLS)) {
+		if (!*max_lv)
+			*max_lv = 255;
+		if (!*max_pv)
+			*max_pv = 255;
+		if (*max_lv > 255 || *max_pv > 255) {
+			log_error("Number of volumes may not exceed 255");
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
 int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 {
 	size_t max_lv, max_pv;
@@ -43,23 +80,6 @@
 	max_pv = arg_uint_value(cmd, maxphysicalvolumes_ARG, 0);
 	alloc = arg_uint_value(cmd, alloc_ARG, ALLOC_NORMAL);
 
-	if (alloc == ALLOC_INHERIT) {
-		log_error("Volume Group allocation policy cannot inherit "
-			  "from anything");
-		return EINVALID_CMD_LINE;
-	}
-
-	if (!(cmd->fmt->features & FMT_UNLIMITED_VOLS)) {
-		if (!max_lv)
-			max_lv = 255;
-		if (!max_pv)
-			max_pv = 255;
-		if (max_lv > 255 || max_pv > 255) {
-			log_error("Number of volumes may not exceed 255");
-			return EINVALID_CMD_LINE;
-		}
-	}
-
 	if (arg_sign_value(cmd, physicalextentsize_ARG, 0) == SIGN_MINUS) {
 		log_error("Physical extent size may not be negative");
 		return EINVALID_CMD_LINE;
@@ -79,15 +99,9 @@
 	extent_size =
 	    arg_uint_value(cmd, physicalextentsize_ARG, DEFAULT_EXTENT);
 
-	if (!extent_size) {
-		log_error("Physical extent size may not be zero");
-		return EINVALID_CMD_LINE;
-	}
-
-	if (!validate_new_vg_name(cmd, vg_name)) {
-		log_error("New volume group name \"%s\" is invalid", vg_name);
-		return ECMD_FAILED;
-	}
+	if (!validate_vg_create_params(cmd, vg_name, extent_size,
+				       &max_pv, &max_lv, alloc))
+	    return EINVALID_CMD_LINE;
 
 	/* Create the new VG */
 	if (!(vg = vg_create(cmd, vg_name, extent_size, max_pv, max_lv, alloc,
/cvs/lvm2/LVM2/test/t-vgcreate-usage.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-vgcreate-usage.sh
+++ -	2008-01-11 07:02:35.770804000 +0000
@@ -0,0 +1,75 @@
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
+test_description='Exercise some vgcreate diagnostics'
+privileges_required_=1
+
+. ./test-lib.sh
+
+cleanup_()
+{
+  test -n "$d1" && losetup -d "$d1"
+  test -n "$d2" && losetup -d "$d2"
+  rm -f "$f1" "$f2"
+}
+
+test_expect_success \
+  'set up temp files, loopback devices, PVs, vgname' \
+  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
+   f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
+   vg=$(this_test_)-test-vg-$$            &&
+   pvcreate $d1 $d2'
+
+lv=vgcreate-usage-$$
+
+test_expect_success \
+  'vgcreate rejects a zero physical extent size' \
+  'vgcreate --physicalextentsize 0 $vg $d1 $d2 2>err;
+   status=$?; echo status=$?; test $status = 3 &&
+   grep "^  Physical extent size may not be zero\$" err'
+
+test_expect_success \
+  'vgcreate rejects "inherit" allocation policy' \
+  'vgcreate --alloc inherit $vg $d1 $d2 2>err;
+   status=$?; echo status=$?; test $status = 3 &&
+   grep "^  Volume Group allocation policy cannot inherit from anything\$" err'
+
+test_expect_success \
+  'vgcreate rejects vgname "."' \
+  'vg=.; vgcreate $vg $d1 $d2 2>err;
+   status=$?; echo status=$?; test $status = 3 &&
+   grep "New volume group name \"$vg\" is invalid\$" err'
+
+test_expect_success \
+  'vgcreate rejects vgname greater than 128 characters' \
+  'vg=thisnameisridiculouslylongtotestvalidationcodecheckingmaximumsizethisiswhathappenswhenprogrammersgetboredandorarenotcreativedonttrythisathome;
+   vgcreate $vg $d1 $d2 2>err;
+   status=$?; echo status=$?; test $status = 3 &&
+   grep "New volume group name \"$vg\" is invalid\$" err'
+
+test_expect_success \
+  'vgcreate rejects already existing vgname "/dev/fd0"' \
+  'vg=/dev/fd0; vgcreate $vg $d1 $d2 2>err;
+   status=$?; echo status=$?; test $status = 3 &&
+   grep "New volume group name \"$vg\" is invalid\$" err'
+
+# FIXME: Not sure why this fails
+#test_expect_success \
+#  'vgcreate rejects MaxLogicalVolumes > 255' \
+#  'vgcreate --metadatatype 1 --maxlogicalvolumes 1024 $vg $d1 $d2 2>err;
+#   cp err save;
+#   status=$?; echo status=$?; test $status = 3 &&
+#   grep "^  Number of volumes may not exceed 255\$" err'
+
+test_done
+# Local Variables:
+# indent-tabs-mode: nil
+# End:


