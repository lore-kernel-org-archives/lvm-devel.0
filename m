From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Jul 2008 14:43:40 -0000
Subject: LVM2 ./WHATS_NEW lib/mirror/mirrored.c
Message-ID: <20080731144340.5562.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-07-31 14:43:39

Modified files:
	.              : WHATS_NEW 
	lib/mirror     : mirrored.c 

Log message:
	Change clustered mirror kernel module name from cmirror to dm-log-clustered.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.941&r2=1.942
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57

--- LVM2/WHATS_NEW	2008/07/31 13:07:01	1.941
+++ LVM2/WHATS_NEW	2008/07/31 14:43:39	1.942
@@ -1,5 +1,6 @@
 Version 2.02.40 - 
 ================================
+  Change clustered mirror kernel module name from cmirror to dm-log-clustered.
   Avoid looping forever in _pv_analyze_mda_raw used by pvck.
   Change lvchange exit status to indicate if any part of the operation failed.
   Fix pvchange and pvremove to handle PVs without mdas.
--- LVM2/lib/mirror/mirrored.c	2008/07/15 00:25:51	1.56
+++ LVM2/lib/mirror/mirrored.c	2008/07/31 14:43:39	1.57
@@ -375,7 +375,7 @@
 	 * FIXME: Fails incorrectly if cmirror was built into kernel.
 	 */
 	if (attributes) {
-		if (!_mirror_attributes && module_present("cmirror"))
+		if (!_mirror_attributes && module_present("log-clustered"))
 			_mirror_attributes |= MIRROR_LOG_CLUSTERED;
 		*attributes = _mirror_attributes;
 	}


