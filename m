From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 8 May 2009 06:10:48 -0000
Subject: LVM2/test lvm-utils.sh t-pvcreate-usage.sh
Message-ID: <20090508061048.20292.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-05-08 06:10:47

Modified files:
	test           : lvm-utils.sh t-pvcreate-usage.sh 

Log message:
	Add tests to check pv_mda_size and vg_mda_size.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lvm-utils.sh.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/test/lvm-utils.sh	2009/01/10 12:19:41	1.17
+++ LVM2/test/lvm-utils.sh	2009/05/08 06:10:45	1.18
@@ -50,6 +50,26 @@
   return 0;
 }
 
+compare_two_fields_()
+{
+    local cmd1=$1;
+    local obj1=$2;
+    local field1=$3;
+    local cmd2=$4;
+    local obj2=$5;
+    local field2=$6;
+    local val1;
+    local val2;
+
+    val1=$($cmd1 --noheadings -o $field1 $obj1)
+    val2=$($cmd2 --noheadings -o $field2 $obj2)
+if test "$verbose" = "t"
+then
+  echo "compare_two_fields_ $obj1($field1): $val1 $obj2($field2): $val2"
+fi
+  test $val1 = $val2
+}
+
 compare_vg_field_()
 {
     local vg1=$1;
--- LVM2/test/t-pvcreate-usage.sh	2009/05/07 12:11:51	1.9
+++ LVM2/test/t-pvcreate-usage.sh	2009/05/08 06:10:45	1.10
@@ -29,6 +29,13 @@
 pvcreate --metadatasize 0 $dev1
 pvremove $dev1
 
+#Verify vg_mda_size is smaller pv_mda_size
+pvcreate --metadatasize 512K $dev1
+pvcreate --metadatasize 96K $dev2
+vgcreate $vg $dev1 $dev2
+compare_two_fields_ vgs $vg vg_mda_size pvs $dev2 pv_mda_size
+vgremove -ff $vg
+
 # x. metadatasize too large
 # For some reason we allow this, even though there's no room for data?
 ##COMM  'pvcreate rejects metadatasize too large' 


