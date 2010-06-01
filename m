From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 1 Jun 2010 21:46:29 -0000
Subject: LVM2/lib/commands toolcontext.c
Message-ID: <20100601214629.19296.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-01 21:46:29

Modified files:
	lib/commands   : toolcontext.c 

Log message:
	Do not fail lvm_init() if init_logging() generates an errno.
	
	Revert to original behavior of lvm commands if init_logging() generated an
	errno.  Fixes rhbz 592967.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.98&r2=1.99

--- LVM2/lib/commands/toolcontext.c	2010/05/21 12:36:31	1.98
+++ LVM2/lib/commands/toolcontext.c	2010/06/01 21:46:29	1.99
@@ -195,6 +195,7 @@
 	dm_log_with_errno_init(print_log);
 #endif
 	reset_log_duplicated();
+	reset_lvm_errno(1);
 }
 
 static int _process_config(struct cmd_context *cmd)


