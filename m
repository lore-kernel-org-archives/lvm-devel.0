From: Takahiro Yasui <tyasui@redhat.com>
Date: Fri, 23 Jan 2009 11:40:22 -0500
Subject: [RFC][PATCH] Add partial mode option in lvm config file
Message-ID: <4979F2F6.6070805@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I would like to introduce "partial_mode" option in lvm config file.
I appreciate any comments on this.


* Introduction

This patch introduces a new configuration parameter, "partial_mode",
in lvm configuration file (lvm.conf). This "partial_mode" affects
some lvm commands, which already support --partial/-P, and sets them
-P option by default.

I think that this partial mode is useful for not only trouble shooting
but also usual operation in case of device failures. For example,
lvm mirroring is used to make systems stable and keep high availability,
and LVs in VGs should be activated even if one of their legs is broken.
However, currently LVs are not activated without a partial option.

Root filesystems and other volumes using lvm have to be activated during
system boot in order to make system continue to work. I think supporting
"partial_mode" in config makes it easy, since we don't have to change
mkinitrd and rc.sysinit script for this use.

In addition, a new command line parameter, "--nopartial", is added in order
to override a configuration in a command line. This parameter is for users
who want to disable partial_mode temporarily for checking LV strictly.


* Example

When "partial_mode" is set to 1, lvm commands work as if -P or --partial
options are indicated in its command line.

  global {
    ...
    partial_mode = 1
  }


Thanks,
---
Takahiro Yasui
Hitachi Computer Products (America), Inc.


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 doc/example.conf   |    6 ++++++
 tools/args.h       |    1 +
 tools/commands.h   |   50 +++++++++++++++++++++++++++++++++-----------------
 tools/lvmcmdline.c |   14 +++++++++++---
 4 files changed, 51 insertions(+), 20 deletions(-)

