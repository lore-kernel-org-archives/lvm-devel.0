From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 5 Jun 2009 10:42:23 -0000
Subject: LVM2/test t-vgrename-usage.sh
Message-ID: <20090605104223.31652.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-06-05 10:42:22

Modified files:
	test           : t-vgrename-usage.sh 

Log message:
	Add vgrename test to check for existence of new vg.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgrename-usage.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/t-vgrename-usage.sh	2008/09/29 16:02:50	1.3
+++ LVM2/test/t-vgrename-usage.sh	2009/06/05 10:42:22	1.4
@@ -27,3 +27,11 @@
 vgrename $UUID $vg2
 check_vg_field_ $vg2 vg_name $vg2
 vgremove $vg2
+
+# vgrename fails - new vg already exists
+vgcreate $vg1 $dev1
+vgcreate $vg2 $dev2
+not vgrename $vg1 $vg2
+vgremove $vg1
+vgremove $vg2
+


