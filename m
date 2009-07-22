From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 22 Jul 2009 03:13:14 -0000
Subject: LVM2/liblvm .exported_symbols
Message-ID: <20090722031314.26380.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-22 03:13:13

Modified files:
	liblvm         : .exported_symbols 

Log message:
	Export lvm_errno and lvm_errmsg in liblvm.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/.exported_symbols.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/liblvm/.exported_symbols	2009/07/14 03:02:44	1.2
+++ LVM2/liblvm/.exported_symbols	2009/07/22 03:13:13	1.3
@@ -7,3 +7,5 @@
 lvm_vg_write
 lvm_vg_close
 lvm_vg_remove
+lvm_errno
+lvm_errmsg


