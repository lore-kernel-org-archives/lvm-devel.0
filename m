From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 16 Mar 2012 12:57:29 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20120316125729.22743.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-16 12:57:28

Modified files:
	test/lib       : aux.sh 

Log message:
	Test suite skip md_detection
	
	Not normally needed - lets' enable it only for test that
	really needs it.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.42&r2=1.43

--- LVM2/test/lib/aux.sh	2012/03/16 12:56:29	1.42
+++ LVM2/test/lib/aux.sh	2012/03/16 12:57:28	1.43
@@ -398,6 +398,7 @@
 devices/cache_dir = "$TESTDIR/etc"
 devices/sysfs_scan = 0
 devices/default_data_alignment = 1
+devices/md_component_detection  = 0
 log/syslog = 0
 log/indent = 1
 log/level = 9


