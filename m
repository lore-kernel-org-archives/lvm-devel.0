From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Feb 2012 14:17:05 -0000
Subject: LVM2 daemons/dmeventd/plugins/snapshot/dmevent ...
Message-ID: <20120213141705.27171.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-13 14:17:04

Modified files:
	daemons/dmeventd/plugins/snapshot: dmeventd_snapshot.c 
	.              : WHATS_NEW_DM 

Log message:
	Make sure dereferenced words[0] and words[1] are defined

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.556&r2=1.557

--- LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2011/12/22 16:37:03	1.18
+++ LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2012/02/13 14:17:04	1.19
@@ -144,7 +144,8 @@
 			break; /* eof, likely */
 
 		/* words[0] is the mount point and words[1] is the device path */
-		dm_split_words(buffer, 3, 0, words);
+		if (dm_split_words(buffer, 3, 0, words) < 2)
+			continue;
 
 		/* find the major/minor of the device */
 		if (stat(words[0], &st))
--- LVM2/WHATS_NEW_DM	2012/02/13 12:06:39	1.556
+++ LVM2/WHATS_NEW_DM	2012/02/13 14:17:04	1.557
@@ -1,5 +1,6 @@
 Version 1.02.71 - 
 ====================================
+  Test for parsed words in _umount() dmeventd snapshot plugin.
   Fix memory leak in fail path of parse_loop_device_name() in dmsetup.
   Check for missing reply_uuid in dm_event_get_registered_device().
   Check for allocation failure in dmeventd restart().


