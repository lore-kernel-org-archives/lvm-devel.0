From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 24 Nov 2010 09:34:35 -0000
Subject: LVM2 ./WHATS_NEW lib/commands/toolcontext.c
Message-ID: <20101124093435.4218.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-24 09:34:35

Modified files:
	.              : WHATS_NEW 
	lib/commands   : toolcontext.c 

Log message:
	Fix resource leak of dlopened pointer
	
	Add missing dlclose in _init_formats() error path.
	Use return_0 to print stack trace from the call.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1806&r2=1.1807
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.108&r2=1.109

--- LVM2/WHATS_NEW	2010/11/23 21:19:45	1.1806
+++ LVM2/WHATS_NEW	2010/11/24 09:34:34	1.1807
@@ -1,5 +1,6 @@
 Version 2.02.78 - 
 ====================================
+  Fix missing dlclose in _init_formats() error path from init_format call.
   Fix missing fclose for _umount() in dmeventd snapshot plugin.
   Fix out-of-scope variable usage in process_each_lv().
   Fix dm_task_destroy(NULL) call in _node_clear_table() error path.
--- LVM2/lib/commands/toolcontext.c	2010/11/11 17:29:05	1.108
+++ LVM2/lib/commands/toolcontext.c	2010/11/24 09:34:35	1.109
@@ -814,8 +814,11 @@
 				return 0;
 			}
 
-			if (!(fmt = init_format_fn(cmd)))
-				return 0;
+			if (!(fmt = init_format_fn(cmd))) {
+				dlclose(lib);
+				return_0;
+			}
+
 			fmt->library = lib;
 			dm_list_add(&cmd->formats, &fmt->list);
 		}


