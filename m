From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Jun 2011 22:38:54 -0000
Subject: LVM2/libdm libdm-common.c libdm-deptree.c
Message-ID: <20110627223854.8636.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-27 22:38:54

Modified files:
	libdm          : libdm-common.c libdm-deptree.c 

Log message:
	Extend debug log messages to distinguish between the 3 states:
	trust udev; verify udev; perform dev node operations directly.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.119&r2=1.120
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.99&r2=1.100

--- LVM2/libdm/libdm-common.c	2011/06/27 21:43:59	1.119
+++ LVM2/libdm/libdm-common.c	2011/06/27 22:38:53	1.120
@@ -828,20 +828,24 @@
 
 static void _log_node_op(const char *action_str, struct node_op_parms *nop)
 {
+	const char *rely = nop->rely_on_udev ? " [trust_udev]" : "" ;
+	const char *verify = nop->warn_if_udev_failed ? " [verify_udev]" : "";
+
 	switch (nop->type) {
 	case NODE_ADD:
-		log_debug("%s: %s NODE_ADD (%" PRIu32 ",%" PRIu32 ") %u:%u 0%o",
-			  nop->dev_name, action_str, nop->major, nop->minor, nop->uid, nop->gid, nop->mode);
+		log_debug("%s: %s NODE_ADD (%" PRIu32 ",%" PRIu32 ") %u:%u 0%o%s%s",
+			  nop->dev_name, action_str, nop->major, nop->minor, nop->uid, nop->gid, nop->mode,
+			  rely, verify);
 		break;
 	case NODE_DEL:
-		log_debug("%s: %s NODE_DEL", nop->dev_name, action_str);
+		log_debug("%s: %s NODE_DEL%s%s", nop->dev_name, action_str, rely, verify);
 		break;
 	case NODE_RENAME:
-		log_debug("%s: %s NODE_RENAME to %s", nop->old_name, action_str, nop->dev_name);
+		log_debug("%s: %s NODE_RENAME to %s%s%s", nop->old_name, action_str, nop->dev_name, rely, verify);
 		break;
 	case NODE_READ_AHEAD:
-		log_debug("%s: %s NODE_READ_AHEAD %" PRIu32 " (flags=%" PRIu32
-			  ")", nop->dev_name, action_str, nop->read_ahead, nop->read_ahead_flags);
+		log_debug("%s: %s NODE_READ_AHEAD %" PRIu32 " (flags=%" PRIu32 ")%s%s",
+			  nop->dev_name, action_str, nop->read_ahead, nop->read_ahead_flags, rely, verify);
 		break;
 	default:
 		; /* NOTREACHED */
@@ -860,6 +864,13 @@
 	char *pos;
 
 	/*
+	 * Clear warn_if_udev_failed if rely_on_udev is set.  It doesn't get
+	 * checked in this case - this just removes the flag from log messages.
+	 */
+	if (rely_on_udev)
+		warn_if_udev_failed = 0;
+
+	/*
 	 * Note: warn_if_udev_failed must have valid content
 	 */
 	if ((type == NODE_DEL) && _other_node_ops(type))
@@ -947,7 +958,7 @@
 				    nop->read_ahead, nop->read_ahead_flags,
 				    nop->warn_if_udev_failed);
 		} else
-			_log_node_op("Skipping (udev)", nop);
+			_log_node_op("Skipping", nop);
 		_del_node_op(nop);
 	}
 }
--- LVM2/libdm/libdm-deptree.c	2011/06/27 21:43:59	1.99
+++ LVM2/libdm/libdm-deptree.c	2011/06/27 22:38:53	1.100
@@ -985,7 +985,7 @@
 
 	/* FIXME Until kernel returns actual name so dm-iface.c can handle it */
 	rm_dev_node(name, dmt->cookie_set && !(udev_flags & DM_UDEV_DISABLE_DM_RULES_FLAG),
-			  dmt->cookie_set && !(udev_flags & DM_UDEV_DISABLE_LIBRARY_FALLBACK));
+			  dmt->cookie_set && (udev_flags & DM_UDEV_DISABLE_LIBRARY_FALLBACK));
 
 	/* FIXME Remove node from tree or mark invalid? */
 


