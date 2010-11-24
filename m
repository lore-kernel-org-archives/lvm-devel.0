From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 24 Nov 2010 09:53:32 -0000
Subject: LVM2 ./WHATS_NEW tools/lvmcmdline.c
Message-ID: <20101124095332.24720.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-24 09:53:31

Modified files:
	.              : WHATS_NEW 
	tools          : lvmcmdline.c 

Log message:
	Add missing destrustion of cmd_context
	
	Lvm1 fallback code missed to destroy cmd_context in error path.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1808&r2=1.1809
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.131&r2=1.132

--- LVM2/WHATS_NEW	2010/11/24 09:43:18	1.1808
+++ LVM2/WHATS_NEW	2010/11/24 09:53:31	1.1809
@@ -1,5 +1,6 @@
 Version 2.02.78 - 
 ====================================
+  Fix missing context desctruction in err path of lvm1 fallback in lvm2_main().
   Fix memory leak in error path of parse_loop_device_name() from dmsetup.
   Fix missing dlclose in _init_formats() error path from init_format call.
   Fix missing fclose for _umount() in dmeventd snapshot plugin.
--- LVM2/tools/lvmcmdline.c	2010/11/17 10:19:30	1.131
+++ LVM2/tools/lvmcmdline.c	2010/11/24 09:53:31	1.132
@@ -1447,10 +1447,12 @@
 		if (!argc) {
 			log_error("Falling back to LVM1 tools, but no "
 				  "command specified.");
-			return ECMD_FAILED;
+			ret = ECMD_FAILED;
+			goto out;
 		}
 		_exec_lvm1_command(argv);
-		return ECMD_FAILED;
+		ret = ECMD_FAILED;
+		goto out;
 	}
 #ifdef READLINE_SUPPORT
 	if (!alias && argc == 1) {


