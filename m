From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 14 Jul 2009 19:59:42 -0000
Subject: LVM2 ./WHATS_NEW test/t-pvremove-usage.sh
Message-ID: <20090714195942.9466.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-14 19:59:41

Modified files:
	.              : WHATS_NEW 
	test           : t-pvremove-usage.sh 

Log message:
	Fix pvremove test breakage.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1183&r2=1.1184
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvremove-usage.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/WHATS_NEW	2009/07/14 12:17:14	1.1183
+++ LVM2/WHATS_NEW	2009/07/14 19:59:41	1.1184
@@ -1,5 +1,6 @@
 Version 2.02.49 - 
 ================================
+  Fix vgck and vgremove segfault if non-existent vg given.
   Enable use of new multi-segment registration for static registration too.
   Exclude VG_GLOBAL from vg_write_lock_held so scans open devs read-only again.
   Add unit test case for liblvm VG create/delete APIs.
--- LVM2/test/t-pvremove-usage.sh	2009/07/14 19:35:35	1.4
+++ LVM2/test/t-pvremove-usage.sh	2009/07/14 19:59:41	1.5
@@ -15,6 +15,7 @@
 pvcreate $dev1
 pvcreate --metadatacopies 0 $dev2
 pvcreate --metadatacopies 2 $dev3
+pvremove $dev2
 
 # failing, but still removing everything what can be removed
 # is somewhat odd as default, what do we have -f for?


