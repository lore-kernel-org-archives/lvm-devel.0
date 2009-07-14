From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 14 Jul 2009 03:02:44 -0000
Subject: LVM2/liblvm .exported_symbols
Message-ID: <20090714030244.30426.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-14 03:02:44

Modified files:
	liblvm         : .exported_symbols 

Log message:
	Add VG APIs to liblvm/.exported_symbols.
	
	Add the following VG APIs to liblvm/.exported_symbols:
	-lvm_reload_config
	-lvm_vg_create
	-lvm_vg_extend
	-lvm_vg_set_extent_size
	-lvm_vg_write
	-lvm_vg_close
	-lvm_vg_remove
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	Acked-by: Alasdair G Kergon <agk@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/.exported_symbols.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/liblvm/.exported_symbols	2009/03/08 18:58:53	1.1
+++ LVM2/liblvm/.exported_symbols	2009/07/14 03:02:44	1.2
@@ -1,3 +1,9 @@
 lvm_create
 lvm_destroy
-lvm_reload_config
\ No newline at end of file
+lvm_reload_config
+lvm_vg_create
+lvm_vg_extend
+lvm_vg_set_extent_size
+lvm_vg_write
+lvm_vg_close
+lvm_vg_remove


