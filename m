From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 27 Jul 2009 21:02:36 -0000
Subject: LVM2/liblvm lvm_base.c
Message-ID: <20090727210236.9185.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-27 21:02:35

Modified files:
	liblvm         : lvm_base.c 

Log message:
	Update return code for lvm_config_reload.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_base.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/liblvm/lvm_base.c	2009/07/27 21:02:17	1.7
+++ LVM2/liblvm/lvm_base.c	2009/07/27 21:02:35	1.8
@@ -67,7 +67,7 @@
 int lvm_config_reload(lvm_t libh)
 {
 	/* FIXME: re-init locking needed here? */
-	if (refresh_toolcontext((struct cmd_context *)libh))
+	if (!refresh_toolcontext((struct cmd_context *)libh))
 		return -1;
 	return 0;
 }


