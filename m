From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 26 Aug 2010 14:21:53 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20100826142153.7885.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-08-26 14:21:52

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	This patch fixes a potential for I/O to hang and LVM commands
	to block when a mirror under a snapshot suffers a failure.
	
	The problem has to do with label scanning.  When a mirror suffers
	a failure, the kernel blocks I/O to prevent corruption.  When
	LVM attempts to repair the mirror, it scans the devices on the
	system for LVM labels.  While mirrors are skipped during this
	scanning process, snapshot-origins are not.  When the origin is
	scanned, it kicks up I/O to the mirror (which is blocked)
	underneath - causing the label scan (an thus the repair operation)
	to hang.
	
	This patch simply bypasses snapshot-origin devices when doing
	labels scans (while ignore_suspended_devices() is set).  This
	fixes the issue.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1724&r2=1.1725
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.201&r2=1.202

--- LVM2/WHATS_NEW	2010/08/26 12:08:19	1.1724
+++ LVM2/WHATS_NEW	2010/08/26 14:21:50	1.1725
@@ -1,5 +1,6 @@
 Version 2.02.74 - 
 ==================================
+  Like mirrors, don't scan origins if ignore_suspended_devices() is set.
   Fix return type qualifier to avoid compiler warning. (2.02.69)
   Automatically generate LSB Requires-Start for clvmd init script.
   Fix return code of pvmove --abort PV.
--- LVM2/lib/activate/dev_manager.c	2010/08/17 19:25:05	1.201
+++ LVM2/lib/activate/dev_manager.c	2010/08/26 14:21:51	1.202
@@ -175,6 +175,21 @@
 			log_debug("%s: Mirror device %s not usable.", dev_name(dev), name);
 			goto out;
 		}
+
+		/*
+		 * Snapshot origin could be sitting on top of a mirror which
+		 * could be blocking I/O.  Skip snapshot origins entirely for
+		 * now.
+		 *
+		 * FIXME: rather than skipping origin, check if mirror is
+		 * underneath and if the mirror is blocking I/O.
+		 */
+		if (target_type && !strcmp(target_type, "snapshot-origin") &&
+		    ignore_suspended_devices()) {
+			log_debug("%s: Snapshot-origin device %s not usable.",
+				  dev_name(dev), name);
+			goto out;
+		}
 	} while (next);
 
 	/* FIXME Also check dependencies? */


