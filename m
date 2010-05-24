From: agk@sourceware.org <agk@sourceware.org>
Date: 24 May 2010 17:46:48 -0000
Subject: LVM2 ./WHATS_NEW lib/mirror/mirrored.c libdm/l ...
Message-ID: <20100524174648.10784.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-05-24 17:46:48

Modified files:
	.              : WHATS_NEW 
	lib/mirror     : mirrored.c 
	libdm          : libdm-deptree.c 

Log message:
	Choose between clustered log versions based on kernel version.
	Add fixmes for broken strcmp.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1595&r2=1.1596
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.79&r2=1.80

--- LVM2/WHATS_NEW	2010/05/24 16:30:15	1.1595
+++ LVM2/WHATS_NEW	2010/05/24 17:46:47	1.1596
@@ -1,6 +1,6 @@
 Version 2.02.67 -
 ===============================
-  Update clustered log kernel module name to log-userspace.
+  Update clustered log kernel module name to log-userspace for 2.6.31 onwards.
   Activate only first head of Replicator for vgchange -ay.
   Add Replicators' LVs to dtree for activation.
   Avoid print activation message if there is a missing VG (Replicator).
--- LVM2/lib/mirror/mirrored.c	2010/05/24 16:30:16	1.69
+++ LVM2/lib/mirror/mirrored.c	2010/05/24 17:46:47	1.70
@@ -28,6 +28,8 @@
 #include "sharedlib.h"
 #include "str_list.h"
 
+#include <sys/utsname.h>
+
 #ifdef DMEVENTD
 #  include "libdevmapper-event.h"
 #endif
@@ -471,6 +473,7 @@
 	uint32_t maj, min, patchlevel;
 	unsigned maj2, min2, patchlevel2;
 	char vsn[80];
+	struct utsname uts;
 
 	if (!_mirrored_checked) {
 		_mirrored_present = target_present(cmd, "mirror", 1);
@@ -503,8 +506,18 @@
 	 * FIXME: Fails incorrectly if cmirror was built into kernel.
 	 */
 	if (attributes) {
-		if (!_mirror_attributes && module_present(cmd, "log-userspace"))
-			_mirror_attributes |= MIRROR_LOG_CLUSTERED;
+		if (!_mirror_attributes) {
+			/*
+			 * The dm-log-userspace module was added to the
+			 * 2.6.31 kernel.
+			 */
+			/* FIXME Replace the broken string comparison! */
+			if (!uname(&uts) && strncmp(uts.release, "2.6.31", 6) < 0) {
+				if (module_present(cmd, "log-clustered"))
+					_mirror_attributes |= MIRROR_LOG_CLUSTERED;
+			} else if (module_present(cmd, "log-userspace"))
+				_mirror_attributes |= MIRROR_LOG_CLUSTERED;
+		}
 		*attributes = _mirror_attributes;
 	}
 	_mirrored_checked = 1;
--- LVM2/libdm/libdm-deptree.c	2010/05/24 09:04:27	1.79
+++ LVM2/libdm/libdm-deptree.c	2010/05/24 17:46:47	1.80
@@ -1575,6 +1575,7 @@
 		 * The dm-log-userspace module was added to the
 		 * 2.6.31 kernel.
 		 */
+		/* FIXME Replace the broken string comparison! */
 		if (strncmp(uts.release, "2.6.31", 6) >= 0)
 			dm_log_userspace = 1;
 	}


