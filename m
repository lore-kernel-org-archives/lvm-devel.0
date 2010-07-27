From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 27 Jul 2010 21:08:33 -0000
Subject: LVM2/test t-nomda-missing.sh
Message-ID: <20100727210833.14082.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-07-27 21:08:33

Modified files:
	test           : t-nomda-missing.sh 

Log message:
	Do not create a clustered volume group in t-nomda-missing.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-nomda-missing.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/t-nomda-missing.sh	2010/07/27 20:05:29	1.1
+++ LVM2/test/t-nomda-missing.sh	2010/07/27 21:08:32	1.2
@@ -5,7 +5,7 @@
 prepare_devs 4
 pvcreate $dev1 $dev2
 pvcreate --metadatacopies 0 $dev3 $dev4
-vgcreate $vg $dev1 $dev2 $dev3 $dev4
+vgcreate -c n $vg $dev1 $dev2 $dev3 $dev4
 
 lvcreate -l1 -n linear1 $vg $dev1
 lvcreate -l1 -n linear2 $vg $dev2


