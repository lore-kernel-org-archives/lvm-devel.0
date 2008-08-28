From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 28 Aug 2008 10:07:34 -0000
Subject: LVM2/test Makefile.in t-lvcreate-usage.sh t-pv ...
Message-ID: <20080828100734.21058.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-08-28 10:07:34

Modified files:
	test           : Makefile.in t-lvcreate-usage.sh 
	                 t-pvchange-usage.sh t-pvcreate-operation.sh 

Log message:
	- fix environment variable prefix to LVM (this is not GIT:-)
	- add lvcreate rejects repeated invocation test
	- fix pvs metadata test for partial failure test
	- add pvchange reject --addtag to lvm1 pv test
	
	(All fixes by Jaroslav Stava)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvchange-usage.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/test/Makefile.in	2008/08/05 12:32:08	1.10
+++ LVM2/test/Makefile.in	2008/08/28 10:07:33	1.11
@@ -48,7 +48,7 @@
 
 $(T): init.sh
 	@echo "*** $@ ***"; '$(SHELL_PATH_SQ)' \
-	  $(TESTS_ENVIRONMENT) $@ $(GIT_TEST_OPTS)
+	  $(TESTS_ENVIRONMENT) $@ $(LVM_TEST_OPTS)
 
 .bin-dir-stamp: lvm-wrapper
 	rm -rf bin
--- LVM2/test/t-lvcreate-usage.sh	2008/04/10 01:06:48	1.5
+++ LVM2/test/t-lvcreate-usage.sh	2008/08/28 10:07:34	1.6
@@ -37,6 +37,15 @@
 lv=lvcreate-usage-$$
 
 test_expect_success \
+  "lvcreate rejects repeated invocation (run 2 times)" '
+   lvcreate -n $lv -l 4 $vg && 
+   { lvcreate -n $lv -l 4 $vg;
+     status=$?; echo status=$status; test $status = 5 &&
+     lvremove -ff $vg/$lv
+   }
+'
+
+test_expect_success \
   'lvcreate rejects a negative stripe_size' \
   'lvcreate -L 64M -n $lv -i2 --stripesize -4 $vg 2>err;
    status=$?; echo status=$status; test $status = 3 &&
--- LVM2/test/t-pvchange-usage.sh	2008/08/12 10:04:31	1.1
+++ LVM2/test/t-pvchange-usage.sh	2008/08/28 10:07:34	1.2
@@ -50,7 +50,7 @@
 '
 
 test_expect_success \
-  "vgchange disable/enable allocation for pvs with metadatacopies = $mda" '
+  "vgchange disable/enable allocation for pvs with metadatacopies = $mda (bz452982)" '
    pvchange $d1 -x n &&
    check_pv_field_ $d1 pv_attr  --  &&
    pvchange $d1 -x y &&
@@ -77,10 +77,11 @@
   "pvchange rejects uuid change under an active lv" '
    lvcreate -l 16 -i 2 -n $lv --alloc anywhere $vg1 &&
    vg_validate_pvlv_counts_ $vg1 2 1 0 &&
-   pvchange -u $d1;
-   status=$?; echo status=$status; test $status = 5 &&
-   lvchange -an "$vg1"/"$lv" &&
-   pvchange -u $d1
+   { pvchange -u $d1;
+     status=$?; echo status=$status; test $status = 5 &&
+     lvchange -an "$vg1"/"$lv" &&
+     pvchange -u $d1
+   }
 '
 
 test_expect_success \
@@ -89,6 +90,14 @@
    vgremove $vg1
 '
 
+test_expect_success \
+  "pvchange reject --addtag to lvm1 pv" '
+   pvcreate -M1 $d1 &&
+   { pvchange $d1 --addtag test;
+     status=$?; echo status=$status; test $status != 0
+   }
+'
+
 test_done
 # Local Variables:
 # indent-tabs-mode: nil
--- LVM2/test/t-pvcreate-operation.sh	2008/08/01 15:44:53	1.8
+++ LVM2/test/t-pvcreate-operation.sh	2008/08/28 10:07:34	1.9
@@ -33,6 +33,14 @@
 
 for mdatype in 1 2
 do
+
+test_expect_success \
+  "pvcreate (lvm$mdatype) succeeds when run repeatedly (pv not in a vg)" '
+   pvcreate -M$mdatype $d1 &&
+   pvcreate -M$mdatype $d1 &&
+   pvremove -f $d1
+'
+
 test_expect_success \
   "pvcreate (lvm$mdatype) fails when PV belongs to VG" \
   'pvcreate -M$mdatype $d1 &&
@@ -63,7 +71,6 @@
 #   mdadm --stop /dev/md0 &&
 #   pvcreate -ff -y -M$mdatype $d1 $d2 &&
 #   pvremove -f $d1 $d2'
-
 done
 
 test_expect_success \


