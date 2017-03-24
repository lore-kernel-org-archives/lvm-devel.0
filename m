From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 23 Mar 2017 23:02:45 -0400
Subject: master - man-generator: emit escaped '-'
Message-ID: <201703240302.v2O32jkJ026626@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=10e0a5066e0848fdc179a10c2a04b7d23a242639
Commit:        10e0a5066e0848fdc179a10c2a04b7d23a242639
Parent:        5eec3de41f6860bbbc45e5929ddcf7d584c6e75b
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 24 04:00:47 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 24 04:00:47 2017 +0100

man-generator: emit escaped '-'

---
 tools/args.h           |  138 ++++++++++++++++++++++++------------------------
 tools/command-lines.in |   86 +++++++++++++++---------------
 tools/command.c        |   41 +++++++++------
 3 files changed, 137 insertions(+), 128 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index b81e2c9..24d3037 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -22,7 +22,7 @@ arg(ARG_UNUSED, '-', "", 0, 0, 0, NULL)  /* place holder for unused 0 value */
 arg(abort_ARG, '\0', "abort", 0, 0, 0,
     "#pvmove\n"
     "Abort any pvmove operations in progress. If a pvmove was started\n"
-    "with the --atomic option, then all LVs will remain on the source PV.\n"
+    "with the \\-\\-atomic option, then all LVs will remain on the source PV.\n"
     "Otherwise, segments that have been moved will remain on the\n"
     "destination PV, while unmoved segments will remain on the source PV.\n"
     "#lvpoll\n"
@@ -45,7 +45,7 @@ arg(addtag_ARG, '\0', "addtag", tag_VAL, ARG_GROUPABLE, 0,
     "multiple tags at once. See lvm(8) for information about tags.\n")
 
 arg(aligned_ARG, '\0', "aligned", 0, 0, 0,
-    "Use with --separator to align the output columns\n")
+    "Use with \\-\\-separator to align the output columns\n")
 
 arg(alloc_ARG, '\0', "alloc", alloc_VAL, 0, 0,
     "Determines the allocation policy when a command needs to allocate\n"
@@ -88,8 +88,8 @@ arg(bootloaderareasize_ARG, '\0', "bootloaderareasize", sizemb_VAL, 0, 0,
     "area. The bootloader area is an area of reserved space on the PV from\n"
     "which LVM will not allocate any extents and it's kept untouched. This is\n"
     "primarily aimed for use with bootloaders to embed their own data or metadata.\n"
-    "The start of the bootloader area is always aligned, see also --dataalignment\n"
-    "and --dataalignmentoffset. The bootloader area size may eventually\n"
+    "The start of the bootloader area is always aligned, see also \\-\\-dataalignment\n"
+    "and \\-\\-dataalignmentoffset. The bootloader area size may eventually\n"
     "end up increased due to the alignment, but it's never less than the\n"
     "size that is requested. To see the bootloader area start and size of\n"
     "an existing PV use pvs -o +pv_ba_start,pv_ba_size.\n")
@@ -142,7 +142,7 @@ arg(dataalignment_ARG, '\0', "dataalignment", sizekb_VAL, 0, 0,
     "Also specify an appropriate Physical Extent size when creating a VG.\n"
     "To see the location of the first Physical Extent of an existing PV,\n"
     "use pvs -o +pe_start. In addition, it may be shifted by an alignment offset.\n"
-    "See lvm.conf/data_alignment_offset_detection and --dataalignmentoffset.\n")
+    "See lvm.conf/data_alignment_offset_detection and \\-\\-dataalignmentoffset.\n")
 
 arg(dataalignmentoffset_ARG, '\0', "dataalignmentoffset", sizekb_VAL, 0, 0,
     "Shift the start of the data area by this additional offset.\n")