Index: LVM2.2.02.44-cvs-20090106/tools/lvmcmdline.c
===================================================================
--- LVM2.2.02.44-cvs-20090106.orig/tools/lvmcmdline.c
+++ LVM2.2.02.44-cvs-20090106/tools/lvmcmdline.c
@@ -778,13 +778,21 @@ static int _get_settings(struct cmd_cont
 	cmd->current_settings.archive = arg_int_value(cmd, autobackup_ARG, cmd->current_settings.archive);
 	cmd->current_settings.backup = arg_int_value(cmd, autobackup_ARG, cmd->current_settings.backup);
 	cmd->current_settings.cache_vgmetadata = cmd->command->flags & CACHE_VGMETADATA ? 1 : 0;
-	cmd->partial_activation = 0;
 
-	if (arg_count(cmd, partial_ARG)) {
+	cmd->partial_activation = find_config_tree_int(cmd, "global/partial_mode", 0);
+	if (arg_count(cmd, partial_ARG) && arg_count(cmd, nopartial_ARG)) {
+		log_print("--partial and --nopartial should be used exclusively.");
+		return EINVALID_CMD_LINE;
+	}
+
+	if (arg_count(cmd, partial_ARG))
 		cmd->partial_activation = 1;
+	else if (arg_count(cmd, nopartial_ARG))
+		cmd->partial_activation = 0;
+
+	if (cmd->partial_activation)
 		log_print("Partial mode. Incomplete volume groups will "
 			  "be activated read-only.");
-	}
 
 	if (arg_count(cmd, ignorelockingfailure_ARG))
 		init_ignorelockingfailure(1);
Index: LVM2.2.02.44-cvs-20090106/tools/args.h
===================================================================
--- LVM2.2.02.44-cvs-20090106.orig/tools/args.h
+++ LVM2.2.02.44-cvs-20090106/tools/args.h
@@ -56,6 +56,7 @@ arg(ignoremonitoring_ARG, '\0', "ignorem
 arg(nameprefixes_ARG, '\0', "nameprefixes", NULL, 0)
 arg(unquoted_ARG, '\0', "unquoted", NULL, 0)
 arg(rows_ARG, '\0', "rows", NULL, 0)
+arg(nopartial_ARG, '\0', "nopartial", NULL, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
Index: LVM2.2.02.44-cvs-20090106/doc/example.conf
===================================================================
--- LVM2.2.02.44-cvs-20090106.orig/doc/example.conf
+++ LVM2.2.02.44-cvs-20090106/doc/example.conf
@@ -268,6 +268,12 @@ global {
 
     # The external locking library to load if locking_type is set to 2.
     #   locking_library = "liblvm2clusterlock.so"
+
+    # This option enables LVM commands to be executed in partial mode
+    # by default. If this option is not specified, or is set to "0",
+    # commands work in non-partial mode by default.
+    # The command line override is -P (--partial) or --nopartial
+    #   partial_mode = 1
 }
 
 activation {
Index: LVM2.2.02.44-cvs-20090106/tools/commands.h
===================================================================
--- LVM2.2.02.44-cvs-20090106.orig/tools/commands.h
+++ LVM2.2.02.44-cvs-20090106/tools/commands.h
@@ -74,6 +74,7 @@ xx(lvchange,
    "\t[--monitor {y|n}]\n"
    "\t[-M|--persistent y|n] [--major major] [--minor minor]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--nopartial]\n"
    "\t[-p|--permission r|rw]\n"
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[--refresh]\n"
@@ -86,8 +87,9 @@ xx(lvchange,
 
    alloc_ARG, autobackup_ARG, available_ARG, contiguous_ARG, force_ARG,
    ignorelockingfailure_ARG, ignoremonitoring_ARG, major_ARG, minor_ARG,
-   monitor_ARG, partial_ARG, permission_ARG, persistent_ARG, readahead_ARG,
-   resync_ARG, refresh_ARG, addtag_ARG, deltag_ARG, test_ARG, yes_ARG)
+   monitor_ARG, partial_ARG, nopartial_ARG, permission_ARG, persistent_ARG,
+   readahead_ARG, resync_ARG, refresh_ARG, addtag_ARG, deltag_ARG, test_ARG,
+   yes_ARG)
 
 xx(lvconvert,
    "Change logical volume layout",
@@ -181,6 +183,7 @@ xx(lvdisplay,
    "\t[-m|--maps]\n"
    "\t[--nosuffix]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--nopartial]\n"
    "\t[--units hsbkmgtHKMGT]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n"
@@ -197,6 +200,7 @@ xx(lvdisplay,
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--nopartial]\n"
    "\t[--segments]\n"
    "\t[--separator Separator]\n"
    "\t[--unbuffered]\n"
@@ -207,8 +211,8 @@ xx(lvdisplay,
 
     aligned_ARG, all_ARG, colon_ARG, columns_ARG, disk_ARG,
     ignorelockingfailure_ARG, maps_ARG, noheadings_ARG, nosuffix_ARG,
-    options_ARG, sort_ARG, partial_ARG, segments_ARG, separator_ARG,
-    unbuffered_ARG, units_ARG)
+    options_ARG, sort_ARG, partial_ARG, nopartial_ARG, segments_ARG,
+    separator_ARG, unbuffered_ARG, units_ARG)
 
 xx(lvextend,
    "Add space to a logical volume",
@@ -372,6 +376,7 @@ xx(lvs,
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--nopartial]\n"
    "\t[--rows]\n"
    "\t[--segments]\n"
    "\t[--separator Separator]\n"
@@ -385,8 +390,8 @@ xx(lvs,
 
    aligned_ARG, all_ARG, ignorelockingfailure_ARG, nameprefixes_ARG,
    noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, 
-   rows_ARG, segments_ARG, separator_ARG, sort_ARG, trustcache_ARG,
-   unbuffered_ARG, units_ARG, unquoted_ARG)
+   nopartial_ARG, rows_ARG, segments_ARG, separator_ARG, sort_ARG,
+   trustcache_ARG, unbuffered_ARG, units_ARG, unquoted_ARG)
 
 xx(lvscan,
    "List all logical volumes in all volume groups",
@@ -398,10 +403,12 @@ xx(lvscan,
    "\t[-h|-?|--help] " "\n"
    "\t[--ignorelockingfailure]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--nopartial]\n"
    "\t[-v|--verbose] " "\n"
    "\t[--version]\n",
 
-   all_ARG, blockdevice_ARG, disk_ARG, ignorelockingfailure_ARG, partial_ARG)
+   all_ARG, blockdevice_ARG, disk_ARG, ignorelockingfailure_ARG, partial_ARG,
+   nopartial_ARG)
 
 xx(pvchange,
    "Change attributes of physical volume(s)",
@@ -583,6 +590,7 @@ xx(pvs,
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--nopartial]\n"
    "\t[--rows]\n"
    "\t[--segments]\n"
    "\t[--separator Separator]\n"
@@ -596,8 +604,8 @@ xx(pvs,
 
    aligned_ARG, all_ARG, ignorelockingfailure_ARG, nameprefixes_ARG,
    noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG,
-   rows_ARG, segments_ARG, separator_ARG, sort_ARG, trustcache_ARG,
-   unbuffered_ARG, units_ARG, unquoted_ARG)
+   nopartial_ARG, rows_ARG, segments_ARG, separator_ARG, sort_ARG,
+   trustcache_ARG, unbuffered_ARG, units_ARG, unquoted_ARG)
 
 xx(pvscan,
    "List all physical volumes",
@@ -608,13 +616,14 @@ xx(pvscan,
    "\t[-h|-?|--help]" "\n"
    "\t[--ignorelockingfailure]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--nopartial]\n"
    "\t[-s|--short] " "\n"
    "\t[-u|--uuid] " "\n"
    "\t[-v|--verbose] " "\n"
    "\t[--version]\n",
 
    exported_ARG, ignorelockingfailure_ARG, novolumegroup_ARG, partial_ARG,
-   short_ARG, uuid_ARG)
+   nopartial_ARG, short_ARG, uuid_ARG)
 
 xx(segtypes,
    "List available segment types",
@@ -630,11 +639,12 @@ xx(vgcfgbackup,
    "\t[-h|-?|--help] " "\n"
    "\t[--ignorelockingfailure]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--nopartial]\n"
    "\t[-v|--verbose]" "\n"
    "\t[--version] " "\n"
    "\t[VolumeGroupName...]\n",
 
-   file_ARG, ignorelockingfailure_ARG, partial_ARG)
+   file_ARG, ignorelockingfailure_ARG, partial_ARG, nopartial_ARG)
 
 xx(vgcfgrestore,
    "Restore volume group configuration",
@@ -660,6 +670,7 @@ xx(vgchange,
    "\t[-A|--autobackup {y|n}] " "\n"
    "\t[--alloc AllocationPolicy] " "\n"
    "\t[-P|--partial] " "\n"
+   "\t[--nopartial]\n"
    "\t[-d|--debug] " "\n"
    "\t[-h|--help] " "\n"
    "\t[--ignorelockingfailure]\n"
@@ -683,8 +694,8 @@ xx(vgchange,
    addtag_ARG, alloc_ARG, allocation_ARG, autobackup_ARG, available_ARG,
    clustered_ARG, deltag_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG,
    logicalvolume_ARG, maxphysicalvolumes_ARG, monitor_ARG, partial_ARG,
-   physicalextentsize_ARG, refresh_ARG, resizeable_ARG, resizable_ARG,
-   test_ARG, uuid_ARG)
+   nopartial_ARG, physicalextentsize_ARG, refresh_ARG, resizeable_ARG,
+   resizable_ARG, test_ARG, uuid_ARG)
 
 xx(vgck,
    "Check the consistency of volume group(s)",
@@ -746,6 +757,7 @@ xx(vgdisplay,
    "\t[--ignorelockingfailure]" "\n"
    "\t[--nosuffix]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--nopartial]\n"
    "\t[--units hsbkmgtHKMGT]\n"
    "\t[-A|--activevolumegroups | [-D|--disk]" "\n"
    "\t[--version]" "\n"
@@ -761,6 +773,7 @@ xx(vgdisplay,
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--nopartial]\n"
    "\t[--separator Separator]\n"
    "\t[--unbuffered]\n"
    "\t[--units hsbkmgtHKMGT]\n"
@@ -770,7 +783,8 @@ xx(vgdisplay,
 
    activevolumegroups_ARG, aligned_ARG, colon_ARG, columns_ARG, disk_ARG,
    ignorelockingfailure_ARG, noheadings_ARG, nosuffix_ARG, options_ARG,
-   partial_ARG, short_ARG, separator_ARG, sort_ARG, unbuffered_ARG, units_ARG)
+   partial_ARG, nopartial_ARG, short_ARG, separator_ARG, sort_ARG,
+   unbuffered_ARG, units_ARG)
 
 xx(vgexport,
    "Unregister volume group(s) from the system",
@@ -907,6 +921,7 @@ xx(vgs,
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--nopartial]\n"
    "\t[--rows]\n"
    "\t[--separator Separator]\n"
    "\t[--trustcache]\n"
@@ -919,8 +934,8 @@ xx(vgs,
 
    aligned_ARG, all_ARG, ignorelockingfailure_ARG, nameprefixes_ARG,
    noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, 
-   rows_ARG, separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG,
-   unquoted_ARG)
+   nopartial_ARG, rows_ARG, separator_ARG, sort_ARG, trustcache_ARG,
+   unbuffered_ARG, units_ARG, unquoted_ARG)
 
 xx(vgscan,
    "Search for all volume groups",
@@ -931,10 +946,11 @@ xx(vgscan,
    "\t[--ignorelockingfailure]\n"
    "\t[--mknodes]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--nopartial]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n",
 
-   ignorelockingfailure_ARG, mknodes_ARG, partial_ARG)
+   ignorelockingfailure_ARG, mknodes_ARG, partial_ARG, nopartial_ARG)
 
 xx(vgsplit,
    "Move physical volumes into a new or existing volume group",


