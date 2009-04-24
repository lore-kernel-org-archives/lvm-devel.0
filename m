From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 24 Apr 2009 08:00:49 -0000
Subject: LVM2/test test-utils.sh
Message-ID: <20090424080049.7937.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-04-24 08:00:48

Modified files:
	test           : test-utils.sh 

Log message:
	Avoid scanning non-PV devices in functional tests, otherwise lvconvert --repair
	breaks for some reason -- possibly needs investagation, but this should fix it
	in the meantime.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/test/test-utils.sh	2009/01/12 18:45:44	1.10
+++ LVM2/test/test-utils.sh	2009/04/24 08:00:48	1.11
@@ -179,7 +179,7 @@
   devices {
     dir = "$G_dev_"
     scan = "$G_dev_"
-    filter = [ "a/dev\/mirror/", "a/dev\/mapper/", "r/.*/" ]
+    filter = [ "a/dev\/mirror/", "a/dev\/mapper\/.*pv[0-9_]*$/", "r/.*/" ]
     cache_dir = "$G_root_/etc"
     sysfs_scan = 0
   }


