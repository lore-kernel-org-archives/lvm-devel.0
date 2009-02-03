From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 3 Feb 2009 16:23:20 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/locking.c tools/l ...
Message-ID: <20090203162320.21473.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-02-03 16:23:19

Modified files:
	.              : WHATS_NEW 
	lib/locking    : locking.c 
	tools          : lvmcmdline.c 

Log message:
	Move locking_type reading inside init_locking().
	
	No functional change.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1033&r2=1.1034
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.91&r2=1.92

--- LVM2/WHATS_NEW	2009/02/03 16:19:25	1.1033
+++ LVM2/WHATS_NEW	2009/02/03 16:23:19	1.1034
@@ -1,5 +1,6 @@
 Version 2.02.45 - 
 ===================================
+  Move locking_type reading inside init_locking().
   Rename get_vgs() to get_vgnames() and clarify related error messages.
   Allow clvmd to be built with all cluster managers & select one on cmdline.
   Mention --with-clvmd=corosync in ./configure.
--- LVM2/lib/locking/locking.c	2008/12/18 05:27:18	1.54
+++ LVM2/lib/locking/locking.c	2009/02/03 16:23:19	1.55
@@ -208,11 +208,16 @@
 
 /*
  * Select a locking type
+ * type: locking type; if < 0, then read config tree value
  */
 int init_locking(int type, struct cmd_context *cmd)
 {
 	init_lockingfailed(0);
 
+	if (type < 0)
+		type = find_config_tree_int(cmd, "global/locking_type", 1);
+		
+	
 	switch (type) {
 	case 0:
 		init_no_locking(&_locking, cmd);
--- LVM2/tools/lvmcmdline.c	2008/12/19 14:43:02	1.91
+++ LVM2/tools/lvmcmdline.c	2009/02/03 16:23:19	1.92
@@ -995,8 +995,7 @@
 	if (arg_count(cmd, nolocking_ARG))
 		locking_type = 0;
 	else
-		locking_type = find_config_tree_int(cmd,
-					       "global/locking_type", 1);
+		locking_type = -1;
 
 	if (!init_locking(locking_type, cmd)) {
 		log_error("Locking type %d initialisation failed.",


