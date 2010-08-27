From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 27 Aug 2010 07:59:41 -0000
Subject: LVM2/test test-utils.sh
Message-ID: <20100827075941.7826.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-08-27 07:59:40

Modified files:
	test           : test-utils.sh 

Log message:
	Currently tests require SI units enabled and data alignment to 1MiB.
	
	For now force it in lvm.conf (otherwise it fails on older systems like RHEL5
	where are these options disabled by default).
	
	FIXME: it should test and detect both versions.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.48&r2=1.49

--- LVM2/test/test-utils.sh	2010/08/12 04:11:50	1.48
+++ LVM2/test/test-utils.sh	2010/08/27 07:59:40	1.49
@@ -366,6 +366,7 @@
     filter = $filter
     cache_dir = "$TESTDIR/etc"
     sysfs_scan = 0
+    default_data_alignment = 1
   }
   log {
     syslog = 0
@@ -384,6 +385,7 @@
     library_dir = "$TESTDIR/lib"
     locking_dir = "$TESTDIR/var/lock/lvm"
     $locktype
+    si_unit_consistency = 1
   }
   activation {
     udev_sync = 1


