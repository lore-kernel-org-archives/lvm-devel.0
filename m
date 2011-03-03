From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 3 Mar 2011 14:16:09 -0000
Subject: LVM2/test t-pvremove-usage.sh
Message-ID: <20110303141609.14434.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-03-03 14:16:08

Modified files:
	test           : t-pvremove-usage.sh 

Log message:
	Fix test, "echo n" is not needed when -y is specified.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvremove-usage.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/test/t-pvremove-usage.sh	2011/01/05 00:16:20	1.7
+++ LVM2/test/t-pvremove-usage.sh	2011/03/03 14:16:08	1.8
@@ -60,7 +60,7 @@
     vgextend $vg $dev1
 
     # pvremove -ff -y is sufficient when pv in a vg (---metadatacopies $mdacp)" '
-    echo n | pvremove -ff -y $dev1
+    pvremove -ff -y $dev1
 
     vgreduce --removemissing $vg
     pvcreate --metadatacopies $mdacp $dev1


