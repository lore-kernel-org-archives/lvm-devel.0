From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 26 May 2014 21:32:20 +0000 (UTC)
Subject: master - dmsetup: add warning
Message-ID: <20140526213220.BF35F60DC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3cb2658fb7ff0bba45e66e79bce8812c819dff52
Commit:        3cb2658fb7ff0bba45e66e79bce8812c819dff52
Parent:        6e9105c7bb7f4a1beb34579303670e4510c7d2e6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 26 22:51:04 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 26 22:56:30 2014 +0200

dmsetup: add warning

Warn when --udevcookie/DM_UDEV_COOKIE is used with 'dmsetup remove --force'.

When command is doing multiple ioctl operations on a single device,
it may invoke udev activity, that is colliding with further ioctl commands.
The result of such operation becomes unpredictable.
Use of --retry could partially help...
---
 WHATS_NEW_DM     |    1 +
 man/dmsetup.8.in |    6 ++++++
 tools/dmsetup.c  |   10 +++++++++-
 3 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 6304ff6..8e221c1 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.88 - 
 =================================
+  Warn user about incorrect use of cookie with 'dmsetup remove --force'.
   Also recognize 'help'/'?' as reserved sort key name to show help.
   Export recognized DM_REPORT_FIELD_RESERVED_NAME_{HELP,HELP_ALT} to show help.
   Add dm_units_to_factor for size unit parsing.
diff --git a/man/dmsetup.8.in b/man/dmsetup.8.in
index 599c843..ae84489 100644
--- a/man/dmsetup.8.in
+++ b/man/dmsetup.8.in
@@ -243,6 +243,9 @@ Specify a one-line table directly on the command line.
 .TP
 .B \-\-udevcookie \fIcookie
 Use cookie for udev synchronisation.
+Note: Same cookie should be used for same type of operations i.e. creation of
+multiple different devices. It's not adviced to combine different
+operations on the single device.
 .TP
 .BR \-u | \-\-uuid
 Specify the uuid.
@@ -429,6 +432,9 @@ process to be killed. If an attempt to remove a device fails,
 perhaps because a process run from a quick udev rule
 temporarily opened the device, the \-\-retry option will cause
 the operation to be retried for a few seconds before failing.
+Do NOT combine \fB\-\-force\fP and \fB\-\-udevcookie\fP,
+as udev may start to process udev rules in the middle of error target
+replacement and result in nondeterministic result.
 .br
 .HP
 .B remove_all
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 4433571..f84d1a8 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -1498,8 +1498,16 @@ error:
 
 static int _remove(CMD_ARGS)
 {
-	if (_switches[FORCE_ARG] && argc > 1)
+	if (_switches[FORCE_ARG] && argc > 1) {
+		/*
+		 * 'remove --force' option is doing 2 operations on the same device
+		 * this is not compatible with the use of --udevcookie/DM_UDEV_COOKIE.
+		 * Udevd collision could be partially avoided with --retry.
+		 */
+		if (_udev_cookie)
+			log_warn("WARNING: Use of cookie and --force is not compatible.");
 		(void) _error_device(cmd, argc, argv, NULL, 0);
+	}
 
 	return _simple(DM_DEVICE_REMOVE, argc > 1 ? argv[1] : NULL, 0, 0);
 }


