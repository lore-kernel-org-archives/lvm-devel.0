From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 15 Jul 2009 06:11:25 -0000
Subject: LVM2/lib/locking no_locking.c
Message-ID: <20090715061125.32574.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-07-15 06:11:25

Modified files:
	lib/locking    : no_locking.c 

Log message:
	Fix warning.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/no_locking.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/lib/locking/no_locking.c	2009/07/15 05:49:48	1.16
+++ LVM2/lib/locking/no_locking.c	2009/07/15 06:11:25	1.17
@@ -70,7 +70,7 @@
 				   const char *resource,
 				   uint32_t flags)
 {
-	if (flags & LCK_TYPE_MASK == LCK_WRITE) {
+	if ((flags & LCK_TYPE_MASK) == LCK_WRITE) {
 		log_error("Write locks are prohibited with --ignorelockingfailure.");
 		return 0;
 	}


