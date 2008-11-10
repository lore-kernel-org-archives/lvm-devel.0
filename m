From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 10 Nov 2008 12:37:04 -0000
Subject: LVM2/test t-lvcreate-usage.sh
Message-ID: <20081110123704.486.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-11-10 12:37:03

Modified files:
	test           : t-lvcreate-usage.sh 

Log message:
	Add bz186013 check -- lvcreate rejects an invalid regionsize (jstava).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/test/t-lvcreate-usage.sh	2008/09/30 17:50:56	1.8
+++ LVM2/test/t-lvcreate-usage.sh	2008/11/10 12:37:03	1.9
@@ -13,9 +13,11 @@
 
 . ./test-utils.sh
 
-aux prepare_vg 2
+aux prepare_pvs 2
+aux pvcreate --metadatacopies 0 $dev1
+vgcreate -cn $vg $devs
 
-# "lvcreate rejects repeated invocation (run 2 times)" 
+# "lvcreate rejects repeated invocation (run 2 times) (bz178216)" 
 lvcreate -n $lv -l 4 $vg 
 not lvcreate -n $lv -l 4 $vg
 lvremove -ff $vg/$lv
@@ -46,6 +48,10 @@
 not lvcreate -L 64M -n $lv -i129 $vg 2>err
 grep "^  Number of stripes (129) must be between 1 and 128\$" err
 
+# 'lvcreate rejects an invalid regionsize (bz186013)' 
+not lvcreate -L 64M -n $lv -R0 $vg 2>err
+grep "Non-zero region size must be supplied." err
+
 # The case on lvdisplay output is to verify that the LV was not created.
 # 'lvcreate rejects an invalid stripe size'
 not lvcreate -L 64M -n $lv -i2 --stripesize 3 $vg 2>err


