From: agk@sourceware.org <agk@sourceware.org>
Date: 21 Aug 2007 19:46:37 -0000
Subject: LVM2 ./WHATS_NEW lib/config/defaults.h lib/met ...
Message-ID: <20070821194637.31926.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-08-21 19:46:36

Modified files:
	.              : WHATS_NEW 
	lib/config     : defaults.h 
	lib/metadata   : lv_manip.c 
	tools          : args.h commands.h lvconvert.c lvcreate.c 
	                 lvmcmdline.c tools.h 

Log message:
	Clean up mirrorlog argument processing.
	Only permit --force, --verbose and --debug arguments to be repeated.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.687&r2=1.688
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.125&r2=1.126
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.100&r2=1.101
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.141&r2=1.142
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/tools.h.diff?cvsroot=lvm2&r1=1.56&r2=1.57

--- LVM2/WHATS_NEW	2007/08/21 17:37:34	1.687
+++ LVM2/WHATS_NEW	2007/08/21 19:46:35	1.688
@@ -1,5 +1,6 @@
 Version 2.02.28 -
 ================================
+  Only permit --force, --verbose and --debug arguments to be repeated.
   Move guts of vgremove into library.
   Fix inconsistent licence notices: executables are GPLv2; libraries LGPLv2.1.
   Move guts of lvremove into library.
@@ -9,10 +10,10 @@
   Add const attributes where possible, first cut.
   Add support for renaming mirrored LVs.
   Factor out core of lvrename() to lv_rename lvm library function.
-  Add --log argument to specify log type for mirrors.
+  Add --mirrorlog argument to specify log type for mirrors.
   Don't try to monitor devices which we failed to create.
   Don't leak a file descriptor in fcntl_lock_file(), when fcntl fails.
-  Remove create_dir function; use now-equivalent dm_create_dir instead
+  Replace create_dir with dm_create_dir.
   Detect stream write failure reliably; new fn: lvm_fclose; use dm_fclose
   Fix clvmd if compiled with gulm support. (2.02.26)
   Trivial fix to lvdisplay man page.
--- LVM2/lib/config/defaults.h	2007/08/20 20:55:24	1.32
+++ LVM2/lib/config/defaults.h	2007/08/21 19:46:35	1.33
@@ -39,6 +39,7 @@
 #define DEFAULT_FALLBACK_TO_LOCAL_LOCKING 1
 #define DEFAULT_FALLBACK_TO_CLUSTERED_LOCKING 1
 
+#define DEFAULT_MIRRORLOG "disk"
 #define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
 #define DEFAULT_MIRROR_DEV_FAULT_POLICY "remove"
 #define DEFAULT_DMEVENTD_MIRROR_LIB "libdevmapper-event-lvm2mirror.so"
--- LVM2/lib/metadata/lv_manip.c	2007/08/21 16:40:33	1.125
+++ LVM2/lib/metadata/lv_manip.c	2007/08/21 19:46:36	1.126
@@ -1574,7 +1574,6 @@
 /*
  * Core of LV renaming routine.
  * VG must be locked by caller.
- * Returns 0 on failure, 1 on success.
  */
 int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 	      const char *new_name)
--- LVM2/tools/args.h	2007/08/20 20:55:30	1.53
+++ LVM2/tools/args.h	2007/08/21 19:46:36	1.54
@@ -1,6 +1,6 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C, 0) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C, 0) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -18,114 +18,114 @@
  * corresponding short option first ...
  */
 /* *INDENT-OFF* */
