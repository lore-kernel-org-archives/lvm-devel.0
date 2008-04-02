From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Apr 2008 21:31:14 -0000
Subject: LVM2/lib/commands toolcontext.c
Message-ID: <20080402213114.24318.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-02 21:31:14

Modified files:
	lib/commands   : toolcontext.c 

Log message:
	enable vg metadata cache by default

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58

--- LVM2/lib/commands/toolcontext.c	2008/01/30 13:59:58	1.57
+++ LVM2/lib/commands/toolcontext.c	2008/04/02 21:31:14	1.58
@@ -987,6 +987,7 @@
 	if (!_init_backup(cmd))
 		goto error;
 
+	cmd->default_settings.cache_vgmetadata = 1;
 	cmd->current_settings = cmd->default_settings;
 
 	cmd->config_valid = 1;


