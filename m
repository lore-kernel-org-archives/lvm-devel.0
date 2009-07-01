From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 1 Jul 2009 17:06:04 -0000
Subject: LVM2/test t-inconsistent-metadata.sh
Message-ID: <20090701170604.12368.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-01 17:06:04

Modified files:
	test           : t-inconsistent-metadata.sh 

Log message:
	Fix t-inconsistent-metadata.sh.
	
	Sun May  3 13:25:10 CEST 2009  Petr Rockai <me@mornfall.net>
	* All tools now handle inconsistent metadata the same way.
	
	Rebase 6/26/09

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-inconsistent-metadata.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/t-inconsistent-metadata.sh	2009/06/05 20:00:52	1.2
+++ LVM2/test/t-inconsistent-metadata.sh	2009/07/01 17:06:04	1.3
@@ -40,23 +40,26 @@
 not grep "Inconsistent metadata found for VG $vg" cmd.out
 check
 
-# vgdisplay doesn't change anything
+# vgdisplay fixes
 init
 vgdisplay 2>&1 | tee cmd.out
-grep "Volume group $vg inconsistent" cmd.out
+grep "Inconsistent metadata found for VG $vg" cmd.out
 vgdisplay 2>&1 | tee cmd.out
-grep "Volume group $vg inconsistent" cmd.out
+not grep "Inconsistent metadata found for VG $vg" cmd.out
+check
 
 # lvs fixes up
 init
 lvs 2>&1 | tee cmd.out
-grep "Inconsistent metadata found for VG $vg - updating" cmd.out
+grep "Inconsistent metadata found for VG $vg" cmd.out
 vgdisplay 2>&1 | tee cmd.out
-not grep "Volume group $vg inconsistent" cmd.out
+not grep "Inconsistent metadata found for VG $vg" cmd.out
 check
 
-# vgs doesn't fix up... (why?)
+# vgs fixes up as well
 init
 vgs 2>&1 | tee cmd.out
-vgdisplay 2>&1 | tee cmd.out
-grep "Volume group $vg inconsistent" cmd.out
+grep "Inconsistent metadata found for VG $vg" cmd.out
+vgs 2>&1 | tee cmd.out
+not grep "Inconsistent metadata found for VG $vg" cmd.out
+check


