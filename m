From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Jan 2012 14:02:47 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM lib/display/di ...
Message-ID: <20120126140247.14189.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-01-26 14:02:44

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 
	lib/display    : display.c 
	lib/config     : defaults.h 
	doc            : example.conf.in 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2244&r2=1.2245
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.534&r2=1.535
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.127&r2=1.128
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.95&r2=1.96
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.42&r2=1.43

--- LVM2/WHATS_NEW	2012/01/25 22:17:57	1.2244
+++ LVM2/WHATS_NEW	2012/01/26 14:02:42	1.2245
@@ -1,19 +1,17 @@
-Version 2.02.89 - 
-==================================
+Version 2.02.89 - 26th January 2012
+===================================
   Add missing check for uname result in clvmd TEST processing.
   Fix memleak in target_version() error path (unsupported LIST_VERSIONS).
-  Limit alignment to 32bit values.
-  Check for correctness of uint64 dev_size value.
-  Rename origin_only parameter to more generic flag use_layer for lv_info().
+  Limit data_alignment and data_alignment_offset to 32bit values.
+  Check for correctness of uint64 dev_size value in format_text.
   Thin pools have segment fields thin_count, zero, transaction_id.
-  Each new created LV volume has creation lv_time and lv_host.
-  Print data_percent and metadata_percent for verbose lvs.
-  Thin pool support lvs data_percent, metadata_percent, data/metadata_lv.
-  Thin volumes support lvs options data_percent, pool_lv.
-  Update lv_info to use -real layer for origin_only LVs.
+  Add data_percent and metadata_percent for thin pools to lvs -v.
+  Add data_lv & metadata_lv fields to lvs for thin pools.
+  Add data_percent & pool_lv fields to lvs for thin volumes.
+  Rename origin_only parm to use_layer for lv_info and use with thin LVs.
   Add lv_thin_pool_transaction_id to read the transaction_id value.
-  Use suspend|resume_origin_only when up-converting RAID, as mirrors do.
-  Fix the way RAID meta LVs are added to the dependency tree.
+  Use {suspend,resume}_origin_only when up-converting RAID, as mirrors do.
+  Always add RAID metadata LVs to deptree (even when origin_only is set).
   Change exclusive LV activation logic to try local node before remote nodes.
   Add CLVMD_FLAG_REMOTE to skip processing on local node.
   Prompt if request is made to remove a snapshot whose "Merge failed".
@@ -21,37 +19,37 @@
   Don't allow a user to merge an invalid snapshot.
   Use m and M lv_attr to indicate that a snapshot merge failed in lvs.
   Differentiate between snapshot status of "Invalid" and "Merge failed".
-  Lookup snapshot usage percent of origin volume when a snapshot is merging.
-  Update lvdisplay with backward compat. config opt. lvm1_compatible_display.
+  Report snapshot usage percent of origin volume when a snapshot is merging.
+  Require global/lvdisplay_shows_full_device_path for (bogus) lvm1-style paths.
   Do not report linear segtype for non-striped targets.
-  Keep info about creation host and time for each logical volume.
+  Record creation host & time for each LV and report as lv_time & lv_host.
   Make error message hit when preallocated memlock memory exceeded clearer.
   Use R lv_attr to indicate read-only activation of non-read-only device in lvs.
   Show read-only activation override in lvdisplay & add 4 to perms in -c.
   Add activation/read_only_volume_list to override LV permission in metadata.
   Give priority to emcpower devices with duplicate PVIDs.
   Add check for error in _adjust_policy_params() (lvextend --use-policies).
-  Supports rounding of percentage (%LV, %VG...) for LV resize upward.
+  Round specified percentages upwards (%LV, %VG...) when resizing LVs.
   Use dmeventd_lvm2_command in dmeventd plugins snapshot, raid, mirror.
-  Add helper dmeventd_lvm2_command() into libdevmapper-event-lvm2 library.
-  Updated documentation for dmeventd.
-  Drop extra stat call before opening device.
+  Add helper dmeventd_lvm2_command() to libdevmapper-event-lvm2 library.
+  Update documentation for dmeventd.
+  Remove unnecessary stat before opening device in dev_open_flags.
   Reduce number of lstat calls when selecting device alias.
-  Add function to inialize common structure device members.
-  Always zalloc device structure during initialization.
+  Add _dev_init to initialize common struct device members.
+  Always zalloc struct device during initialization.
   Fix missing thread list manipulation protection in dmeventd.
   Do not derefence lv pointer in _percent_run() function before NULL check.
   Allow empty strings for description and creation_host config fields.
   Issue deprecation warning when removing last lvm1-format snapshot.
   Reinstate support for snapshot removal with lvm1 format. (2.02.86)
