From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 20:29:56 -0000
Subject: LVM2/test/api test.c vgtest.c
Message-ID: <20090726202956.22778.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 20:29:56

Modified files:
	test/api       : test.c vgtest.c 

Log message:
	Update test/api/*.c to use consistent liblvm error returns.
	
	For now, liblvm will return -1 (fail) / 0 (success) or
	NULL (fail) / non-NULL (success).  Upon failure, lvm_errno and
	lvm_errmsg should be used to determine the precise error.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/vgtest.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/test/api/test.c	2009/07/26 16:44:05	1.13
+++ LVM2/test/api/test.c	2009/07/26 20:29:56	1.14
@@ -327,7 +327,7 @@
 	}
 	if (!(lv = _lookup_lv_by_name(argv[2])))
 		return;
-	if (!lvm_vg_remove_lv(lv))
+	if (lvm_vg_remove_lv(lv))
 		printf("Error ");
 	else {
 		printf("Success ");
--- LVM2/test/api/vgtest.c	2009/07/22 22:25:30	1.4
+++ LVM2/test/api/vgtest.c	2009/07/26 20:29:56	1.5
@@ -50,7 +50,7 @@
 
 	printf("Extending VG %s\n", vg_name);
 	status = lvm_vg_extend(vg, device);
-	if (!status) {
+	if (status) {
 		fprintf(stderr, "Error extending volume group %s "
 			"with device %s\n", vg_name, device);
 		goto bad;
@@ -58,7 +58,7 @@
 
 	printf("Setting VG %s extent_size to %"PRIu64"\n", vg_name, size);
 	status = lvm_vg_set_extent_size(vg, size);
-	if (!status) {
+	if (status) {
 		fprintf(stderr, "Can not set physical extent "
 			"size '%"PRIu64"' for '%s'\n",
 			size, vg_name);
@@ -67,7 +67,7 @@
 
 	printf("Committing VG %s to disk\n", vg_name);
 	status = lvm_vg_write(vg);
-	if (!status) {
+	if (status) {
 		fprintf(stderr, "Creation of volume group '%s' on "
 			"device '%s' failed\n",
 			vg_name, device);
@@ -75,14 +75,14 @@
 	}
 
 	printf("Closing VG %s\n", vg_name);
-	if (!lvm_vg_close(vg))
+	if (lvm_vg_close(vg))
 		goto bad;
 	printf("Re-opening VG %s for reading\n", vg_name);
 	vg = lvm_vg_open(handle, vg_name, "r", 0);
 	if (!vg)
 		goto bad;
 	printf("Closing VG %s\n", vg_name);
-	if (!lvm_vg_close(vg))
+	if (lvm_vg_close(vg))
 		goto bad;
 	printf("Re-opening VG %s for writing\n", vg_name);
 	vg = lvm_vg_open(handle, vg_name, "w", 0);
@@ -90,7 +90,7 @@
 		goto bad;
 	printf("Removing VG %s from system\n", vg_name);
 	status = lvm_vg_remove(vg);
-	if (lvm_errno(handle)) {
+	if (status) {
 		fprintf(stderr, "Revmoval of volume group '%s' failed\n",
 			vg_name);
 		goto bad;


