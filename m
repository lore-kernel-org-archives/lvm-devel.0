From: agk@sourceware.org <agk@sourceware.org>
Date: 4 Aug 2009 15:36:16 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf lib/activate ...
Message-ID: <20090804153616.22860.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-08-04 15:36:15

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf 
	lib/activate   : dev_manager.c 
	lib/commands   : toolcontext.c toolcontext.h 
	lib/config     : defaults.h 
	tools          : lvmcmdline.c 

Log message:
	Add activation/udev_sync to lvm.conf.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1229&r2=1.1230
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.157&r2=1.158
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.83&r2=1.84
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.h.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.104&r2=1.105

--- LVM2/WHATS_NEW	2009/08/03 18:09:25	1.1229
+++ LVM2/WHATS_NEW	2009/08/04 15:36:13	1.1230
@@ -1,5 +1,6 @@
 Version 2.02.51 - 
 ================================
+  Add activation/udev_sync to lvm.conf.
   Only change LV symlinks on ACTIVATE not PRELOAD.
   Make lvconvert honour log mirror options combined with downconversion.
   Allow LV suspend while --ignorelockingfailure is in force.
--- LVM2/doc/example.conf	2009/08/01 17:08:44	1.44
+++ LVM2/doc/example.conf	2009/08/04 15:36:14	1.45
@@ -301,6 +301,16 @@
 }
 
 activation {
+    # Set to 0 to disable udev syncronisation (if compiled into the binaries).
+    # Processes will not wait for notification from udev.
+    # They will continue irrespective of any possible udev processing
+    # in the background.  You should only use this if udev is not running
+    # or has rules that ignore the devices LVM2 creates.
+    # The command line argument --nodevsync takes precedence over this setting.
+    # If set to 1 when udev is not running, and there are LVM2 processes
+    # waiting for udev, run 'dmsetup udevcomplete' manually to wake them up.
+    udev_sync = 1
+
     # How to fill in missing stripes if activating an incomplete volume.
     # Using "error" will make inaccessible parts of the device return
     # I/O errors on access.  You can instead use a device path, in which 
--- LVM2/lib/activate/dev_manager.c	2009/08/03 18:09:26	1.157
+++ LVM2/lib/activate/dev_manager.c	2009/08/04 15:36:14	1.158
@@ -455,6 +455,8 @@
 
 	dm->target_state = NULL;
 
+	dm_udev_set_sync_support(cmd->current_settings.udev_sync);
+
 	return dm;
 
       bad:
--- LVM2/lib/commands/toolcontext.c	2009/07/21 20:00:04	1.83
+++ LVM2/lib/commands/toolcontext.c	2009/08/04 15:36:14	1.84
@@ -265,6 +265,10 @@
 		return 0;
 	}
 
+	cmd->default_settings.udev_sync = find_config_tree_int(cmd,
+								"activation/udev_sync",
+								DEFAULT_UDEV_SYNC);
+
 	cmd->stripe_filler = find_config_tree_str(cmd,
 						  "activation/missing_stripe_filler",
 						  DEFAULT_STRIPE_FILLER);
--- LVM2/lib/commands/toolcontext.h	2009/07/13 19:49:49	1.32
+++ LVM2/lib/commands/toolcontext.h	2009/08/04 15:36:14	1.33
@@ -34,6 +34,7 @@
 	int archive;		/* should we archive ? */
 	int backup;		/* should we backup ? */
 	int read_ahead;		/* DM_READ_AHEAD_NONE or _AUTO */
+	int udev_sync;
 	int cache_vgmetadata;
 	const char *msg_prefix;
 	struct format_type *fmt;
--- LVM2/lib/config/defaults.h	2009/08/01 17:08:44	1.49
+++ LVM2/lib/config/defaults.h	2009/08/04 15:36:14	1.50
@@ -68,6 +68,7 @@
 #define DEFAULT_PVMETADATACOPIES 1
 #define DEFAULT_LABELSECTOR UINT64_C(1)
 #define DEFAULT_READ_AHEAD "auto"
+#define DEFAULT_UDEV_SYNC 0
 #define DEFAULT_EXTENT_SIZE 4096	/* In KB */
 #define DEFAULT_MAX_PV 0
 #define DEFAULT_MAX_LV 0
--- LVM2/tools/lvmcmdline.c	2009/07/27 21:01:58	1.104
+++ LVM2/tools/lvmcmdline.c	2009/08/04 15:36:15	1.105
@@ -830,6 +830,9 @@
 	} else
 		init_trust_cache(0);
 
+	if (arg_count(cmd, noudevsync_ARG))
+		cmd->current_settings.udev_sync = 0;
+
 	/* Handle synonyms */
 	if (!_merge_synonym(cmd, resizable_ARG, resizeable_ARG) ||
 	    !_merge_synonym(cmd, allocation_ARG, allocatable_ARG) ||


