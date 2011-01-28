From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Jan 2011 16:11:14 -0000
Subject: LVM2/test/api percent.sh
Message-ID: <20110128161114.32321.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-28 16:11:14

Modified files:
	test/api       : percent.sh 

Log message:
	Query only test related vg name

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/percent.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/test/api/percent.sh	2011/01/07 15:04:52	1.4
+++ LVM2/test/api/percent.sh	2011/01/28 16:11:14	1.5
@@ -23,5 +23,5 @@
 lvcreate -s -n snap2 $vg/foo -l 6 -c 4k
 dd if=/dev/urandom of=$DM_DEV_DIR/$vg/snap2 count=1 bs=1024
 lvcreate -m 1 -n mirr $vg -l 1 --mirrorlog core
-lvs
+lvs $vg
 aux apitest percent $vg


