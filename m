From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 24 May 2010 15:28:46 -0000
Subject: LVM2/test t-pvcreate-operation-md.sh
Message-ID: <20100524152846.6076.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-05-24 15:28:45

Modified files:
	test           : t-pvcreate-operation-md.sh 

Log message:
	Skip t-pvcreate-operation-md if mdadm fails to create the required device.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation-md.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/test/t-pvcreate-operation-md.sh	2010/04/13 21:42:44	1.5
+++ LVM2/test/t-pvcreate-operation-md.sh	2010/05/24 15:28:45	1.6
@@ -45,9 +45,10 @@
 }
 
 # create 2 disk MD raid0 array (stripe_width=128K)
-[ -b "$mddev" ] && exit 200
+test -b "$mddev" && exit 200
 mdadm --create $mddev --auto=md --level 0 --raid-devices=2 --chunk 64 $dev1 $dev2
 trap 'aux cleanup_md' EXIT # cleanup this MD device at the end of the test
+test -b "$mddev" || exit 200
 
 # Test alignment of PV on MD without any MD-aware or topology-aware detection
 # - should treat $mddev just like any other block device


