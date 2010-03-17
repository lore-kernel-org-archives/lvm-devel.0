From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 17 Mar 2010 17:02:02 -0000
Subject: LVM2/test t-pvchange-usage.sh
Message-ID: <20100317170202.25416.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-03-17 17:02:01

Modified files:
	test           : t-pvchange-usage.sh 

Log message:
	Add pvchange -u --all to testsuite.
	
	This can be an interesting test case when using PVs with --metadatacopies 0.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvchange-usage.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/t-pvchange-usage.sh	2008/10/06 16:47:07	1.3
+++ LVM2/test/t-pvchange-usage.sh	2010/03/17 17:02:01	1.4
@@ -46,6 +46,8 @@
 pvchange -u $dev1 
 pvchange -u $dev2 
 vg_validate_pvlv_counts_ $vg1 2 0 0
+pvchange -u --all
+vg_validate_pvlv_counts_ $vg1 2 0 0
 
 # "pvchange rejects uuid change under an active lv" 
 lvcreate -l 16 -i 2 -n $lv --alloc anywhere $vg1 


