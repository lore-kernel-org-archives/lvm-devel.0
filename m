From: mpatocka@sourceware.org <mpatocka@sourceware.org>
Date: Mon, 13 Jul 2009 23:16:35 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20090713231617.334.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mpatocka at sourceware.org	2009-07-13 23:16:17

Modified files:
	.              : WHATS_NEW 

Log message:
	WHATS_NEW

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1178&r2=1.1179

--- LVM2/WHATS_NEW	2009/07/13 19:49:48	1.1178
+++ LVM2/WHATS_NEW	2009/07/13 23:16:17	1.1179
@@ -1,5 +1,7 @@
 Version 2.02.49 - 
 ================================
+  Changed exit() to _exit() after fork(); avoid flushing libc buffers twice.
+  Fixed invalid type being passed as printf argument on Sparc64.
   Make cmd->cmd_line const.
   Fix dev name mismatch in vgcreate man page example.
   Refactor vg_remove_single for use in liblvm.


