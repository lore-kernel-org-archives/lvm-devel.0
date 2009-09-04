From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 4 Sep 2009 19:17:46 -0000
Subject: LVM2/test/api vgtest.c
Message-ID: <20090904191746.4520.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-04 19:17:46

Modified files:
	test/api       : vgtest.c 

Log message:
	Update lvm2app unit test vgtest - fix remove bug.
	
	We now must commit to disk after lvm_vg_remove().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/vgtest.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/test/api/vgtest.c	2009/09/04 12:54:23	1.12
+++ LVM2/test/api/vgtest.c	2009/09/04 19:17:46	1.13
@@ -49,9 +49,8 @@
 	printf("Committing VG %s to disk\n", vg_name); \
 	status = lvm_vg_write(vg); \
 	if (status) { \
-		fprintf(stderr, "Creation of volume group '%s' on " \
-			"device '%s' failed\n", \
-			lvm_vg_get_name(vg), device[0]); \
+		fprintf(stderr, "Commit of volume group '%s' failed\n", \
+			lvm_vg_get_name(vg)); \
 		goto bad; \
 	}
 #define vg_open(vg_name, mode) \
@@ -147,6 +146,7 @@
 
 	vg_open(vg_name, "w");
 	vg_remove(vg);
+	vg_commit(vg);
 	vg_close(vg);
 
 	lvm_quit(handle);


