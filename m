From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 9 May 2012 14:45:00 -0000
Subject: LVM2/test/shell pvcreate-operation.sh
Message-ID: <20120509144500.9162.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-05-09 14:44:59

Modified files:
	test/shell     : pvcreate-operation.sh 

Log message:
	Remove VG/PV used in the test.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/pvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/shell/pvcreate-operation.sh	2012/05/09 12:30:59	1.3
+++ LVM2/test/shell/pvcreate-operation.sh	2012/05/09 14:44:59	1.4
@@ -118,6 +118,8 @@
 vgcreate $vg1 $dev1
 vgcfgbackup -f $backupfile
 vgcfgrestore -f $backupfile $vg1
+vgremove -f $vg1
+pvremove -f $dev1
 
 # pvcreate wipes swap signature when forced
 dd if=/dev/zero of="$dev1" bs=1024 count=64


