From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 3 Aug 2009 12:11:45 -0000
Subject: LVM2/liblvm lvm2app.h lvm_vg.c
Message-ID: <20090803121145.22909.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-08-03 12:11:45

Modified files:
	liblvm         : lvm2app.h lvm_vg.c 

Log message:
	Move FIXME from user visible lvm2app.h to lvm_vg.c
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm2app.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25

--- LVM2/liblvm/lvm2app.h	2009/07/29 18:38:27	1.2
+++ LVM2/liblvm/lvm2app.h	2009/08/03 12:11:45	1.3
@@ -265,7 +265,6 @@
 
 /**
  * Scan all devices on the system for VGs and LVM metadata.
- * FIXME: Elaborate on when to use, side-effects, .cache file, etc
  *
  * \return
  * 0 (success) or -1 (failure).
--- LVM2/liblvm/lvm_vg.c	2009/07/29 13:26:01	1.24
+++ LVM2/liblvm/lvm_vg.c	2009/08/03 12:11:45	1.25
@@ -309,6 +309,9 @@
 	return get_vgids((struct cmd_context *)libh, 0);
 }
 
+/*
+ * FIXME: Elaborate on when to use, side-effects, .cache file, etc
+ */
 int lvm_scan(lvm_t libh)
 {
 	if (!lvmcache_label_scan((struct cmd_context *)libh, 2))


