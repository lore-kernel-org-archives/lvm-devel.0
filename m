From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Jul 2011 19:19:45 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20110708191945.27018.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-07-08 19:19:44

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.280&r2=1.281
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.85&r2=1.86
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2040&r2=1.2041
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.479&r2=1.480

--- LVM2/VERSION	2011/04/29 19:02:22	1.280
+++ LVM2/VERSION	2011/07/08 19:19:44	1.281
@@ -1 +1 @@
-2.02.86(2)-cvs (2011-04-29)
+2.02.86(2)-cvs (2011-07-08)
--- LVM2/VERSION_DM	2011/04/29 17:05:20	1.85
+++ LVM2/VERSION_DM	2011/07/08 19:19:44	1.86
@@ -1 +1 @@
-1.02.65-cvs (2011-04-29)
+1.02.65-cvs (2011-07-08)
--- LVM2/WHATS_NEW	2011/07/08 16:49:04	1.2040
+++ LVM2/WHATS_NEW	2011/07/08 19:19:44	1.2041
@@ -1,12 +1,12 @@
-Version 2.02.86 -  
-=================================
-  Fix warning in pvcreate for MD linear devices.
+Version 2.02.86 - 8th July 2011
+===============================
+  Remove unnecessary warning in pvcreate for MD linear devices.
   Move snapshot removal activation logic into lib/activate.
   Cope with a PV only discovered missing when creating deptree.
   Abort operation if dm_tree_node_add_target_area fails.
   Add activation/checks to lvm.conf to perform additional ioctl validation.
+  Always preload on suspend, even if no metadata changed (lvchange --refresh).
   When suspending, automatically preload newly-visible existing LVs.
-  Report internal error when parameters are missing on table load.
   Teardown any stray devices with $COMMON_PREFIX during test runs.
   Reinstate correct permissions when creating mirrors. [2.02.85]
   Append 'm' attribute to pv_attr for missing PVs.
@@ -14,16 +14,14 @@
   Remove enforcement of udev verification when using non-standard /dev location.
   Fix to preserve exclusive activation of mirror while up-converting.
   Reject allocation if number of extents is not divisible by area count.
-  Fix issue preventing cluster mirror creation.
+  Fix cluster mirror creation to work with new mirror allocation algorithm.
   Ignore activation/verify_udev_operations if dm kernel driver vsn < 4.18.
   Add activation/verify_udev_operations to lvm.conf, disabled by default.
   Call vg_mark_partial_lvs() before VG structure is returned from the cache.
   Remove unused internal flag ACTIVATE_EXCL from the code.
   Remove useless test of ACTIVATE_EXCL in lv_add_mirrors() clustered code path.
-  Use lv_activate_opts struct instead of MERGING status flag.
-  Use lv_activate_opts struct instead of ACTIVATE_EXCL status flag.
   Add lv_activate_opts structure for activation (replacing activation flags).
-  Fix a problem with inconsistent pre-commit metadata on MISSING_PV devices.
+  Ignore inconsistent pre-commit metadata on MISSING_PV devs while activating.
   Add proper udev library context initialization and finalization to liblvm.
   Fix last snapshot removal to avoid table reload while a device is suspended.
   Use dm_get_suspended_counter in replacement critical_section logic.
@@ -33,11 +31,12 @@
   Annotate critical section debug messages.
   Fix reduction of mirrors with striped segments to always align to stripe size.
   Validate mirror segments size.
-  Fix extent rounding for striped volumes (never reduce more than requested).
+  Include lvmetad development code in tree.
+  Fix extent rounding for striped volumes never to reduce more than requested.
   Fix create_temp_name to replace any '/' found in the hostname with '?'.
-  Always use append to file in lvmdump (selinux policy - no file truncation).
+  Always use append to file in lvmdump. selinux policy may ban file truncation.
   Propagate test mode to clvmd to skip activation and changes to held locks.
-  Defer writing PV labels to vg_write.
+  Defer writing PV labels until vg_write.
   Store label_sector only in struct physical_volume.
   Permit --available with lvcreate so non-snapshot LVs need not be activated.
   Report sector containing label in verbose message.
@@ -46,8 +45,8 @@
   Do not log a superfluous stack message when the lv is properly processed.
   Do not issue an error message when unable to remove .cache on read-only fs.
   Avoid memlock size mismatch by preallocating stdio line buffers.
+  Rewrite vgreduce --removemissing --force to share lvconvert code.
   Reorganize lvconvert --repair code to allow reuse.
-  Rewrite vgreduce --removemissing --force leveraging shared lvconvert code.
 
 Version 2.02.85 - 29th April 2011
 =================================
--- LVM2/WHATS_NEW_DM	2011/07/08 17:08:19	1.479
+++ LVM2/WHATS_NEW_DM	2011/07/08 19:19:44	1.480
@@ -1,12 +1,13 @@
-Version 1.02.65 - 
-==================================
+Version 1.02.65 - 8th July 2011
+===============================
   Remove dev name prefix from dmsetup line output if exactly one dev requested.
   Report internal error if suspending a device using an already-suspended dev.
+  Report error if a table load requiring target parameters has none supplied.
   Add dmsetup --checks and dm_task_enable_checks framework to validate ioctls.
   Add age_in_minutes parameter to dmsetup udevcomplete_all.
   Return immediately from dm_lib_exit() if called more than once.
   Disable udev fallback by default and add --verifyudev option to dmsetup.
-  Warn if a table is loaded while a device is known to be in suspended state.
+  Report internal error if any table is loaded while any dev is known suspended.
   Add dm_get_suspended_counter() for number of devs in suspended state by lib.
   Fix "all" report field prefix matching to include label fields with pv_all.
   Delay resuming new preloaded mirror devices with core logs in deptree code.


