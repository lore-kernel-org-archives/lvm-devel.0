From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 29 Mar 2010 16:50:28 -0000
Subject: LVM2/test t-mirror-lvconvert.sh
Message-ID: <20100329165028.4394.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-03-29 16:50:28

Modified files:
	test           : t-mirror-lvconvert.sh 

Log message:
	Work around a problem in t-mirror-lvconvert: different PV order on the
	commandline of lvconvert can lead to allocation failures even if enough space
	is available. A separate testcase demonstrating the problem will follow.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-lvconvert.sh.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/test/t-mirror-lvconvert.sh	2010/03/26 22:15:44	1.17
+++ LVM2/test/t-mirror-lvconvert.sh	2010/03/29 16:50:27	1.18
@@ -267,11 +267,12 @@
 # "add 1 mirror and disk log" 
 prepare_lvs_ 
 lvs -a -o+devices $vg
-lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2 
+lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
 lvs -a -o+devices $vg
 check_mirror_count_ $vg/$lv1 2 
 not_sh check_mirror_log_ $vg/$lv1 
-lvconvert -m+1 --mirrorlog disk -i1 $vg/$lv1 $dev4 $dev3:0
+# FIXME on next line, specifying $dev4 $dev3:0 (i.e log device device last) fails (!)
+lvconvert -m+1 --mirrorlog disk -i1 $vg/$lv1 $dev3:0 $dev4 
 lvs -a -o+devices $vg
 check_no_tmplvs_ $vg/$lv1 
 check_mirror_count_ $vg/$lv1 3 


