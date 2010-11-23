From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Nov 2010 21:19:47 -0000
Subject: LVM2 ./WHATS_NEW daemons/dmeventd/plugins/snap ...
Message-ID: <20101123211947.29382.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-23 21:19:46

Modified files:
	.              : WHATS_NEW 
	daemons/dmeventd/plugins/snapshot: dmeventd_snapshot.c 

Log message:
	Add missing fclose
	
	Fixing resource leak in _umount().
	
	CHECKME: mountpoints with spaces need to be checked

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1805&r2=1.1806
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/WHATS_NEW	2010/11/23 20:39:13	1.1805
+++ LVM2/WHATS_NEW	2010/11/23 21:19:45	1.1806
@@ -1,5 +1,6 @@
 Version 2.02.78 - 
 ====================================
+  Fix missing fclose for _umount() in dmeventd snapshot plugin.
   Fix out-of-scope variable usage in process_each_lv().
   Fix dm_task_destroy(NULL) call in _node_clear_table() error path.
   Fix resource leak in _rm_blks().
--- LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2010/10/29 16:43:51	1.12
+++ LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2010/11/23 21:19:45	1.13
@@ -170,6 +170,9 @@
                                        device, words[1], strerror(errno));
 		}
 	}
+
+	if (fclose(mounts))
+		syslog(LOG_ERR, "Failed to close /proc/mounts.\n");
 }
 
 void process_event(struct dm_task *dmt,


