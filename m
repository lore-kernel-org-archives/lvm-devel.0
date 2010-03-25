From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Mar 2010 12:14:15 -0000
Subject: LVM2/test t-mirror-lvconvert.sh
Message-ID: <20100325121415.30022.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-03-25 12:14:14

Modified files:
	test           : t-mirror-lvconvert.sh 

Log message:
	more diagnostics

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-lvconvert.sh.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/test/t-mirror-lvconvert.sh	2010/03/25 11:47:00	1.15
+++ LVM2/test/t-mirror-lvconvert.sh	2010/03/25 12:14:14	1.16
@@ -21,7 +21,7 @@
 
   rm -f out
   for i in $(lvs -odevices --noheadings $lv | sed 's/([^)]*)//g; s/,/ /g'); do
-    lvs -a -odevices --noheadings $vg/$i 
+    lvs -a -o+devices $vg/$i 
     lvs -a -odevices --noheadings $vg/$i | sed 's/([^)]*)//g; s/,/ /g' | \
       sort | uniq >> out
   done
@@ -37,7 +37,7 @@
   local lv=$1
 
   # if the lv has multiple segments, it's not contiguous
-  lvs -a --segments --noheadings $lv
+  lvs -a --segments $lv
   [ $(lvs -a --segments --noheadings $lv | wc -l) -ne 1 ] && return 1
 
   return 0
@@ -61,7 +61,7 @@
   local lv="$1"_mlog
   shift 1
   if ! lvs -a $lv; then return 0; fi # FIXME?
-  lvs -a -odevices --noheadings $lv
+  lvs -a -o+devices $lv
   lvs -a -odevices --noheadings $lv | sed 's/,/\n/g' > out
   for d in $*; do grep "$d(" out || return 1; done
   for d in $*; do grep -v "$d(" out > out2 || true; mv out2 out; done
@@ -103,7 +103,7 @@
 check_no_tmplvs_()
 {
   local lv=$1
-  lvs -a --noheadings -oname $(dirname $lv)
+  lvs -a -oname $(dirname $lv)
   lvs -a --noheadings -oname $(dirname $lv) > out
   ! grep tmp out
 }
@@ -150,10 +150,13 @@
 
 # add 1 mirror
 prepare_lvs_
+lvs -a -o+devices $vg
 lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
+lvs -a -o+devices $vg
 check_mirror_count_ $vg/$lv1 2
 check_mirror_log_ $vg/$lv1
 lvconvert -m+1 -i1 $vg/$lv1 $dev4
+lvs -a -o+devices $vg
 check_no_tmplvs_ $vg/$lv1
 check_mirror_count_ $vg/$lv1 3
 mimages_are_redundant_ $vg $lv1
@@ -163,10 +166,13 @@
 # remove 1 mirror from corelog'ed mirror
 #  should retain 'core' log type
 prepare_lvs_
+lvs -a -o+devices $vg
 lvcreate -l2 -m2 --corelog -n $lv1 $vg
+lvs -a -o+devices $vg
 check_mirror_count_ $vg/$lv1 3
 not_sh check_mirror_log_ $vg/$lv1
 lvconvert -m -1 -i1 $vg/$lv1
+lvs -a -o+devices $vg
 check_no_tmplvs_ $vg/$lv1
 check_mirror_count_ $vg/$lv1 2
 mimages_are_redundant_ $vg $lv1
@@ -175,10 +181,13 @@
 
 # add 2 mirrors
 prepare_lvs_
+lvs -a -o+devices $vg
 lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
+lvs -a -o+devices $vg
 check_mirror_count_ $vg/$lv1 2
 check_mirror_log_ $vg/$lv1
 lvconvert -m+2 -i1 $vg/$lv1 $dev4 $dev5
+lvs -a -o+devices $vg
 check_no_tmplvs_ $vg/$lv1
 check_mirror_count_ $vg/$lv1 4
 mimages_are_redundant_ $vg $lv1
@@ -188,10 +197,13 @@
 # add 1 mirror to core log mirror,
 #  explicitly keep log as 'core'
 prepare_lvs_
+lvs -a -o+devices $vg
 lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
+lvs -a -o+devices $vg
 check_mirror_count_ $vg/$lv1 2
 not_sh check_mirror_log_ $vg/$lv1
 lvconvert -m+1 -i1 --mirrorlog core $vg/$lv1 $dev4 
