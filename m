From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 1 Jun 2010 21:47:58 -0000
Subject: LVM2 lib/commands/toolcontext.c ./WHATS_NEW
Message-ID: <20100601214758.19602.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-01 21:47:57

Modified files:
	lib/commands   : toolcontext.c 
	.              : WHATS_NEW 

Log message:
	Revert _init_rand() to reset errno - restores original init behavior.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.99&r2=1.100
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1602&r2=1.1603

--- LVM2/lib/commands/toolcontext.c	2010/06/01 21:46:29	1.99
+++ LVM2/lib/commands/toolcontext.c	2010/06/01 21:47:57	1.100
@@ -1084,10 +1084,13 @@
 
 static void _init_rand(struct cmd_context *cmd)
 {
-	if (read_urandom(&cmd->rand_seed, sizeof(cmd->rand_seed)))
+	if (read_urandom(&cmd->rand_seed, sizeof(cmd->rand_seed))) {
+		reset_lvm_errno(1);
 		return;
+	}
 
 	cmd->rand_seed = (unsigned) time(NULL) + (unsigned) getpid();
+	reset_lvm_errno(1);
 }
 
 static void _init_globals(struct cmd_context *cmd)
--- LVM2/WHATS_NEW	2010/06/01 19:02:12	1.1602
+++ LVM2/WHATS_NEW	2010/06/01 21:47:57	1.1603
@@ -1,5 +1,6 @@
 Version 2.02.67 -
 ===============================
+  Do not fail lvm_init() if init_logging() or _init_rand() generates an errno.
   Don't merge unchanged persistent cache file before dumping if tool scanned.
   Fix incorrect memory pool deallocation while using vg_read for files.
   Add --type parameter description to the lvcreate man page.


