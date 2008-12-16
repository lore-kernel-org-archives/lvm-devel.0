From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 16 Dec 2008 20:02:52 -0000
Subject: LVM2/test t-pvcreate-operation.sh
Message-ID: <20081216200252.11724.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-12-16 20:02:52

Modified files:
	test           : t-pvcreate-operation.sh 

Log message:
	Remove status=noxfer from test, not all dd versions support this (RHEL4 for example).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/test/t-pvcreate-operation.sh	2008/11/11 15:46:15	1.13
+++ LVM2/test/t-pvcreate-operation.sh	2008/12/16 20:02:52	1.14
@@ -82,7 +82,7 @@
 do
 # pvcreate (lvm2) succeeds writing LVM label at sector $i
     pvcreate --labelsector $i $dev1
-    dd if=$dev1 bs=512 skip=$i count=1 status=noxfer 2>&1 | strings | grep -q LABELONE;
+    dd if=$dev1 bs=512 skip=$i count=1 2>/dev/null | strings | grep -q LABELONE;
     pvremove -f $dev1
 done
 


