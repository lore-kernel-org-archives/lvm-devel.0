From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 22 Jul 2009 22:25:30 -0000
Subject: LVM2/test/api vgtest.c
Message-ID: <20090722222530.1171.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-22 22:25:30

Modified files:
	test/api       : vgtest.c 

Log message:
	Add a couple lvm_vg_open() calls to vgtest.c.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/vgtest.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/api/vgtest.c	2009/07/22 16:49:54	1.3
+++ LVM2/test/api/vgtest.c	2009/07/22 22:25:30	1.4
@@ -74,6 +74,20 @@
 		goto bad;
 	}
 
+	printf("Closing VG %s\n", vg_name);
+	if (!lvm_vg_close(vg))
+		goto bad;
+	printf("Re-opening VG %s for reading\n", vg_name);
+	vg = lvm_vg_open(handle, vg_name, "r", 0);
+	if (!vg)
+		goto bad;
+	printf("Closing VG %s\n", vg_name);
+	if (!lvm_vg_close(vg))
+		goto bad;
+	printf("Re-opening VG %s for writing\n", vg_name);
+	vg = lvm_vg_open(handle, vg_name, "w", 0);
+	if (!vg)
+		goto bad;
 	printf("Removing VG %s from system\n", vg_name);
 	status = lvm_vg_remove(vg);
 	if (lvm_errno(handle)) {