-arg(version_ARG, '\0', "version", NULL)
-arg(quiet_ARG, '\0', "quiet", NULL)
-arg(physicalvolumesize_ARG, '\0', "setphysicalvolumesize", size_mb_arg)
-arg(ignorelockingfailure_ARG, '\0', "ignorelockingfailure", NULL)
-arg(nolocking_ARG, '\0', "nolocking", NULL)
-arg(metadatacopies_ARG, '\0', "metadatacopies", int_arg)
-arg(metadatasize_ARG, '\0', "metadatasize", size_mb_arg)
-arg(restorefile_ARG, '\0', "restorefile", string_arg)
-arg(labelsector_ARG, '\0', "labelsector", int_arg)
-arg(driverloaded_ARG, '\0', "driverloaded", yes_no_arg)
-arg(aligned_ARG, '\0', "aligned", NULL)
-arg(unbuffered_ARG, '\0', "unbuffered", NULL)
-arg(noheadings_ARG, '\0', "noheadings", NULL)
-arg(segments_ARG, '\0', "segments", NULL)
-arg(units_ARG, '\0', "units", string_arg)
-arg(nosuffix_ARG, '\0', "nosuffix", NULL)
-arg(removemissing_ARG, '\0', "removemissing", NULL)
-arg(abort_ARG, '\0', "abort", NULL)
-arg(addtag_ARG, '\0', "addtag", tag_arg)
-arg(deltag_ARG, '\0', "deltag", tag_arg)
-arg(refresh_ARG, '\0', "refresh", NULL)
-arg(mknodes_ARG, '\0', "mknodes", NULL)
-arg(minor_ARG, '\0', "minor", minor_arg)
-arg(type_ARG, '\0', "type", segtype_arg)
-arg(alloc_ARG, '\0', "alloc", alloc_arg)
-arg(separator_ARG, '\0', "separator", string_arg)
-arg(mirrorsonly_ARG, '\0', "mirrorsonly", NULL)
-arg(nosync_ARG, '\0', "nosync", NULL)
-arg(resync_ARG, '\0', "resync", NULL)
-arg(corelog_ARG, '\0', "corelog", NULL)
-arg(mirrorlog_ARG, '\0', "log", string_arg)
-arg(monitor_ARG, '\0', "monitor", yes_no_arg)
-arg(config_ARG, '\0', "config", string_arg)
-arg(trustcache_ARG, '\0', "trustcache", NULL)
-arg(ignoremonitoring_ARG, '\0', "ignoremonitoring", NULL)
+arg(version_ARG, '\0', "version", NULL, 0)
+arg(quiet_ARG, '\0', "quiet", NULL, 0)
+arg(physicalvolumesize_ARG, '\0', "setphysicalvolumesize", size_mb_arg, 0)
+arg(ignorelockingfailure_ARG, '\0', "ignorelockingfailure", NULL, 0)
+arg(nolocking_ARG, '\0', "nolocking", NULL, 0)
+arg(metadatacopies_ARG, '\0', "metadatacopies", int_arg, 0)
+arg(metadatasize_ARG, '\0', "metadatasize", size_mb_arg, 0)
+arg(restorefile_ARG, '\0', "restorefile", string_arg, 0)
+arg(labelsector_ARG, '\0', "labelsector", int_arg, 0)
+arg(driverloaded_ARG, '\0', "driverloaded", yes_no_arg, 0)
+arg(aligned_ARG, '\0', "aligned", NULL, 0)
+arg(unbuffered_ARG, '\0', "unbuffered", NULL, 0)
+arg(noheadings_ARG, '\0', "noheadings", NULL, 0)
+arg(segments_ARG, '\0', "segments", NULL, 0)
+arg(units_ARG, '\0', "units", string_arg, 0)
+arg(nosuffix_ARG, '\0', "nosuffix", NULL, 0)
+arg(removemissing_ARG, '\0', "removemissing", NULL, 0)
+arg(abort_ARG, '\0', "abort", NULL, 0)
+arg(addtag_ARG, '\0', "addtag", tag_arg, 0)
+arg(deltag_ARG, '\0', "deltag", tag_arg, 0)
+arg(refresh_ARG, '\0', "refresh", NULL, 0)
+arg(mknodes_ARG, '\0', "mknodes", NULL, 0)
+arg(minor_ARG, '\0', "minor", minor_arg, 0)
+arg(type_ARG, '\0', "type", segtype_arg, 0)
+arg(alloc_ARG, '\0', "alloc", alloc_arg, 0)
+arg(separator_ARG, '\0', "separator", string_arg, 0)
+arg(mirrorsonly_ARG, '\0', "mirrorsonly", NULL, 0)
+arg(nosync_ARG, '\0', "nosync", NULL, 0)
+arg(resync_ARG, '\0', "resync", NULL, 0)
+arg(corelog_ARG, '\0', "corelog", NULL, 0)
+arg(mirrorlog_ARG, '\0', "mirrorlog", string_arg, 0)
+arg(monitor_ARG, '\0', "monitor", yes_no_arg, 0)
+arg(config_ARG, '\0', "config", string_arg, 0)
+arg(trustcache_ARG, '\0', "trustcache", NULL, 0)
+arg(ignoremonitoring_ARG, '\0', "ignoremonitoring", NULL, 0)
 
 /* Allow some variations */
