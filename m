From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jul 2011 08:41:53 -0000
Subject: LVM2/test t-lvcreate-operation.sh
Message-ID: <20110725084153.16148.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-07-25 08:41:53

Modified files:
	test           : t-lvcreate-operation.sh 

Log message:
	Add simple test for read-only table reload suppression
	
	Just a small test for previous libdm commit.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/test/t-lvcreate-operation.sh	2011/01/05 00:16:20	1.6
+++ LVM2/test/t-lvcreate-operation.sh	2011/07/25 08:41:52	1.7
@@ -29,6 +29,7 @@
 # Create snapshots of LVs on --metadatacopies 0 PV (bz450651)
 lvcreate -n$lv1 -l4 $vg $dev1
 lvcreate -n$lv2 -l4 -s $vg/$lv1
+lvcreate -n$lv3 -l4 --permission r -s $vg/$lv1
 cleanup_lvs
 
 # ---


