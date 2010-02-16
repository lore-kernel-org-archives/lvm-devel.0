From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 16 Feb 2010 17:48:47 -0000
Subject: LVM2/test lvm-utils.sh t-vgchange-usage.sh
Message-ID: <20100216174847.26309.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-02-16 17:48:46

Modified files:
	test           : lvm-utils.sh t-vgchange-usage.sh 

Log message:
	Add get_{pv|vg|lv}_field() nightly test helper functions.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lvm-utils.sh.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgchange-usage.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/lvm-utils.sh	2010/01/11 15:43:19	1.19
+++ LVM2/test/lvm-utils.sh	2010/02/16 17:48:46	1.20
@@ -87,6 +87,28 @@
   test $val1 = $val2
 }
 
+
+get_pv_field() {
+	local pv=$1
+	local field=$2
+	local value
+	pvs --noheading -o $field $pv | sed 's/^ *//'
+}
+
+get_vg_field() {
+	local vg=$1
+	local field=$2
+	local value
+	vgs --noheading -o $field $vg | sed 's/^ *//'
+}
+
+get_lv_field() {
+	local lv=$1
+	local field=$2
+	local value
+	lvs --noheading -o $field $lv | sed 's/^ *//'
+}
+
 check_vg_field_()
 {
     local vg=$1;
--- LVM2/test/t-vgchange-usage.sh	2008/11/11 15:29:24	1.1
+++ LVM2/test/t-vgchange-usage.sh	2010/02/16 17:48:46	1.2
@@ -17,13 +17,6 @@
 pvcreate --metadatacopies 0 $dev1
 vgcreate $vg $devs
 
-get_vg_field() {
-	local vg=$1
-	local field=$2
-	local value
-	vgs --noheading -o $field $vg | sed 's/^ *//'
-}
-
 vgdisplay $vg
 
 # vgchange -p MaxPhysicalVolumes (bz202232)


