From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 25 Aug 2010 09:38:08 -0500
Subject: [PATCH] Do not scan snapshot origin for labels while 'ignore_suspended_devices()' is set
Message-ID: <1282747088.10709.1.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

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

Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Index: LVM2/lib/activate/dev_manager.c
===================================================================
--- LVM2.orig/lib/activate/dev_manager.c
+++ LVM2/lib/activate/dev_manager.c
@@ -175,6 +175,21 @@ int device_is_usable(struct device *dev)
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



