From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 27 Jul 2009 21:13:56 -0000
Subject: LVM2/liblvm lvm.h
Message-ID: <20090727211356.21666.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-27 21:13:54

Modified files:
	liblvm         : lvm.h 

Log message:
	Add warning to lvm.h stating API development in progress.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.32&r2=1.33

--- LVM2/liblvm/lvm.h	2009/07/27 21:02:17	1.32
+++ LVM2/liblvm/lvm.h	2009/07/27 21:13:54	1.33
@@ -19,6 +19,16 @@
 
 #include <stdint.h>
 
+
+/******************************** WARNING ********************************/
+/*
+ * NOTE: This API is under development and subject to change at any time.
+ *
+ * Please send feedback to lvm-devel at redhat.com
+ */
+/******************************** WARNING ********************************/
+
+
 /******************************** structures ********************************/
 
 /* Internal object structures - do not use directly */


