From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 02:35:20 -0000
Subject: LVM2/test/api test.c
Message-ID: <20090726023520.17393.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 02:35:20

Modified files:
	test/api       : test.c 

Log message:
	Update test/api/test.c to handle read/write open modes.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/test/api/test.c	2009/07/24 12:51:32	1.5
+++ LVM2/test/api/test.c	2009/07/26 02:35:19	1.6
@@ -162,8 +162,10 @@
 		printf ("VG already open\n");
 		return;
 	}
-	/* FIXME: allow different open modes */
-	vg = lvm_vg_open(libh, argv[1], "r", 0);
+	if (argc < 3)
+		vg = lvm_vg_open(libh, argv[1], "r", 0);
+	else
+		vg = lvm_vg_open(libh, argv[1], argv[2], 0);
 	if (!vg || !lvm_vg_get_name(vg)) {
 		printf("Error opening %s\n", argv[1]);
 		return;


