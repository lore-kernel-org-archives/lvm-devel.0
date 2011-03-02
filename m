From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 2 Mar 2011 20:14:40 -0000
Subject: LVM2/test t-mirror-names.sh
Message-ID: <20110302201440.22086.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-03-02 20:14:40

Modified files:
	test           : t-mirror-names.sh 

Log message:
	Increase check timeout again.
	
	It fails on my s390x Hercules emulator otherwise. :)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-names.sh.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/test/t-mirror-names.sh	2011/01/05 00:16:20	1.8
+++ LVM2/test/t-mirror-names.sh	2011/03/02 20:14:39	1.9
@@ -120,7 +120,7 @@
 
 #COMM "converting mirror names is ${lv1}_mimagetmp_2"
 lvcreate -l2 -m1 -n $lv1 $vg 
-lvconvert -m+1 -i+10 -b $vg/$lv1
+lvconvert -m+1 -i+40 -b $vg/$lv1
 convlv=$(lv_convert_lv_ "$vg/$lv1") 
 test "$convlv" = "$lv1"_mimagetmp_2 
 lv_devices_ $vg/$lv1 "$convlv" "$lv1"_mimage_2 


