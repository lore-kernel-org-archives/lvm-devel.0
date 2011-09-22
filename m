From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 22 Sep 2011 17:12:29 -0000
Subject: LVM2 ./WHATS_NEW_DM man/dmsetup.8.in tools/dms ...
Message-ID: <20110922171229.24006.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-09-22 17:12:28

Modified files:
	.              : WHATS_NEW_DM 
	man            : dmsetup.8.in 
	tools          : dmsetup.c 

Log message:
	Add --retry option for dmsetup remove to retry removal if not successful.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.500&r2=1.501
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmsetup.8.in.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.168&r2=1.169

--- LVM2/WHATS_NEW_DM	2011/09/22 17:09:48	1.500
+++ LVM2/WHATS_NEW_DM	2011/09/22 17:12:28	1.501
@@ -1,5 +1,6 @@
 Version 1.02.68 -
 ==================================
+  Add --retry option for dmsetup remove to retry removal if not successful.
   Add dm_task_retry_remove fn to use retry logic for device removal.
   Remove unused passed parameters for _mirror_emit_segment_line().
   Add dm_config and string character escaping functions to libdevmapper.
--- LVM2/man/dmsetup.8.in	2011/07/01 14:09:20	1.42
+++ LVM2/man/dmsetup.8.in	2011/09/22 17:12:28	1.43
@@ -11,7 +11,7 @@
 .I [{ --addnodeonresume | --addnodeoncreate }]
 .br
 .B dmsetup remove
-.I [-f|--force] device_name
+.I [-f|--force] [--retry] device_name
 .br
 .B dmsetup remove_all
 .I [-f|--force]
@@ -280,7 +280,7 @@
 correspond to mapped devices currently loaded by the device-mapper kernel
 driver, adding, changing or removing nodes as necessary.
 .IP \fBremove
-.I [-f|--force] device_name
+.I [-f|--force] [--retry] device_name
 .br
 Removes a device.  It will no longer be visible to dmsetup.
 Open devices cannot be removed except with older kernels
@@ -290,7 +290,10 @@
 be removed because an uninterruptible process is waiting for
 I/O to return from it, adding --force will replace the table 
 with one that fails all I/O, which might allow the 
-process to be killed.
+process to be killed. If an attempt to remove a device fails,
+perhaps because a process run from a quick udev rule
+temporarily opened the device, the --retry option will cause
+the operation to be retried for a few seconds before failing.
 .IP \fBremove_all
 .I [-f|--force]
 .br
--- LVM2/tools/dmsetup.c	2011/08/11 19:18:18	1.168
+++ LVM2/tools/dmsetup.c	2011/09/22 17:12:28	1.169
@@ -140,6 +140,7 @@
 	NOUDEVSYNC_ARG,
 	OPTIONS_ARG,
 	READAHEAD_ARG,
+	RETRY_ARG,
 	ROWS_ARG,
 	SEPARATOR_ARG,
 	SETUUID_ARG,
@@ -1279,6 +1280,9 @@
 	if (udev_wait_flag && !dm_task_set_cookie(dmt, &cookie, udev_flags))
 		goto out;
 
+	if (_switches[RETRY_ARG] && task == DM_DEVICE_REMOVE)
+		dm_task_retry_remove(dmt);
+
 	r = dm_task_run(dmt);
 
       out:
@@ -2805,7 +2809,7 @@
 		"        [--checks] [-v|--verbose [-v|--verbose ...]]\n"
 		"        [-r|--readonly] [--noopencount] [--nolockfs] [--inactive]\n"
 		"        [--udevcookie [cookie]] [--noudevrules] [--noudevsync] [--verifyudev]\n"
-		"        [-y|--yes] [--readahead [+]<sectors>|auto|none]\n"
+		"        [-y|--yes] [--readahead [+]<sectors>|auto|none] [--retry]\n"
 		"        [-c|-C|--columns] [-o <fields>] [-O|--sort <sort_fields>]\n"
 		"        [--nameprefixes] [--noheadings] [--separator <separator>]\n\n");
 	for (i = 0; _commands[i].name; i++)
@@ -3178,6 +3182,7 @@
 		{"noudevsync", 0, &ind, NOUDEVSYNC_ARG},
 		{"options", 1, &ind, OPTIONS_ARG},
 		{"readahead", 1, &ind, READAHEAD_ARG},
+		{"retry", 0, &ind, RETRY_ARG},
 		{"rows", 0, &ind, ROWS_ARG},
 		{"separator", 1, &ind, SEPARATOR_ARG},
 		{"setuuid", 0, &ind, SETUUID_ARG},
@@ -3362,6 +3367,8 @@
 				}
 			}
 		}
+		if ((ind == RETRY_ARG))
+			_switches[RETRY_ARG]++;
 		if ((ind == ROWS_ARG))
 			_switches[ROWS_ARG]++;
 		if ((ind == SETUUID_ARG))


