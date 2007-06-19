From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 19 Jun 2007 10:51:52 -0000
Subject: LVM2 ./WHATS_NEW tools/lvm2cmd.c
Message-ID: <20070619105152.31327.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2007-06-19 10:51:52

Modified files:
	.              : WHATS_NEW 
	tools          : lvm2cmd.c 

Log message:
	Fix missing lvm_shell symbol in lvm2cmd library. (2.02.23)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.638&r2=1.639
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm2cmd.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2007/06/19 04:23:31	1.638
+++ LVM2/WHATS_NEW	2007/06/19 10:51:51	1.639
@@ -1,5 +1,6 @@
 Version 2.02.27 - 
 ================================
+  Fix missing lvm_shell symbol in lvm2cmd library. (2.02.23)
   Add vg_status function and clean up vg->status in tools directory.
   Add --ignoremonitoring to disable all dmeventd interaction.
   Remove get_ prefix from get_pv_* functions.
--- LVM2/tools/lvm2cmd.c	2006/08/18 21:17:18	1.1
+++ LVM2/tools/lvm2cmd.c	2007/06/19 10:51:51	1.2
@@ -19,3 +19,8 @@
 {
 	return cmdlib_lvm2_init(0);
 }
+
+int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
+{
+	return 0;
+}


