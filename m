From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Oct 2010 10:40:15 -0000
Subject: LVM2 ./WHATS_NEW tools/vgchange.c
Message-ID: <20101025104015.27806.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-10-25 10:40:14

Modified files:
	.              : WHATS_NEW 
	tools          : vgchange.c 

Log message:
	Don't take write lock in vgchange --refresh, --poll or --monitor.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1767&r2=1.1768
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.113&r2=1.114

--- LVM2/WHATS_NEW	2010/10/25 10:37:34	1.1767
+++ LVM2/WHATS_NEW	2010/10/25 10:40:13	1.1768
@@ -1,6 +1,7 @@
 Version 2.02.75 - 
 =====================================
-  Skip dm devices in scan if they contain only error targets.
+  Don't take write lock in vgchange --refresh, --poll or --monitor.
+  Skip dm devices in scan if they contain only error targets or are empty.
   Fix strict-aliasing compile warning in partition table scanning.
   Add an option to automatically extend snapshots through dmeventd.
   Remove dependency on libm, floor() is replaced with integer algorithm.
--- LVM2/tools/vgchange.c	2010/08/17 16:25:35	1.113
+++ LVM2/tools/vgchange.c	2010/10/25 10:40:13	1.114
@@ -687,7 +687,10 @@
 	}
 
 	return process_each_vg(cmd, argc, argv,
-			       (arg_count(cmd, available_ARG)) ?
+			       (arg_count(cmd, available_ARG) ||
+				arg_count(cmd, refresh_ARG) ||
+				arg_count(cmd, monitor_ARG) ||
+				arg_count(cmd, poll_ARG)) ?
 			       0 : READ_FOR_UPDATE,
 			       NULL,
 			       &vgchange_single);


