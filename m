From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 25 Jul 2008 14:37:01 -0000
Subject: LVM2 test/t-pvcreate-operation.sh tools/pvcreate.c
Message-ID: <20080725143701.27268.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-07-25 14:36:56

Modified files:
	test           : t-pvcreate-operation.sh 
	tools          : pvcreate.c 

Log message:
	Refactor pvcreate - --force parameter.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71

--- LVM2/test/t-pvcreate-operation.sh	2008/07/25 00:30:57	1.4
+++ LVM2/test/t-pvcreate-operation.sh	2008/07/25 14:36:52	1.5
@@ -45,7 +45,7 @@
 done
 
 test_expect_success \
-  'pvcreate (lvm2) fails when PV with metadatacopies=0 belongs to VG' \
+  'pvcreate (lvm2) fails without -ff when PV with metadatacopies=0 belongs to VG' \
   'pvcreate --metadatacopies 0 $d1 &&
    pvcreate --metadatacopies 1 $d2 &&
    vgcreate $vg1 $d1 $d2 &&
--- LVM2/tools/pvcreate.c	2008/07/25 14:12:29	1.70
+++ LVM2/tools/pvcreate.c	2008/07/25 14:36:55	1.71
@@ -28,6 +28,7 @@
 	uint32_t extent_count;
 	uint32_t extent_size;
 	const char *restorefile; /* 0 if no --restorefile option */
+	force_t force;
 };
 
 const char _really_init[] =
@@ -64,7 +65,7 @@
 
 	/* Allow partial & exported VGs to be destroyed. */
 	/* We must have -ff to overwrite a non orphan */
-	if (pv && !is_orphan(pv) && arg_count(cmd, force_ARG) != 2) {
+	if (pv && !is_orphan(pv) && pp->force != DONT_PROMPT_OVERRIDE) {
 		log_error("Can't initialize physical volume \"%s\" of "
 			  "volume group \"%s\" without -ff", name, pv_vg_name(pv));
 		return 0;
@@ -129,7 +130,7 @@
 	if (sigint_caught())
 		return 0;
 
-	if (pv && !is_orphan(pv) && arg_count(cmd, force_ARG)) {
+	if (pv && !is_orphan(pv) && pp->force) {
 		log_warn("WARNING: Forcing physical volume creation on "
 			  "%s%s%s%s", name,
 			  !is_orphan(pv) ? " of volume group \"" : "",
@@ -291,6 +292,8 @@
 		return 0;
 	}
 
+	pp->force = arg_count(cmd, force_ARG);
+
 	if (arg_int_value(cmd, labelsector_ARG, 0) >= LABEL_SCAN_SECTORS) {
 		log_error("labelsector must be less than %lu",
 			  LABEL_SCAN_SECTORS);


