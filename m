From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 11 May 2009 16:17:13 -0000
Subject: LVM2/test t-read-ahead.sh
Message-ID: <20090511161713.11722.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-05-11 16:17:12

Modified files:
	test           : t-read-ahead.sh 

Log message:
	Update t-read-ahead.sh to validate lv_read_ahead and lv_kernel_read_ahead.
	
	- check default values
	- check active/inactive values

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-read-ahead.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/test/t-read-ahead.sh	2008/11/10 12:43:35	1.4
+++ LVM2/test/t-read-ahead.sh	2009/05/11 16:17:12	1.5
@@ -43,3 +43,13 @@
 check_lvs_ lv_read_ahead 400                                   
 lvremove -ff "$vg"
 
+# Check default, active/inactive values for read_ahead / kernel_read_ahead
+lvcreate -n $lv -l 50%FREE $vg
+lvchange -an $vg/$lv
+check_lv_field_ $vg/$lv lv_read_ahead auto
+check_lv_field_ $vg/$lv lv_kernel_read_ahead -1
+lvchange -r 512 $vg/$lv
+lvchange -ay $vg/$lv
+check_lv_field_ $vg/$lv lv_read_ahead 256.00K
+check_lv_field_ $vg/$lv lv_kernel_read_ahead 256.00K
+lvremove -ff $vg


