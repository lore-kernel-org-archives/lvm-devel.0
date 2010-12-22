From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 22 Dec 2010 15:36:43 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c tools ...
Message-ID: <20101222153643.20331.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-22 15:36:42

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 
	tools          : vgrename.c 

Log message:
	Add backtraces for backup and backup_remove fail paths

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1854&r2=1.1855
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.418&r2=1.419
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74

--- LVM2/WHATS_NEW	2010/12/22 15:28:44	1.1854
+++ LVM2/WHATS_NEW	2010/12/22 15:36:41	1.1855
@@ -1,5 +1,6 @@
 Version 2.02.80 - 
 ====================================
+  Add backtraces for backup and backup_remove fail paths.
   Detect errors from dm_task_set calls in _get_device_info (dmeventd).
   Add backtraces for archive and backup_locally in check_current_backup().
   Fix memory leak in debug mode of restart_clvmd() error path.
--- LVM2/lib/metadata/metadata.c	2010/12/14 17:51:09	1.418
+++ LVM2/lib/metadata/metadata.c	2010/12/22 15:36:41	1.419
@@ -611,7 +611,8 @@
 		}
 	}
 
-	backup_remove(vg->cmd, vg->name);
+	if (!backup_remove(vg->cmd, vg->name))
+		stack;
 
 	if (ret)
 		log_print("Volume group \"%s\" successfully removed", vg->name);
--- LVM2/tools/vgrename.c	2010/12/08 20:50:51	1.73
+++ LVM2/tools/vgrename.c	2010/12/22 15:36:42	1.74
@@ -164,8 +164,10 @@
 		}
 	}
 
-	backup(vg);
-	backup_remove(cmd, vg_name_old);
+	if (!backup(vg))
+		stack;
+	if (!backup_remove(cmd, vg_name_old))
+		stack;
 
 	unlock_vg(cmd, vg_name_new);
 	unlock_and_free_vg(cmd, vg, vg_name_old);


