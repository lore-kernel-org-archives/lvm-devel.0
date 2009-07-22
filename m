From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 22 Jul 2009 16:49:54 -0000
Subject: LVM2/test/api vgtest.c
Message-ID: <20090722164954.18577.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-22 16:49:54

Modified files:
	test/api       : vgtest.c 

Log message:
	Update api/test/vgtest.c error handling.
	
	Reverts some of my 'cleanup' from last night.  For now we will use pass/fail
	on API calls (either 'int' return or NULL/non-NULL handle), then use
	lvm_errno() to get more specific errors.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/vgtest.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/api/vgtest.c	2009/07/22 03:13:57	1.2
+++ LVM2/test/api/vgtest.c	2009/07/22 16:49:54	1.3
@@ -43,38 +43,34 @@
 
 	printf("Creating VG %s\n", vg_name);
 	vg = lvm_vg_create(handle, vg_name);
-	if (lvm_errno(handle)) {
+	if (!vg) {
 		fprintf(stderr, "Error creating volume group %s\n", vg_name);
-		fprintf(stderr, "LVM Error: %s\n", lvm_errmsg(handle));
 		goto bad;
 	}
 
 	printf("Extending VG %s\n", vg_name);
 	status = lvm_vg_extend(vg, device);
-	if (lvm_errno(handle)) {
+	if (!status) {
 		fprintf(stderr, "Error extending volume group %s "
 			"with device %s\n", vg_name, device);
-		fprintf(stderr, "LVM Error: %s\n", lvm_errmsg(handle));
 		goto bad;
 	}
 
 	printf("Setting VG %s extent_size to %"PRIu64"\n", vg_name, size);
 	status = lvm_vg_set_extent_size(vg, size);
-	if (lvm_errno(handle)) {
+	if (!status) {
 		fprintf(stderr, "Can not set physical extent "
 			"size '%"PRIu64"' for '%s'\n",
 			size, vg_name);
-		fprintf(stderr, "LVM Error: %s\n", lvm_errmsg(handle));
 		goto bad;
 	}
 
 	printf("Committing VG %s to disk\n", vg_name);
 	status = lvm_vg_write(vg);
-	if (lvm_errno(handle)) {
+	if (!status) {
 		fprintf(stderr, "Creation of volume group '%s' on "
 			"device '%s' failed\n",
 			vg_name, device);
-		fprintf(stderr, "LVM Error: %s\n", lvm_errmsg(handle));
 		goto bad;
 	}
 
@@ -83,7 +79,6 @@
 	if (lvm_errno(handle)) {
 		fprintf(stderr, "Revmoval of volume group '%s' failed\n",
 			vg_name);
-		fprintf(stderr, "LVM Error: %s\n", lvm_errmsg(handle));
 		goto bad;
 	}
 
@@ -93,6 +88,8 @@
 	_exit(0);
 bad:
 	printf("liblvm vgcreate unit test FAIL\n");
+	if (handle && lvm_errno(handle))
+		fprintf(stderr, "LVM Error: %s\n", lvm_errmsg(handle));
 	if (vg)
 		lvm_vg_close(vg);
 	if (handle)