@@ -205,7 +205,7 @@ arg(ignorelockingfailure_ARG, '\0', "ignorelockingfailure", 0, 0, 0,
     "operations after locking failures.\n")
 
 arg(ignoremonitoring_ARG, '\0', "ignoremonitoring", 0, 0, 0,
-    "Do not interact with dmeventd unless --monitor is specified.\n"
+    "Do not interact with dmeventd unless \\-\\-monitor is specified.\n"
     "Do not use this if dmeventd is already monitoring a device.\n")
 
 arg(ignoreskippedcluster_ARG, '\0', "ignoreskippedcluster", 0, 0, 0,
@@ -244,7 +244,7 @@ arg(locktype_ARG, '\0', "locktype", locktype_VAL, 0, 0,
     "Change the VG lock type to or from a shared lock type used with lvmlockd.\n"
     "See lvmlockd(8) for more information.\n"
     "#vgcreate\n"
-    "Specify the VG lock type directly in place of using --shared.\n"
+    "Specify the VG lock type directly in place of using \\-\\-shared.\n"
     "See lvmlockd(8) for more information.\n")
 
 arg(logonly_ARG, '\0', "logonly", 0, 0, 0,
@@ -260,12 +260,12 @@ arg(maxrecoveryrate_ARG, '\0', "maxrecoveryrate", sizekb_VAL, 0, 0,
     "See \\fBlvmraid\\fP(7) for more information.\n")
 
 arg(merge_ARG, '\0', "merge", 0, 0, 0,
-    "An alias for --mergethin, --mergemirrors, or --mergesnapshot,\n"
+    "An alias for \\-\\-mergethin, \\-\\-mergemirrors, or \\-\\-mergesnapshot,\n"
     "depending on the type of LV.\n")
 
 arg(mergemirrors_ARG, '\0', "mergemirrors", 0, 0, 0,
     "Merge LV images that were split from a raid1 LV.\n"
-    "See --splitmirrors with --trackchanges.\n")
+    "See \\-\\-splitmirrors with \\-\\-trackchanges.\n")
 
 arg(mergesnapshot_ARG, '\0', "mergesnapshot", 0, 0, 0,
     "Merge COW snapshot LV into its origin.\n"
@@ -288,9 +288,9 @@ arg(mergethin_ARG, '\0', "mergethin", 0, 0, 0,
     "See \\fBlvmthin\\fP(7) for more information.\n")
 
 arg(mergedconfig_ARG, '\0', "mergedconfig", 0, 0, 0,
-    "When the command is run with --config\n"
-    "and/or --commandprofile (or using LVM_COMMAND_PROFILE\n"
-    "environment variable), --profile, or --metadataprofile,\n"
+    "When the command is run with \\-\\-config\n"
+    "and/or \\-\\-commandprofile (or using LVM_COMMAND_PROFILE\n"
+    "environment variable), \\-\\-profile, or \\-\\-metadataprofile,\n"
     "merge all the contents of the \"config cascade\" before displaying it.\n"
     "Without merging, only the configuration at the front of the\n"
     "cascade is displayed.\n"
@@ -349,7 +349,7 @@ arg(monitor_ARG, '\0', "monitor", bool_VAL, 0, 0,
 
 arg(nameprefixes_ARG, '\0', "nameprefixes", 0, 0, 0,
     "Add an \"LVM2_\" prefix plus the field name to the output. Useful\n"
-    "with --noheadings to produce a list of field=value pairs that can\n"
+    "with \\-\\-noheadings to produce a list of field=value pairs that can\n"
     "be used to set environment variables (for example, in udev rules).\n")
 
 arg(noheadings_ARG, '\0', "noheadings", 0, 0, 0,
@@ -365,11 +365,11 @@ arg(nolocking_ARG, '\0', "nolocking", 0, 0, 0,
     "Disable locking.\n")
 
 arg(norestorefile_ARG, '\0', "norestorefile", 0, 0, 0,
-    "In conjunction with --uuid, this allows a uuid to be specified\n"
+    "In conjunction with \\-\\-uuid, this allows a uuid to be specified\n"
     "without also requiring that a backup of the metadata be provided.\n")
 
 arg(nosuffix_ARG, '\0', "nosuffix", 0, 0, 0,
-    "Suppress the suffix on output sizes. Use with --units\n"
+    "Suppress the suffix on output sizes. Use with \\-\\-units\n"
     "(except h and H) if processing the output.\n")
 
 arg(nosync_ARG, '\0', "nosync", 0, 0, 0,
@@ -409,11 +409,11 @@ arg(physicalvolumesize_ARG, '\0', "setphysicalvolumesize", sizemb_VAL, 0, 0,
 arg(poll_ARG, '\0', "poll", bool_VAL, 0, 0,
     "When yes, start the background transformation of an LV.\n"
     "An incomplete transformation, e.g. pvmove or lvconvert interrupted\n"
-    "by reboot or crash, can be restarted from the last checkpoint with --poll y.\n"
+    "by reboot or crash, can be restarted from the last checkpoint with \\-\\-poll y.\n"
     "When no, background transformation of an LV will not occur, and the\n"
     "transformation will not complete. It may not be appropriate to immediately\n"
-    "poll an LV after activation, in which case --poll n can be used to defer\n"
-    "polling until a later --poll y command.\n")
+    "poll an LV after activation, in which case \\-\\-poll n can be used to defer\n"
+    "polling until a later \\-\\-poll y command.\n")
 
 arg(polloperation_ARG, '\0', "polloperation", polloperation_VAL, 0, 0,
     "The command to perform from lvmpolld.\n")
@@ -440,7 +440,7 @@ arg(poolmetadataspare_ARG, '\0', "poolmetadataspare", bool_VAL, 0, 0,
     "space that can be used when repairing a pool.\n")
 
 arg(profile_ARG, '\0', "profile", string_VAL, 0, 0,
-    "An alias for --commandprofile or --metadataprofile, depending\n"
+    "An alias for \\-\\-commandprofile or \\-\\-metadataprofile, depending\n"
     "on the command.\n")
 
 arg(pvmetadatacopies_ARG, '\0', "pvmetadatacopies", pvmetadatacopies_VAL, 0, 0,
@@ -475,7 +475,7 @@ arg(removemissing_ARG, '\0', "removemissing", 0, 0, 0,
     "on them. This resumes normal operation of the VG (new LVs may again\n"
     "be created, changed and so on).\n"
     "If this is not possible because LVs are referencing the missing PVs,\n"
-    "this option can be combined with --force to have the command remove\n"
+    "this option can be combined with \\-\\-force to have the command remove\n"
     "any partial LVs. In this case, any LVs and dependent snapshots that\n"
     "were partly on the missing disks are removed completely, including\n"
     "those parts on disks that are still present.\n"
@@ -485,7 +485,7 @@ arg(removemissing_ARG, '\0', "removemissing", 0, 0, 0,
 arg(rebuild_ARG, '\0', "rebuild", pv_VAL, ARG_GROUPABLE, 0,
     "Selects a PV to rebuild in a raid LV. Multiple PVs can be rebuilt by\n"
     "repeating this option.\n"
-    "Use this option in place of --resync or --syncaction repair when the\n"
+    "Use this option in place of \\-\\-resync or \\-\\-syncaction repair when the\n"
     "PVs with corrupted data are known, and their data should be reconstructed\n"
     "rather than reconstructing default (rotating) data.\n"
     "See \\fBlvmraid\\fP(7) for more information.\n")
@@ -510,7 +510,7 @@ arg(reportformat_ARG, '\0', "reportformat", reportformat_VAL, 0, 0,
     "output in JSON format. See \\fBlvmreport\\fP(7) for more information.\n")
 
 arg(restorefile_ARG, '\0', "restorefile", string_VAL, 0, 0,
-    "In conjunction with --uuid, this reads the file (produced by\n"
+    "In conjunction with \\-\\-uuid, this reads the file (produced by\n"
     "vgcfgbackup), extracts the location and size of the data on the PV,\n"
     "and ensures that the metadata produced by the program is consistent\n"
     "with the contents of the file, i.e. the physical extents will be in\n"
@@ -525,7 +525,7 @@ arg(restoremissing_ARG, '\0', "restoremissing", 0, 0, 0,
 arg(resync_ARG, '\0', "resync", 0, 0, 0,
     "Initiates mirror synchronization. Synchronization generally happens\n"
     "automatically, but this option forces it to run.\n"
-    "Also see --rebuild to synchronize a specific PV.\n"
+    "Also see \\-\\-rebuild to synchronize a specific PV.\n"
     "During synchronization, data is read from the primary mirror device\n"
     "and copied to the others. This can take considerable time, during\n"
     "which the LV is without a complete redundant copy of the data.\n"
@@ -567,16 +567,16 @@ arg(shared_ARG, '\0', "shared", 0, 0, 0,
 arg(sinceversion_ARG, '\0', "sinceversion", string_VAL, 0, 0,
     "Specify an LVM version in x.y.z format where x is the major version,\n"
     "the y is the minor version and z is the patchlevel (e.g. 2.2.106).\n"
-    "This option is currently applicable only with --typeconfig new\n"
+    "This option is currently applicable only with \\-\\-typeconfig new\n"
     "to display all configuration settings introduced since given version.\n")
 
 arg(splitcache_ARG, '\0', "splitcache", 0, 0, 0,
     "Separates a cache pool from a cache LV, and keeps the unused cache pool LV.\n"
-    "Before the separation, the cache is flushed. Also see --uncache.\n")
+    "Before the separation, the cache is flushed. Also see \\-\\-uncache.\n")
 
 arg(splitmirrors_ARG, '\0', "splitmirrors", number_VAL, 0, 0,
     "Splits the specified number of images from a raid1 or mirror LV\n"
-    "and uses them to create a new LV. If --trackchanges is also specified,\n"
+    "and uses them to create a new LV. If \\-\\-trackchanges is also specified,\n"
     "changes to the raid1 LV are tracked while the split LV remains detached.\n")
 
 arg(splitsnapshot_ARG, '\0', "splitsnapshot", 0, 0, 0,
@@ -587,7 +587,7 @@ arg(splitsnapshot_ARG, '\0', "splitsnapshot", 0, 0, 0,
 arg(showdeprecated_ARG, '\0', "showdeprecated", 0, 0, 0,
     "Include deprecated configuration settings in the output. These settings\n"
     "are deprecated after a certain version. If a concrete version is specified\n"
-    "with --atversion, deprecated settings are automatically included\n"
+    "with \\-\\-atversion, deprecated settings are automatically included\n"
     "if the specified version is lower than the version in which the settings were\n"
     "deprecated. The current and diff types include deprecated settings\n"
     "in their output by default, all the other types ignore deprecated settings.\n")
@@ -606,7 +606,7 @@ arg(stripes_long_ARG, '\0', "stripes", number_VAL, 0, 0,
     "Specifies the number of stripes in a striped LV. This is the number of\n"
     "PVs (devices) that a striped LV is spread across. Data that\n"
     "appears sequential in the LV is spread across multiple devices in units of\n"
-    "the stripe size (see --stripesize). This does not apply to\n"
+    "the stripe size (see \\-\\-stripesize). This does not apply to\n"
     "existing allocated space, only newly allocated space can be striped.\n")
 
 arg(swapmetadata_ARG, '\0', "swapmetadata", 0, 0, 0,
@@ -631,8 +631,8 @@ arg(sysinit_ARG, '\0', "sysinit", 0, 0, 0,
     "scripts (e.g. rc.sysinit or an initrd), before writable filesystems are\n"
     "available. As such, some functionality needs to be disabled and this option\n"
     "acts as a shortcut which selects an appropriate set of options. Currently,\n"
-    "this is equivalent to using --ignorelockingfailure, --ignoremonitoring,\n"
-    "--poll n, and setting env var LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES.\n"
+    "this is equivalent to using \\-\\-ignorelockingfailure, \\-\\-ignoremonitoring,\n"
+    "\\-\\-poll n, and setting env var LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES.\n"
     "When used in conjunction with lvmetad enabled and running,\n"
     "vgchange/lvchange skip autoactivation, and defer to pvscan autoactivation.\n")
 
@@ -655,7 +655,7 @@ arg(thinpool_ARG, '\0', "thinpool", lv_VAL, 0, 0,
     "The name of a thin pool LV.\n")
 
 arg(trackchanges_ARG, '\0', "trackchanges", 0, 0, 0,
-    "Can be used with --splitmirrors on a raid1 LV. This causes\n"
+    "Can be used with \\-\\-splitmirrors on a raid1 LV. This causes\n"
     "changes to the original raid1 LV to be tracked while the split images\n"
     "remain detached. This allows the read-only detached image(s) to be\n"
     "merged efficiently back into the raid1 LV later. Only the regions with\n"
@@ -675,7 +675,7 @@ arg(type_ARG, '\0', "type", segtype_VAL, 0, 0,
     "For copy-on-write snapshots (\\fBsnapshot\\fP) see usage definitions.\n"
     "Several commands omit an explicit type option because the type\n"
     "is inferred from other options or shortcuts\n"
-    "(e.g. --stripes, --mirrors, --snapshot, --virtualsize, --thin, --cache).\n"
+    "(e.g. \\-\\-stripes, \\-\\-mirrors, \\-\\-snapshot, \\-\\-virtualsize, \\-\\-thin, \\-\\-cache).\n"
     "Use inferred types with care because it can lead to unexpected results.\n")
 
 arg(unbuffered_ARG, '\0', "unbuffered", 0, 0, 0,
@@ -683,7 +683,7 @@ arg(unbuffered_ARG, '\0', "unbuffered", 0, 0, 0,
 
 arg(uncache_ARG, '\0', "uncache", 0, 0, 0,
     "Separates a cache pool from a cache LV, and deletes the unused cache pool LV.\n"
-    "Before the separation, the cache is flushed. Also see --splitcache.\n")
+    "Before the separation, the cache is flushed. Also see \\-\\-splitcache.\n")
 
 arg(cachepolicy_ARG, '\0', "cachepolicy", string_VAL, 0, 0,
     "Specifies the cache policy for a cache LV.\n"
@@ -707,10 +707,10 @@ arg(units_ARG, '\0', "units", units_VAL, 0, 0,
     "(h)uman-readable, (b)ytes, (s)ectors, (k)ilobytes, (m)egabytes,\n"
     "(g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.\n"
     "Capitalise to use multiples of 1000 (S.I.) instead of 1024.\n"
-    "Custom units can be specified, e.g. --units 3M.\n")
+    "Custom units can be specified, e.g. \\-\\-units 3M.\n")
 
 arg(unquoted_ARG, '\0', "unquoted", 0, 0, 0,
-    "When used with --nameprefixes, output values in the field=value\n"
+    "When used with \\-\\-nameprefixes, output values in the field=value\n"
     "pairs are not quoted.\n")
 
 arg(usepolicies_ARG, '\0', "usepolicies", 0, 0, 0,
@@ -721,7 +721,7 @@ arg(validate_ARG, '\0', "validate", 0, 0, 0,
     "Validate current configuration used and exit with appropriate\n"
     "return code. The validation is done only for the configuration\n"
     "at the front of the \"config cascade\". To validate the whole\n"
-    "merged configuration tree, also use --mergedconfig.\n"
+    "merged configuration tree, also use \\-\\-mergedconfig.\n"
     "The validation is done even if lvm.conf config/checks is disabled.\n")
 
 arg(version_ARG, '\0', "version", 0, 0, 0,
@@ -787,7 +787,7 @@ arg(writemostly_ARG, '\0', "writemostly", writemostly_VAL, ARG_GROUPABLE, 0,
  * these variants.  The description of the standard option names
  * can mention a synonym, or in some cases the man page generation
  * recognizes some of these and prints the option name to include
- * the variant, e.g. man page generation prints --[raid]writebehind.
+ * the variant, e.g. man page generation prints \\-\\-[raid]writebehind.
  */
 arg(corelog_ARG, '\0', "corelog", 0, 0, 0, NULL)
 arg(resizable_ARG, '\0', "resizable", bool_VAL, 0, 0, NULL)
@@ -838,10 +838,10 @@ arg(activate_ARG, 'a', "activate", activation_VAL, 0, 0,
     "In some cases, creating an LV requires it to be active.\n"
     "For example, COW snapshots of an active origin LV can only\n"
     "be created in the active state (this does not apply to thin snapshots.)\n"
-    "The --zero option normally requires the LV to be active.\n"
+    "The \\-\\-zero option normally requires the LV to be active.\n"
     "If autoactivation \\fBay\\fP is used, the LV is only activated\n"
     "if it matches an item in lvm.conf activation/auto_activation_volume_list.\n"
-    "\\fBay\\fP implies --zero n and --wipesignatures n.\n"
+    "\\fBay\\fP implies \\-\\-zero n and \\-\\-wipesignatures n.\n"
     "See lvmlockd(8) for more information about activation options for shared VGs.\n"
     "See clvmd(8) for more information about activation options for clustered VGs.\n")
 
@@ -964,7 +964,7 @@ arg(help_ARG, 'h', "help", 0, 0, 0,
 
 arg(cache_ARG, 'H', "cache", 0, 0, 0,
     "Specifies the command is handling a cache LV or cache pool.\n"
-    "See --type cache and --type cache-pool.\n"
+    "See \\-\\-type cache and \\-\\-type cache-pool.\n"
     "See \\fBlvmcache\\fP(7) for more information about LVM caching.\n")
 
 arg(history_ARG, 'H', "history", 0, 0, 0,
@@ -989,7 +989,7 @@ arg(stripes_ARG, 'i', "stripes", number_VAL, 0, 0,
     "Specifies the number of stripes in a striped LV. This is the number of\n"
     "PVs (devices) that a striped LV is spread across. Data that\n"
     "appears sequential in the LV is spread across multiple devices in units of\n"
-    "the stripe size (see --stripesize). This does not change existing\n"
+    "the stripe size (see \\-\\-stripesize). This does not change existing\n"
     "allocated space, but only applies to space being allocated by the command.\n"
     "When creating a RAID 4/5/6 LV, this number does not include the extra\n"
     "devices that are required for parity. The largest number depends on\n"
@@ -1017,7 +1017,7 @@ arg(maxlogicalvolumes_ARG, 'l', "maxlogicalvolumes", uint32_VAL, 0, 0,
 arg(extents_ARG, 'l', "extents", extents_VAL, 0, 0,
     "#lvcreate\n"
     "Specifies the size of the new LV in logical extents.\n"
-    "The --size and --extents options are alternate methods of specifying size.\n"
+    "The \\-\\-size and \\-\\-extents options are alternate methods of specifying size.\n"
     "The total number of physical extents used will be\n"
     "greater when redundant data is needed for RAID levels.\n"
     "An alternate syntax allows the size to be determined indirectly\n"
@@ -1035,7 +1035,7 @@ arg(extents_ARG, 'l', "extents", extents_VAL, 0, 0,
     "#lvextend\n"
     "#lvresize\n"
     "Specifies the new size of the LV in logical extents.\n"
-    "The --size and --extents options are alternate methods of specifying size.\n"
+    "The \\-\\-size and \\-\\-extents options are alternate methods of specifying size.\n"
     "The total number of physical extents used will be\n"
     "greater when redundant data is needed for RAID levels.\n"
     "An alternate syntax allows the size to be determined indirectly\n"
@@ -1058,10 +1058,10 @@ arg(list_ARG, 'l', "list", 0, 0, 0,
     "#dumpconfig\n"
     "#config\n"
     "List config settings with summarizing comment. This is the same as using\n"
-    "options --typeconfig list --withsummary.\n"
+    "options \\-\\-typeconfig list \\-\\-withsummary.\n"
     "#vgcfgrestore\n"
     "List metadata backup and archive files pertaining to the VG.\n"
-    "May be used with --file. Does not restore the VG.\n"
+    "May be used with \\-\\-file. Does not restore the VG.\n"
     "#vgmerge\n"
     "Display merged destination VG like vgdisplay -v.\n")
 
@@ -1076,14 +1076,14 @@ arg(lvmpartition_ARG, 'l', "lvmpartition", 0, 0, 0,
 arg(size_ARG, 'L', "size", sizemb_VAL, 0, 0,
     "#lvcreate\n"
     "Specifies the size of the new LV.\n"
-    "The --size and --extents options are alternate methods of specifying size.\n"
+    "The \\-\\-size and \\-\\-extents options are alternate methods of specifying size.\n"
     "The total number of physical extents used will be\n"
     "greater when redundant data is needed for RAID levels.\n"
     "#lvreduce\n"
     "#lvextend\n"
     "#lvresize\n"
     "Specifies the new size of the LV.\n"
-    "The --size and --extents options are alternate methods of specifying size.\n"
+    "The \\-\\-size and \\-\\-extents options are alternate methods of specifying size.\n"
     "The total number of physical extents used will be\n"
     "greater when redundant data is needed for RAID levels.\n"
     "When the plus \\fB+\\fP or minus \\fB-\\fP prefix is used,\n"
@@ -1103,7 +1103,7 @@ arg(major_ARG, 'j', "major", number_VAL, ARG_GROUPABLE, 0,
 arg(setactivationskip_ARG, 'k', "setactivationskip", bool_VAL, 0, 0,
     "Persistently sets (yes) or clears (no) the \"activation skip\" flag on an LV.\n"
     "An LV with this flag set is not activated unless the\n"
-    "--ignoreactivationskip option is used by the activation command.\n"
+    "\\-\\-ignoreactivationskip option is used by the activation command.\n"
     "This flag is set by default on new thin snapshot LVs.\n"
     "The flag is not applied to deactivation.\n"
     "The current value of the flag is indicated in the lvs lv_attr bits.\n")
@@ -1116,7 +1116,7 @@ arg(maps_ARG, 'm', "maps", 0, 0, 0,
     "#lvdisplay\n"
     "Display the mapping of logical extents to PVs and physical extents.\n"
     "To map physical extents to logical extents use:\n"
-    "pvs --segments -o+lv_name,seg_start_pe,segtype\n"
+    "pvs \\-\\-segments -o+lv_name,seg_start_pe,segtype\n"
     "#pvdisplay\n"
     "Display the mapping of physical extents to LVs and logical extents.\n")
 
@@ -1125,27 +1125,27 @@ arg(maps_ARG, 'm', "maps", 0, 0, 0,
 arg(mirrors_ARG, 'm', "mirrors", number_VAL, 0, 0,
     "#lvcreate\n"
     "Specifies the number of mirror images in addition to the original LV\n"
-    "image, e.g. --mirrors 1 means there are two images of the data, the\n"
+    "image, e.g. \\-\\-mirrors 1 means there are two images of the data, the\n"
     "original and one mirror image.\n"
     "Optional positional PV args on the command line can specify the devices\n"
     "the images should be placed on.\n"
     "There are two mirroring implementations: \"raid1\" and \"mirror\".\n"
     "These are the names of the corresponding LV types, or \"segment types\".\n"
-    "Use the --type option to specify which to use (raid1 is default,\n"
+    "Use the \\-\\-type option to specify which to use (raid1 is default,\n"
     "and mirror is legacy)\n"
     "Use lvm.conf global/mirror_segtype_default and\n"
     "global/raid10_segtype_default to configure the default types.\n"
-    "See the --nosync option for avoiding initial image synchronization.\n"
+    "See the \\-\\-nosync option for avoiding initial image synchronization.\n"
     "See \\fBlvmraid\\fP(7) for more information.\n"
     "#lvconvert\n"
     "Specifies the number of mirror images in addition to the original LV\n"
-    "image, e.g. --mirrors 1 means there are two images of the data, the\n"
+    "image, e.g. \\-\\-mirrors 1 means there are two images of the data, the\n"
     "original and one mirror image.\n"
     "Optional positional PV args on the command line can specify the devices\n"
     "the images should be placed on.\n"
     "There are two mirroring implementations: \"raid1\" and \"mirror\".\n"
     "These are the names of the corresponding LV types, or \"segment types\".\n"
-    "Use the --type option to specify which to use (raid1 is default,\n"
+    "Use the \\-\\-type option to specify which to use (raid1 is default,\n"
     "and mirror is legacy)\n"
     "Use lvm.conf global/mirror_segtype_default and\n"
     "global/raid10_segtype_default to configure the default types.\n"
@@ -1176,7 +1176,7 @@ arg(name_ARG, 'n', "name", string_VAL, 0, 0,
 
 arg(nofsck_ARG, 'n', "nofsck", 0, 0, 0,
     "Do not perform fsck before resizing filesystem when filesystem\n"
-    "requires it. You may need to use --force to proceed with\n"
+    "requires it. You may need to use \\-\\-force to proceed with\n"
     "this option.\n")
 
 arg(novolumegroup_ARG, 'n', "novolumegroup", 0, 0, 0,
@@ -1217,8 +1217,8 @@ arg(sort_ARG, 'O', "sort", string_VAL, ARG_GROUPABLE, 0,
 arg(maxphysicalvolumes_ARG, 'p', "maxphysicalvolumes", uint32_VAL, 0, 0,
     "Sets the maximum number of PVs that can belong to the VG.\n"
     "The value 0 removes any limitation.\n"
-    "For large numbers of PVs, also see options --pvmetadatacopies,\n"
-    "and --vgmetadatacopies for improving performance.\n")
+    "For large numbers of PVs, also see options \\-\\-pvmetadatacopies,\n"
+    "and \\-\\-vgmetadatacopies for improving performance.\n")
 
 arg(permission_ARG, 'p', "permission", permission_VAL, 0, 0,
     "Set access permission to read only \\fBr\\fP or read and write \\fBrw\\fP.\n")
@@ -1235,7 +1235,7 @@ arg(partial_ARG, 'P', "partial", 0, 0, 0,
 arg(physicalvolume_ARG, 'P', "physicalvolume", 0, 0, 0, NULL)
 
 arg(quiet_ARG, 'q', "quiet", 0, ARG_COUNTABLE, 0,
-    "Suppress output and log messages. Overrides --debug and --verbose.\n"
+    "Suppress output and log messages. Overrides \\-\\-debug and \\-\\-verbose.\n"
     "Repeat once to also suppress any prompts with answer no.\n")
 
 arg(readahead_ARG, 'r', "readahead", readahead_VAL, 0, 0,
@@ -1285,7 +1285,7 @@ arg(snapshot_ARG, 's', "snapshot", 0, 0, 0,
     "the size option is NOT specified. Thin snapshots share the same blocks\n"
     "in the thin pool, and do not allocate new space from the VG.\n"
     "Thin snapshots are created with the \"activation skip\" flag,\n"
-    "see --setactivationskip.\n"
+    "see \\-\\-setactivationskip.\n"
     "A thin snapshot of a non-thin \"external origin\" LV is created\n"
     "when a thin pool is specified. Unprovisioned blocks in the thin snapshot\n"
     "LV are read from the external origin LV. The external origin LV must\n"
@@ -1299,11 +1299,11 @@ arg(snapshot_ARG, 's', "snapshot", 0, 0, 0,
     "be extended with lvextend (shrinking is also allowed with lvreduce.)\n"
     "A small amount of the COW snapshot LV size is used to track COW block\n"
     "locations, so the full size is not available for COW data blocks.\n"
-    "Use lvs to check how much space is used, and see --monitor to\n"
+    "Use lvs to check how much space is used, and see \\-\\-monitor to\n"
     "to automatically extend the size to avoid running out of space.\n"
     "#lvconvert\n"
     "Combine a former COW snapshot LV with a former origin LV to reverse\n"
-    "a previous --splitsnapshot command.\n")
+    "a previous \\-\\-splitsnapshot command.\n")
 
 arg(short_ARG, 's', "short", 0, 0, 0,
     "#pvdisplay\n"
@@ -1318,9 +1318,9 @@ arg(stdin_ARG, 's', "stdin", 0, 0, 0, NULL)
 
 arg(select_ARG, 'S', "select", string_VAL, ARG_GROUPABLE, 0,
     "Select objects for processing and reporting based on specified criteria.\n"
-    "The criteria syntax is described by \\fB--select help\\fP and \\fBlvmreport\\fP(7).\n"
+    "The criteria syntax is described by \\fB\\-\\-select help\\fP and \\fBlvmreport\\fP(7).\n"
     "For reporting commands, one row is displayed for each object matching the criteria.\n"
-    "See \\fB--options help\\fP for selectable object fields.\n"
+    "See \\fB\\-\\-options help\\fP for selectable object fields.\n"
     "Rows can be displayed with an additional \"selected\" field (-o selected)\n"
     "showing 1 if the row matches the selection and 0 otherwise.\n"
     "For non-reporting commands which process LVM entities, the selection is\n"
@@ -1335,7 +1335,7 @@ arg(test_ARG, 't', "test", 0, 0, 0,
 
 arg(thin_ARG, 'T', "thin", 0, 0, 0,
     "Specifies the command is handling a thin LV or thin pool.\n"
-    "See --type thin, --type thin-pool, and --virtualsize.\n"
+    "See \\-\\-type thin, \\-\\-type thin-pool, and \\-\\-virtualsize.\n"
     "See \\fBlvmthin\\fP(7) for more information about LVM thin provisioning.\n")
 
 arg(uuid_ARG, 'u', "uuid", 0, 0, 0,
@@ -1351,7 +1351,7 @@ arg(uuidstr_ARG, 'u', "uuid", string_VAL, 0, 0,
     "Without this option, a random UUID is generated.\n"
     "This option is needed before restoring a backup of LVM metadata\n"
     "onto a replacement device; see vgcfgrestore(8). As such, use of\n"
-    "--restorefile is compulsory unless the --norestorefile is used.\n"
+    "\\-\\-restorefile is compulsory unless the \\-\\-norestorefile is used.\n"
     "All PVs must have unique UUIDs, and LVM will prevent certain operations\n"
     "if multiple devices are seen with the same UUID.\n"
     "See vgimportclone(8) for more information.\n")
@@ -1383,9 +1383,9 @@ arg(virtualsize_ARG, 'V', "virtualsize", sizemb_VAL, 0, 0,
 arg(wipesignatures_ARG, 'W', "wipesignatures", bool_VAL, 0, 0,
     "Controls detection and subsequent wiping of signatures on new LVs.\n"
     "There is a prompt for each signature detected to confirm its wiping\n"
-    "(unless --yes is used to override confirmations.)\n"
+    "(unless \\-\\-yes is used to override confirmations.)\n"
     "When not specified, signatures are wiped whenever zeroing is done\n"
-    "(see --zero). This behaviour can be configured with\n"
+    "(see \\-\\-zero). This behaviour can be configured with\n"
     "lvm.conf allocation/wipe_signatures_when_zeroing_new_lvs.\n"
     "If blkid wiping is used (lvm.conf allocation/use_blkid_wiping)\n"
     "and LVM is compiled with blkid wiping support, then the blkid(8)\n"
@@ -1410,7 +1410,7 @@ arg(yes_ARG, 'y', "yes", 0, 0, 0,
 arg(zero_ARG, 'Z', "zero", bool_VAL, 0, 0,
     "#lvchange\n"
     "Set zeroing mode for thin pool. Note: already provisioned blocks from pool\n"
-    "in non-zero mode are not cleared in unwritten parts when setting --zero y.\n"
+    "in non-zero mode are not cleared in unwritten parts when setting \\-\\-zero y.\n"
     "#lvconvert\n"
     "For snapshots, this controls zeroing of the first 4KiB of data in the\n"
     "snapshot. If the LV is read-only, the snapshot will not be zeroed.\n"
@@ -1427,7 +1427,7 @@ arg(zero_ARG, 'Z', "zero", bool_VAL, 0, 0,
     "#vgextend\n"
     "Controls if the first 4 sectors (2048 bytes) of the device are wiped.\n"
     "The default is to wipe these sectors unless either or both of\n"
-    "--restorefile or --uuid are specified.\n")
+    "\\-\\-restorefile or \\-\\-uuid are specified.\n")
 
 /* this should always be last */
 arg(ARG_COUNT, '-', "", 0, 0, 0, NULL)
diff --git a/tools/command-lines.in b/tools/command-lines.in
index f8a5e57..6a73bf8 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -338,7 +338,7 @@ OO: --mirrors SNumber, --regionsize RegionSize, --interval Number, --mirrorlog M
 OP: PV ...
 ID: lvconvert_raid_types
 DESC: Convert LV to type mirror (also see type raid1),
-DESC: (also see lvconvert --mirrors).
+DESC: (also see lvconvert \\-\\-mirrors).
 RULE: all not lv_is_locked lv_is_pvmove
 FLAGS: SECONDARY_SYNTAX
 
@@ -433,7 +433,7 @@ lvconvert --thin --thinpool LV LV_linear_striped_raid_cache
 OO: --type thin, --originname LV_new, OO_LVCONVERT_POOL, OO_LVCONVERT
 ID: lvconvert_to_thin_with_external
 DESC: Convert LV to a thin LV, using the original LV as an external origin
-DESC: (infers --type thin).
+DESC: (infers \\-\\-type thin).
 FLAGS: SECONDARY_SYNTAX
 RULE: all and lv_is_visible
 RULE: all not lv_is_locked
@@ -450,7 +450,7 @@ RULE: all and lv_is_visible
 lvconvert --cache --cachepool LV LV_linear_striped_raid_thinpool
 OO: --type cache, OO_LVCONVERT_CACHE, OO_LVCONVERT_POOL, OO_LVCONVERT
 ID: lvconvert_to_cache_vol
-DESC: Convert LV to type cache (infers --type cache).
+DESC: Convert LV to type cache (infers \\-\\-type cache).
 RULE: all and lv_is_visible
 FLAGS: SECONDARY_SYNTAX
 
@@ -492,8 +492,8 @@ OO: --type thin-pool, --stripes_long Number, --stripesize SizeKB,
 --discards Discards, OO_LVCONVERT_POOL, OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_to_thinpool_or_swap_metadata
-DESC: Convert LV to type thin-pool (variant, use --type thin-pool).
-DESC: Swap metadata LV in a thin pool (variant, use --swapmetadata).
+DESC: Convert LV to type thin-pool (variant, use \\-\\-type thin-pool).
+DESC: Swap metadata LV in a thin pool (variant, use \\-\\-swapmetadata).
 FLAGS: PREVIOUS_SYNTAX
 
 ---
@@ -530,8 +530,8 @@ lvconvert --cachepool LV_linear_striped_raid_cachepool
 OO: --type cache-pool, OO_LVCONVERT_CACHE, OO_LVCONVERT_POOL, OO_LVCONVERT
 OP: PV ...
 ID: lvconvert_to_cachepool_or_swap_metadata
-DESC: Convert LV to type cache-pool (variant, use --type cache-pool).
-DESC: Swap metadata LV in a cache pool (variant, use --swapmetadata).
+DESC: Convert LV to type cache-pool (variant, use \\-\\-type cache-pool).
+DESC: Swap metadata LV in a cache pool (variant, use \\-\\-swapmetadata).
 FLAGS: PREVIOUS_SYNTAX
 
 ---
@@ -569,9 +569,9 @@ FLAGS: SECONDARY_SYNTAX
 lvconvert --merge LV_linear_striped_raid_thin_snapshot|VG|Tag ...
 OO: --background, --interval Number, OO_LVCONVERT
 ID: lvconvert_merge
-DESC: Merge LV that was split from a mirror (variant, use --mergemirrors).
-DESC: Merge thin LV into its origin LV (variant, use --mergethin).
-DESC: Merge COW snapshot LV into its origin (variant, use --mergesnapshot).
+DESC: Merge LV that was split from a mirror (variant, use \\-\\-mergemirrors).
+DESC: Merge thin LV into its origin LV (variant, use \\-\\-mergethin).
+DESC: Merge COW snapshot LV into its origin (variant, use \\-\\-mergesnapshot).
 RULE: all not lv_is_locked lv_is_pvmove lv_is_merging_origin lv_is_virtual_origin lv_is_external_origin lv_is_merging_cow
 FLAGS: SECONDARY_SYNTAX
 
@@ -684,7 +684,7 @@ RULE: all and lv_is_converting
 lvconvert LV_mirror_raid
 OO: OO_LVCONVERT
 ID: lvconvert_start_poll
-DESC: Poll LV to continue conversion (also see --startpoll).
+DESC: Poll LV to continue conversion (also see \\-\\-startpoll).
 RULE: all and lv_is_converting
 FLAGS: SECONDARY_SYNTAX
 
@@ -772,7 +772,7 @@ lvcreate --type striped --size SizeMB VG
 OO: --stripes Number, --stripesize SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_striped
-DESC: Create a striped LV (also see lvcreate --stripes).
+DESC: Create a striped LV (also see lvcreate \\-\\-stripes).
 FLAGS: SECONDARY_SYNTAX
 
 # R13 (just --stripes)
@@ -780,7 +780,7 @@ lvcreate --stripes Number --size SizeMB VG
 OO: --stripesize SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_striped
-DESC: Create a striped LV (infers --type striped).
+DESC: Create a striped LV (infers \\-\\-type striped).
 
 # R5,R7 (--type mirror with or without --mirrors)
 lvcreate --type mirror --size SizeMB VG
@@ -788,7 +788,7 @@ OO: --mirrors PNumber, --mirrorlog MirrorLog, --regionsize RegionSize,
 --stripes Number, --stripesize SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_mirror
-DESC: Create a mirror LV (also see --type raid1).
+DESC: Create a mirror LV (also see \\-\\-type raid1).
 FLAGS: SECONDARY_SYNTAX
 
 # R14 (just --mirrors)
@@ -797,7 +797,7 @@ lvcreate --mirrors PNumber --size SizeMB VG
 OO: --mirrorlog MirrorLog, --regionsize RegionSize, --minrecoveryrate SizeKB, --maxrecoveryrate SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_mirror_or_raid1
-DESC: Create a raid1 or mirror LV (infers --type raid1|mirror).
+DESC: Create a raid1 or mirror LV (infers \\-\\-type raid1|mirror).
 
 # R9,R10,R11,R12 (--type raid with any use of --stripes/--mirrors)
 lvcreate --type raid --size SizeMB VG
@@ -828,7 +828,7 @@ OO: --snapshot, --stripes Number, --stripesize SizeKB,
 OP: PV ...
 ID: lvcreate_cow_snapshot
 DESC: Create a COW snapshot LV of an origin LV
-DESC: (also see --snapshot).
+DESC: (also see \\-\\-snapshot).
 FLAGS: SECONDARY_SYNTAX
 
 lvcreate --snapshot --size SizeMB LV
@@ -846,7 +846,7 @@ OO: --snapshot, --chunksize SizeKB, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_cow_snapshot_with_virtual_origin
 DESC: Create a sparse COW snapshot LV of a virtual origin LV
-DESC: (also see --snapshot).
+DESC: (also see \\-\\-snapshot).
 FLAGS: SECONDARY_SYNTAX
 
 lvcreate --snapshot --size SizeMB --virtualsize SizeMB VG
@@ -873,7 +873,7 @@ OO: --type thin-pool, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
 OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_thinpool
-DESC: Create a thin pool (infers --type thin-pool).
+DESC: Create a thin pool (infers \\-\\-type thin-pool).
 FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type thin-pool
@@ -883,8 +883,8 @@ OO: --thin, --type thin-pool, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
 OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_thinpool
-DESC: Create a thin pool named by the --thinpool arg
-DESC: (infers --type thin-pool).
+DESC: Create a thin pool named by the \\-\\-thinpool arg
+DESC: (infers \\-\\-type thin-pool).
 FLAGS: SECONDARY_SYNTAX
 
 ---
@@ -905,8 +905,8 @@ lvcreate --type cache-pool --size SizeMB --cachepool LV_new VG
 OO: --cache, OO_LVCREATE_POOL, OO_LVCREATE_CACHE, OO_LVCREATE
 OP: PV ...
 ID: lvcreate_cachepool
-DESC: Create a cache pool named by the --cachepool arg
-DESC: (variant, uses --cachepool in place of --name).
+DESC: Create a cache pool named by the \\-\\-cachepool arg
+DESC: (variant, uses \\-\\-cachepool in place of \\-\\-name).
 FLAGS: SECONDARY_SYNTAX
 
 ---
@@ -924,7 +924,7 @@ OO: --thin, OO_LVCREATE_THIN, OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_vol
 DESC: Create a thin LV in a thin pool named in the first arg
-DESC: (variant, also see --thinpool for naming pool).
+DESC: (variant, also see \\-\\-thinpool for naming pool).
 FLAGS: SECONDARY_SYNTAX
 
 # NB. this is the variant which can substitute
@@ -935,7 +935,7 @@ lvcreate --virtualsize SizeMB --thinpool LV_thinpool VG
 OO: --type thin, --thin, OO_LVCREATE_THIN, OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_vol
-DESC: Create a thin LV in a thin pool (infers --type thin).
+DESC: Create a thin LV in a thin pool (infers \\-\\-type thin).
 
 # alternate form of lvcreate --type thin
 lvcreate --virtualsize SizeMB LV_thinpool
@@ -943,7 +943,7 @@ OO: --type thin, --thin, OO_LVCREATE_THIN, OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_vol
 DESC: Create a thin LV in the thin pool named in the first arg
-DESC: (variant, infers --type thin, also see --thinpool for
+DESC: (variant, infers \\-\\-type thin, also see \\-\\-thinpool for
 DESC: naming pool.)
 FLAGS: SECONDARY_SYNTAX
 
@@ -962,7 +962,7 @@ OO: --type thin, OO_LVCREATE_THIN, OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_snapshot
 DESC: Create a thin LV that is a snapshot of an existing thin LV
-DESC: (infers --type thin).
+DESC: (infers \\-\\-type thin).
 FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type thin
@@ -971,7 +971,7 @@ OO: --type thin, OO_LVCREATE_THIN, OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_snapshot
 DESC: Create a thin LV that is a snapshot of an existing thin LV
-DESC: (infers --type thin).
+DESC: (infers \\-\\-type thin).
 
 lvcreate --type thin --thinpool LV_thinpool LV
 OO: --thin, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE
@@ -985,7 +985,7 @@ OO: --type thin, OO_LVCREATE_THIN, OO_LVCREATE
 IO: --mirrors 0
 ID: lvcreate_thin_snapshot_of_external
 DESC: Create a thin LV that is a snapshot of an external origin LV
-DESC: (infers --type thin).
+DESC: (infers \\-\\-type thin).
 FLAGS: SECONDARY_SYNTAX
 
 ---
@@ -1013,7 +1013,7 @@ OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_thin_vol_and_thinpool
 DESC: Create a thin LV, first creating a thin pool for it,
-DESC: where the new thin pool is named by the --thinpool arg.
+DESC: where the new thin pool is named by the \\-\\-thinpool arg.
 
 # alternate form of lvcreate --type thin
 lvcreate --virtualsize SizeMB --size SizeMB --thinpool LV_new
@@ -1023,8 +1023,8 @@ OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_thin_vol_and_thinpool
 DESC: Create a thin LV, first creating a thin pool for it,
-DESC: where the new thin pool is named by the --thinpool arg
-DESC: (variant, infers --type thin).
+DESC: where the new thin pool is named by the \\-\\-thinpool arg
+DESC: (variant, infers \\-\\-type thin).
 FLAGS: SECONDARY_SYNTAX
 
 # same as prev but accepts VG pos arg
@@ -1036,8 +1036,8 @@ OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_thin_vol_and_thinpool
 DESC: Create a thin LV, first creating a thin pool for it,
-DESC: where the new thin pool is named by the --thinpool arg
-DESC: (variant, infers --type thin).
+DESC: where the new thin pool is named by the \\-\\-thinpool arg
+DESC: (variant, infers \\-\\-type thin).
 FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type thin
@@ -1063,7 +1063,7 @@ ID: lvcreate_thin_vol_and_thinpool
 DESC: Create a thin LV, first creating a thin pool for it,
 DESC: where the new thin pool is named in the first arg,
 DESC: or the new thin pool name is generated when the first
-DESC: arg is a VG name (variant, infers --type thin).
+DESC: arg is a VG name (variant, infers \\-\\-type thin).
 FLAGS: SECONDARY_SYNTAX
 
 ---
@@ -1075,10 +1075,10 @@ OP: PV ...
 IO: --mirrors 0
 ID: lvcreate_thin_vol_with_thinpool_or_sparse_snapshot
 DESC: Create a thin LV, first creating a thin pool for it
-DESC: (infers --type thin).
+DESC: (infers \\-\\-type thin).
 DESC: Create a sparse snapshot of a virtual origin LV
-DESC: (infers --type snapshot).
-DESC: Chooses --type thin or --type snapshot according to
+DESC: (infers \\-\\-type snapshot).
+DESC: Chooses \\-\\-type thin or \\-\\-type snapshot according to
 DESC: config setting sparse_segtype_default.
 FLAGS: SECONDARY_SYNTAX
 
@@ -1095,7 +1095,7 @@ OP: PV ...
 ID: lvcreate_cache_vol_with_new_origin
 DESC: Create a cache LV, first creating a new origin LV,
 DESC: then combining it with the existing cache pool named
-DESC: by the --cachepool arg.
+DESC: by the \\-\\-cachepool arg.
 
 # alternate form of lvcreate --type cache
 lvcreate --size SizeMB --cachepool LV_cachepool VG
@@ -1105,7 +1105,7 @@ OP: PV ...
 ID: lvcreate_cache_vol_with_new_origin
 DESC: Create a cache LV, first creating a new origin LV,
 DESC: then combining it with the existing cache pool named
-DESC: by the --cachepool arg (variant, infers --type cache).
+DESC: by the \\-\\-cachepool arg (variant, infers \\-\\-type cache).
 FLAGS: SECONDARY_SYNTAX
 
 # alternate form of lvcreate --type cache
@@ -1116,7 +1116,7 @@ OP: PV ...
 ID: lvcreate_cache_vol_with_new_origin
 DESC: Create a cache LV, first creating a new origin LV,
 DESC: then combining it with the existing cache pool named
-DESC: in the first arg (variant, also use --cachepool).
+DESC: in the first arg (variant, also use \\-\\-cachepool).
 FLAGS: SECONDARY_SYNTAX
 
 # This is a ridiculously crazy command which nobody could
@@ -1134,8 +1134,8 @@ FLAGS: SECONDARY_SYNTAX
 # ID: lvcreate_cache_vol_with_new_origin
 # DESC: Create a cache LV, first creating a new origin LV,
 # DESC: then combining it with the existing cache pool named
-# DESC: in the first arg (variant, infers --type cache,
-# DESC: also use --cachepool).
+# DESC: in the first arg (variant, infers \\-\\-type cache,
+# DESC: also use \\-\\-cachepool).
 #
 # 2. If LV is not a cachepool, then it's a disguised lvconvert.
 #
@@ -1165,7 +1165,7 @@ ID: lvcreate_cache_vol_with_new_origin_or_convert_to_cache_vol_with_cachepool
 DESC: When LV is a cache pool, create a cache LV,
 DESC: first creating a new origin LV, then combining it with
 DESC: the existing cache pool named in the first arg
-DESC: (variant, infers --type cache, also use --cachepool).
+DESC: (variant, infers \\-\\-type cache, also use \\-\\-cachepool).
 DESC: When LV is not a cache pool, convert the specified LV
 DESC: to type cache after creating a new cache pool LV to use
 DESC: (use lvconvert).
diff --git a/tools/command.c b/tools/command.c
index 325632f..9c9bf88 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -2093,7 +2093,7 @@ void print_usage_notes(struct command_name *cname)
                "        capitalization, e.g. 'k' and 'K' both refer to 1024.\n"
                "        The default input unit is specified by letter, followed by |UNIT.\n"
                "        UNIT represents other possible input units: BbBsSkKmMgGtTpPeE.\n"
-               "        (This should not be confused with the output control --units, where\n"
+               "        (This should not be confused with the output control \\-\\-units, where\n"
                "        capital letters mean multiple of 1000.)\n");
 	printf("\n");
 }
@@ -2295,6 +2295,13 @@ static void print_def_man(struct command_name *cname, int opt_enum, struct arg_d
 		printf(" ...");
 }
 
+static const char *_emit_long_opt_name(char *buf, const char *long_opt_name, ssize_t len)
+{
+	strcpy(buf, "\\-\\-");
+	strncat(buf, long_opt_name + 2, len - 3);
+	return buf;
+}
+
 static char *man_long_opt_name(const char *cmdname, int opt_enum)
 {
 	static char long_opt_name[64];
@@ -2303,34 +2310,34 @@ static char *man_long_opt_name(const char *cmdname, int opt_enum)
 
 	switch (opt_enum) {
 	case syncaction_ARG:
-		strncpy(long_opt_name, "--[raid]syncaction", 63);
+		strncpy(long_opt_name, "\\-\\-[raid]syncaction", 63);
 		break;
 	case writemostly_ARG:
-		strncpy(long_opt_name, "--[raid]writemostly", 63);
+		strncpy(long_opt_name, "\\-\\-[raid]writemostly", 63);
 		break;
 	case minrecoveryrate_ARG:
-		strncpy(long_opt_name, "--[raid]minrecoveryrate", 63);
+		strncpy(long_opt_name, "\\-\\-[raid]minrecoveryrate", 63);
 		break;
 	case maxrecoveryrate_ARG:
-		strncpy(long_opt_name, "--[raid]maxrecoveryrate", 63);
+		strncpy(long_opt_name, "\\-\\-[raid]maxrecoveryrate", 63);
 		break;
 	case writebehind_ARG:
-		strncpy(long_opt_name, "--[raid]writebehind", 63);
+		strncpy(long_opt_name, "\\-\\-[raid]writebehind", 63);
 		break;
 	case vgmetadatacopies_ARG:
 		if (!strncmp(cmdname, "vg", 2))
-			strncpy(long_opt_name, "--[vg]metadatacopies", 63);
+			strncpy(long_opt_name, "\\-\\-[vg]metadatacopies", 63);
 		else
-			strncpy(long_opt_name, "--vgmetadatacopies", 63);
+			strncpy(long_opt_name, "\\-\\-vgmetadatacopies", 63);
 		break;
 	case pvmetadatacopies_ARG:
 		if (!strncmp(cmdname, "pv", 2))
-			strncpy(long_opt_name, "--[pv]metadatacopies", 63);
+			strncpy(long_opt_name, "\\-\\-[pv]metadatacopies", 63);
 		else
-			strncpy(long_opt_name, "--pvmetadatacopies", 63);
+			strncpy(long_opt_name, "\\-\\-pvmetadatacopies", 63);
 		break;
 	default:
-		strncpy(long_opt_name, opt_names[opt_enum].long_opt, 63);
+		_emit_long_opt_name(long_opt_name, opt_names[opt_enum].long_opt, 63);
 		break;
 	}
 
@@ -2344,6 +2351,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 	int sep, ro, rp, oo, op, opt_enum;
 	int need_ro_indent_end = 0;
 	int include_extents = 0;
+	char long_opt_name[64];
 
 	if (!(cname = find_command_name(cmd->name)))
 		return;
@@ -2481,7 +2489,8 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 				       opt_names[opt_enum].short_opt,
 				       man_long_opt_name(cmd->name, opt_enum));
 			} else {
-				printf(" \\fB%s\\fP", opt_names[cmd->required_opt_args[ro].opt].long_opt);
+				_emit_long_opt_name(long_opt_name, opt_names[cmd->required_opt_args[ro].opt].long_opt, 63);
+				printf(" \\fB%s\\fP", long_opt_name);
 			}
 
 			if (cmd->required_opt_args[ro].def.val_bits) {
@@ -2528,7 +2537,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 			 * in opt_names[] according to the command name.
 			 */
 			printf(".ad l\n");
-			printf("[ \\fB-l\\fP|\\fB--extents\\fP ");
+			printf("[ \\fB-l\\fP|\\fB\\-\\-extents\\fP ");
 			print_val_man(cname, extents_ARG, opt_names[extents_ARG].val_enum);
 			printf(" ]\n");
 			printf(".ad b\n");
@@ -3089,7 +3098,7 @@ static void _print_man_all_positions_desc(struct command_name *cname)
 		if (!strcmp(cname->name, "lvcreate"))
 			printf("For lvcreate, the required VG positional arg may be\n"
 			       "omitted when the VG name is included in another option,\n"
-			       "e.g. --name VG/LV.\n");
+			       "e.g. \\-\\-name VG/LV.\n");
 	}
 
 	if (has_lv_val) {
@@ -3138,7 +3147,7 @@ static void _print_man_all_positions_desc(struct command_name *cname)
 		printf("\n");
 		printf(".br\n");
 		printf("Select indicates that a required positional parameter can\n"
-		       "be omitted if the \\fB--select\\fP option is used.\n"
+		       "be omitted if the \\fB\\-\\-select\\fP option is used.\n"
 		       "No arg appears in this position.\n");
 	}
 
@@ -3168,7 +3177,7 @@ static void _print_man_all_positions_desc(struct command_name *cname)
 	       "b|B is bytes, s|S is sectors of 512 bytes, k|K is kilobytes,\n"
 	       "m|M is megabytes, g|G is gigabytes, t|T is terabytes,\n"
 	       "p|P is petabytes, e|E is exabytes.\n"
-	       "(This should not be confused with the output control --units, where\n"
+	       "(This should not be confused with the output control \\-\\-units, where\n"
 	       "capital letters mean multiple of 1000.)\n");
 
 	printf(".SH ENVIRONMENT VARIABLES\n");


