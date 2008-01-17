From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 17 Jan 2008 15:56:54 -0000
Subject: LVM2/test t-lvextend-percent-extents.sh
Message-ID: <20080117155654.18181.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-01-17 15:56:54

Modified files:
	test           : t-lvextend-percent-extents.sh 

Log message:
	Minor test fix

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvextend-percent-extents.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/t-lvextend-percent-extents.sh	2007/09/24 19:19:18	1.2
+++ LVM2/test/t-lvextend-percent-extents.sh	2008/01/17 15:56:53	1.3
@@ -67,7 +67,7 @@
 # Exercise the range overlap code.  Allocate every 2 extents.
 #
 #      Physical Extents
-#           1         2
+#          1         2
 #012345678901234567890123
 #
 #aaXXaaXXaaXXaaXXaaXXaaXX - (a)llocated
@@ -88,7 +88,8 @@
   'Reset LV to 12 extents, allocate every other 2 extents' \
   'create_pvs=`for i in $(seq 0 4 20); do echo -n "\$d1:$i-$(($i + 1)) "; done` &&
    lvremove -f $vg/$lv; test $? = 0 &&
-   lvcreate -l 12 -n $lv $vg $create_pvs; test $? = 0'
+   lvcreate -l 12 -n $lv $vg $create_pvs; test $? = 0 &&
+   check_lv_size_ $vg/$lv "48.00M"'
 
 test_expect_success \
   'lvextend with partially allocated PVs and extents 100%PVS with PE ranges' \


