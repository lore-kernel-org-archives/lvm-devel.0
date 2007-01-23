From: agk@sourceware.org <agk@sourceware.org>
Date: 23 Jan 2007 16:03:54 -0000
Subject: LVM2 ./WHATS_NEW lib/commands/toolcontext.c
Message-ID: <20070123160354.18078.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-23 16:03:54

Modified files:
	.              : WHATS_NEW 
	lib/commands   : toolcontext.c 

Log message:
	Long-lived processes write out persistent dev cache in refresh_toolcontext().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.552&r2=1.553
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45

--- LVM2/WHATS_NEW	2007/01/23 15:58:05	1.552
+++ LVM2/WHATS_NEW	2007/01/23 16:03:53	1.553
@@ -1,5 +1,6 @@
 Version 2.02.20 -
 ===================================
+  Long-lived processes write out persistent dev cache in refresh_toolcontext().
   Fix refresh_toolcontext() always to wipe persistent device filter cache.
   Add is_long_lived to toolcontext.
   Add --clustered to man pages.
--- LVM2/lib/commands/toolcontext.c	2007/01/23 15:58:05	1.44
+++ LVM2/lib/commands/toolcontext.c	2007/01/23 16:03:54	1.45
@@ -1080,6 +1080,13 @@
 	if (!_init_segtypes(cmd))
 		return 0;
 
+	/*
+	 * If we are a long-lived process, write out the updated persistent
+	 * device cache for the benefit of short-lived processes.
+	 */
+	if (cmd->is_long_lived && cmd->dump_filter)
+		persistent_filter_dump(cmd->filter);
+
 	cmd->config_valid = 1;
 	return 1;
 }


