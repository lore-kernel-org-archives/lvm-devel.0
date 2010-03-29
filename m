From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 29 Mar 2010 16:40:51 -0000
Subject: LVM2/test t-vgsplit-operation.sh
Message-ID: <20100329164051.1015.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-03-29 16:40:51

Modified files:
	test           : t-vgsplit-operation.sh 

Log message:
	Enforce distinct-PV allocation of snapshot/origin pairs in vgsplit test.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-operation.sh.diff?cvsroot=lvm2&r1=1.24&r2=1.25

--- LVM2/test/t-vgsplit-operation.sh	2009/12/28 18:33:04	1.24
+++ LVM2/test/t-vgsplit-operation.sh	2010/03/29 16:40:51	1.25
@@ -195,8 +195,8 @@
 COMM "vgsplit fails splitting one LV with 2 snapshots, only origin LV specified" 
 vgcreate -c n $vg1 $dev1 $dev2 $dev3 $dev4 
 lvcreate -l 16 -n $lv1 $vg1 $dev1 $dev2 
-lvcreate -l 4 -n $lv2 -s $vg1/$lv1 
-lvcreate -l 4 -n $lv3 -s $vg1/$lv1 
+lvcreate -l 4 -n $lv2 -s $vg1/$lv1 $dev3
+lvcreate -l 4 -n $lv3 -s $vg1/$lv1 $dev4
 vg_validate_pvlv_counts_ $vg1 4 3 2 
 vgchange -an $vg1 
 not vgsplit -n $lv1 $vg1 $vg2;
@@ -208,8 +208,8 @@
 COMM "vgsplit fails splitting one LV with 2 snapshots, only snapshot LV specified" 
 vgcreate -c n $vg1 $dev1 $dev2 $dev3 $dev4 
 lvcreate -l 16 -n $lv1 $vg1 $dev1 $dev2 
-lvcreate -l 4 -n $lv2 -s $vg1/$lv1 
-lvcreate -l 4 -n $lv3 -s $vg1/$lv1 
+lvcreate -l 4 -n $lv2 -s $vg1/$lv1 $dev3
+lvcreate -l 4 -n $lv3 -s $vg1/$lv1 $dev4
 vg_validate_pvlv_counts_ $vg1 4 3 2 
 vgchange -an $vg1 
 not vgsplit -n $lv2 $vg1 $vg2


