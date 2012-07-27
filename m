From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 27 Jul 2012 19:03:50 +0000 (UTC)
Subject: master - dmsetup: allow --noflush with status/wait for thin
Message-ID: <20120727190350.31B9D33A5@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=25ae0b39b77d80990d0821729ab4f2307bd38c16
Commit:        25ae0b39b77d80990d0821729ab4f2307bd38c16
Parent:        186a2772e8ac3c2088bdfc833c32d773464d666b
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jul 27 20:03:07 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jul 27 20:03:07 2012 +0100

dmsetup: allow --noflush with status/wait for thin

Allow --noflush with dmsetup status and wait (for thin target 1.3.0 /
ioctl 4.23.0).
---
 WHATS_NEW_DM          |    1 +
 libdm/misc/dm-ioctl.h |   12 +++++++-----
 man/dmsetup.8.in      |    9 ++++++++-
 tools/dmsetup.c       |    7 +++++--
 4 files changed, 21 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 0bfd016..a790ccf 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.76 - 
 ===============================
+  Allow --noflush with dmsetup status and wait (for thin target).
   Add dm_config_write_one_node to libdevmapper.
   Add support for thin pool message release/reserve_metadata_snap.
   Add support for thin pool discard and external origin.
diff --git a/libdm/misc/dm-ioctl.h b/libdm/misc/dm-ioctl.h
index c031315..1cf66fe 100644
--- a/libdm/misc/dm-ioctl.h
+++ b/libdm/misc/dm-ioctl.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001 - 2003 Sistina Software (UK) Limited.
- * Copyright (C) 2004 - 2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004 - 2012 Red Hat, Inc. All rights reserved.
  *
  * This file is released under the LGPL.
  */
@@ -269,9 +269,9 @@ enum {
 #define DM_DEV_SET_GEOMETRY	_IOWR(DM_IOCTL, DM_DEV_SET_GEOMETRY_CMD, struct dm_ioctl)
 
 #define DM_VERSION_MAJOR	4
-#define DM_VERSION_MINOR	20
+#define DM_VERSION_MINOR	23
 #define DM_VERSION_PATCHLEVEL	0
-#define DM_VERSION_EXTRA	"-ioctl (2011-02-02)"
+#define DM_VERSION_EXTRA	"-ioctl (2012-07-25)"
 
 /* Status bits */
 #define DM_READONLY_FLAG	(1 << 0) /* In/Out */
@@ -309,6 +309,8 @@ enum {
 
 /*
  * Set this to suspend without flushing queued ios.
+ * Also disables flushing uncommitted changes in the thin target before
+ * generating statistics for DM_TABLE_STATUS and DM_DEV_WAIT.
  */
 #define DM_NOFLUSH_FLAG		(1 << 11) /* In */
 
@@ -331,8 +333,8 @@ enum {
 #define DM_UUID_FLAG			(1 << 14) /* In */
 
 /*
- * If set, all buffers are wiped after use. Used when sending
- * or requesting sensitive data like crypt key.
+ * If set, all buffers are wiped after use. Use when sending
+ * or requesting sensitive data such as an encryption key.
  */
 #define DM_SECURE_DATA_FLAG		(1 << 15) /* In */
 
diff --git a/man/dmsetup.8.in b/man/dmsetup.8.in
index 8eb679b..90c715f 100644
--- a/man/dmsetup.8.in
+++ b/man/dmsetup.8.in
@@ -109,6 +109,7 @@ dmsetup \- low level logical volume management
 .B dmsetup status
 .RB [ \-\-target
 .IR target_type ]
+.RB [ \-\-noflush ]
 .RI [ device_name ]
 .br
 .B dmsetup suspend
@@ -143,6 +144,7 @@ dmsetup \- low level logical volume management
 .B dmsetup version
 .br
 .B dmsetup wait
+.RB [ \-\-noflush ]
 .I device_name
 .RI [ event_nr ]
 .br
@@ -477,11 +479,13 @@ Default subsystem is LVM.
 .B status
 .RB [ \-\-target
 .IR target_type ]
+.RB [ \-\-noflush ]
 .RI [ device_name ]
 .br
 Outputs status information for each of the device's targets.
 With \-\-target, only information relating to the specified target type
-is displayed.
+any is displayed.  With \-\-noflush, the thin target (from version 1.3.0)
+doesn't commit any outstanding changes to disk before reporting its statistics.
 .br
 .HP
 .B suspend
@@ -577,6 +581,7 @@ Outputs version information.
 
 .TP
 .B wait
+.RB [ \-\-noflush ]
 .I device_name
 .RI [ event_nr ]
 .br
@@ -584,6 +589,8 @@ Sleeps until the event counter for device_name exceeds event_nr.
 Use \-v to see the event number returned.
 To wait until the next event is triggered, use \fBinfo\fP to find
 the last event number.
+With \-\-noflush, the thin target (from version 1.3.0) doesn't commit
+any outstanding changes to disk before reporting its statistics.
 .SH TABLE FORMAT
 Each line of the table specifies a single target and is of the form:
 .P
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 2787b76..5422f0b 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -1642,6 +1642,9 @@ static int _status(CMD_ARGS)
 	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
 		goto out;
 
+	if (_switches[NOFLUSH_ARG] && !dm_task_no_flush(dmt))
+		goto out;
+
 	if (!dm_task_run(dmt))
 		goto out;
 
@@ -2994,9 +2997,9 @@ static struct command _commands[] = {
 	{"ls", "[--target <target_type>] [--exec <command>] [-o options] [--tree]", 0, 0, 0, _ls},
 	{"info", "[<device>]", 0, -1, 1, _info},
 	{"deps", "[-o options] [<device>]", 0, -1, 1, _deps},
-	{"status", "[<device>] [--target <target_type>]", 0, -1, 1, _status},
+	{"status", "[<device>] [--noflush] [--target <target_type>]", 0, -1, 1, _status},
 	{"table", "[<device>] [--target <target_type>] [--showkeys]", 0, -1, 1, _status},
-	{"wait", "<device> [<event_nr>]", 0, 2, 0, _wait},
+	{"wait", "<device> [<event_nr>] [--noflush]", 0, 2, 0, _wait},
 	{"mknodes", "[<device>]", 0, -1, 1, _mknodes},
 	{"mangle", "[<device>]", 0, -1, 1, _mangle},
 	{"udevcreatecookie", "", 0, 0, 0, _udevcreatecookie},


