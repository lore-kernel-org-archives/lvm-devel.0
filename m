From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Dec 2010 14:34:49 -0000
Subject: LVM2/lib/commands toolcontext.c
Message-ID: <20101220143449.24959.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-20 14:34:49

Modified files:
	lib/commands   : toolcontext.c 

Log message:
	Verbose log old_umask value
	
	Use old_umask value and print its content through verbose log.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.112&r2=1.113

--- LVM2/lib/commands/toolcontext.c	2010/12/20 13:12:56	1.112
+++ LVM2/lib/commands/toolcontext.c	2010/12/20 14:34:49	1.113
@@ -213,7 +213,8 @@
 
 	if ((old_umask = umask((mode_t) cmd->default_settings.umask)) !=
 	    (mode_t) cmd->default_settings.umask)
-		log_verbose("Set umask to %04o", cmd->default_settings.umask);
+		log_verbose("Set umask from %04o to %04o",
+                            old_umask, cmd->default_settings.umask);
 
 	/* dev dir */
 	if (dm_snprintf(cmd->dev_dir, sizeof(cmd->dev_dir), "%s/",


