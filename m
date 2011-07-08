From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Jul 2011 16:49:05 -0000
Subject: LVM2 ./WHATS_NEW lib/commands/toolcontext.c
Message-ID: <20110708164905.3327.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-07-08 16:49:04

Modified files:
	.              : WHATS_NEW 
	lib/commands   : toolcontext.c 

Log message:
	Ignore activation/verify_udev_operations if dm kernel driver vsn < 4.18.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2039&r2=1.2040
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.124&r2=1.125

--- LVM2/WHATS_NEW	2011/07/08 15:53:59	1.2039
+++ LVM2/WHATS_NEW	2011/07/08 16:49:04	1.2040
@@ -15,6 +15,7 @@
   Fix to preserve exclusive activation of mirror while up-converting.
   Reject allocation if number of extents is not divisible by area count.
   Fix issue preventing cluster mirror creation.
+  Ignore activation/verify_udev_operations if dm kernel driver vsn < 4.18.
   Add activation/verify_udev_operations to lvm.conf, disabled by default.
   Call vg_mark_partial_lvs() before VG structure is returned from the cache.
   Remove unused internal flag ACTIVATE_EXCL from the code.
--- LVM2/lib/commands/toolcontext.c	2011/07/01 14:09:19	1.124
+++ LVM2/lib/commands/toolcontext.c	2011/07/08 16:49:04	1.125
@@ -200,6 +200,21 @@
 	reset_lvm_errno(1);
 }
 
+/*
+ * Until the DM_UEVENT_GENERATED_FLAG was introduced in kernel patch 
+ * 856a6f1dbd8940e72755af145ebcd806408ecedd
+ * some operations could not be performed by udev, requiring our fallback code.
+ */
+static int _dm_driver_has_stable_udev_support()
+{
+	char vsn[80];
+	unsigned maj, min, patchlevel;
+
+	return driver_version(vsn, sizeof(vsn)) &&
+	       (sscanf(vsn, "%u.%u.%u", &maj, &min, &patchlevel) == 3) &&
+	       (maj == 4 ? min >= 18 : maj > 4);
+}
+
 static int _process_config(struct cmd_context *cmd)
 {
 	mode_t old_umask;
@@ -299,6 +314,13 @@
 		find_config_tree_int(cmd, "activation/verify_udev_operations",
 				     DEFAULT_VERIFY_UDEV_OPERATIONS) : 1;
 
+	/* Do not rely fully on udev if the udev support is known to be incomplete. */
+	if (!cmd->default_settings.udev_fallback && !_dm_driver_has_stable_udev_support()) {
+		log_very_verbose("Kernel driver has incomplete udev support so "
+				 "LVM will check and perform some operations itself.");
+		cmd->default_settings.udev_fallback = 1;
+	}
+
 #else
 	/* We must use old node/symlink creation code if not compiled with udev support at all! */
 	cmd->default_settings.udev_fallback = 1;


