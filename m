From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 10 Jan 2009 12:19:41 -0000
Subject: LVM2/test lvm-utils.sh
Message-ID: <20090110121941.19060.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-01-10 12:19:41

Modified files:
	test           : lvm-utils.sh 

Log message:
	Fix some checks in lvm-utils.sh. Note that "$(test ...)" is always empty, since
	"test" never prints anything. Therefore, "return $(test ...)" is equivalent to
	just "return;" which means success in sh (same as return 0). We can however,
	thanks to set -e, use "test foo = bar" as an assertion.
	
	PS: test a == b is invalid syntax. It is either = or -eq: = is textual and -eq
	is numeric comparison.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lvm-utils.sh.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/test/lvm-utils.sh	2008/12/10 16:15:41	1.16
+++ LVM2/test/lvm-utils.sh	2009/01/10 12:19:41	1.17
@@ -64,7 +64,7 @@
 then
   echo "compare_vg_field_ VG1: $val1 VG2: $val2"
 fi
-  return $(test $val1 == $val2 )
+  test $val1 = $val2
 }
 
 check_vg_field_()
@@ -79,7 +79,7 @@
 then
   echo "check_vg_field_ VG=$vg, field=$field, actual=$actual, expected=$expected"
 fi
-  return $(test $actual == $expected)
+  test $actual = $expected
 }
 
 check_pv_field_()
@@ -94,7 +94,7 @@
 then
   echo "check_pv_field_ PV=$pv, field=$field, actual=$actual, expected=$expected"
 fi
-  return $(test $actual == $expected)
+    test $actual = $expected
 }
 
 check_lv_field_()
@@ -109,7 +109,7 @@
 then
   echo "check_lv_field_ LV=$lv, field=$field, actual=$actual, expected=$expected"
 fi
-  return $(test $actual == $expected)
+  test $actual = $expected
 }
 
 vg_validate_pvlv_counts_()


