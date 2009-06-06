From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 6 Jun 2009 16:40:39 -0000
Subject: LVM2/test t-pvcreate-operation.sh t-pvcreate-u ...
Message-ID: <20090606164039.5791.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-06-06 16:40:39

Modified files:
	test           : t-pvcreate-operation.sh t-pvcreate-usage.sh 
	                 t-read-ahead.sh 

Log message:
	Fix various problems in tests
	
	- PPC uses 64k page, some caculations are wrong in tests
	- file utility is buggy on PPC and cannot detect swap, use blkid instead
	- read ahead is quietly rounded down according to page size
	(for now use some common divisor value in test)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-read-ahead.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/test/t-pvcreate-operation.sh	2009/03/17 13:59:56	1.15
+++ LVM2/test/t-pvcreate-operation.sh	2009/06/06 16:40:39	1.16
@@ -112,6 +112,6 @@
 # pvcreate wipes swap signature when forced
 dd if=/dev/zero of=$dev1 bs=1024 count=64
 mkswap $dev1
-file -s $dev1 | grep "swap file"
+blkid -c /dev/null $dev1 | grep "swap"
 pvcreate -f $dev1
-file -s $dev1 | not grep "swap file"
+blkid -c /dev/null $dev1 | not grep "swap"
--- LVM2/test/t-pvcreate-usage.sh	2009/05/08 06:10:45	1.10
+++ LVM2/test/t-pvcreate-usage.sh	2009/06/06 16:40:39	1.11
@@ -10,6 +10,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description='Test pvcreate option values'
+PAGESIZE=$(getconf PAGESIZE)
 
 . ./test-utils.sh
 
@@ -101,11 +102,19 @@
 pvcreate --metadatasize 100k --dataalignment 100k $dev1
 check_pv_field_ $dev1 pe_start 200.00K
 
+# metadata area start is aligned according to pagesize
+# pagesize should be 64k or 4k ...
+if [ $PAGESIZE -eq 65536 ] ; then
+	pv_align="192.50K"
+else
+	pv_align="133.00K"
+fi
+
 pvcreate --metadatasize 128k --dataalignment 3.5k $dev1
-check_pv_field_ $dev1 pe_start 133.00K
+check_pv_field_ $dev1 pe_start $pv_align
 
 pvcreate --metadatasize 128k --metadatacopies 2 --dataalignment 3.5k $dev1
-check_pv_field_ $dev1 pe_start 133.00K
+check_pv_field_ $dev1 pe_start $pv_align
 
 #COMM 'pv with LVM1 compatible data alignment can be convereted'
 #compatible == LVM1_PE_ALIGN == 64k
--- LVM2/test/t-read-ahead.sh	2009/05/20 11:27:14	1.7
+++ LVM2/test/t-read-ahead.sh	2009/06/06 16:40:39	1.8
@@ -39,8 +39,8 @@
 lvchange -r auto "$vg"/"$lv" 2>&1 | grep auto
 check_lvs_ lv_read_ahead auto
 check_lvs_ lv_kernel_read_ahead 5120
-lvchange -r 400 "$vg/$lv"
-check_lvs_ lv_read_ahead 400
+lvchange -r 640 "$vg/$lv"
+check_lvs_ lv_read_ahead 640
 lvremove -ff "$vg"
 
 #COMM "read ahead is properly inherited from underlying PV"


