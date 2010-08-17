From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Aug 2010 22:01:42 -0000
Subject: LVM2/test t-lvconvert-mirror.sh
Message-ID: <20100817220142.15558.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-08-17 22:01:41

Modified files:
	test           : t-lvconvert-mirror.sh 

Log message:
	Attempt to fix buildbot failure in t-lvconvert-mirror.sh due to failing to
	wait for mirror to get into sync before running subsequent command.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/test/t-lvconvert-mirror.sh	2010/05/12 10:08:35	1.6
+++ LVM2/test/t-lvconvert-mirror.sh	2010/08/17 22:01:41	1.7
@@ -222,6 +222,7 @@
 # BZ 463272: disk log mirror convert option is lost if downconvert option is also given
 aux prepare_vg 5
 lvcreate -l1 -m2 --corelog -n $lv1 $vg $dev1 $dev2 $dev3
+while [ `lvs --noheadings -o copy_percent $vg/$lv1` != "100.00" ]; do sleep 1; done
 lvconvert -m1 --mirrorlog disk $vg/$lv1 $dev1
 check mirror $vg $lv1 $dev1
 


