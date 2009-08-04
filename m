From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 4 Aug 2009 15:53:04 -0000
Subject: LVM2/tools args.h commands.h
Message-ID: <20090804155304.30059.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-08-04 15:53:04

Modified files:
	tools          : args.h commands.h 

Log message:
	Add --noudevsync option for relevant LVM tools.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.66&r2=1.67
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.130&r2=1.131

--- LVM2/tools/args.h	2009/07/30 17:45:29	1.66
+++ LVM2/tools/args.h	2009/08/04 15:53:04	1.67
@@ -62,6 +62,7 @@
 arg(dataalignmentoffset_ARG, '\0', "dataalignmentoffset", size_kb_arg, 0)
 arg(virtualoriginsize_ARG, '\0', "virtualoriginsize", size_mb_arg, 0)
 arg(virtualsize_ARG, '\0', "virtualsize", size_mb_arg, 0)
+arg(noudevsync_ARG, '\0', "noudevsync", NULL, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
--- LVM2/tools/commands.h	2009/07/30 17:45:30	1.130
+++ LVM2/tools/commands.h	2009/08/04 15:53:04	1.131
@@ -72,6 +72,7 @@
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoremonitoring]\n"
    "\t[--monitor {y|n}]\n"
+   "\t[--noudevsync]\n"
    "\t[-M|--persistent y|n] [--major major] [--minor minor]\n"
    "\t[-P|--partial] " "\n"
    "\t[-p|--permission r|rw]\n"
@@ -86,8 +87,9 @@
 
    alloc_ARG, autobackup_ARG, available_ARG, contiguous_ARG, force_ARG,
    ignorelockingfailure_ARG, ignoremonitoring_ARG, major_ARG, minor_ARG,