-arg(resizable_ARG, '\0', "resizable", yes_no_arg)
-arg(allocation_ARG, '\0', "allocation", yes_no_arg)
+arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
+arg(allocation_ARG, '\0', "allocation", yes_no_arg, 0)
 
 /*
  * ... and now the short args.
  */
-arg(available_ARG, 'a', "available", yes_no_excl_arg)
-arg(all_ARG, 'a', "all", NULL)
-arg(autobackup_ARG, 'A', "autobackup", yes_no_arg)
-arg(activevolumegroups_ARG, 'A', "activevolumegroups", NULL)
-arg(background_ARG, 'b', "background", NULL)
-arg(blockdevice_ARG, 'b', "blockdevice", NULL)
-arg(chunksize_ARG, 'c', "chunksize", size_kb_arg)
-arg(clustered_ARG, 'c', "clustered", yes_no_arg)
-arg(colon_ARG, 'c', "colon", NULL)
-arg(columns_ARG, 'C', "columns", NULL)
-arg(contiguous_ARG, 'C', "contiguous", yes_no_arg)
-arg(debug_ARG, 'd', "debug", NULL)
-arg(disk_ARG, 'D', "disk", NULL)
-arg(exported_ARG, 'e', "exported", NULL)
-arg(physicalextent_ARG, 'E', "physicalextent", NULL)
-arg(file_ARG, 'f', "file", string_arg)
-arg(force_ARG, 'f', "force", NULL)
-arg(full_ARG, 'f', "full", NULL)
-arg(help_ARG, 'h', "help", NULL)
-arg(help2_ARG, '?', "", NULL)
-arg(stripesize_ARG, 'I', "stripesize", size_kb_arg)
-arg(stripes_ARG, 'i', "stripes", int_arg)
-arg(interval_ARG, 'i', "interval", int_arg)
-arg(iop_version_ARG, 'i', "iop_version", NULL)
-arg(logicalvolume_ARG, 'l', "logicalvolume", int_arg)
-arg(maxlogicalvolumes_ARG, 'l', "maxlogicalvolumes", int_arg)
-arg(extents_ARG, 'l', "extents", int_arg_with_sign_and_percent)
-arg(lvmpartition_ARG, 'l', "lvmpartition", NULL)
-arg(list_ARG, 'l', "list", NULL)
-arg(size_ARG, 'L', "size", size_mb_arg)
-arg(logicalextent_ARG, 'L', "logicalextent", int_arg_with_sign)
-arg(persistent_ARG, 'M', "persistent", yes_no_arg)
-arg(major_ARG, 'j', "major", major_arg)
-arg(mirrors_ARG, 'm', "mirrors", int_arg_with_sign)
-arg(metadatatype_ARG, 'M', "metadatatype", metadatatype_arg)
-arg(maps_ARG, 'm', "maps", NULL)
-arg(name_ARG, 'n', "name", string_arg)
-arg(oldpath_ARG, 'n', "oldpath", NULL)
-arg(nofsck_ARG, 'n', "nofsck", NULL)
-arg(novolumegroup_ARG, 'n', "novolumegroup", NULL)
-arg(options_ARG, 'o', "options", string_arg)
-arg(sort_ARG, 'O', "sort", string_arg)
-arg(permission_ARG, 'p', "permission", permission_arg)
-arg(maxphysicalvolumes_ARG, 'p', "maxphysicalvolumes", int_arg)
-arg(partial_ARG, 'P', "partial", NULL)
-arg(physicalvolume_ARG, 'P', "physicalvolume", NULL)
-arg(readahead_ARG, 'r', "readahead", int_arg)
-arg(resizefs_ARG, 'r', "resizefs", NULL)
-arg(reset_ARG, 'R', "reset", NULL)
-arg(regionsize_ARG, 'R', "regionsize", size_mb_arg)
-arg(physicalextentsize_ARG, 's', "physicalextentsize", size_mb_arg)
-arg(stdin_ARG, 's', "stdin", NULL)
-arg(snapshot_ARG, 's', "snapshot", NULL)
-arg(short_ARG, 's', "short", NULL)
-arg(test_ARG, 't', "test", NULL)
-arg(uuid_ARG, 'u', "uuid", NULL)
-arg(uuidstr_ARG, 'u', "uuid", string_arg)
-arg(uuidlist_ARG, 'U', "uuidlist", NULL)
-arg(verbose_ARG, 'v', "verbose", NULL)
-arg(volumegroup_ARG, 'V', "volumegroup", NULL)
-arg(allocatable_ARG, 'x', "allocatable", yes_no_arg)
-arg(resizeable_ARG, 'x', "resizeable", yes_no_arg)
-arg(yes_ARG, 'y', "yes", NULL)
-arg(zero_ARG, 'Z', "zero", yes_no_arg)
+arg(available_ARG, 'a', "available", yes_no_excl_arg, 0)
+arg(all_ARG, 'a', "all", NULL, 0)
+arg(autobackup_ARG, 'A', "autobackup", yes_no_arg, 0)
+arg(activevolumegroups_ARG, 'A', "activevolumegroups", NULL, 0)
+arg(background_ARG, 'b', "background", NULL, 0)
+arg(blockdevice_ARG, 'b', "blockdevice", NULL, 0)
+arg(chunksize_ARG, 'c', "chunksize", size_kb_arg, 0)
+arg(clustered_ARG, 'c', "clustered", yes_no_arg, 0)
+arg(colon_ARG, 'c', "colon", NULL, 0)
+arg(columns_ARG, 'C', "columns", NULL, 0)
+arg(contiguous_ARG, 'C', "contiguous", yes_no_arg, 0)
+arg(debug_ARG, 'd', "debug", NULL, ARG_REPEATABLE)
+arg(disk_ARG, 'D', "disk", NULL, 0)
+arg(exported_ARG, 'e', "exported", NULL, 0)
+arg(physicalextent_ARG, 'E', "physicalextent", NULL, 0)
+arg(file_ARG, 'f', "file", string_arg, 0)
+arg(force_ARG, 'f', "force", NULL, ARG_REPEATABLE)
+arg(full_ARG, 'f', "full", NULL, 0)
+arg(help_ARG, 'h', "help", NULL, 0)
+arg(help2_ARG, '?', "", NULL, 0)
+arg(stripesize_ARG, 'I', "stripesize", size_kb_arg, 0)
+arg(stripes_ARG, 'i', "stripes", int_arg, 0)
+arg(interval_ARG, 'i', "interval", int_arg, 0)
+arg(iop_version_ARG, 'i', "iop_version", NULL, 0)
+arg(logicalvolume_ARG, 'l', "logicalvolume", int_arg, 0)
+arg(maxlogicalvolumes_ARG, 'l', "maxlogicalvolumes", int_arg, 0)
+arg(extents_ARG, 'l', "extents", int_arg_with_sign_and_percent, 0)
+arg(lvmpartition_ARG, 'l', "lvmpartition", NULL, 0)
+arg(list_ARG, 'l', "list", NULL, 0)
+arg(size_ARG, 'L', "size", size_mb_arg, 0)
+arg(logicalextent_ARG, 'L', "logicalextent", int_arg_with_sign, 0)
+arg(persistent_ARG, 'M', "persistent", yes_no_arg, 0)
+arg(major_ARG, 'j', "major", major_arg, 0)
+arg(mirrors_ARG, 'm', "mirrors", int_arg_with_sign, 0)
+arg(metadatatype_ARG, 'M', "metadatatype", metadatatype_arg, 0)
+arg(maps_ARG, 'm', "maps", NULL, 0)
+arg(name_ARG, 'n', "name", string_arg, 0)
+arg(oldpath_ARG, 'n', "oldpath", NULL, 0)
+arg(nofsck_ARG, 'n', "nofsck", NULL, 0)
+arg(novolumegroup_ARG, 'n', "novolumegroup", NULL, 0)
+arg(options_ARG, 'o', "options", string_arg, 0)
+arg(sort_ARG, 'O', "sort", string_arg, 0)
+arg(permission_ARG, 'p', "permission", permission_arg, 0)
+arg(maxphysicalvolumes_ARG, 'p', "maxphysicalvolumes", int_arg, 0)
+arg(partial_ARG, 'P', "partial", NULL, 0)
+arg(physicalvolume_ARG, 'P', "physicalvolume", NULL, 0)
+arg(readahead_ARG, 'r', "readahead", int_arg, 0)
+arg(resizefs_ARG, 'r', "resizefs", NULL, 0)
+arg(reset_ARG, 'R', "reset", NULL, 0)
+arg(regionsize_ARG, 'R', "regionsize", size_mb_arg, 0)
+arg(physicalextentsize_ARG, 's', "physicalextentsize", size_mb_arg, 0)
+arg(stdin_ARG, 's', "stdin", NULL, 0)
+arg(snapshot_ARG, 's', "snapshot", NULL, 0)
+arg(short_ARG, 's', "short", NULL, 0)
+arg(test_ARG, 't', "test", NULL, 0)
+arg(uuid_ARG, 'u', "uuid", NULL, 0)
+arg(uuidstr_ARG, 'u', "uuid", string_arg, 0)
+arg(uuidlist_ARG, 'U', "uuidlist", NULL, 0)
+arg(verbose_ARG, 'v', "verbose", NULL, ARG_REPEATABLE)
+arg(volumegroup_ARG, 'V', "volumegroup", NULL, 0)
+arg(allocatable_ARG, 'x', "allocatable", yes_no_arg, 0)
+arg(resizeable_ARG, 'x', "resizeable", yes_no_arg, 0)
+arg(yes_ARG, 'y', "yes", NULL, 0)
+arg(zero_ARG, 'Z', "zero", yes_no_arg, 0)
 
 /* this should always be last */
