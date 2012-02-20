From: agk@sourceware.org <agk@sourceware.org>
Date: 20 Feb 2012 19:38:21 -0000
Subject: LVM2 WHATS_NEW WHATS_NEW_DM VERSION VERSION_DM
Message-ID: <20120220193821.30403.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-20 19:38:19

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM VERSION VERSION_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2295&r2=1.2296
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.568&r2=1.569
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.292&r2=1.293
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.97&r2=1.98

--- LVM2/WHATS_NEW	2012/02/15 15:18:43	1.2295
+++ LVM2/WHATS_NEW	2012/02/20 19:38:19	1.2296
@@ -1,7 +1,7 @@
-Version 2.02.92 - 
+Version 2.02.92 - 20th February 2012
 ====================================
-  Read monitoring config settings for every lvm command.
-  Initialize monitoring support only for thin pools and skip thin volumes.
+  Read dmeventd monitoring config settings for every lvm command.
+  For thin devices, initialize monitoring only for thin pools not thin volumes.
   Make conversion from a synced 'mirror' to 'raid1' not cause a full resync.
   Properly test buffer for unit check in units_to_bytes().
   Add configure --with-systemdsystemunitdir.
--- LVM2/WHATS_NEW_DM	2012/02/16 14:39:02	1.568
+++ LVM2/WHATS_NEW_DM	2012/02/20 19:38:19	1.569
@@ -1,9 +1,9 @@
-Version 1.02.71 - 
+Version 1.02.71 - 20th February 2012
 ====================================
   Switch to using built-in blkid in 13-dm-disk.rules.
   Add "watch" rule to 13-dm-disk.rules.
   Detect failing fifo and skip 20s retry communication period.
-  Add DM_DEFAULT_NAME_MANGLING_MODE env. variable to override configured value.
+  Add DM_DEFAULT_NAME_MANGLING_MODE environment variable as an override.
   Add dm_lib_init to automatically initialise device-mapper library on load.
   Replace any '\' char with '\\' in table specification on input.
   Add mangle command to dmsetup to provide renaming to correct mangled form.
@@ -12,7 +12,7 @@
   Add dm_task_get_name_mangled/unmangled to libdevmapper.
   Mangle device name on dm_task_set_name/newname call if necessary.
   Add dm_set/get_name_mangling_mode to set/get name mangling in libdevmapper.
-  Add configure --with-default-name-mangling.
+  Add configure --with-default-name-mangling for udev-friendly dev name charset.
   Test for parsed words in _umount() dmeventd snapshot plugin.
   Fix memory leak in fail path of parse_loop_device_name() in dmsetup.
   Check for missing reply_uuid in dm_event_get_registered_device().
--- LVM2/VERSION	2012/02/13 00:23:21	1.292
+++ LVM2/VERSION	2012/02/20 19:38:19	1.293
@@ -1 +1 @@
-2.02.92(2)-cvs (2012-02-12)
+2.02.92(2)-cvs (2012-02-20)
--- LVM2/VERSION_DM	2012/02/13 00:23:21	1.97
+++ LVM2/VERSION_DM	2012/02/20 19:38:19	1.98
@@ -1 +1 @@
-1.02.71-cvs (2012-02-12)
+1.02.71-cvs (2012-02-20)


