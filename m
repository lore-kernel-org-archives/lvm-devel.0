From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Mar 2010 11:47:00 -0000
Subject: LVM2/test t-mirror-lvconvert.sh
Message-ID: <20100325114700.4525.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-03-25 11:47:00

Modified files:
	test           : t-mirror-lvconvert.sh 

Log message:
	add debug mesgs and attempt to control which device is used for log as perhaps intended

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-lvconvert.sh.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/test/t-mirror-lvconvert.sh	2010/02/17 15:41:28	1.14
+++ LVM2/test/t-mirror-lvconvert.sh	2010/03/25 11:47:00	1.15
@@ -21,6 +21,7 @@
 
   rm -f out
   for i in $(lvs -odevices --noheadings $lv | sed 's/([^)]*)//g; s/,/ /g'); do
+    lvs -a -odevices --noheadings $vg/$i 
     lvs -a -odevices --noheadings $vg/$i | sed 's/([^)]*)//g; s/,/ /g' | \
       sort | uniq >> out
   done
@@ -36,6 +37,7 @@
   local lv=$1
 
   # if the lv has multiple segments, it's not contiguous
+  lvs -a --segments --noheadings $lv
   [ $(lvs -a --segments --noheadings $lv | wc -l) -ne 1 ] && return 1
 
   return 0
@@ -59,6 +61,7 @@
   local lv="$1"_mlog
   shift 1
   if ! lvs -a $lv; then return 0; fi # FIXME?
+  lvs -a -odevices --noheadings $lv
   lvs -a -odevices --noheadings $lv | sed 's/,/\n/g' > out
   for d in $*; do grep "$d(" out || return 1; done
   for d in $*; do grep -v "$d(" out > out2 || true; mv out2 out; done
@@ -100,6 +103,7 @@
 check_no_tmplvs_()
 {
   local lv=$1
+  lvs -a --noheadings -oname $(dirname $lv)
   lvs -a --noheadings -oname $(dirname $lv) > out
   ! grep tmp out
 }
@@ -146,7 +150,7 @@
 
 # add 1 mirror
 prepare_lvs_
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
 check_mirror_count_ $vg/$lv1 2
 check_mirror_log_ $vg/$lv1
 lvconvert -m+1 -i1 $vg/$lv1 $dev4
@@ -171,7 +175,7 @@
 
 # add 2 mirrors
 prepare_lvs_
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
 check_mirror_count_ $vg/$lv1 2
 check_mirror_log_ $vg/$lv1
 lvconvert -m+2 -i1 $vg/$lv1 $dev4 $dev5
@@ -224,7 +228,7 @@
 
 # add 1 mirror then add 1 more mirror during conversion
 prepare_lvs_
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
 check_mirror_count_ $vg/$lv1 2
 check_mirror_log_ $vg/$lv1
 lvconvert -m+1 -b $vg/$lv1 $dev4
@@ -243,7 +247,7 @@
 lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2 
 check_mirror_count_ $vg/$lv1 2 
 not_sh check_mirror_log_ $vg/$lv1 
-lvconvert -m+1 --mirrorlog disk -i1 $vg/$lv1 $dev4 $dev3:0-1 
+lvconvert -m+1 --mirrorlog disk -i1 $vg/$lv1 $dev4 $dev3:0
 check_no_tmplvs_ $vg/$lv1 
 check_mirror_count_ $vg/$lv1 3 
 check_mirror_log_ $vg/$lv1 
@@ -256,7 +260,7 @@
 
 # convert inactive mirror and start polling
 prepare_lvs_
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
 check_mirror_count_ $vg/$lv1 2
 lvchange -an $vg/$lv1
 lvconvert -m+1 $vg/$lv1 $dev4
@@ -271,7 +275,7 @@
 
 # "remove newly added mirror" 
 prepare_lvs_ 
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
 check_mirror_count_ $vg/$lv1 2 
 check_mirror_log_ $vg/$lv1 
 lvconvert -m+1 -b $vg/$lv1 $dev4 
@@ -285,7 +289,7 @@
 
 # "remove one of newly added mirrors" 
 prepare_lvs_ 
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
 check_mirror_count_ $vg/$lv1 2 
 check_mirror_log_ $vg/$lv1 
 lvconvert -m+2 -b $vg/$lv1 $dev4 $dev5 
@@ -300,7 +304,7 @@
 
 # "remove from original mirror (the original is still mirror)"
 prepare_lvs_ 
-lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev5 $dev3:0-1 
+lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev5 $dev3:0
 check_mirror_count_ $vg/$lv1 3 
 check_mirror_log_ $vg/$lv1 
 lvconvert -m+1 -b $vg/$lv1 $dev4 
@@ -315,7 +319,7 @@
 
 # "remove from original mirror (the original becomes linear)"
 prepare_lvs_ 
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
 check_mirror_count_ $vg/$lv1 2 
 check_mirror_log_ $vg/$lv1 
 lvconvert -m+1 -b $vg/$lv1 $dev4 