-arg(ARG_COUNT, '-', "", NULL)
+arg(ARG_COUNT, '-', "", NULL, 0)
 /* *INDENT-ON* */
--- LVM2/tools/commands.h	2007/08/20 20:55:30	1.100
+++ LVM2/tools/commands.h	2007/08/21 19:46:36	1.101
@@ -88,7 +88,7 @@
 xx(lvconvert,
    "Change logical volume layout",
    "lvconvert "
-   "[-m|--mirrors Mirrors [--log {disk|core}]]\n"
+   "[-m|--mirrors Mirrors [{--mirrorlog {disk|core}|--corelog}]]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
    "\t[--alloc AllocationPolicy]\n"
    "\t[-d|--debug]\n"
@@ -107,7 +107,7 @@
    "\t[--version]" "\n"
    "\tOriginalLogicalVolume[Path] SnapshotLogicalVolume[Path]\n",
 
-   alloc_ARG, chunksize_ARG, mirrors_ARG, corelog_ARG, mirrorlog_ARG,
+   alloc_ARG, chunksize_ARG, corelog_ARG, mirrorlog_ARG, mirrors_ARG,
    regionsize_ARG, snapshot_ARG, test_ARG, zero_ARG)
 
 xx(lvcreate,
@@ -123,7 +123,7 @@
    "\t{-l|--extents LogicalExtentsNumber |\n"
    "\t -L|--size LogicalVolumeSize[kKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
-   "\t[-m|--mirrors Mirrors [--nosync] [--log {disk|core}]]\n"
+   "\t[-m|--mirrors Mirrors [--nosync] [{--mirrorlog {disk|core}|--corelog}]]\n"
    "\t[-n|--name LogicalVolumeName]\n"
    "\t[-p|--permission {r|rw}]\n"
    "\t[-r|--readahead ReadAheadSectors]\n"
@@ -156,10 +156,10 @@
    "\tOriginalLogicalVolume[Path] [PhysicalVolumePath...]\n\n",
 
    addtag_ARG, alloc_ARG, autobackup_ARG, chunksize_ARG, contiguous_ARG,
-   corelog_ARG, mirrorlog_ARG, extents_ARG, major_ARG, minor_ARG, mirrors_ARG, name_ARG,
-   nosync_ARG, permission_ARG, persistent_ARG, readahead_ARG, regionsize_ARG,
-   size_ARG, snapshot_ARG, stripes_ARG, stripesize_ARG, test_ARG, type_ARG,
-   zero_ARG)
+   corelog_ARG, extents_ARG, major_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG,
+   name_ARG, nosync_ARG, permission_ARG, persistent_ARG, readahead_ARG,
+   regionsize_ARG, size_ARG, snapshot_ARG, stripes_ARG, stripesize_ARG,
+   test_ARG, type_ARG, zero_ARG)
 
 xx(lvdisplay,
    "Display information about a logical volume",
--- LVM2/tools/lvconvert.c	2007/08/20 20:55:30	1.34
+++ LVM2/tools/lvconvert.c	2007/08/21 19:46:36	1.35
@@ -101,29 +101,13 @@
 static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			int argc, char **argv)
 {
-	int count = 0;
 	int region_size;
 	int pagesize = lvm_getpagesize();
 
 	memset(lp, 0, sizeof(*lp));
 
-	if (arg_count(cmd, mirrorlog_ARG) > 1) {
-		log_error("Too many --log arguments supplied.");
-		return 0;
-	}
-	if (arg_count(cmd, mirrors_ARG) > 1) {
-		log_error("Too many --mirrors arguments supplied.");
-		return 0;
-	}
-	if (arg_count(cmd, snapshot_ARG) > 1) {
-		log_error("Too many --snapshot arguments supplied.");
-		return 0;
-	}
-	if (arg_count(cmd, mirrorlog_ARG) || arg_count(cmd, mirrors_ARG))
-		count = 1;
-	count += arg_count(cmd, snapshot_ARG);
-
-	if (count != 1) {
+	if (arg_count(cmd, snapshot_ARG) &&
+	    (arg_count(cmd, mirrorlog_ARG) || arg_count(cmd, mirrors_ARG))) {
 		log_error("--snapshots argument cannot be mixed "
 			  "with --mirrors or --log");
 		return 0;
@@ -254,8 +238,8 @@
 	struct list *parallel_areas;
 	struct segment_type *segtype;  /* FIXME: could I just use lp->segtype */
 	float sync_percent;
-	const char *log_arg;
-	int corelog = 0;
+	const char *mirrorlog;
+	unsigned corelog = 0;
 
 	seg = first_seg(lv);
 	existing_mirrors = seg->area_count;
@@ -289,25 +273,26 @@
 	/*
 	 * Adjust log type
 	 */
-	if (arg_count(cmd, corelog_ARG)) {
-		log_verbose("Setting logging type to \"core\"");
+	if (arg_count(cmd, corelog_ARG))
 		corelog = 1;
-	}
 
-	if (arg_count(cmd, mirrorlog_ARG)) {
-		log_arg = arg_str_value(cmd, mirrorlog_ARG, "disk");
-		if (!strcmp("disk", log_arg)) {
-			log_verbose("Setting logging type to \"disk\"");
-			corelog = 0;
-		} else if (!strcmp("core", log_arg)) {
-			log_verbose("Setting logging type to \"core\"");
-			corelog = 1;
-		} else {
-			log_error("Unknown logging type, \"%s\"", log_arg);
+	mirrorlog = arg_str_value(cmd, mirrorlog_ARG, DEFAULT_MIRRORLOG);
+	if (!strcmp("disk", mirrorlog)) {
+		if (corelog) {
+			log_error("--mirrorlog disk and --corelog "
+				  "are incompatible");
 			return 0;
 		}
+		corelog = 0;
+	} else if (!strcmp("core", mirrorlog))
+		corelog = 1;
+	else {
+		log_error("Unknown mirrorlog type: %s", mirrorlog);
+		return 0;
 	}
 
+	log_verbose("Setting logging type to %s", mirrorlog);
+
 	/*
 	 * Region size must not change on existing mirrors
 	 */
--- LVM2/tools/lvcreate.c	2007/08/20 20:55:30	1.141
+++ LVM2/tools/lvcreate.c	2007/08/21 19:46:36	1.142
@@ -241,7 +241,7 @@
 	int argc = *pargc;
 	int region_size;
 	int pagesize = lvm_getpagesize();
-	const char *log_arg;
+	const char *mirrorlog;
 
 	if (argc && (unsigned) argc < lp->mirrors) {
 		log_error("Too few physical volumes on "
@@ -285,25 +285,26 @@
 		return 0;
 	}
 
-	if (arg_count(cmd, corelog_ARG)) {
-		log_verbose("Setting logging type to \"core\"");
+	if (arg_count(cmd, corelog_ARG))
 		lp->corelog = 1;
-	}
 
-	if (arg_count(cmd, mirrorlog_ARG)) {
-		log_arg = arg_str_value(cmd, mirrorlog_ARG, "disk");
-		if (!strcmp("disk", log_arg)) {
-			log_verbose("Setting logging type to \"disk\"");
-			lp->corelog = 0;
-		} else if (!strcmp("core", log_arg)) {
-			log_verbose("Setting logging type to \"core\"");
-			lp->corelog = 1;
-		} else {
-			log_error("Unknown logging type, \"%s\"", log_arg);
+	mirrorlog = arg_str_value(cmd, mirrorlog_ARG, DEFAULT_MIRRORLOG);
+	if (!strcmp("disk", mirrorlog)) {
+		if (lp->corelog) {
+			log_error("--mirrorlog disk and --corelog "
+				  "are incompatible");
 			return 0;
 		}
+		lp->corelog = 0;
+	} else if (!strcmp("core", mirrorlog))
+		lp->corelog = 1;
+	else {
+		log_error("Unknown mirrorlog type: %s", mirrorlog);
+		return 0;
 	}
 
+	log_verbose("Setting logging type to %s", mirrorlog);
+
 	lp->nosync = arg_count(cmd, nosync_ARG) ? 1 : 0;
 
 	return 1;
--- LVM2/tools/lvmcmdline.c	2007/08/20 20:55:30	1.47
+++ LVM2/tools/lvmcmdline.c	2007/08/21 19:46:36	1.48
@@ -45,7 +45,7 @@
  * Table of valid switches
  */
 static struct arg _the_args[ARG_COUNT + 1] = {
-#define arg(a, b, c, d) {b, "", "--" c, d, 0, NULL, 0, 0, INT64_C(0), UINT64_C(0), SIGN_NONE, PERCENT_NONE, NULL},
+#define arg(a, b, c, d, e) {b, "", "--" c, d, e, 0, NULL, 0, 0, INT64_C(0), UINT64_C(0), SIGN_NONE, PERCENT_NONE, NULL},
 #include "args.h"
 #undef arg
 };
@@ -568,16 +568,16 @@
 			return 0;
 		}
 
-		if (a->fn) {
-			if (a->count) {
-				log_error("Option%s%c%s%s may not be repeated",
-					  a->short_arg ? " -" : "",
-					  a->short_arg ? : ' ',
-					  (a->short_arg && a->long_arg) ?
-					  "/" : "", a->long_arg ? : "");
-				return 0;
-			}
+		if (a->count && !(a->flags & ARG_REPEATABLE)) {
+			log_error("Option%s%c%s%s may not be repeated",
+				  a->short_arg ? " -" : "",
+				  a->short_arg ? : ' ',
+				  (a->short_arg && a->long_arg) ?
+				  "/" : "", a->long_arg ? : "");
+			return 0;
+		}
 
+		if (a->fn) {
 			if (!optarg) {
 				log_error("Option requires argument.");
 				return 0;
--- LVM2/tools/tools.h	2007/08/20 20:55:30	1.56
+++ LVM2/tools/tools.h	2007/08/21 19:46:36	1.57
@@ -68,7 +68,7 @@
 
 /* define the enums for the command line switches */
 enum {
-#define arg(a, b, c, d) a ,
+#define arg(a, b, c, d, e) a ,
 #include "args.h"
 #undef arg
 };
@@ -94,6 +94,8 @@
 	CHANGE_ALN = 4
 };
 
+#define ARG_REPEATABLE 0x00000001
+
 /* a global table of possible arguments */
 struct arg {
 	const char short_arg;
@@ -101,6 +103,7 @@
 	const char *long_arg;
 
 	int (*fn) (struct cmd_context * cmd, struct arg * a);
+	uint32_t flags;
 
 	unsigned count;
 	char *value;