-  Add policy based automated repair of RAID logical volumes
-  Don't allow two images to be split and tracked from a RAID LV at one time
-  Don't allow size change of RAID LV that is tracking changes for a split image
-  Don't allow size change of RAID sub-LVs independently
-  Don't allow name change of RAID LV that is tracking changes for a split image
-  Do not allow users to change the name of RAID sub-LVs independently
-  Do not allow users to change permissions on RAID sub-LVs
-  Support the ability to replace specific devices in a RAID array via lvconvert.
+  Add policy-based automated repair of RAID logical volumes.
+  Don't allow two images to be split and tracked from a RAID LV at one time.
+  Don't allow size change of RAID LV that is tracking changes for a split image.
+  Don't allow size change of RAID sub-LVs independently.
+  Don't allow name change of RAID LV that is tracking changes for a split image.
+  Do not allow users to change the name of RAID sub-LVs independently.
+  Do not allow users to change permissions on RAID sub-LVs.
+  Allow lvconvert to replace specified devices in a RAID array.
   Add activation/use_linear_target enabled by default.
   Use gcc warning options only with .c to .o compilation.
   Move y/n prompts to stderr and repeat if response has both 'n' and 'y'.
@@ -64,31 +62,31 @@
   Add query before removing snapshots when inactive snapshot origin is removed.
   Allow changing availability state of snapshots.
   Skip non-virtual snapshots for availability change for lvchange with vg name.
-  Adjusted mirror region size only for mirrors and raids.
+  Skip adjusting mirror region size unless mirror or raid.
   Reorder prompt conditions for removal of active volumes.
-  Avoid 'mda inconsistency' by properly registering UNLABELLED_PV flag (2.02.86)
+  Avoid 'mda inconsistency' by properly registering UNLABELLED_PV flag.(2.02.86)
   Fix --enable-static_link unless using --enable-dmeventd / --enable-udev_sync.
   Move gentoo MAKEDEV to /sbin in lvm2create_initrd.
   Add filter to avoid scan of device if it is part of active multipath.
   Add missing default $LVM_VG_NAME usage for snapshots.
-  Fix extent_count overflow with lvextend.
+  Avoid extent_count overflow with lvextend.
   Add missing lvrename mirrored log recursion in for_each_sub_lv.
   Improve lv_extend stack reporting.
   Increase virtual segment size instead of creating multiple segment list.
   Add last_seg(lv) internal function.
   Support empty string for log/prefix.
-  Fix regression that allowed mirrored logs for cluster mirrors.
+  Disallow mirrored logs for cluster mirrors. (2.02.72)
   Don't print char type[8] as a plain string in pvck PV type.
-  Use vg memory pool implicitely for vg read.
+  Use vg memory pool implicitly for vg read.
   Always use vg memory pool for allocated lv segment.
   Remove extra 4kB buffer allocated on stack in print_log().
   Make move_lv_segment non-static function and use dm_list function.
   Pass exclusive LV locks to all nodes in the cluster.
-  Improve lvcreate man documentation of the chunksize option.
-  Improve man page style for lvcreate, lvs.
+  Improve lvcreate chunksize man page description.
+  Improve man page style for lvcreate & lvs.
   Avoid recursive calls to dmeventd in its LVM plugins.
   Log dev name now returned to kernel for registering during cmirror CTR.
-  Fix lv_info open_count test for disabled verify_udev_operations (2.02.86).
+  Fix lv_info open_count test for disabled verify_udev_operations. (2.02.86)
   Simplify code for lvm worker thread in clvmd.                     
   Use pthread_barrier to synchronize clvmd threads at startup.
   Limit clvmd's thread size to 128KiB and ignore activation/reserved_stack.
@@ -100,9 +98,9 @@
   Add ability to convert mirror segtype to RAID1 segtype.
   Add ability to convert from linear to RAID1.
   Add ability to extend mirrors with '--nosync' option.
-  Fix splitmirror in cluster having different DM/LVM views of storage.
-  Fix improper udev settings during suspend/resume for mirror sub-LVs.
-  Fix vgsplit when there are mirrors that have mirrored logs.
+  Fix splitmirror LV names to maintain consistent state in a cluster.
+  Apply appropriate udev flags when suspending/resuming mirror sub-LVs.
+  Fix vgsplit to handle mirrored logs.
   Clarify multi-name device filter pattern matching explanation in lvm.conf.
   Introduce lv_send_message and dev_manager_send_message.
   Introduce revert_lv for better pvmove cleanup.
@@ -134,19 +132,19 @@
   Fix clvmd processing of invalid request on local socket.
   Fix command line option decoding.
   Reset LV status when unlinking LV from VG.
-  Fix overly strict extent-count divisibility requirements for striped mirrors.
+  Fix overly-strict extent-count divisibility requirements for striped mirrors.
   Fix rounding direction in lvresize when reducing volume size.
   Fix possible overflow of size if %FREE or %VG is used.
   Fix vgchange activation of snapshot with virtual origin.
   Activate virtual snapshot origin exclusively (only on local node in cluster).
   Fix lv_mirror_count to handle mirrored stripes properly.
   Fix failure to down-convert a mirror to linear due to udev "dev open" conflict