-   monitor_ARG, partial_ARG, permission_ARG, persistent_ARG, readahead_ARG,
-   resync_ARG, refresh_ARG, addtag_ARG, deltag_ARG, test_ARG, yes_ARG)
+   monitor_ARG, noudevsync_ARG, partial_ARG, permission_ARG, persistent_ARG,
+   readahead_ARG, resync_ARG, refresh_ARG, addtag_ARG, deltag_ARG, test_ARG,
+   yes_ARG)
 
 xx(lvconvert,
    "Change logical volume layout",
@@ -102,6 +104,7 @@
    "\t[-f|--force]\n"
    "\t[-h|-?|--help]\n"
    "\t[-i|--interval seconds]\n"
+   "\t[--noudevsync]\n"
    "\t[-v|--verbose]\n"
    "\t[-y|--yes]\n"
    "\t[--version]" "\n"
@@ -112,14 +115,15 @@
    "\t[-c|--chunksize]\n"
    "\t[-d|--debug]\n"
    "\t[-h|-?|--help]\n"
+   "\t[--noudevsync]\n"
    "\t[-v|--verbose]\n"
    "\t[-Z|--zero {y|n}]\n"
    "\t[--version]" "\n"
    "\tOriginalLogicalVolume[Path] SnapshotLogicalVolume[Path]\n",
 
    alloc_ARG, background_ARG, chunksize_ARG, corelog_ARG, interval_ARG,
-   mirrorlog_ARG, mirrors_ARG, regionsize_ARG, repair_ARG, snapshot_ARG,
-   test_ARG, use_policies_ARG, yes_ARG, force_ARG, zero_ARG)
+   mirrorlog_ARG, mirrors_ARG, noudevsync_ARG, regionsize_ARG, repair_ARG,
+   snapshot_ARG, test_ARG, use_policies_ARG, yes_ARG, force_ARG, zero_ARG)
 
 xx(lvcreate,
    "Create a logical volume",
@@ -137,6 +141,7 @@
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
    "\t[-m|--mirrors Mirrors [--nosync] [{--mirrorlog {disk|core}|--corelog}]]\n"
    "\t[-n|--name LogicalVolumeName]\n"
+   "\t[--noudevsync]\n"
    "\t[-p|--permission {r|rw}]\n"
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
@@ -162,6 +167,7 @@
    "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
    "\t[-n|--name LogicalVolumeName]\n"
+   "\t[--noudevsync]\n"
    "\t[-p|--permission {r|rw}]\n"
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[-t|--test]\n"
@@ -172,9 +178,10 @@
 
    addtag_ARG, alloc_ARG, autobackup_ARG, chunksize_ARG, contiguous_ARG,
    corelog_ARG, extents_ARG, major_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG,
-   name_ARG, nosync_ARG, permission_ARG, persistent_ARG, readahead_ARG,
-   regionsize_ARG, size_ARG, snapshot_ARG, stripes_ARG, stripesize_ARG,
-   test_ARG, type_ARG, virtualoriginsize_ARG, virtualsize_ARG, zero_ARG)
+   name_ARG, nosync_ARG, noudevsync_ARG, permission_ARG, persistent_ARG,
+   readahead_ARG, regionsize_ARG, size_ARG, snapshot_ARG, stripes_ARG,
+   stripesize_ARG, test_ARG, type_ARG, virtualoriginsize_ARG, virtualsize_ARG,
+   zero_ARG)
 
 xx(lvdisplay,
    "Display information about a logical volume",
@@ -231,6 +238,7 @@
    "\t -L|--size [+]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-m|--mirrors Mirrors]\n"
    "\t[-n|--nofsck]\n"
+   "\t[--noudevsync]\n"
    "\t[-r|--resizefs]\n"
    "\t[-t|--test]\n"
    "\t[--type VolumeType]\n"
@@ -239,8 +247,8 @@
    "\tLogicalVolume[Path] [ PhysicalVolumePath... ]\n",
 
    alloc_ARG, autobackup_ARG, extents_ARG, force_ARG, mirrors_ARG,
-   nofsck_ARG, resizefs_ARG, size_ARG, stripes_ARG, stripesize_ARG,
-   test_ARG, type_ARG)
+   nofsck_ARG, noudevsync_ARG, resizefs_ARG, size_ARG, stripes_ARG,
+   stripesize_ARG, test_ARG, type_ARG)
 
 xx(lvmchange,
    "With the device mapper, this is obsolete and does nothing.",
@@ -300,6 +308,7 @@
    "\t{-l|--extents [-]LogicalExtentsNumber[%{VG|LV|FREE}] |\n"
    "\t -L|--size [-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-n|--nofsck]\n"
+   "\t[--noudevsync]\n"
    "\t[-r|--resizefs]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
@@ -307,8 +316,8 @@
    "\t[--version]" "\n"
    "\tLogicalVolume[Path]\n",
 
-   autobackup_ARG, force_ARG,  extents_ARG, nofsck_ARG, resizefs_ARG,
-   size_ARG, test_ARG, yes_ARG)
+   autobackup_ARG, force_ARG,  extents_ARG, nofsck_ARG, noudevsync_ARG,
+   resizefs_ARG, size_ARG, test_ARG, yes_ARG)
 
 xx(lvremove,
    "Remove logical volume(s) from the system",
@@ -318,12 +327,13 @@
    "\t[-d|--debug]\n"
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
+   "\t[--noudevsync]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n"
    "\tLogicalVolume[Path] [LogicalVolume[Path]...]\n",
 
-   autobackup_ARG, force_ARG, test_ARG)
+   autobackup_ARG, force_ARG, noudevsync_ARG, test_ARG)
 
 xx(lvrename,
    "Rename a logical volume",
@@ -332,13 +342,14 @@
    "\t[-A|--autobackup {y|n}] " "\n"
    "\t[-d|--debug] " "\n"
    "\t[-h|-?|--help] " "\n"
+   "\t[--noudevsync]\n"
    "\t[-t|--test] " "\n"
    "\t[-v|--verbose]" "\n"
    "\t[--version] " "\n"
    "\t{ OldLogicalVolumePath NewLogicalVolumePath |" "\n"
    "\t  VolumeGroupName OldLogicalVolumeName NewLogicalVolumeName }\n",
 
-   autobackup_ARG, test_ARG)
+   autobackup_ARG, noudevsync_ARG, test_ARG)
 
 xx(lvresize,
    "Resize a logical volume",
@@ -353,6 +364,7 @@
    "\t{-l|--extents [+|-]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |\n"
    "\t -L|--size [+|-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-n|--nofsck]\n"
+   "\t[--noudevsync]\n"
    "\t[-r|--resizefs]\n"
    "\t[-t|--test]\n"
    "\t[--type VolumeType]\n"
@@ -361,8 +373,8 @@
    "\tLogicalVolume[Path] [ PhysicalVolumePath... ]\n",
 
    alloc_ARG, autobackup_ARG, extents_ARG, force_ARG, nofsck_ARG,
-   resizefs_ARG, size_ARG, stripes_ARG, stripesize_ARG, test_ARG,
-   type_ARG)
+   noudevsync_ARG, resizefs_ARG, size_ARG, stripes_ARG, stripesize_ARG,
+   test_ARG, type_ARG)
 
 xx(lvs,
    "Display information about logical volumes",
@@ -551,6 +563,7 @@
    "\t[-d|--debug]\n "
    "\t[-h|-?|--help]\n"
    "\t[-i|--interval seconds]\n"
+   "\t[--noudevsync]\n"
    "\t[-t|--test]\n "
    "\t[-v|--verbose]\n "
    "\t[--version]\n"
@@ -560,7 +573,7 @@
    "\t[DestinationPhysicalVolume[:PhysicalExtent[-PhysicalExtent]...]...]\n",
 
    abort_ARG, alloc_ARG, autobackup_ARG, background_ARG,
-   interval_ARG, name_ARG, test_ARG)
+   interval_ARG, name_ARG, noudevsync_ARG, test_ARG)
 
 xx(pvremove,
    "Remove LVM label(s) from physical volume(s)",
@@ -674,6 +687,7 @@
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoremonitoring]\n"
    "\t[--monitor {y|n}]\n"
+   "\t[--noudevsync]\n"
    "\t[--refresh]\n"
    "\t[-t|--test]" "\n"
    "\t[-u|--uuid] " "\n"
@@ -691,9 +705,9 @@
 
    addtag_ARG, alloc_ARG, allocation_ARG, autobackup_ARG, available_ARG,
    clustered_ARG, deltag_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG,
-   logicalvolume_ARG, maxphysicalvolumes_ARG, monitor_ARG, partial_ARG,
-   physicalextentsize_ARG, refresh_ARG, resizeable_ARG, resizable_ARG,
-   test_ARG, uuid_ARG)
+   logicalvolume_ARG, maxphysicalvolumes_ARG, monitor_ARG, noudevsync_ARG,
+   partial_ARG, physicalextentsize_ARG, refresh_ARG, resizeable_ARG,
+   resizable_ARG, test_ARG, uuid_ARG)
 
 xx(vgck,
    "Check the consistency of volume group(s)",
@@ -879,12 +893,13 @@
    "\t[-d|--debug]\n"
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
+   "\t[--noudevsync]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n"
    "\tVolumeGroupName [VolumeGroupName...]\n",
 
-   force_ARG, test_ARG)
+   force_ARG, noudevsync_ARG, test_ARG)
 
 xx(vgrename,
    "Rename a volume group",


