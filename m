From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 22 Jan 2008 03:25:46 -0000
Subject: LVM2 test/t-vgsplit-operation.sh tools/vgsplit.c
Message-ID: <20080122032546.10101.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-01-22 03:25:45

Modified files:
	test           : t-vgsplit-operation.sh 
	tools          : vgsplit.c 

Log message:
	Fix vgsplit - print different message on successful split of existing / new vg
	Fix vgsplit - fix a couple error paths that forgot to call unlock_vg
	Update vgsplit test cases

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-operation.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48

--- LVM2/test/t-vgsplit-operation.sh	2008/01/22 02:48:53	1.5
+++ LVM2/test/t-vgsplit-operation.sh	2008/01/22 03:25:45	1.6
@@ -39,7 +39,9 @@
 test_expect_success \
   'vgsplit accepts new vg as destination of split' \
   'vgcreate $vg1 $d1 $d2 &&
-   vgsplit $vg1 $vg2 $d1 &&
+   vgsplit $vg1 $vg2 $d1 1>err;
+   status=$?; echo status=$?; test $status = 0 &&
+   grep "New volume group \"$vg2\" successfully split from \"$vg1\"" err &&
    vgremove $vg1 &&
    vgremove $vg2'
 
@@ -47,7 +49,9 @@
   'vgsplit accepts existing vg as destination of split' \
   'vgcreate $vg1 $d1 $d2 &&
    vgcreate $vg2 $d3 $d4 &&
-   vgsplit $vg1 $vg2 $d1 &&
+   vgsplit $vg1 $vg2 $d1 1>err;
+   status=$?; echo status=$?; test $status = 0 &&
+   grep "Existing volume group \"$vg2\" successfully split from \"$vg1\"" err &&
    vgremove $vg1 &&
    vgremove $vg2'
 
--- LVM2/tools/vgsplit.c	2008/01/22 02:48:53	1.47
+++ LVM2/tools/vgsplit.c	2008/01/22 03:25:45	1.48
@@ -229,6 +229,7 @@
 	struct volume_group *vg_to, *vg_from;
 	int opt;
 	int active;
+	int existing_vg;
 
 	if (argc < 3) {
 		log_error("Existing VG, new VG and physical volumes required.");
@@ -264,6 +265,7 @@
 	if ((vg_to = vg_lock_and_read(cmd, vg_name_to, NULL,
 				      LCK_VG_WRITE | LCK_NONBLOCK,
 				      0, 0))) {
+		existing_vg = 1;
 		if (new_vg_option_specified(cmd)) {
 			log_error("Volume group \"%s\" exists, but new VG "
 				    "option specified", vg_name_to);
@@ -272,6 +274,7 @@
 		if (!vgs_are_compatible(cmd, vg_from,vg_to))
 			goto error;
 	} else {
+		existing_vg = 0;
 
 		/* Set metadata format of original VG */
 		/* FIXME: need some common logic */
@@ -284,11 +287,15 @@
 		vp_def.alloc = vg_from->alloc;
 		vp_def.clustered = 0;
 
-		if (fill_vg_create_params(cmd, vg_name_to, &vp_new, &vp_def))
+		if (fill_vg_create_params(cmd, vg_name_to, &vp_new, &vp_def)) {
+			unlock_vg(cmd, vg_name_from);
 			return EINVALID_CMD_LINE;
+		}
 
-		if (validate_vg_create_params(cmd, &vp_new))
+		if (validate_vg_create_params(cmd, &vp_new)) {
+			unlock_vg(cmd, vg_name_from);
 			return EINVALID_CMD_LINE;
+		}
 
 		if (!(vg_to = vg_create(cmd, vg_name_to, vp_new.extent_size,
 					vp_new.max_pv, vp_new.max_lv,
@@ -371,7 +378,8 @@
 	unlock_vg(cmd, vg_name_from);
 	unlock_vg(cmd, vg_name_to);
 
-	log_print("Volume group \"%s\" successfully split from \"%s\"",
+	log_print("%s volume group \"%s\" successfully split from \"%s\"",
+		  existing_vg ? "Existing" : "New",
 		  vg_to->name, vg_from->name);
 	return ECMD_PROCESSED;
 


