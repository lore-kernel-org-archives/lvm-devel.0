From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 5 Jan 2011 01:04:47 -0000
Subject: LVM2/test t-pvcreate-operation-md.sh
Message-ID: <20110105010447.11413.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-01-05 01:04:47

Modified files:
	test           : t-pvcreate-operation-md.sh 

Log message:
	Fix another bug in t-pvcreate-operation-md (should pass now).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation-md.sh.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/test/t-pvcreate-operation-md.sh	2011/01/05 00:38:41	1.12
+++ LVM2/test/t-pvcreate-operation-md.sh	2011/01/05 01:04:47	1.13
@@ -45,13 +45,13 @@
 
 cleanup_md_and_teardown() {
     cleanup_md
-    teardown
+    aux teardown
 }
 
 # create 2 disk MD raid0 array (stripe_width=128K)
 test -b "$mddev" && exit 200
 mdadm --create --metadata=1.0 $mddev --auto=md --level 0 --raid-devices=2 --chunk 64 $dev1 $dev2
-trap 'aux cleanup_md_and_teardown' EXIT # cleanup this MD device at the end of the test
+trap 'cleanup_md_and_teardown' EXIT # cleanup this MD device at the end of the test
 test -b "$mddev" || exit 200
 
 # Test alignment of PV on MD without any MD-aware or topology-aware detection


