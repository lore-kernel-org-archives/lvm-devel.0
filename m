From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 2 Aug 2009 21:03:09 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/no_locking.c
Message-ID: <20090802210309.20342.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-08-02 21:03:09

Modified files:
	.              : WHATS_NEW 
	lib/locking    : no_locking.c 

Log message:
	Allow LV suspend while --ignorelockingfailure is in force.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1226&r2=1.1227
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/no_locking.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/WHATS_NEW	2009/08/02 21:01:51	1.1226
+++ LVM2/WHATS_NEW	2009/08/02 21:03:09	1.1227
@@ -1,5 +1,6 @@
 Version 2.02.51 - 
 ================================
+  Allow LV suspend while --ignorelockingfailure is in force.
   Update synopsis in lvconvert manpage to mention --repair.
   Set cookies in activation code and wait for udev to complete processing.
   Added configure --enable-udev_rules --enable-udev_sync.
--- LVM2/lib/locking/no_locking.c	2009/07/15 06:11:25	1.17
+++ LVM2/lib/locking/no_locking.c	2009/08/02 21:03:09	1.18
@@ -70,7 +70,8 @@
 				   const char *resource,
 				   uint32_t flags)
 {
-	if ((flags & LCK_TYPE_MASK) == LCK_WRITE) {
+	if ((flags & LCK_TYPE_MASK) == LCK_WRITE &&
+	    (flags & LCK_SCOPE_MASK) == LCK_VG) {
 		log_error("Write locks are prohibited with --ignorelockingfailure.");
 		return 0;
 	}


