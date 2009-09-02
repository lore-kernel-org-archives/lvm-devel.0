From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 2 Sep 2009 19:38:53 -0000
Subject: LVM2/test t-vgsplit-usage.sh
Message-ID: <20090902193853.8629.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-02 19:38:53

Modified files:
	test           : t-vgsplit-usage.sh 

Log message:
	Fix vgsplit test to require -M on ordering of vgnames.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-usage.sh.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/test/t-vgsplit-usage.sh	2009/09/02 18:31:11	1.13
+++ LVM2/test/t-vgsplit-usage.sh	2009/09/02 19:38:53	1.14
@@ -21,12 +21,13 @@
 pvcreate -M$mdatype $devs
 
 # ensure name order does not matter
+# NOTE: if we're using lvm1, we must use -M on vgsplit
 vgcreate -M$mdatype $vg1 $devs
-vgsplit $vg1 $vg2 $dev1
+vgsplit -M$mdatype $vg1 $vg2 $dev1
 vgremove $vg1
 vgremove $vg2
 vgcreate -M$mdatype $vg2 $devs
-vgsplit $vg2 $vg1 $dev1
+vgsplit -M$mdatype $vg2 $vg1 $dev1
 vgremove $vg1
 vgremove $vg2
 


