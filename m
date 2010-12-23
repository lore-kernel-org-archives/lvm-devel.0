From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 23 Dec 2010 14:23:31 -0000
Subject: LVM2 ./WHATS_NEW tools/pvchange.c
Message-ID: <20101223142331.23379.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-12-23 14:23:30

Modified files:
	.              : WHATS_NEW 
	tools          : pvchange.c 

Log message:
	Fix wrongly paired unlocking of global lock in pvchange. (2.02.66)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1855&r2=1.1856
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.86&r2=1.87

--- LVM2/WHATS_NEW	2010/12/22 15:36:41	1.1855
+++ LVM2/WHATS_NEW	2010/12/23 14:23:30	1.1856
@@ -1,5 +1,6 @@
 Version 2.02.80 - 
 ====================================
+  Fix wrongly paired unlocking of global lock in pvchange. (2.02.66)
   Add backtraces for backup and backup_remove fail paths.
   Detect errors from dm_task_set calls in _get_device_info (dmeventd).
   Add backtraces for archive and backup_locally in check_current_backup().
--- LVM2/tools/pvchange.c	2010/12/08 20:50:51	1.86
+++ LVM2/tools/pvchange.c	2010/12/23 14:23:30	1.87
@@ -288,9 +288,9 @@
 				unlock_and_free_vg(cmd, vg, sll->str);
 			}
 		}
+		unlock_vg(cmd, VG_GLOBAL);
 	}
 
-	unlock_vg(cmd, VG_GLOBAL);
 	log_print("%d physical volume%s changed / %d physical volume%s "
 		  "not changed",
 		  done, done == 1 ? "" : "s",


