From: agk@sourceware.org <agk@sourceware.org>
Date: 21 Oct 2011 15:49:46 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/cluster_locking.c
Message-ID: <20111021154946.13441.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-10-21 15:49:45

Modified files:
	.              : WHATS_NEW 
	lib/locking    : cluster_locking.c 

Log message:
	Pass exclusive LV locks to all nodes in the cluster.
	This was the intended behaviour, as described in the lvchange man page, so you
	have complete control through volume_list in lvm.conf, but the code seems to
	have been treating -ae as local-only for a very long time.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2165&r2=1.2166
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60

--- LVM2/WHATS_NEW	2011/10/21 09:53:16	1.2165
+++ LVM2/WHATS_NEW	2011/10/21 15:49:45	1.2166
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Pass exclusive LV locks to all nodes in the cluster.
   Improve lvcreate man documentation of the chunksize option.
   Improve man page style for lvcreate.
   Avoid recursive calls to dmeventd in its LVM plugins.
@@ -19,7 +20,7 @@
   Fix splitmirror in cluster having different DM/LVM views of storage.
   Fix improper udev settings during suspend/resume for mirror sub-LVs.
   Fix vgsplit when there are mirrors that have mirrored logs.
-  Clarify multi-name device filter pattern matching explanation in lvm.conf.5.
+  Clarify multi-name device filter pattern matching explanation in lvm.conf.
   Introduce lv_send_message and dev_manager_send_message.
   Introduce revert_lv for better pvmove cleanup.
   Replace incomplete pvmove activation failure recovery code with a message.
--- LVM2/lib/locking/cluster_locking.c	2011/09/27 22:43:41	1.59
+++ LVM2/lib/locking/cluster_locking.c	2011/10/21 15:49:45	1.60
@@ -366,7 +366,6 @@
 	} else if (clvmd_cmd != CLVMD_CMD_VG_BACKUP) {
 		if (strncmp(name, "P_", 2) &&
 		    (clvmd_cmd == CLVMD_CMD_LOCK_VG ||
-		     (flags & LCK_TYPE_MASK) == LCK_EXCL ||
 		     (flags & LCK_LOCAL) ||
 		     !(flags & LCK_CLUSTER_VG)))
 			node = ".";


