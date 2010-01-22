From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 22 Jan 2010 12:38:17 -0000
Subject: LVM2/daemons/dmeventd/plugins/lvm2 .exported_s ...
Message-ID: <20100122123817.10298.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-01-22 12:38:16

Modified files:
	daemons/dmeventd/plugins/lvm2: .exported_symbols 

Log message:
	Fix exported symbols for lvm2 dmeventd wrapper.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/lvm2/.exported_symbols.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/daemons/dmeventd/plugins/lvm2/.exported_symbols	2010/01/21 22:15:46	1.1
+++ LVM2/daemons/dmeventd/plugins/lvm2/.exported_symbols	2010/01/22 12:38:16	1.2
@@ -1,6 +1,6 @@
-init_lvm
-fini_lvm
-lock_lvm
-unlock_lvm
-lvm_pool
-lvm_handle
+dmeventd_lvm2_init
+dmeventd_lvm2_exit
+dmeventd_lvm2_lock
+dmeventd_lvm2_unlock
+dmeventd_lvm2_pool
+dmeventd_lvm2_run