+lvs -a -o+devices $vg
 check_no_tmplvs_ $vg/$lv1 
 check_mirror_count_ $vg/$lv1 3 
 not_sh check_mirror_log_ $vg/$lv1
@@ -201,10 +213,13 @@
 # add 1 mirror to core log mirror, but
 #  implicitly keep log as 'core'
 prepare_lvs_
+lvs -a -o+devices $vg
 lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
+lvs -a -o+devices $vg
 check_mirror_count_ $vg/$lv1 2
 not_sh check_mirror_log_ $vg/$lv1
 lvconvert -m +1 -i1 $vg/$lv1
+lvs -a -o+devices $vg
 check_no_tmplvs_ $vg/$lv1
 check_mirror_count_ $vg/$lv1 3
 not_sh check_mirror_log_ $vg/$lv1
@@ -213,10 +228,13 @@
 
 # add 2 mirrors to core log mirror" 
 prepare_lvs_ 
+lvs -a -o+devices $vg
 lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2 
+lvs -a -o+devices $vg
 check_mirror_count_ $vg/$lv1 2 
 not_sh check_mirror_log_ $vg/$lv1 
 lvconvert -m+2 -i1 --mirrorlog core $vg/$lv1 $dev4 $dev5 
+lvs -a -o+devices $vg
 check_no_tmplvs_ $vg/$lv1 
 check_mirror_count_ $vg/$lv1 4 
 not_sh check_mirror_log_ $vg/$lv1
@@ -228,11 +246,15 @@
 
 # add 1 mirror then add 1 more mirror during conversion
 prepare_lvs_
+lvs -a -o+devices $vg
 lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
+lvs -a -o+devices $vg
 check_mirror_count_ $vg/$lv1 2
 check_mirror_log_ $vg/$lv1
 lvconvert -m+1 -b $vg/$lv1 $dev4
+lvs -a -o+devices $vg
 lvconvert -m+1 -i3 $vg/$lv1 $dev5
+lvs -a -o+devices $vg
 check_no_tmplvs_ $vg/$lv1
 check_mirror_count_ $vg/$lv1 4
 mimages_are_redundant_ $vg $lv1
@@ -244,10 +266,13 @@
 
 # "add 1 mirror and disk log" 
 prepare_lvs_ 
+lvs -a -o+devices $vg
 lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2 
+lvs -a -o+devices $vg
 check_mirror_count_ $vg/$lv1 2 
 not_sh check_mirror_log_ $vg/$lv1 
 lvconvert -m+1 --mirrorlog disk -i1 $vg/$lv1 $dev4 $dev3:0
+lvs -a -o+devices $vg
 check_no_tmplvs_ $vg/$lv1 
 check_mirror_count_ $vg/$lv1 3 
 check_mirror_log_ $vg/$lv1 
@@ -260,13 +285,16 @@
 
 # convert inactive mirror and start polling
 prepare_lvs_
+lvs -a -o+devices $vg
 lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
+lvs -a -o+devices $vg
 check_mirror_count_ $vg/$lv1 2
 lvchange -an $vg/$lv1
 lvconvert -m+1 $vg/$lv1 $dev4
+lvs -a -o+devices $vg
 lvchange -ay $vg/$lv1
 wait_conversion_ $vg/$lv1
-lvs -a
+lvs -a -o+devices $vg
 check_no_tmplvs_ $vg/$lv1
 check_and_cleanup_lvs_
 
@@ -275,12 +303,17 @@
 
 # "remove newly added mirror" 
 prepare_lvs_ 
+lvs -a -o+devices $vg
 lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
+lvs -a -o+devices $vg
 check_mirror_count_ $vg/$lv1 2 
 check_mirror_log_ $vg/$lv1 
 lvconvert -m+1 -b $vg/$lv1 $dev4 
+lvs -a -o+devices $vg
 lvconvert -m-1 $vg/$lv1 $dev4 
+lvs -a -o+devices $vg
 wait_conversion_ $vg/$lv1 
+lvs -a -o+devices $vg
 check_no_tmplvs_ $vg/$lv1 
 check_mirror_count_ $vg/$lv1 2 
 mimages_are_redundant_ $vg $lv1 
@@ -289,13 +322,19 @@
 
 # "remove one of newly added mirrors" 
 prepare_lvs_ 
+lvs -a -o+devices $vg
 lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
+lvs -a -o+devices $vg
 check_mirror_count_ $vg/$lv1 2 
 check_mirror_log_ $vg/$lv1 
 lvconvert -m+2 -b $vg/$lv1 $dev4 $dev5 
