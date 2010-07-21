From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 21 Jul 2010 14:12:48 -0000
Subject: LVM2/test t-pvcreate-operation-md.sh
Message-ID: <20100721141248.14596.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-07-21 14:12:48

Modified files:
	test           : t-pvcreate-operation-md.sh 

Log message:
	Don't fail t-pvcreate-operation-md if mdadm is broken.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation-md.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/test/t-pvcreate-operation-md.sh	2010/05/24 15:28:45	1.6
+++ LVM2/test/t-pvcreate-operation-md.sh	2010/07/21 14:12:47	1.7
@@ -35,7 +35,7 @@
     # sleeps offer hack to defeat: 'md: md127 still in use'
     # see: https://bugzilla.redhat.com/show_bug.cgi?id=509908#c25
     sleep 2
-    mdadm --stop $mddev
+    mdadm --stop $mddev || true
     if [ -b "$mddev" ]; then
         # mdadm doesn't always cleanup the device node
 	sleep 2


