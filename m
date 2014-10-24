From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:40:28 +0000 (UTC)
Subject: master - cleanup: commands.h shorted string
Message-ID: <20141024144028.74A0E60CE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=df933c2ac92203c7352be2e7062ca8c01777cb51
Commit:        df933c2ac92203c7352be2e7062ca8c01777cb51
Parent:        f1cb267274916fcd63456a859ff433bdceefef07
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 18 10:58:23 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:31 2014 +0200

cleanup: commands.h shorted string

Replace  " "\n"  with simplier  \n"
---
 tools/commands.h |  498 +++++++++++++++++++++++++++---------------------------
 1 files changed, 249 insertions(+), 249 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 2e99fb1..524297d 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -17,13 +17,13 @@
 xx(e2fsadm,
    "Resize logical volume and ext2 filesystem",
    "e2fsadm "
-   "[-d|--debug] " "[-h|--help] " "[-n|--nofsck]" "\n"
-   "\t{[-l|--extents] [+|-]LogicalExtentsNumber |" "\n"
-   "\t [-L|--size] [+|-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}" "\n"
-   "\t[-t|--test] "  "\n"
-   "\t[-v|--verbose] "  "\n"
-   "\t[--version] " "\n"
-   "\tLogicalVolumePath" "\n",
+   "[-d|--debug] " "[-h|--help] " "[-n|--nofsck]\n"
+   "\t{[-l|--extents] [+|-]LogicalExtentsNumber |\n"
+   "\t [-L|--size] [+|-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
+   "\t[-t|--test]\n"
+   "\t[-v|--verbose]\n"
+   "\t[--version]\n"
+   "\tLogicalVolumePath\n",
 
     extents_ARG, size_ARG, nofsck_ARG, test_ARG)
 *********/
