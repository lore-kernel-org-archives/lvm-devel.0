From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 4 Jun 2011 21:55:25 -0000
Subject: LVM2/test/api pe_start.c pe_start.sh
Message-ID: <20110604215525.13241.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-06-04 21:55:25

Modified files:
	test/api       : pe_start.c pe_start.sh 

Log message:
	Also check in the pe_start API test that the disks have not been touched.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/pe_start.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/pe_start.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/api/pe_start.c	2011/06/04 21:46:34	1.1
+++ LVM2/test/api/pe_start.c	2011/06/04 21:55:25	1.2
@@ -27,13 +27,13 @@
 	handle = lvm_init(NULL);
         assert(handle);
 
-	vg = lvm_vg_create(handle, "test_vg");
+	vg = lvm_vg_create(handle, argv[1]);
         assert(vg);
 
-	if (lvm_vg_extend(vg, argv[1]))
+	if (lvm_vg_extend(vg, argv[2]))
 		abort();
 
-	pv = lvm_pv_from_name(vg, argv[1]);
+	pv = lvm_pv_from_name(vg, argv[2]);
 	assert(pv);
 
         v = lvm_pv_get_property(pv, "pe_start");
--- LVM2/test/api/pe_start.sh	2011/06/04 21:46:34	1.1
+++ LVM2/test/api/pe_start.sh	2011/06/04 21:55:25	1.2
@@ -14,4 +14,6 @@
 . lib/test
 
 aux prepare_devs 2
-aux apitest pe_start $dev1
+aux apitest pe_start test_vg $dev1
+not vgs test_vg
+not pvs $dev1


