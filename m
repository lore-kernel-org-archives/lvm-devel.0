From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Jan 2010 13:41:39 -0000
Subject: LVM2/tools lvmcmdline.c
Message-ID: <20100121134139.4011.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-01-21 13:41:39

Modified files:
	tools          : lvmcmdline.c 

Log message:
	Reset released pointer and counters.
	
	DSO is currently not dl_close-ing pluing during it is unregister handling,
	so clear structure and related counter, so there are no memory problems.
	Futher fixes are needed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.111&r2=1.112

--- LVM2/tools/lvmcmdline.c	2010/01/11 19:19:17	1.111
+++ LVM2/tools/lvmcmdline.c	2010/01/21 13:41:39	1.112
@@ -1213,6 +1213,10 @@
 		dm_free(_cmdline.commands[i].valid_args);
 
 	dm_free(_cmdline.commands);
+
+	_cmdline.commands = NULL;
+	_cmdline.num_commands = 0;
+	_cmdline.commands_size = 0;
 }
 
 void lvm_fin(struct cmd_context *cmd)


