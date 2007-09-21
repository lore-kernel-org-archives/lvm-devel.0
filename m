From: meyering@sourceware.org <meyering@sourceware.org>
Date: 21 Sep 2007 18:06:33 -0000
Subject: LVM2 ./WHATS_NEW tools/lvmcmdline.c
Message-ID: <20070921180633.21567.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-09-21 18:06:33

Modified files:
	.              : WHATS_NEW 
	tools          : lvmcmdline.c 

Log message:
	After a diagnostic, suggest --help, rather than printing all --help output.
	
	Print just one line:
	Use `COMMAND --help' for more information.
	after "real" diagnostic(s), rather than all of the usage lines.
	Otherwise, the 30-40+ lines of --help output could obscure the real diagnostic.
	
	Author: Jim Meyering <jim@meyering.net>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.711&r2=1.712
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.49&r2=1.50

--- LVM2/WHATS_NEW	2007/09/20 21:39:07	1.711
+++ LVM2/WHATS_NEW	2007/09/21 18:06:33	1.712
@@ -1,5 +1,6 @@
 Version 2.02.29 -
 ==================================
+  After a diagnostic, suggest --help, rather than printing all --help output.
   Add %PVS extents option to lvresize, lvextend, and lvcreate.
   Moved the obsolete test subdirectory to old-tests.
   Remove no-longer-correct restrictions on PV arg count with stripes/mirrors.
--- LVM2/tools/lvmcmdline.c	2007/09/20 21:39:08	1.49
+++ LVM2/tools/lvmcmdline.c	2007/09/21 18:06:33	1.50
@@ -466,6 +466,11 @@
 	return _cmdline.commands + i;
 }
 
+static void _short_usage(const char *name)
+{
+	log_error("Run `%s --help' for more information.\n", name);
+}
+
 static void _usage(const char *name)
 {
 	struct command *com = _find_command(name);
@@ -921,7 +926,7 @@
 	dm_pool_empty(cmd->mem);
 
 	if (ret == EINVALID_CMD_LINE && !_cmdline.interactive)
-		_usage(cmd->command->name);
+		_short_usage(cmd->command->name);
 
 	log_debug("Completed: %s", cmd->cmd_line);
 


