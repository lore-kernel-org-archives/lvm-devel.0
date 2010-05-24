From: agk@sourceware.org <agk@sourceware.org>
Date: 24 May 2010 16:30:18 -0000
Subject: LVM2 ./WHATS_NEW lib/mirror/mirrored.c
Message-ID: <20100524163018.26663.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-05-24 16:30:16

Modified files:
	.              : WHATS_NEW 
	lib/mirror     : mirrored.c 

Log message:
	Update clustered log kernel module name to log-userspace.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1594&r2=1.1595
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69

--- LVM2/WHATS_NEW	2010/05/24 09:03:39	1.1594
+++ LVM2/WHATS_NEW	2010/05/24 16:30:15	1.1595
@@ -1,5 +1,6 @@
 Version 2.02.67 -
 ===============================
+  Update clustered log kernel module name to log-userspace.
   Activate only first head of Replicator for vgchange -ay.
   Add Replicators' LVs to dtree for activation.
   Avoid print activation message if there is a missing VG (Replicator).
--- LVM2/lib/mirror/mirrored.c	2010/05/24 15:32:21	1.68
+++ LVM2/lib/mirror/mirrored.c	2010/05/24 16:30:16	1.69
@@ -503,7 +503,7 @@
 	 * FIXME: Fails incorrectly if cmirror was built into kernel.
 	 */
 	if (attributes) {
-		if (!_mirror_attributes && module_present(cmd, "log-clustered"))
+		if (!_mirror_attributes && module_present(cmd, "log-userspace"))
 			_mirror_attributes |= MIRROR_LOG_CLUSTERED;
 		*attributes = _mirror_attributes;
 	}


