From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 15 Jul 2009 05:57:12 -0000
Subject: LVM2/lib/locking locking_types.h
Message-ID: <20090715055712.8593.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-07-15 05:57:11

Modified files:
	lib/locking    : locking_types.h 

Log message:
	Fix bad prototype from previous checkin.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking_types.h.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/lib/locking/locking_types.h	2009/07/15 05:49:48	1.18
+++ LVM2/lib/locking/locking_types.h	2009/07/15 05:57:11	1.19
@@ -40,7 +40,7 @@
  */
 int init_no_locking(struct locking_type *locking, struct cmd_context *cmd);
 
-int init_boottime_locking(struct locking_type *locking, struct cmd_context *cmd);
+int init_readonly_locking(struct locking_type *locking, struct cmd_context *cmd);
 
 int init_file_locking(struct locking_type *locking, struct cmd_context *cmd);
 


