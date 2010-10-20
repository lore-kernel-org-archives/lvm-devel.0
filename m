From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 20 Oct 2010 15:35:00 -0000
Subject: LVM2/test t-mirror-names.sh
Message-ID: <20101020153500.2139.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-10-20 15:35:00

Modified files:
	test           : t-mirror-names.sh 

Log message:
	Reduce a (huge) timeout in t-mirror-names.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-names.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/test/t-mirror-names.sh	2010/04/07 16:00:19	1.6
+++ LVM2/test/t-mirror-names.sh	2010/10/20 15:35:00	1.7
@@ -120,7 +120,7 @@
 
 #COMM "converting mirror names is ${lv1}_mimagetmp_2"
 lvcreate -l2 -m1 -n $lv1 $vg 
-lvconvert -m+1 -i+1000 -b $vg/$lv1
+lvconvert -m+1 -i+10 -b $vg/$lv1
 convlv=$(lv_convert_lv_ "$vg/$lv1") 
 test "$convlv" = "$lv1"_mimagetmp_2 
 lv_devices_ $vg/$lv1 "$convlv" "$lv1"_mimage_2 


