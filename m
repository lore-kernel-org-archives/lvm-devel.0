From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Mar 2008 18:02:23 -0000
Subject: LVM2/test lvm-utils.sh
Message-ID: <20080328180223.1282.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-03-28 18:02:23

Modified files:
	test           : lvm-utils.sh 

Log message:
	Enhance test debugging by updating verbose mode of check_*_field_ functions.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lvm-utils.sh.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/test/lvm-utils.sh	2008/03/23 15:40:35	1.8
+++ LVM2/test/lvm-utils.sh	2008/03/28 18:02:22	1.9
@@ -63,7 +63,7 @@
 {
 if test "$verbose" = "t"
 then
-  echo "check_vg_field_ actual: `vgs --noheadings -o $2 $1` expected $3"
+  echo "check_vg_field_ VG: $1 actual: `vgs --noheadings -o $2 $1` expected $3"
 fi
   return $(test $(vgs --noheadings -o $2 $1) == $3)
 }
@@ -72,7 +72,7 @@
 {
 if test "$verbose" = "t"
 then
-  echo "check_pv_field_ actual: `pvs --noheadings -o $2 $1` expected $3"
+  echo "check_pv_field_ PV: $1 actual: `pvs --noheadings -o $2 $1` expected $3"
 fi
   return $(test $(pvs --noheadings -o $2 $1) == $3)
 }
@@ -81,7 +81,7 @@
 {
 if test "$verbose" = "t"
 then
-  echo "check_lv_field_ actual: `lvs --noheadings -o $2 $1` expected $3"
+  echo "check_lv_field_ LV: $1 actual: `lvs --noheadings -o $2 $1` expected $3"
 fi
   return $(test $(lvs --noheadings -o $2 $1) == $3)
 }


