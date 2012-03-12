From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 12 Mar 2012 14:15:06 -0000
Subject: LVM2 ./WHATS_NEW lib/commands/toolcontext.c to ...
Message-ID: <20120312141506.17666.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-12 14:15:05

Modified files:
	.              : WHATS_NEW 
	lib/commands   : toolcontext.c 
	tools          : lvmcmdline.c 

Log message:
	Fix error path for create_toolcontext
	
	Never return unfinished toolcontext - since error path is hit on
	various stages of initialization we cannot leave it partially uninitialized,
	since we would need to spread many more test across the code for config_valid.
	Instead return NULL and properly release udev library resources as well.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2349&r2=1.2350
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.153&r2=1.154
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.153&r2=1.154

--- LVM2/WHATS_NEW	2012/03/06 09:22:02	1.2349
+++ LVM2/WHATS_NEW	2012/03/12 14:15:04	1.2350
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Fix error path for failing toolcontext creation.
   Fix warn msg for thin pool chunk size and update man for chunksize (2.02.89).
 
 Version 2.02.95 - 6th March 2012
--- LVM2/lib/commands/toolcontext.c	2012/03/01 21:16:05	1.153
+++ LVM2/lib/commands/toolcontext.c	2012/03/12 14:15:04	1.154
@@ -1371,6 +1371,11 @@
 
 	cmd->config_valid = 1;
 out:
+	if (cmd->config_valid != 1) {
+		destroy_toolcontext(cmd);
+		cmd = NULL;
+	}
+
 	return cmd;
 }
 
--- LVM2/tools/lvmcmdline.c	2012/03/06 02:30:50	1.153
+++ LVM2/tools/lvmcmdline.c	2012/03/12 14:15:04	1.154
@@ -1248,13 +1248,16 @@
 	if (!udev_init_library_context())
 		stack;
 
-	if (!(cmd = create_toolcontext(0, NULL, 1, 0)))
+	if (!(cmd = create_toolcontext(0, NULL, 1, 0))) {
+		udev_fin_library_context();
 		return_NULL;
+	}
 
 	_cmdline.arg_props = &_arg_props[0];
 
 	if (stored_errno()) {
 		destroy_toolcontext(cmd);
+		udev_fin_library_context();
 		return_NULL;
 	}
 