@@ -31,7 +31,7 @@ xx(e2fsadm,
 xx(devtypes,
    "Display recognised built-in block device types",
    PERMITTED_READ_ONLY,
-   "devtypes" "\n"
+   "devtypes\n"
    "\t[--aligned]\n"
    "\t[--binary]\n"
    "\t[--commandprofile ProfileName]\n"
@@ -47,7 +47,7 @@ xx(devtypes,
    "\t[--separator Separator]\n"
    "\t[--unbuffered]\n"
    "\t[--unquoted]\n"
-   "\t[--version]" "\n",
+   "\t[--version]\n",
 
    aligned_ARG, binary_ARG, nameprefixes_ARG,
    noheadings_ARG, nosuffix_ARG, options_ARG,
@@ -58,19 +58,19 @@ xx(dumpconfig,
    "Dump configuration",
    PERMITTED_READ_ONLY,
    "dumpconfig\n"
-   "\t[-f|--file filename] \n"
-   "\t[--type {current|default|diff|missing|new|profilable|profilable-command|profilable-metadata} \n"
-   "\t[--atversion version]] \n"
-   "\t[--ignoreadvanced] \n"
-   "\t[--ignoreunsupported] \n"
-   "\t[--config ConfigurationString] \n"
-   "\t[--commandprofile ProfileName] \n"
-   "\t[--profile ProfileName] \n"
-   "\t[--metadataprofile ProfileName] \n"
-   "\t[--mergedconfig] \n"
+   "\t[-f|--file filename]\n"
+   "\t[--type {current|default|diff|missing|new|profilable|profilable-command|profilable-metadata}\n"
+   "\t[--atversion version]]\n"
+   "\t[--ignoreadvanced]\n"
+   "\t[--ignoreunsupported]\n"
+   "\t[--config ConfigurationString]\n"
+   "\t[--commandprofile ProfileName]\n"
+   "\t[--profile ProfileName]\n"
+   "\t[--metadataprofile ProfileName]\n"
+   "\t[--mergedconfig]\n"
    "\t[--validate]\n"
-   "\t[--withcomments] \n"
-   "\t[--withversions] \n"
+   "\t[--withcomments]\n"
+   "\t[--withversions]\n"
    "\t[ConfigurationNode...]\n",
    atversion_ARG, configtype_ARG, file_ARG, ignoreadvanced_ARG,
    ignoreunsupported_ARG, mergedconfig_ARG, metadataprofile_ARG,
@@ -84,7 +84,7 @@ xx(formats,
 xx(help,
    "Display help for commands",
    PERMITTED_READ_ONLY,
-   "help <command>" "\n")
+   "help <command>\n")
 
 /*********
 xx(lvactivate,
@@ -117,13 +117,13 @@ xx(lvchange,
    "\t[--ignoremonitoring]\n"
    "\t[--ignoreskippedcluster]\n"
    "\t[-k|--setactivationskip {y|n}]\n"
-   "\t[-K|--ignoreactivationskip] \n"
+   "\t[-K|--ignoreactivationskip]\n"
    "\t[--monitor {y|n}]\n"
    "\t[--poll {y|n}]\n"
    "\t[--noudevsync]\n"
    "\t[-M|--persistent y|n] [--major major] [--minor minor]\n"
    "\t[--metadataprofile ProfileName]\n"
-   "\t[-P|--partial] " "\n"
+   "\t[-P|--partial]\n"
    "\t[-p|--permission r|rw]\n"
    "\t[--[raid]minrecoveryrate Rate]\n"
    "\t[--[raid]maxrecoveryrate Rate]\n"
@@ -253,15 +253,15 @@ xx(lvconvert,
 xx(lvcreate,
    "Create a logical volume",
    0,
-   "lvcreate " "\n"
+   "lvcreate\n"
    "\t[-A|--autobackup {y|n}]\n"
    "\t[-a|--activate [a|e|l]{y|n}]\n"
    "\t[--addtag Tag]\n"
    "\t[--alloc AllocationPolicy]\n"
    "\t[-H|--cache\n"
-   "\t  [-c|--chunksize ChunkSize]\n"
    "\t  [--cachemode {writeback|writethrough}]\n"
    "\t[--cachepool CachePoolLogicalVolume{Name|Path}]\n"
+   "\t[-c|--chunksize ChunkSize]\n"
    "\t[-C|--contiguous {y|n}]\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
@@ -270,7 +270,7 @@ xx(lvcreate,
    "\t[--monitor {y|n}]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
    "\t[-k|--setactivationskip {y|n}]\n"
-   "\t[-K|--ignoreactivationskip] \n"
+   "\t[-K|--ignoreactivationskip]\n"
    "\t{-l|--extents LogicalExtentsNumber[%{VG|PVS|FREE}] |\n"
    "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
@@ -279,15 +279,14 @@ xx(lvcreate,
    "\t[-n|--name LogicalVolumeName]\n"
    "\t[--noudevsync]\n"
    "\t[-p|--permission {r|rw}]\n"
+   "\t[--poolmetadatasize MetadataSize[bBsSkKmMgG]]\n"
+   "\t[--poolmetadataspare {y|n}]]\n"
    "\t[--[raid]minrecoveryrate Rate]\n"
    "\t[--[raid]maxrecoveryrate Rate]\n"
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
    "\t[-T|--thin\n"
-   "\t  [-c|--chunksize ChunkSize]\n"
    "\t  [--discards {ignore|nopassdown|passdown}]\n"
-   "\t  [--poolmetadatasize MetadataSize[bBsSkKmMgG]]\n"
-   "\t  [--poolmetadataspare {y|n}]]\n"
    "\t[--thinpool ThinPoolLogicalVolume{Name|Path}]\n"
    "\t[-t|--test]\n"
    "\t[--type VolumeType]\n"
@@ -297,15 +296,16 @@ xx(lvcreate,
    "\t[--version]\n"
    "\tVolumeGroupName [PhysicalVolumePath...]\n\n"
 
-   "lvcreate \n"
+   "lvcreate\n"
    "\t{ {-s|--snapshot} OriginalLogicalVolume[Path] |\n"
    "\t  [-s|--snapshot] VolumeGroupName[Path] -V|--virtualsize VirtualSize}\n"
-   "\t  {-T|--thin} VolumeGroupName[Path][/PoolLogicalVolume] \n"
+   "\t  {-H|--cache} VolumeGroupName[Path][/OriginalLogicalVolume]\n"
+   "\t  {-T|--thin} VolumeGroupName[Path][/PoolLogicalVolume]\n"
    "\t              -V|--virtualsize VirtualSize}\n"
-   "\t[-c|--chunksize]\n"
    "\t[-A|--autobackup {y|n}]\n"
    "\t[--addtag Tag]\n"
    "\t[--alloc AllocationPolicy]\n"
+   "\t[-c|--chunksize]\n"
    "\t[-C|--contiguous {y|n}]\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
@@ -315,7 +315,7 @@ xx(lvcreate,
    "\t[--monitor {y|n}]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
    "\t[-k|--setactivationskip {y|n}]\n"
-   "\t[-K|--ignoreactivationskip] \n"
+   "\t[-K|--ignoreactivationskip]\n"
    "\t{-l|--extents LogicalExtentsNumber[%{VG|FREE|ORIGIN}] |\n"
    "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[--poolmetadatasize MetadataVolumeSize[bBsSkKmMgG]]\n"
@@ -326,10 +326,10 @@ xx(lvcreate,
    "\t[-p|--permission {r|rw}]\n"
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[-t|--test]\n"
-   "\t[--thinpool ThinPoolLogicalVolume[Path]]\n"
+   "\t[{--thinpool ThinPoolLogicalVolume[Path] |\n"
+   "\t  --cachepool CachePoolLogicalVolume[Path]}]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
-
    "\t[PhysicalVolumePath...]\n\n",
 
    addtag_ARG, alloc_ARG, autobackup_ARG, activate_ARG, available_ARG,
@@ -357,11 +357,11 @@ xx(lvdisplay,
    "\t[--ignoreskippedcluster]\n"
    "\t[-m|--maps]\n"
    "\t[--nosuffix]\n"
-   "\t[-P|--partial] " "\n"
+   "\t[-P|--partial]\n"
    "\t[--readonly]\n"
    "\t[--units hHbBsSkKmMgGtTpPeE]\n"
    "\t[-v|--verbose]\n"
-   "\t[--version]" "\n"
+   "\t[--version]\n"
    "\t[LogicalVolume[Path] [LogicalVolume[Path]...]]\n"
    "\n"
    "lvdisplay --columns|-C\n"
@@ -377,17 +377,17 @@ xx(lvdisplay,
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-S|--select Selection]\n"
-   "\t[-P|--partial] " "\n"
+   "\t[-P|--partial]\n"
    "\t[--readonly]\n"
    "\t[--segments]\n"
    "\t[--separator Separator]\n"
    "\t[--unbuffered]\n"
    "\t[--units hHbBsSkKmMgGtTpPeE]\n"
    "\t[-v|--verbose]\n"
-   "\t[--version]" "\n"
+   "\t[--version]\n"
    "\t[LogicalVolume[Path] [LogicalVolume[Path]...]]\n",
 
-    aligned_ARG, all_ARG, colon_ARG, columns_ARG, ignorelockingfailure_ARG, 
+    aligned_ARG, all_ARG, colon_ARG, columns_ARG, ignorelockingfailure_ARG,
     ignoreskippedcluster_ARG, maps_ARG, noheadings_ARG, nosuffix_ARG,
     options_ARG, sort_ARG, partial_ARG, readonly_ARG, segments_ARG,
     select_ARG, separator_ARG, unbuffered_ARG, units_ARG)
@@ -415,7 +415,7 @@ xx(lvextend,
    "\t[-t|--test]\n"
    "\t[--type VolumeType]\n"
    "\t[-v|--verbose]\n"
-   "\t[--version]" "\n"
+   "\t[--version]\n"
    "\tLogicalVolume[Path] [ PhysicalVolumePath... ]\n",
 
    alloc_ARG, autobackup_ARG, extents_ARG, force_ARG, mirrors_ARG,
@@ -432,7 +432,7 @@ xx(lvmchange,
    "\t[-h|--help]\n"
    "\t[-R|--reset]\n"
    "\t[-v|--verbose]\n"
-   "\t[--version]" "\n",
+   "\t[--version]\n",
 
     reset_ARG)
 
@@ -445,7 +445,7 @@ xx(lvmdiskscan,
    "\t[-h|--help]\n"
    "\t[-l|--lvmpartition]\n"
    "\t[--readonly]\n"
-   "\t[--version]" "\n",
+   "\t[--version]\n",
 
    lvmpartition_ARG, readonly_ARG)
 
@@ -457,8 +457,8 @@ xx(lvmsadc,
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[-v|--verbose]\n"
-   "\t[--version]" "\n"
-   "\t[LogFilePath]\n" )
+   "\t[--version]\n"
+   "\t[LogFilePath]\n")
 
 xx(lvmsar,
    "Create activity report",
@@ -470,7 +470,7 @@ xx(lvmsar,
    "\t[-h|--help]\n"
    "\t[-s|--stdin]\n"
    "\t[-v|--verbose]\n"
-   "\t[--version]" "\n"
+   "\t[--version]\n"
    "\tLogFilePath\n",
 
    full_ARG, stdin_ARG)
@@ -491,7 +491,7 @@ xx(lvreduce,
    "\t[-r|--resizefs]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
-   "\t[--version]" "\n"
+   "\t[--version]\n"
    "\t[-y|--yes]\n"
    "\tLogicalVolume[Path]\n",
 
@@ -510,7 +510,7 @@ xx(lvremove,
    "\t[--noudevsync]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
-   "\t[--version]" "\n"
+   "\t[--version]\n"
    "\tLogicalVolume[Path] [LogicalVolume[Path]...]\n",
 
    autobackup_ARG, force_ARG, noudevsync_ARG, test_ARG)
@@ -519,15 +519,15 @@ xx(lvrename,
    "Rename a logical volume",
    0,
    "lvrename\n"
-   "\t[-A|--autobackup {y|n}] " "\n"
+   "\t[-A|--autobackup {y|n}]\n"
    "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug] " "\n"
-   "\t[-h|-?|--help] " "\n"
+   "\t[-d|--debug]\n"
+   "\t[-h|-?|--help]\n"
    "\t[--noudevsync]\n"
-   "\t[-t|--test] " "\n"
-   "\t[-v|--verbose]" "\n"
-   "\t[--version] " "\n"
-   "\t{ OldLogicalVolumePath NewLogicalVolumePath |" "\n"
+   "\t[-t|--test]\n"
+   "\t[-v|--verbose]\n"
+   "\t[--version]\n"
+   "\t{ OldLogicalVolumePath NewLogicalVolumePath |\n"
    "\t  VolumeGroupName OldLogicalVolumeName NewLogicalVolumeName }\n",
 
    autobackup_ARG, noudevsync_ARG, test_ARG)
@@ -552,7 +552,7 @@ xx(lvresize,
    "\t[-t|--test]\n"
    "\t[--type VolumeType]\n"
    "\t[-v|--verbose]\n"
-   "\t[--version]" "\n"
+   "\t[--version]\n"
    "\tLogicalVolume[Path] [ PhysicalVolumePath... ]\n",
 
    alloc_ARG, autobackup_ARG, extents_ARG, force_ARG, nofsck_ARG,
@@ -563,7 +563,7 @@ xx(lvresize,
 xx(lvs,
    "Display information about logical volumes",
    PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT,
-   "lvs" "\n"
+   "lvs\n"
    "\t[-a|--all]\n"
    "\t[--aligned]\n"
    "\t[--binary]\n"
@@ -577,7 +577,7 @@ xx(lvs,
    "\t[--nosuffix]\n"
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
-   "\t[-P|--partial] " "\n"
+   "\t[-P|--partial]\n"
    "\t[--readonly]\n"
    "\t[--rows]\n"
    "\t[--segments]\n"
@@ -588,7 +588,7 @@ xx(lvs,
    "\t[--units hHbBsSkKmMgGtTpPeE]\n"
    "\t[--unquoted]\n"
    "\t[-v|--verbose]\n"
-   "\t[--version]" "\n"
+   "\t[--version]\n"
    "\t[LogicalVolume[Path] [LogicalVolume[Path]...]]\n",
 
    aligned_ARG, all_ARG, binary_ARG, ignorelockingfailure_ARG,
@@ -600,17 +600,17 @@ xx(lvs,
 xx(lvscan,
    "List all logical volumes in all volume groups",
    PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT,
-   "lvscan " "\n"
+   "lvscan\n"
    "\t[-a|--all]\n"
-   "\t[-b|--blockdevice] " "\n"
+   "\t[-b|--blockdevice]\n"
    "\t[--cache]\n"
    "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug] " "\n"
-   "\t[-h|-?|--help] " "\n"
+   "\t[-d|--debug]\n"
+   "\t[-h|-?|--help]\n"
    "\t[--ignorelockingfailure]\n"
-   "\t[-P|--partial] " "\n"
+   "\t[-P|--partial]\n"
    "\t[--readonly]\n"
-   "\t[-v|--verbose] " "\n"
+   "\t[-v|--verbose]\n"
    "\t[--version]\n",
 
    all_ARG, blockdevice_ARG, ignorelockingfailure_ARG, partial_ARG,
@@ -633,7 +633,7 @@ xx(pvchange,
    "\t[-v|--verbose]\n"
    "\t[--addtag Tag]\n"
    "\t[--deltag Tag]\n"
-   "\t[--version]" "\n"
+   "\t[--version]\n"
    "\t[PhysicalVolumePath...]\n",
 
    all_ARG, allocatable_ARG, allocation_ARG, autobackup_ARG, deltag_ARG,
@@ -642,14 +642,14 @@ xx(pvchange,
 xx(pvresize,
    "Resize physical volume(s)",
    0,
-   "pvresize " "\n"
+   "pvresize\n"
    "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]" "\n"
-   "\t[-h|-?|--help] " "\n"
-   "\t[--setphysicalvolumesize PhysicalVolumeSize[bBsSkKmMgGtTpPeE]" "\n"
-   "\t[-t|--test] " "\n"
-   "\t[-v|--verbose] " "\n"
-   "\t[--version] " "\n"
+   "\t[-d|--debug]\n"
+   "\t[-h|-?|--help]\n"
+   "\t[--setphysicalvolumesize PhysicalVolumeSize[bBsSkKmMgGtTpPeE]\n"
+   "\t[-t|--test]\n"
+   "\t[-v|--verbose]\n"
+   "\t[--version]\n"
    "\tPhysicalVolume [PhysicalVolume...]\n",
 
    physicalvolumesize_ARG, test_ARG)
@@ -661,9 +661,9 @@ xx(pvck,
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
-   "\t[--labelsector sector] " "\n"
+   "\t[--labelsector sector]\n"
    "\t[-v|--verbose]\n"
-   "\t[--version]" "\n"
+   "\t[--version]\n"
    "\tPhysicalVolume [PhysicalVolume...]\n",
 
    labelsector_ARG)
@@ -671,27 +671,27 @@ xx(pvck,
 xx(pvcreate,
    "Initialize physical volume(s) for use by LVM",
    0,
-   "pvcreate " "\n"
+   "pvcreate\n"
    "\t[--norestorefile]\n"
    "\t[--restorefile file]\n"
    "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]" "\n"
-   "\t[-f[f]|--force [--force]] " "\n"
-   "\t[-h|-?|--help] " "\n"
-   "\t[--labelsector sector] " "\n"
-   "\t[-M|--metadatatype 1|2]" "\n"
-   "\t[--pvmetadatacopies #copies]" "\n"
-   "\t[--bootloaderareasize BootLoaderAreaSize[bBsSkKmMgGtTpPeE]]" "\n"
-   "\t[--metadatasize MetadataSize[bBsSkKmMgGtTpPeE]]" "\n"
-   "\t[--dataalignment Alignment[bBsSkKmMgGtTpPeE]]" "\n"
-   "\t[--dataalignmentoffset AlignmentOffset[bBsSkKmMgGtTpPeE]]" "\n"
-   "\t[--setphysicalvolumesize PhysicalVolumeSize[bBsSkKmMgGtTpPeE]" "\n"
-   "\t[-t|--test] " "\n"
-   "\t[-u|--uuid uuid] " "\n"
-   "\t[-v|--verbose] " "\n"
-   "\t[-y|--yes]" "\n"
+   "\t[-d|--debug]\n"
+   "\t[-f[f]|--force [--force]]\n"
+   "\t[-h|-?|--help]\n"
+   "\t[--labelsector sector]\n"
+   "\t[-M|--metadatatype 1|2]\n"
+   "\t[--pvmetadatacopies #copies]\n"
+   "\t[--bootloaderareasize BootLoaderAreaSize[bBsSkKmMgGtTpPeE]]\n"
+   "\t[--metadatasize MetadataSize[bBsSkKmMgGtTpPeE]]\n"
+   "\t[--dataalignment Alignment[bBsSkKmMgGtTpPeE]]\n"
+   "\t[--dataalignmentoffset AlignmentOffset[bBsSkKmMgGtTpPeE]]\n"
+   "\t[--setphysicalvolumesize PhysicalVolumeSize[bBsSkKmMgGtTpPeE]\n"
+   "\t[-t|--test]\n"
+   "\t[-u|--uuid uuid]\n"
+   "\t[-v|--verbose]\n"
+   "\t[-y|--yes]\n"
    "\t[-Z|--zero {y|n}]\n"
-   "\t[--version] " "\n"
+   "\t[--version]\n"
    "\tPhysicalVolume [PhysicalVolume...]\n",
 
    dataalignment_ARG, dataalignmentoffset_ARG, bootloaderareasize_ARG,
@@ -703,18 +703,18 @@ xx(pvcreate,
 xx(pvdata,
    "Display the on-disk metadata for physical volume(s)",
    0,
-   "pvdata " "\n"
-   "\t[-a|--all] " "\n"
+   "pvdata\n"
+   "\t[-a|--all]\n"
    "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug] " "\n"
-   "\t[-E|--physicalextent] " "\n"
-   "\t[-h|-?|--help]" "\n"
-   "\t[-L|--logicalvolume] " "\n"
-   "\t[-P[P]|--physicalvolume [--physicalvolume]]" "\n"
-   "\t[-U|--uuidlist] " "\n"
-   "\t[-v[v]|--verbose [--verbose]] " "\n"
-   "\t[-V|--volumegroup]" "\n"
-   "\t[--version] " "\n"
+   "\t[-d|--debug]\n"
+   "\t[-E|--physicalextent]\n"
+   "\t[-h|-?|--help]\n"
+   "\t[-L|--logicalvolume]\n"
+   "\t[-P[P]|--physicalvolume [--physicalvolume]]\n"
+   "\t[-U|--uuidlist]\n"
+   "\t[-v[v]|--verbose [--verbose]]\n"
+   "\t[-V|--volumegroup]\n"
+   "\t[--version]\n"
    "\tPhysicalVolume [PhysicalVolume...]\n",
 
    all_ARG,  logicalextent_ARG, physicalextent_ARG,
@@ -736,7 +736,7 @@ xx(pvdisplay,
    "\t[-s|--short]\n"
    "\t[--units hHbBsSkKmMgGtTpPeE]\n"
    "\t[-v|--verbose]\n"
-   "\t[--version]" "\n"
+   "\t[--version]\n"
    "\t[PhysicalVolumePath [PhysicalVolumePath...]]\n"
    "\n"
    "pvdisplay --columns|-C\n"
@@ -757,7 +757,7 @@ xx(pvdisplay,
    "\t[--unbuffered]\n"
    "\t[--units hHbBsSkKmMgGtTpPeE]\n"
    "\t[-v|--verbose]\n"
-   "\t[--version]" "\n"
+   "\t[--version]\n"
    "\t[PhysicalVolumePath [PhysicalVolumePath...]]\n",
 
    aligned_ARG, all_ARG, colon_ARG, columns_ARG, ignorelockingfailure_ARG,
@@ -768,7 +768,7 @@ xx(pvdisplay,
 xx(pvmove,
    "Move extents from one physical volume to another",
    ALL_VGS_IS_DEFAULT,	/* For polldaemon to find pvmoves in-progress using process_each_vg. */
-   "pvmove " "\n"
+   "pvmove\n"
    "\t[--abort]\n"
    "\t[--alloc AllocationPolicy]\n"
    "\t[--atomic]\n"
@@ -793,15 +793,15 @@ xx(pvmove,
 xx(pvremove,
    "Remove LVM label(s) from physical volume(s)",
    0,
-   "pvremove " "\n"
+   "pvremove\n"
    "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]" "\n"
-   "\t[-f[f]|--force [--force]] " "\n"
-   "\t[-h|-?|--help] " "\n"
-   "\t[-t|--test] " "\n"
-   "\t[-v|--verbose] " "\n"
-   "\t[--version] " "\n"
-   "\t[-y|--yes]" "\n"
+   "\t[-d|--debug]\n"
+   "\t[-f[f]|--force [--force]]\n"
+   "\t[-h|-?|--help]\n"
+   "\t[-t|--test]\n"
+   "\t[-v|--verbose]\n"
+   "\t[--version]\n"
+   "\t[-y|--yes]\n"
    "\tPhysicalVolume [PhysicalVolume...]\n",
 
    force_ARG, test_ARG)
@@ -809,13 +809,13 @@ xx(pvremove,
 xx(pvs,
    "Display information about physical volumes",
    CACHE_VGMETADATA | PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_ALL_DEVS,
-   "pvs" "\n"
+   "pvs\n"
    "\t[-a|--all]\n"
    "\t[--aligned]\n"
    "\t[--binary]\n"
    "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]" "\n"
-   "\t[-h|-?|--help] " "\n"
+   "\t[-d|--debug]\n"
+   "\t[-h|-?|--help]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoreskippedcluster]\n"
    "\t[--nameprefixes]\n"
@@ -823,7 +823,7 @@ xx(pvs,
    "\t[--nosuffix]\n"
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
-   "\t[-P|--partial] " "\n"
+   "\t[-P|--partial]\n"
    "\t[--readonly]\n"
    "\t[--rows]\n"
    "\t[--segments]\n"
@@ -846,19 +846,19 @@ xx(pvs,
 xx(pvscan,
    "List all physical volumes",
    PERMITTED_READ_ONLY,
-   "pvscan " "\n"
+   "pvscan\n"
    "\t[-b|--background]\n"
    "\t[--cache [-a|--activate ay] [ DevicePath | --major major --minor minor]...]\n"
    "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug] " "\n"
-   "\t{-e|--exported | -n|--novolumegroup} " "\n"
-   "\t[-h|-?|--help]" "\n"
+   "\t[-d|--debug]\n"
+   "\t{-e|--exported | -n|--novolumegroup}\n"
+   "\t[-h|-?|--help]\n"
    "\t[--ignorelockingfailure]\n"
-   "\t[-P|--partial] " "\n"
+   "\t[-P|--partial]\n"
    "\t[--readonly]\n"
-   "\t[-s|--short] " "\n"
-   "\t[-u|--uuid] " "\n"
-   "\t[-v|--verbose] " "\n"
+   "\t[-s|--short]\n"
+   "\t[-u|--uuid]\n"
+   "\t[-v|--verbose]\n"
    "\t[--version]\n",
 
    activate_ARG, available_ARG, backgroundfork_ARG, cache_long_ARG,
@@ -878,16 +878,16 @@ xx(tags,
 xx(vgcfgbackup,
    "Backup volume group configuration(s)",
    PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT,
-   "vgcfgbackup " "\n"
+   "vgcfgbackup\n"
    "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug] " "\n"
-   "\t[-f|--file filename] " "\n"
-   "\t[-h|-?|--help] " "\n"
+   "\t[-d|--debug]\n"
+   "\t[-f|--file filename]\n"
+   "\t[-h|-?|--help]\n"
    "\t[--ignorelockingfailure]\n"
-   "\t[-P|--partial] " "\n"
+   "\t[-P|--partial]\n"
    "\t[--readonly]\n"
-   "\t[-v|--verbose]" "\n"
-   "\t[--version] " "\n"
+   "\t[-v|--verbose]\n"
+   "\t[--version]\n"
    "\t[VolumeGroupName...]\n",
 
    file_ARG, ignorelockingfailure_ARG, partial_ARG, readonly_ARG)
@@ -895,17 +895,17 @@ xx(vgcfgbackup,
 xx(vgcfgrestore,
    "Restore volume group configuration",
    0,
-   "vgcfgrestore " "\n"
+   "vgcfgrestore\n"
    "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug] " "\n"
-   "\t[-f|--file filename] " "\n"
+   "\t[-d|--debug]\n"
+   "\t[-f|--file filename]\n"
    "\t[--force]\n"
-   "\t[-l[l]|--list [--list]]" "\n"
-   "\t[-M|--metadatatype 1|2]" "\n"
-   "\t[-h|--help]" "\n"
-   "\t[-t|--test] " "\n"
-   "\t[-v|--verbose]" "\n"
-   "\t[--version] " "\n"
+   "\t[-l[l]|--list [--list]]\n"
+   "\t[-M|--metadatatype 1|2]\n"
+   "\t[-h|--help]\n"
+   "\t[-t|--test]\n"
+   "\t[-v|--verbose]\n"
+   "\t[--version]\n"
    "\tVolumeGroupName",
 
    file_ARG, force_long_ARG, list_ARG, metadatatype_ARG, test_ARG)
@@ -913,36 +913,36 @@ xx(vgcfgrestore,
 xx(vgchange,
    "Change volume group attributes",
    CACHE_VGMETADATA | PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT,
-   "vgchange" "\n"
-   "\t[-A|--autobackup {y|n}] " "\n"
-   "\t[--alloc AllocationPolicy] " "\n"
-   "\t[-P|--partial] " "\n"
+   "vgchange\n"
+   "\t[-A|--autobackup {y|n}]\n"
+   "\t[--alloc AllocationPolicy]\n"
+   "\t[-P|--partial]\n"
    "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug] " "\n"
-   "\t[--detachprofile] " "\n"
-   "\t[-h|--help] " "\n"
+   "\t[-d|--debug]\n"
+   "\t[--detachprofile]\n"
+   "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoremonitoring]\n"
    "\t[--ignoreskippedcluster]\n"
-   "\t[-K|--ignoreactivationskip] \n"
+   "\t[-K|--ignoreactivationskip]\n"
    "\t[--metadataprofile ProfileName]\n"
    "\t[--monitor {y|n}]\n"
-   "\t[--[vg]metadatacopies #copies] " "\n"
+   "\t[--[vg]metadatacopies #copies]\n"
    "\t[--poll {y|n}]\n"
    "\t[--noudevsync]\n"
    "\t[--refresh]\n"
    "\t[--sysinit]\n"
-   "\t[-t|--test]" "\n"
-   "\t[-u|--uuid] " "\n"
-   "\t[-v|--verbose] " "\n"
-   "\t[--version]" "\n"
-   "\t{-a|--activate [a|e|l]{y|n}  |" "\n"
-   "\t[--activationmode {complete|degraded|partial}]" "\n"
-   "\t -c|--clustered {y|n} |" "\n"
-   "\t -x|--resizeable {y|n} |" "\n"
-   "\t -l|--logicalvolume MaxLogicalVolumes |" "\n"
-   "\t -p|--maxphysicalvolumes MaxPhysicalVolumes |" "\n"
-   "\t -s|--physicalextentsize PhysicalExtentSize[bBsSkKmMgGtTpPeE] |" "\n"
+   "\t[-t|--test]\n"
+   "\t[-u|--uuid]\n"
+   "\t[-v|--verbose]\n"
+   "\t[--version]\n"
+   "\t{-a|--activate [a|e|l]{y|n}  |\n"
+   "\t[--activationmode {complete|degraded|partial}]\n"
+   "\t -c|--clustered {y|n} |\n"
+   "\t -x|--resizeable {y|n} |\n"
+   "\t -l|--logicalvolume MaxLogicalVolumes |\n"
+   "\t -p|--maxphysicalvolumes MaxPhysicalVolumes |\n"
+   "\t -s|--physicalextentsize PhysicalExtentSize[bBsSkKmMgGtTpPeE] |\n"
    "\t --addtag Tag |\n"
    "\t --deltag Tag}\n"
    "\t[VolumeGroupName...]\n",
@@ -964,52 +964,52 @@ xx(vgck,
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[-v|--verbose]\n"
-   "\t[--version]" "\n"
-   "\t[VolumeGroupName...]\n" )
+   "\t[--version]\n"
+   "\t[VolumeGroupName...]\n")
 
 xx(vgconvert,
    "Change volume group metadata format",
    0,
-   "vgconvert  " "\n"
+   "vgconvert\n"
    "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]" "\n"
-   "\t[-h|--help] " "\n"
-   "\t[--labelsector sector] " "\n"
-   "\t[-M|--metadatatype 1|2]" "\n"
-   "\t[--pvmetadatacopies #copies]" "\n"
-   "\t[--metadatasize MetadataSize[bBsSkKmMgGtTpPeE]]" "\n"
-   "\t[--bootloaderareasize BootLoaderAreaSize[bBsSkKmMgGtTpPeE]]" "\n"
-   "\t[-t|--test] " "\n"
-   "\t[-v|--verbose] " "\n"
-   "\t[--version] " "\n"
+   "\t[-d|--debug]\n"
+   "\t[-h|--help]\n"
+   "\t[--labelsector sector]\n"
+   "\t[-M|--metadatatype 1|2]\n"
+   "\t[--pvmetadatacopies #copies]\n"
+   "\t[--metadatasize MetadataSize[bBsSkKmMgGtTpPeE]]\n"
+   "\t[--bootloaderareasize BootLoaderAreaSize[bBsSkKmMgGtTpPeE]]\n"
+   "\t[-t|--test]\n"
+   "\t[-v|--verbose]\n"
+   "\t[--version]\n"
    "\tVolumeGroupName [VolumeGroupName...]\n",
 
    force_ARG, test_ARG, labelsector_ARG, bootloaderareasize_ARG,
    metadatatype_ARG, metadatacopies_ARG, pvmetadatacopies_ARG,
-   metadatasize_ARG )
+   metadatasize_ARG)
 
 xx(vgcreate,
    "Create a volume group",
    0,
-   "vgcreate" "\n"
-   "\t[-A|--autobackup {y|n}] " "\n"
-   "\t[--addtag Tag] " "\n"
-   "\t[--alloc AllocationPolicy] " "\n"
-   "\t[-c|--clustered {y|n}] " "\n"
+   "vgcreate\n"
+   "\t[-A|--autobackup {y|n}]\n"
+   "\t[--addtag Tag]\n"
+   "\t[--alloc AllocationPolicy]\n"
+   "\t[-c|--clustered {y|n}]\n"
    "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]" "\n"
-   "\t[-h|--help]" "\n"
-   "\t[-l|--maxlogicalvolumes MaxLogicalVolumes]" "\n"
+   "\t[-d|--debug]\n"
+   "\t[-h|--help]\n"
+   "\t[-l|--maxlogicalvolumes MaxLogicalVolumes]\n"
    "\t[--metadataprofile ProfileName]\n"
-   "\t[-M|--metadatatype 1|2] " "\n"
-   "\t[--[vg]metadatacopies #copies] " "\n"
-   "\t[-p|--maxphysicalvolumes MaxPhysicalVolumes] " "\n"
-   "\t[-s|--physicalextentsize PhysicalExtentSize[bBsSkKmMgGtTpPeE]] " "\n"
-   "\t[-t|--test] " "\n"
-   "\t[-v|--verbose]" "\n"
-   "\t[--version] " "\n"
-   "\t[-y|--yes]" "\n"
-   "\t[ PHYSICAL DEVICE OPTIONS ] " "\n"
+   "\t[-M|--metadatatype 1|2]\n"
+   "\t[--[vg]metadatacopies #copies]\n"
+   "\t[-p|--maxphysicalvolumes MaxPhysicalVolumes]\n"
+   "\t[-s|--physicalextentsize PhysicalExtentSize[bBsSkKmMgGtTpPeE]]\n"
+   "\t[-t|--test]\n"
+   "\t[-v|--verbose]\n"
+   "\t[--version]\n"
+   "\t[-y|--yes]\n"
+   "\t[ PHYSICAL DEVICE OPTIONS ]\n"
    "\tVolumeGroupName PhysicalDevicePath [PhysicalDevicePath...]\n",
 
    addtag_ARG, alloc_ARG, autobackup_ARG, clustered_ARG, maxlogicalvolumes_ARG,
@@ -1021,40 +1021,40 @@ xx(vgcreate,
 xx(vgdisplay,
    "Display volume group information",
    PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT,
-   "vgdisplay " "\n"
-   "\t[-A|--activevolumegroups]" "\n"
-   "\t[-c|--colon | -s|--short | -v|--verbose]" "\n"
+   "vgdisplay\n"
+   "\t[-A|--activevolumegroups]\n"
+   "\t[-c|--colon | -s|--short | -v|--verbose]\n"
    "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug] " "\n"
-   "\t[-h|--help] " "\n"
-   "\t[--ignorelockingfailure]" "\n"
+   "\t[-d|--debug]\n"
+   "\t[-h|--help]\n"
+   "\t[--ignorelockingfailure]\n"
    "\t[--ignoreskippedcluster]\n"
    "\t[--nosuffix]\n"
-   "\t[-P|--partial] " "\n"
+   "\t[-P|--partial]\n"
    "\t[--readonly]\n"
    "\t[--units hHbBsSkKmMgGtTpPeE]\n"
-   "\t[--version]" "\n"
+   "\t[--version]\n"
    "\t[VolumeGroupName [VolumeGroupName...]]\n"
    "\n"
    "vgdisplay --columns|-C\n"
    "\t[--aligned]\n"
    "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug] " "\n"
-   "\t[-h|--help] " "\n"
-   "\t[--ignorelockingfailure]" "\n"
+   "\t[-d|--debug]\n"
+   "\t[-h|--help]\n"
+   "\t[--ignorelockingfailure]\n"
    "\t[--ignoreskippedcluster]\n"
    "\t[--noheadings]\n"
    "\t[--nosuffix]\n"
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
-   "\t[-P|--partial] " "\n"
+   "\t[-P|--partial]\n"
    "\t[-S|--select Selection]\n"
    "\t[--readonly]\n"
    "\t[--separator Separator]\n"
    "\t[--unbuffered]\n"
    "\t[--units hHbBsSkKmMgGtTpPeE]\n"
-   "\t[--verbose]" "\n"
-   "\t[--version]" "\n"
+   "\t[--verbose]\n"
+   "\t[--version]\n"
    "\t[VolumeGroupName [VolumeGroupName...]]\n",
 
    activevolumegroups_ARG, aligned_ARG, colon_ARG, columns_ARG,
@@ -1065,13 +1065,13 @@ xx(vgdisplay,
 xx(vgexport,
    "Unregister volume group(s) from the system",
    ALL_VGS_IS_DEFAULT,
-   "vgexport " "\n"
-   "\t[-a|--all] " "\n"
+   "vgexport\n"
+   "\t[-a|--all]\n"
    "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug] " "\n"
-   "\t[-h|--help]" "\n"
-   "\t[-v|--verbose] " "\n"
-   "\t[--version] " "\n"
+   "\t[-d|--debug]\n"
+   "\t[-h|--help]\n"
+   "\t[-v|--verbose]\n"
+   "\t[--version]\n"
    "\tVolumeGroupName [VolumeGroupName...]\n",
 
    all_ARG, test_ARG)
@@ -1088,9 +1088,9 @@ xx(vgextend,
    "\t[-h|--help]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
-   "\t[--version]" "\n"
+   "\t[--version]\n"
    "\t[-y|--yes]\n"
-   "\t[ PHYSICAL DEVICE OPTIONS ] " "\n"
+   "\t[ PHYSICAL DEVICE OPTIONS ]\n"
    "\tVolumeGroupName PhysicalDevicePath [PhysicalDevicePath...]\n",
 
    autobackup_ARG, test_ARG,
@@ -1102,16 +1102,16 @@ xx(vgextend,
 xx(vgimport,
    "Register exported volume group with system",
    ALL_VGS_IS_DEFAULT,
-   "vgimport " "\n"
+   "vgimport\n"
    "\t[-a|--all]\n"
    "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug] " "\n"
-   "\t[-f|--force] " "\n"
-   "\t[-h|--help] " "\n"
-   "\t[-t|--test] " "\n"
-   "\t[-v|--verbose]" "\n"
-   "\t[--version]" "\n"
-   "\tVolumeGroupName..." "\n",
+   "\t[-d|--debug]\n"
+   "\t[-f|--force]\n"
+   "\t[-h|--help]\n"
+   "\t[-t|--test]\n"
+   "\t[-v|--verbose]\n"
+   "\t[--version]\n"
+   "\tVolumeGroupName...\n",
 
    all_ARG, force_ARG, test_ARG)
 
@@ -1126,7 +1126,7 @@ xx(vgmerge,
    "\t[-l|--list]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
-   "\t[--version]" "\n"
+   "\t[--version]\n"
    "\tDestinationVolumeGroupName SourceVolumeGroupName\n",
 
    autobackup_ARG, list_ARG, test_ARG)
@@ -1141,7 +1141,7 @@ xx(vgmknodes,
    "\t[--ignorelockingfailure]\n"
    "\t[--refresh]\n"
    "\t[-v|--verbose]\n"
-   "\t[--version]" "\n"
+   "\t[--version]\n"
    "\t[VolumeGroupName...]\n",
 
    ignorelockingfailure_ARG, refresh_ARG)
@@ -1160,7 +1160,7 @@ xx(vgreduce,
    "\t[-f|--force]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
-   "\t[--version]" "\n"
+   "\t[--version]\n"
    "\tVolumeGroupName\n"
    "\t[PhysicalVolumePath...]\n",
 
@@ -1178,7 +1178,7 @@ xx(vgremove,
    "\t[--noudevsync]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
-   "\t[--version]" "\n"
+   "\t[--version]\n"
    "\tVolumeGroupName [VolumeGroupName...]\n",
 
    force_ARG, noudevsync_ARG, test_ARG)
@@ -1193,7 +1193,7 @@ xx(vgrename,
    "\t[-h|--help]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
-   "\t[--version]" "\n"
+   "\t[--version]\n"
    "\tOldVolumeGroupPath NewVolumeGroupPath |\n"
    "\tOldVolumeGroupName NewVolumeGroupName\n",
 
@@ -1202,7 +1202,7 @@ xx(vgrename,
 xx(vgs,
    "Display information about volume groups",
    PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT,
-   "vgs" "\n"
+   "vgs\n"
    "\t[--aligned]\n"
    "\t[--binary]\n"
    "\t[-a|--all]\n"
@@ -1216,7 +1216,7 @@ xx(vgs,
    "\t[--nosuffix]\n"
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
-   "\t[-P|--partial] " "\n"
+   "\t[-P|--partial]\n"
    "\t[--readonly]\n"
    "\t[--rows]\n"
    "\t[-S|--select Selection]\n"
@@ -1245,31 +1245,31 @@ xx(vgscan,
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--mknodes]\n"
-   "\t[-P|--partial] " "\n"
+   "\t[-P|--partial]\n"
    "\t[-v|--verbose]\n"
-   "\t[--version]" "\n",
+   "\t[--version]\n",
 
    cache_long_ARG, ignorelockingfailure_ARG, mknodes_ARG, partial_ARG)
 
 xx(vgsplit,
    "Move physical volumes into a new or existing volume group",
    0,
-   "vgsplit " "\n"
-   "\t[-A|--autobackup {y|n}] " "\n"
-   "\t[--alloc AllocationPolicy] " "\n"
-   "\t[-c|--clustered {y|n}] " "\n"
+   "vgsplit\n"
+   "\t[-A|--autobackup {y|n}]\n"
+   "\t[--alloc AllocationPolicy]\n"
+   "\t[-c|--clustered {y|n}]\n"
    "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug] " "\n"
-   "\t[-h|--help] " "\n"
-   "\t[-l|--maxlogicalvolumes MaxLogicalVolumes]" "\n"
-   "\t[-M|--metadatatype 1|2] " "\n"
-   "\t[--[vg]metadatacopies #copies] " "\n"
+   "\t[-d|--debug]\n"
+   "\t[-h|--help]\n"
+   "\t[-l|--maxlogicalvolumes MaxLogicalVolumes]\n"
+   "\t[-M|--metadatatype 1|2]\n"
+   "\t[--[vg]metadatacopies #copies]\n"
    "\t[-n|--name LogicalVolumeName]\n"
-   "\t[-p|--maxphysicalvolumes MaxPhysicalVolumes] " "\n"
-   "\t[-t|--test] " "\n"
-   "\t[-v|--verbose] " "\n"
-   "\t[--version]" "\n"
-   "\tSourceVolumeGroupName DestinationVolumeGroupName" "\n"
+   "\t[-p|--maxphysicalvolumes MaxPhysicalVolumes]\n"
+   "\t[-t|--test]\n"
+   "\t[-v|--verbose]\n"
+   "\t[--version]\n"
+   "\tSourceVolumeGroupName DestinationVolumeGroupName\n"
    "\t[PhysicalVolumePath...]\n",
 
    alloc_ARG, autobackup_ARG, clustered_ARG,
@@ -1279,4 +1279,4 @@ xx(vgsplit,
 xx(version,
    "Display software and driver version information",
    PERMITTED_READ_ONLY,
-   "version\n" )
+   "version\n")


