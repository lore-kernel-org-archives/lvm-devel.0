From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Jan 2009 13:14:23 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20090126131423.16776.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-01-26 13:14:22

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.188&r2=1.189
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1024&r2=1.1025
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.260&r2=1.261

--- LVM2/VERSION	2008/11/19 14:14:51	1.188
+++ LVM2/VERSION	2009/01/26 13:14:22	1.189
@@ -1 +1 @@
-2.02.44-cvs (2008-11-19)
+2.02.44-cvs (2009-01-26)
--- LVM2/VERSION_DM	2008/11/19 14:14:52	1.3
+++ LVM2/VERSION_DM	2009/01/26 13:14:22	1.4
@@ -1 +1 @@
-1.02.30-cvs (2008-11-19)
+1.02.30-cvs (2009-01-26)
--- LVM2/WHATS_NEW	2009/01/22 10:21:12	1.1024
+++ LVM2/WHATS_NEW	2009/01/26 13:14:22	1.1025
@@ -1,33 +1,33 @@
-Version 2.02.44 - 
-====================================
-  Add corosync/DLM cluster interface to clvmd
+Version 2.02.44 - 26th January 2009
+===================================
+  Add corosync/DLM cluster interface to clvmd.
   Add --nameprefixes, --unquoted, --rows to pvs, vgs, lvs man pages.
-  Fix fsadm failure with block size != 1K.
+  Fix lvresize size conversion for fsadm when block size is not 1K.
   Fix pvs segfault when run with orphan PV and some VG fields.
   Display a 'dev_size' of zero for missing devices in reports.
   Add pv_mda_size to pvs and vg_mda_size to vgs.
   Fix lvmdump /sys listing to include virtual devices directory.
   Add "--refresh" functionality to vgchange and vgmknodes.
-  Check for maximal LV size when wiping device.
+  Avoid exceeding LV size when wiping device.
   Calculate mirror log size instead of using 1 extent.
-  Check if requested major/minor pair is already used.
+  Ensure requested device number is available before activating with it.
   Fix incorrect exit status from 'help <command>'.
   Fix vgrename using UUID if there are VGs with identical names.
   Fix segfault when invalid field given in reporting commands.
   Refactor init_lvm() for lvmcmdline and clvmd.
   Add liblvm interactive test infrastructure to build.
   Use better random seed value in temp file creation.
-  Add generic function to read /dev/urandom, used in uuid calculation.
+  Add read_urandom to read /dev/urandom. Use in uuid calculation.
   Use displayable_lvs_in_vg and lv_is_displayable for consistency throughout.
   Fix race in vgcreate that would result in second caller overwriting first.
   Fix uninitialised lv_count in vgdisplay -c.
   Don't skip updating pvid hash when lvmcache_info struct got swapped.
   Add tinfo to termcap search path for pld-linux.
   Fix startup race in clvmd.
-  Generate Red Hat clvmd startup script at configuration time with correct paths.
+  Generate Red Hat clvmd startup script at config time with correct paths.
   Fix clvmd & dmeventd builds after tree restructuring.
   Cope with snapshot dependencies when removing a whole VG with lvremove.
-  Make man pages consistent with either-or options (use "|" everywhere).
+  Make man pages and tool help text consistent using | for alternative options.
 
 Version 2.02.43 - 10th November 2008
 ====================================
--- LVM2/WHATS_NEW_DM	2009/01/10 03:01:35	1.260
+++ LVM2/WHATS_NEW_DM	2009/01/26 13:14:22	1.261
@@ -1,8 +1,8 @@
-Version 1.02.30 -
+Version 1.02.30 - 26th January 2009
 ====================================
   Add "all" field to reports expanding to all fields of report type.
-  Add checks for device names in dmsetup and show proper error messages.
-  Replace _dm_snprintf with EMIT_PARAMS macro for creating target lines
+  Enforce device name length and character limitations in libdm.
+  Replace _dm_snprintf with EMIT_PARAMS macro for creating target lines.
 
 Version 1.02.29 - 10th November 2008
 ====================================


