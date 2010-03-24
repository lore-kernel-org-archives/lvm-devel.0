From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 24 Mar 2010 22:25:12 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c
Message-ID: <20100324222512.19347.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-03-24 22:25:11

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 

Log message:
	Revert having clvmd consult the lvm.conf "activation/monitoring".
	Correctly implementing the intent of this change requires more
	analysis.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1476&r2=1.1477
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.85&r2=1.86

--- LVM2/WHATS_NEW	2010/03/23 22:30:18	1.1476
+++ LVM2/WHATS_NEW	2010/03/24 22:25:11	1.1477
@@ -1,7 +1,6 @@
 Version 2.02.63 - 
 ================================
   Add "monitoring" option to "activation" section of lvm.conf.
-  Have clvmd consult the lvm.conf "activation/monitoring".
   Add --monitor and --ignoremonitoring support to lvcreate.
   Allow dynamic extension of array of areas selected as allocation candidates.
   Export and use only valid cookie value in test suite.
--- LVM2/daemons/clvmd/lvm-functions.c	2010/03/23 22:30:19	1.85
+++ LVM2/daemons/clvmd/lvm-functions.c	2010/03/24 22:25:11	1.86
@@ -542,12 +542,8 @@
 	if (lock_flags & LCK_MIRROR_NOSYNC_MODE)
 		init_mirror_in_sync(0);
 
-	if (!(lock_flags & LCK_DMEVENTD_MONITOR_MODE)) {
-		int dmeventd_mode =
-			find_config_tree_bool(cmd, "activation/monitoring",
-					      DEFAULT_DMEVENTD_MONITOR);
-		init_dmeventd_monitor(dmeventd_mode);
-	}
+	if (!(lock_flags & LCK_DMEVENTD_MONITOR_MODE))
+		init_dmeventd_monitor(DEFAULT_DMEVENTD_MONITOR);
 
 	cmd->partial_activation = 0;
 


