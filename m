From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 22 Jul 2009 03:13:57 -0000
Subject: LVM2/test/api vgtest.c
Message-ID: <20090722031357.26668.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-22 03:13:57

Modified files:
	test/api       : vgtest.c 

Log message:
	Update test/api/vgtest.c to use lvm_errno and lvm_errmsg.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/vgtest.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/api/vgtest.c	2009/07/21 10:46:45	1.1
+++ LVM2/test/api/vgtest.c	2009/07/22 03:13:57	1.2
@@ -43,42 +43,47 @@
 
 	printf("Creating VG %s\n", vg_name);
 	vg = lvm_vg_create(handle, vg_name);
-	if (!vg) {
+	if (lvm_errno(handle)) {
 		fprintf(stderr, "Error creating volume group %s\n", vg_name);
+		fprintf(stderr, "LVM Error: %s\n", lvm_errmsg(handle));
 		goto bad;
 	}
 
 	printf("Extending VG %s\n", vg_name);
 	status = lvm_vg_extend(vg, device);
-	if (!status) {
+	if (lvm_errno(handle)) {
 		fprintf(stderr, "Error extending volume group %s "
 			"with device %s\n", vg_name, device);
+		fprintf(stderr, "LVM Error: %s\n", lvm_errmsg(handle));
 		goto bad;
 	}
 
 	printf("Setting VG %s extent_size to %"PRIu64"\n", vg_name, size);
 	status = lvm_vg_set_extent_size(vg, size);
-	if (!status) {
+	if (lvm_errno(handle)) {
 		fprintf(stderr, "Can not set physical extent "
 			"size '%"PRIu64"' for '%s'\n",
 			size, vg_name);
+		fprintf(stderr, "LVM Error: %s\n", lvm_errmsg(handle));
 		goto bad;
 	}
 
 	printf("Committing VG %s to disk\n", vg_name);
 	status = lvm_vg_write(vg);
-	if (!status) {
+	if (lvm_errno(handle)) {
 		fprintf(stderr, "Creation of volume group '%s' on "
 			"device '%s' failed\n",
 			vg_name, device);
+		fprintf(stderr, "LVM Error: %s\n", lvm_errmsg(handle));
 		goto bad;
 	}
 
 	printf("Removing VG %s from system\n", vg_name);
 	status = lvm_vg_remove(vg);
-	if (!status) {
+	if (lvm_errno(handle)) {
 		fprintf(stderr, "Revmoval of volume group '%s' failed\n",
 			vg_name);
+		fprintf(stderr, "LVM Error: %s\n", lvm_errmsg(handle));
 		goto bad;
 	}
 


