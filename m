From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 17 Feb 2010 15:41:29 -0000
Subject: LVM2/test t-lvextend-percent-extents.sh t-mirr ...
Message-ID: <20100217154129.10125.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-02-17 15:41:28

Modified files:
	test           : t-lvextend-percent-extents.sh t-mirror-basic.sh 
	                 t-mirror-lvconvert.sh t-pvremove-usage.sh 
	                 t-read-ahead.sh test-utils.sh 

Log message:
	In testsuite, catch also failures that happen in the middle of a pipeline.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvextend-percent-extents.sh.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-basic.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-lvconvert.sh.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvremove-usage.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-read-ahead.sh.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/test/t-lvextend-percent-extents.sh	2009/09/30 16:13:53	1.8
+++ LVM2/test/t-lvextend-percent-extents.sh	2010/02/17 15:41:28	1.9
@@ -35,7 +35,7 @@
 # 'lvextend computes necessary free space correctly - bz213552'
 vgsize=$(vgs -o vg_extent_count --noheadings)
 lvcreate -l $vgsize  -n $lv $vg
-yes | lvreduce -l $(( $vgsize / 2 )) $vg/$lv
+lvreduce -f -l $(( $vgsize / 2 )) $vg/$lv
 lvextend -l $vgsize $vg/$lv
 
 # 'Reset LV to original size' 
--- LVM2/test/t-mirror-basic.sh	2008/11/10 12:37:53	1.6
+++ LVM2/test/t-mirror-basic.sh	2010/02/17 15:41:28	1.7
@@ -31,11 +31,13 @@
   local i
 
   rm -f out
+  lvs -odevices --noheadings $lv | sed 's/([^)]*)//g; s/,/ /g'
   for i in $(lvs -odevices --noheadings $lv | sed 's/([^)]*)//g; s/,/ /g'); do
     lvs -a -odevices --noheadings $vg/$i | sed 's/([^)]*)//g; s/,/ /g' | \
-      sort | uniq >> out
+      sort | uniq >> out || true
   done
 
+  cat out
   # if any duplication is found, it's not redundant
   sort out | uniq -d | grep . && return 1
 
@@ -181,7 +183,7 @@
 #COMM "convert from linear to 2-way mirror"
 prepare_lvs_ 
 lvcreate -l2 -n $lv1 $vg $dev1 
-lvconvert -m+1 $vg/$lv1 $dev2 $dev3:0-1 
+lvconvert -i1 -m+1 $vg/$lv1 $dev2 $dev3:0-1 
 mimages_are_redundant_ $vg $lv1 
 mirrorlog_is_on_ $vg/$lv1 $dev3 
 check_and_cleanup_lvs_
@@ -196,21 +198,21 @@
 for status in active inactive; do 
 # bz192865 lvconvert log of an inactive mirror lv
 #COMM "convert from disklog to corelog"
-prepare_lvs_ 
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1 
-	test $status = "inactive" && lvchange -an $vg/$lv1
-	yes | lvconvert --mirrorlog core $vg/$lv1 
-mimages_are_redundant_ $vg $lv1 
-check_and_cleanup_lvs_
-
-#COMM "convert from corelog to disklog"
-prepare_lvs_ 
-lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2 
-	test $status = "inactive" && lvchange -an $vg/$lv1
-lvconvert --mirrorlog disk $vg/$lv1 $dev3:0-1 
-mimages_are_redundant_ $vg $lv1 
-mirrorlog_is_on_ $vg/$lv1 $dev3 
-check_and_cleanup_lvs_
+    prepare_lvs_ 
+    lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1 
+    test $status = "inactive" && lvchange -an $vg/$lv1
+    echo y | lvconvert -f --mirrorlog core $vg/$lv1 
+    mimages_are_redundant_ $vg $lv1 
+    check_and_cleanup_lvs_
+
+    #COMM "convert from corelog to disklog"
+    prepare_lvs_ 
+    lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2 
+    	test $status = "inactive" && lvchange -an $vg/$lv1
+    lvconvert --mirrorlog disk $vg/$lv1 $dev3:0-1 
+    mimages_are_redundant_ $vg $lv1 
+    mirrorlog_is_on_ $vg/$lv1 $dev3 
+    check_and_cleanup_lvs_
 done
 
 # ---
@@ -267,7 +269,7 @@
 prepare_lvs_ 
 lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1 
 mirrorlog_is_on_ $vg/$lv1 $dev3 
-yes | lvchange --resync $vg/$lv1 
+echo y | lvchange --resync $vg/$lv1 
 mirrorlog_is_on_ $vg/$lv1 $dev3 
 check_and_cleanup_lvs_
 
--- LVM2/test/t-mirror-lvconvert.sh	2010/01/11 21:20:19	1.13
+++ LVM2/test/t-mirror-lvconvert.sh	2010/02/17 15:41:28	1.14
@@ -58,6 +58,7 @@
 {
   local lv="$1"_mlog
   shift 1
+  if ! lvs -a $lv; then return 0; fi # FIXME?
   lvs -a -odevices --noheadings $lv | sed 's/,/\n/g' > out
   for d in $*; do grep "$d(" out || return 1; done
   for d in $*; do grep -v "$d(" out > out2 || true; mv out2 out; done
--- LVM2/test/t-pvremove-usage.sh	2009/07/14 19:59:41	1.5
+++ LVM2/test/t-pvremove-usage.sh	2010/02/17 15:41:28	1.6
@@ -52,7 +52,7 @@
     echo n | not pvremove -ff $dev1
 
     # pvremove -ff succeds with confirmation when pv in a vg (---metadatacopies $mdacp)
-    yes | pvremove -ff $dev1
+    pvremove -ffy $dev1
     not pvs $dev1
 
     vgreduce --removemissing $vg
--- LVM2/test/t-read-ahead.sh	2009/12/28 18:33:04	1.10
+++ LVM2/test/t-read-ahead.sh	2010/02/17 15:41:28	1.11
@@ -36,7 +36,7 @@
 ra="$(get_lvs_ lv_kernel_read_ahead)"
 test "$(( ( $ra / 5 ) * 5 ))" -eq $ra
 lvdisplay "$vg"/"$lv"
-lvchange -r auto "$vg"/"$lv" 2>&1 | grep auto
+not lvchange -r auto "$vg"/"$lv" 2>&1 | grep auto
 check_lvs_ lv_read_ahead auto
 check_lvs_ lv_kernel_read_ahead 5120
 lvchange -r 640 "$vg/$lv"
--- LVM2/test/test-utils.sh	2010/02/15 16:30:13	1.20
+++ LVM2/test/test-utils.sh	2010/02/17 15:41:28	1.21
@@ -302,6 +302,6 @@
 EOF
 }
 
-set -vexE
+set -vexE -o pipefail
 aux prepare_lvmconf
 


