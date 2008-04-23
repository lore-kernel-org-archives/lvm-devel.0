From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 23 Apr 2008 13:02:03 -0000
Subject: LVM2/test lvm-utils.sh
Message-ID: <20080423130203.28130.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-04-23 13:02:03

Modified files:
	test           : lvm-utils.sh 

Log message:
	Update test function _check_{vg|lv|pv}_field to aid in test debug.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lvm-utils.sh.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/test/lvm-utils.sh	2008/04/11 14:06:16	1.10
+++ LVM2/test/lvm-utils.sh	2008/04/23 13:02:03	1.11
@@ -63,7 +63,7 @@
 {
 if test "$verbose" = "t"
 then
-  echo "check_vg_field_ VG: $1 actual: `vgs --noheadings -o $2 $1` expected $3"
+  echo "check_vg_field_ VG=$1, field=$2, actual=`vgs --noheadings -o $2 $1`, expected=$3"
 fi
   return $(test $(vgs --noheadings -o $2 $1) == $3)
 }
@@ -72,7 +72,7 @@
 {
 if test "$verbose" = "t"
 then
-  echo "check_pv_field_ PV: $1 actual: `pvs --noheadings -o $2 $1` expected $3"
+  echo "check_pv_field_ PV=$1, field=$2, actual=`pvs --noheadings -o $2 $1`, expected=$3"
 fi
   return $(test $(pvs --noheadings -o $2 $1) == $3)
 }
@@ -81,7 +81,7 @@
 {
 if test "$verbose" = "t"
 then
-  echo "check_lv_field_ LV: $1 actual: `lvs --noheadings -o $2 $1` expected $3"
+  echo "check_lv_field_ LV=$1, field=$2, actual=`lvs --noheadings -o $2 $1`, expected=$3"
 fi
   return $(test $(lvs --noheadings -o $2 $1) == $3)
 }


