From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 8 May 2009 05:15:53 -0000
Subject: LVM2/test t-vgcreate-usage.sh
Message-ID: <20090508051553.13733.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-05-08 05:15:52

Modified files:
	test           : t-vgcreate-usage.sh 

Log message:
	Add tests to check vgcreate --physicalextentsize and field vg_extent_size.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgcreate-usage.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/test/t-vgcreate-usage.sh	2008/11/10 12:43:35	1.6
+++ LVM2/test/t-vgcreate-usage.sh	2009/05/08 05:15:52	1.7
@@ -66,3 +66,16 @@
 
 #COMM "vgcreate fails when the only pv has --metadatacopies 0"
 not vgcreate $vg $dev3
+
+# Test default (4MB) vg_extent_size as well as limits of extent_size
+not vgcreate --physicalextentsize 0K $vg $dev1 $dev2
+vgcreate $vg $dev1 $dev2
+check_vg_field_ $vg vg_extent_size 4.00M
+vgremove -ff $vg
+vgcreate --physicalextentsize 1K $vg $dev1 $dev2
+check_vg_field_ $vg vg_extent_size 1.00K
+vgremove -ff $vg
+not vgcreate --physicalextentsize 3K $vg $dev1 $dev2
+not vgcreate --physicalextentsize 1024T $vg $dev1 $dev2
+#not vgcreate --physicalextentsize 1T $vg $dev1 $dev2
+# FIXME: vgcreate allows physicalextentsize larger than pv size!