+lvs -a -o+devices $vg
 lvconvert -m-1 $vg/$lv1 $dev4 
+lvs -a -o+devices $vg
 lvconvert -i1 $vg/$lv1 
+lvs -a -o+devices $vg
 wait_conversion_ $vg/$lv1 
+lvs -a -o+devices $vg
 check_no_tmplvs_ $vg/$lv1 
 check_mirror_count_ $vg/$lv1 3 
 mimages_are_redundant_ $vg $lv1 
@@ -304,13 +343,19 @@
 
 # "remove from original mirror (the original is still mirror)"
 prepare_lvs_ 
+lvs -a -o+devices $vg
 lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev5 $dev3:0
+lvs -a -o+devices $vg
 check_mirror_count_ $vg/$lv1 3 
 check_mirror_log_ $vg/$lv1 
 lvconvert -m+1 -b $vg/$lv1 $dev4 
+lvs -a -o+devices $vg
 lvconvert -m-1 $vg/$lv1 $dev2 
+lvs -a -o+devices $vg
 lvconvert -i1 $vg/$lv1 
+lvs -a -o+devices $vg
 wait_conversion_ $vg/$lv1 
+lvs -a -o+devices $vg
 check_no_tmplvs_ $vg/$lv1 
 check_mirror_count_ $vg/$lv1 3 
 mimages_are_redundant_ $vg $lv1 
@@ -319,13 +364,19 @@
 
 # "remove from original mirror (the original becomes linear)"
 prepare_lvs_ 
+lvs -a -o+devices $vg
 lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
+lvs -a -o+devices $vg
 check_mirror_count_ $vg/$lv1 2 
 check_mirror_log_ $vg/$lv1 
 lvconvert -m+1 -b $vg/$lv1 $dev4 
+lvs -a -o+devices $vg
 lvconvert -m-1 $vg/$lv1 $dev2 
+lvs -a -o+devices $vg
 lvconvert -i1 $vg/$lv1 
+lvs -a -o+devices $vg
 wait_conversion_ $vg/$lv1 
+lvs -a -o+devices $vg
 check_no_tmplvs_ $vg/$lv1 
 check_mirror_count_ $vg/$lv1 2 
 mimages_are_redundant_ $vg $lv1 
@@ -336,32 +387,45 @@
 
 # "rhbz440405: lvconvert -m0 incorrectly fails if all PEs allocated"
 prepare_lvs_ 
+lvs -a -o+devices $vg
 lvcreate -l`pvs --noheadings -ope_count $dev1` -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0 
+lvs -a -o+devices $vg
 check_mirror_count_ $vg/$lv1 2 
 check_mirror_log_ $vg/$lv1 
 lvconvert -m0 $vg/$lv1 $dev1 
+lvs -a -o+devices $vg
 check_no_tmplvs_ $vg/$lv1 
 check_mirror_count_ $vg/$lv1 1 
 check_and_cleanup_lvs_
 
 # "rhbz264241: lvm mirror doesn't lose it's "M" --nosync attribute after being down and the up converted"
 prepare_lvs_
+lvs -a -o+devices $vg
 lvcreate -l2 -m1 -n$lv1 --nosync $vg 
+lvs -a -o+devices $vg
 lvconvert -m0 $vg/$lv1
+lvs -a -o+devices $vg
 lvconvert -m1 $vg/$lv1
+lvs -a -o+devices $vg
 lvs --noheadings -o attr $vg/$lv1 | grep '^ *m'
 check_and_cleanup_lvs_
 
 # lvconvert from linear (on multiple PVs) to mirror
 prepare_lvs_
+lvs -a -o+devices $vg
 lvcreate -l 8 -n $lv1 $vg $dev1:0-3 $dev2:0-3
+lvs -a -o+devices $vg
 lvconvert -m1 $vg/$lv1
+lvs -a -o+devices $vg
 check_mirror_count_ $vg/$lv1 2
 check_mirror_log_ $vg/$lv1
 check_and_cleanup_lvs_
 
 # BZ 463272: disk log mirror convert option is lost if downconvert option is also given
 prepare_lvs_
+lvs -a -o+devices $vg
 lvcreate -l1 -m2 --corelog -n $lv1 $vg
+lvs -a -o+devices $vg
 lvconvert -m1 --mirrorlog disk $vg/$lv1
+lvs -a -o+devices $vg
 check_mirror_log_ $vg/$lv1