-  Fix mirrored log creation when PE size is small - force log_size >= region_size
+  Fix mirrored log creation when PE size is small: use log_size >= region_size.
   Fix log size calculation when only a log is being added to a mirror.
   Add 7th lv_attr char to show the related kernel target.
   Terminate pv_attr field correctly. (2.02.86)
   Fix 'not not' typo in pvcreate man page.
-  Improve man page style for fsadm, lvreduce, lvremove, lvrename, lvresize.
+  Improve man page style for fsadm, lvreduce, lvremove, lvrename & lvresize.
   Support break for vgchange and vgrefresh operation.
   Switch int to unsigned type for pvmetadatacopies for pv_create().
   Replace :space: with [\t ] for awk in vgimportclone (not widely supported).
--- LVM2/WHATS_NEW_DM	2012/01/26 10:11:30	1.534
+++ LVM2/WHATS_NEW_DM	2012/01/26 14:02:42	1.535
@@ -15,6 +15,7 @@
   Include a copy of kernel DM documentation in doc/kernel.
   Improve man page style for dmsetup and mention more targets.
   Fix _get_proc_number to be tolerant of malformed /proc/misc entries.
+  Fix missing thread list manipulation protection in dmeventd.
   Add ExecReload to dm-event.service for systemd to reload dmeventd properly.
   Add dm_config_tree_find_str_allow_empty and dm_config_find_str_allow_empty.
   Fix compile-time pool memory locking with DEBUG_MEM.
--- LVM2/lib/display/display.c	2012/01/25 17:14:56	1.127
+++ LVM2/lib/display/display.c	2012/01/26 14:02:43	1.128
@@ -526,14 +526,14 @@
 
 	log_print("--- Logical volume ---");
 
-	lvm1compat = find_config_tree_int(cmd, "global/lvm1_compatible_display",
-					  DEFAULT_LVM1_COMPATIBLE_DISPLAY);
+	lvm1compat = find_config_tree_int(cmd, "global/lvdisplay_shows_full_device_path",
+					  DEFAULT_LVDISPLAY_SHOWS_FULL_DEVICE_PATH);
 
-	if (lvm1compat) {
-		/* Note: Invisible devices do not get /dev/vg/lv */
+	if (lvm1compat)
+		/* /dev/vgname/lvname doen't actually exist for internal devices */
 		log_print("LV Name                %s%s/%s",
 			  lv->vg->cmd->dev_dir, lv->vg->name, lv->name);
-	} else if (lv_is_visible(lv)) {
+	else if (lv_is_visible(lv)) {
 		/* Thin pool does not have /dev/vg/name link */
 		if (!lv_is_thin_pool(lv))
 			log_print("LV Path                %s%s/%s",
@@ -541,7 +541,7 @@
 				  lv->vg->name, lv->name);
 		log_print("LV Name                %s", lv->name);
 	} else
-		log_print("Invisible LV Name      %s", lv->name);
+		log_print("Internal LV Name       %s", lv->name);
 
 	log_print("VG Name                %s", lv->vg->name);
 	log_print("LV UUID                %s", uuid);
--- LVM2/lib/config/defaults.h	2012/01/25 11:32:41	1.95
+++ LVM2/lib/config/defaults.h	2012/01/26 14:02:44	1.96
@@ -49,7 +49,7 @@
 #define DEFAULT_PRIORITISE_WRITE_LOCKS 1
 #define DEFAULT_USE_MLOCKALL 0
 #define DEFAULT_METADATA_READ_ONLY 0
-#define DEFAULT_LVM1_COMPATIBLE_DISPLAY 0
+#define DEFAULT_LVDISPLAY_SHOWS_FULL_DEVICE_PATH 0
 
 #define DEFAULT_MIRROR_SEGTYPE "mirror"
 #define DEFAULT_MIRRORLOG "disk"
--- LVM2/doc/example.conf.in	2012/01/20 16:59:59	1.42
+++ LVM2/doc/example.conf.in	2012/01/26 14:02:44	1.43
@@ -446,10 +446,13 @@
     # setting.
     mirror_segtype_default = "mirror"
 
-    # Whether to lvdisplay LV name in lvm1 compatible format /dev/vgname/lvname
-    # Default is now to display LV name and path (if exists) separately.
-    # If the old behavior is preffered use set to 1.
-    # lvm1_compatible_display = 1
+    # The default format for displaying LV names in lvdisplay was changed 
+    # in version 2.02.89 to show the LV name and path separately.
+    # Previously this was always shown as /dev/vgname/lvname even when that
+    # was never a valid path in the /dev filesystem.
+    # Set to 1 to reinstate the previous format.
+    #
+    # lvdisplay_shows_full_device_path = 0
 }
 
 activation {


