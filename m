From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:40:39 +0000 (UTC)
Subject: master - commands: recognize --reportformat option for other commands
Message-ID: <20160620094039.F362A6031C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f1e7f35bb5982f6767bcaa8ab775bde580316c5d
Commit:        f1e7f35bb5982f6767bcaa8ab775bde580316c5d
Parent:        f8a93763e59eea8cef3762908c3e663c7a22a4fa
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue May 17 13:32:56 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:42 2016 +0200

commands: recognize --reportformat option for other commands

Enables --reportformat option for all command using processing_handle
(and process_each_* fn variant), that is: lvchange, lvcreate, lvdisplay,
lvextend, lvreduce, lvremove, lvrename, lvresize, lvscan, pvchange,
pvresize, pvcreate, pvdisplay, pvmove, pvremove, pvscan, vgcfgbackup,
vgchange, vgck, vgconvert, vgcreate, vgdisplay, vgexport, vgextend,
vgimport, vgmknodes, vgreduce, vgremove, vgrename command.
---
 tools/commands.h |  114 ++++++++++++++++++++++++++++++++++++------------------
 1 files changed, 76 insertions(+), 38 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index b544ae1..4db57d5 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -175,6 +175,7 @@ xx(lvchange,
    "\t[--[raid]writemostly <PhysicalVolume>[:{t|n|y}]]\n"
    "\t[-r|--readahead <ReadAheadSectors>|auto|none]\n"
    "\t[--refresh]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[--resync]\n"
    "\t[-S|--select Selection]\n"
    "\t[--sysinit]\n"
@@ -194,9 +195,9 @@ xx(lvchange,
    monitor_ARG, minrecoveryrate_ARG, maxrecoveryrate_ARG, noudevsync_ARG,
    partial_ARG, permission_ARG, persistent_ARG, poll_ARG,
    raidminrecoveryrate_ARG, raidmaxrecoveryrate_ARG, raidsyncaction_ARG,
-   raidwritebehind_ARG, raidwritemostly_ARG, readahead_ARG, resync_ARG,
-   refresh_ARG, select_ARG, setactivationskip_ARG, syncaction_ARG, sysinit_ARG,
-   test_ARG, writebehind_ARG, writemostly_ARG, zero_ARG)
+   raidwritebehind_ARG, raidwritemostly_ARG, readahead_ARG, reportformat_ARG,
+   resync_ARG, refresh_ARG, select_ARG, setactivationskip_ARG, syncaction_ARG,
+   sysinit_ARG, test_ARG, writebehind_ARG, writemostly_ARG, zero_ARG)
 
 #define COMMON_OPTS \
 	"\t[--commandprofile <ProfileName>] [-d|--debug] [-h|-?|--help]\n" \
@@ -337,6 +338,7 @@ xx(lvcreate,
    "\t[--[raid]minrecoveryrate Rate]\n"
    "\t[--[raid]maxrecoveryrate Rate]\n"
    "\t[-r|--readahead {ReadAheadSectors|auto|none}]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
    "\t[-T|--thin\n"
    "\t  [--discards {ignore|nopassdown|passdown}]\n"
@@ -380,6 +382,7 @@ xx(lvcreate,
    "\t[--noudevsync]\n"
    "\t[-p|--permission {r|rw}]\n"
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-t|--test]\n"
    "\t[{--thinpool ThinPoolLogicalVolume[Path] |\n"
    "\t  --cachepool CachePoolLogicalVolume[Path]}]\n"
@@ -397,9 +400,10 @@ xx(lvcreate,
    //pooldatasize_ARG,
    poolmetadatasize_ARG, poolmetadataspare_ARG,
    raidminrecoveryrate_ARG, raidmaxrecoveryrate_ARG,
-   readahead_ARG, regionsize_ARG, setactivationskip_ARG, size_ARG, snapshot_ARG,
-   stripes_ARG, stripesize_ARG, test_ARG, thin_ARG, thinpool_ARG, type_ARG,
-   virtualoriginsize_ARG, virtualsize_ARG, wipesignatures_ARG, zero_ARG)
+   readahead_ARG, regionsize_ARG, reportformat_ARG, setactivationskip_ARG,
+   size_ARG, snapshot_ARG, stripes_ARG, stripesize_ARG, test_ARG, thin_ARG,
+   thinpool_ARG, type_ARG, virtualoriginsize_ARG, virtualsize_ARG,
+   wipesignatures_ARG, zero_ARG)
 
 xx(lvdisplay,
    "Display information about a logical volume",
@@ -442,6 +446,7 @@ xx(lvdisplay,
    "\t[-S|--select Selection]\n"
    "\t[-P|--partial]\n"
    "\t[--readonly]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[--segments]\n"
    "\t[--separator Separator]\n"
    "\t[--unbuffered]\n"
@@ -453,8 +458,8 @@ xx(lvdisplay,
     aligned_ARG, all_ARG, binary_ARG, colon_ARG, columns_ARG, foreign_ARG,
     history_ARG, ignorelockingfailure_ARG, ignoreskippedcluster_ARG,
     maps_ARG, noheadings_ARG, nosuffix_ARG, options_ARG, sort_ARG,
-    partial_ARG, readonly_ARG, segments_ARG, select_ARG, separator_ARG,
-    shared_ARG, unbuffered_ARG, units_ARG)
+    partial_ARG, readonly_ARG, reportformat_ARG, segments_ARG, select_ARG,
+    separator_ARG, shared_ARG, unbuffered_ARG, units_ARG)
 
 xx(lvextend,
    "Add space to a logical volume",
@@ -475,6 +480,7 @@ xx(lvextend,
    "\t[--use-policies]\n"
    "\t[-n|--nofsck]\n"
    "\t[--noudevsync]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-r|--resizefs]\n"
    "\t[-t|--test]\n"
    "\t[--type VolumeType]\n"
@@ -484,7 +490,7 @@ xx(lvextend,
 
    alloc_ARG, autobackup_ARG, extents_ARG, force_ARG, mirrors_ARG,
    nofsck_ARG, nosync_ARG, noudevsync_ARG, poolmetadatasize_ARG,
-   resizefs_ARG, size_ARG, stripes_ARG, stripesize_ARG,
+   reportformat_ARG, resizefs_ARG, size_ARG, stripes_ARG, stripesize_ARG,
    test_ARG, type_ARG, usepolicies_ARG)
 
 xx(lvmchange,
@@ -584,6 +590,7 @@ xx(lvreduce,
    "\t[-n|--nofsck]\n"
    "\t[--noudevsync]\n"
    "\t[-r|--resizefs]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
@@ -591,7 +598,7 @@ xx(lvreduce,
    "\tLogicalVolume[Path]\n",
 
    autobackup_ARG, force_ARG,  extents_ARG, nofsck_ARG, noudevsync_ARG,
-   resizefs_ARG, size_ARG, test_ARG)
+   reportformat_ARG, resizefs_ARG, size_ARG, test_ARG)
 
 xx(lvremove,
    "Remove logical volume(s) from the system",
@@ -604,6 +611,7 @@ xx(lvremove,
    "\t[-h|--help]\n"
    "\t[--nohistory]\n"
    "\t[--noudevsync]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-S|--select Selection]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
@@ -611,7 +619,7 @@ xx(lvremove,
    "\tLogicalVolume[Path] [LogicalVolume[Path]...]\n",
 
    autobackup_ARG, force_ARG, nohistory_ARG, noudevsync_ARG,
-   select_ARG, test_ARG)
+   reportformat_ARG, select_ARG, test_ARG)
 
 xx(lvrename,
    "Rename a logical volume",
@@ -622,13 +630,14 @@ xx(lvrename,
    "\t[-d|--debug]\n"
    "\t[-h|-?|--help]\n"
    "\t[--noudevsync]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
    "\t{ OldLogicalVolumePath NewLogicalVolumePath |\n"
    "\t  VolumeGroupName OldLogicalVolumeName NewLogicalVolumeName }\n",
 
-   autobackup_ARG, noudevsync_ARG, test_ARG)
+   autobackup_ARG, noudevsync_ARG, reportformat_ARG, test_ARG)
 
 xx(lvresize,
    "Resize a logical volume",
@@ -646,6 +655,7 @@ xx(lvresize,
    "\t --poolmetadatasize [+]MetadataVolumeSize[bBsSkKmMgG]}\n"
    "\t[-n|--nofsck]\n"
    "\t[--noudevsync]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-r|--resizefs]\n"
    "\t[-t|--test]\n"
    "\t[--type VolumeType]\n"
@@ -654,8 +664,8 @@ xx(lvresize,
    "\tLogicalVolume[Path] [ PhysicalVolumePath... ]\n",
 
    alloc_ARG, autobackup_ARG, extents_ARG, force_ARG, nofsck_ARG,
-   noudevsync_ARG, resizefs_ARG, poolmetadatasize_ARG,
-   size_ARG, stripes_ARG, stripesize_ARG,
+   noudevsync_ARG, reportformat_ARG, resizefs_ARG,
+   poolmetadatasize_ARG, size_ARG, stripes_ARG, stripesize_ARG,
    test_ARG, type_ARG)
 
 xx(lvs,
@@ -712,11 +722,12 @@ xx(lvscan,
    "\t[--ignorelockingfailure]\n"
    "\t[-P|--partial]\n"
    "\t[--readonly]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n",
 
    all_ARG, blockdevice_ARG, ignorelockingfailure_ARG, partial_ARG,
-   readonly_ARG, cache_long_ARG)
+   readonly_ARG, reportformat_ARG, cache_long_ARG)
 
 xx(pvchange,
    "Change attributes of physical volume(s)",
@@ -730,6 +741,7 @@ xx(pvchange,
    "\t[-h|--help]\n"
    "\t[--ignoreskippedcluster]\n"
    "\t[--metadataignore y|n]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-S|--select Selection]\n"
    "\t[-t|--test]\n"
    "\t[-u|--uuid]\n"
@@ -742,7 +754,7 @@ xx(pvchange,
 
    all_ARG, allocatable_ARG, allocation_ARG, autobackup_ARG, deltag_ARG,
    addtag_ARG, force_ARG, ignoreskippedcluster_ARG, metadataignore_ARG,
-   select_ARG, test_ARG, uuid_ARG)
+   reportformat_ARG, select_ARG, test_ARG, uuid_ARG)
 
 xx(pvresize,
    "Resize physical volume(s)",
@@ -751,13 +763,14 @@ xx(pvresize,
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|-?|--help]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[--setphysicalvolumesize PhysicalVolumeSize[bBsSkKmMgGtTpPeE]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
    "\tPhysicalVolume [PhysicalVolume...]\n",
 
-   physicalvolumesize_ARG, test_ARG)
+   physicalvolumesize_ARG, reportformat_ARG, test_ARG)
 
 xx(pvck,
    "Check the consistency of physical volume(s)",
@@ -779,6 +792,7 @@ xx(pvcreate,
    "pvcreate\n"
    "\t[--norestorefile]\n"
    "\t[--restorefile file]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-f[f]|--force [--force]]\n"
@@ -803,7 +817,7 @@ xx(pvcreate,
    force_ARG, test_ARG, labelsector_ARG, metadatatype_ARG,
    metadatacopies_ARG, metadatasize_ARG, metadataignore_ARG,
    norestorefile_ARG, physicalvolumesize_ARG, pvmetadatacopies_ARG,
-   restorefile_ARG, uuidstr_ARG, zero_ARG)
+   reportformat_ARG, restorefile_ARG, uuidstr_ARG, zero_ARG)
 
 xx(pvdata,
    "Display the on-disk metadata for physical volume(s)",
@@ -860,6 +874,7 @@ xx(pvdisplay,
    "\t[--nosuffix]\n"
    "\t[-o|--options [+|-|#]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-S|--select Selection]\n"
    "\t[--readonly]\n"
    "\t[--separator Separator]\n"
@@ -871,7 +886,7 @@ xx(pvdisplay,
 
    aligned_ARG, all_ARG, binary_ARG, colon_ARG, columns_ARG, foreign_ARG,
    ignorelockingfailure_ARG, ignoreskippedcluster_ARG, maps_ARG,
-   noheadings_ARG, nosuffix_ARG, options_ARG, readonly_ARG,
+   noheadings_ARG, nosuffix_ARG, options_ARG, readonly_ARG, reportformat_ARG,
    select_ARG, separator_ARG, shared_ARG, short_ARG, sort_ARG, unbuffered_ARG,
    units_ARG)
 
@@ -891,6 +906,7 @@ xx(pvmove,
    "\t[-h|-?|--help]\n"
    "\t[-i|--interval seconds]\n"
    "\t[--noudevsync]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-t|--test]\n "
    "\t[-v|--verbose]\n "
    "\t[--version]\n"
@@ -900,7 +916,7 @@ xx(pvmove,
    "\t[DestinationPhysicalVolume[:PhysicalExtent[-PhysicalExtent]...]...]\n",
 
    abort_ARG, alloc_ARG, atomic_ARG, autobackup_ARG, background_ARG,
-   interval_ARG, name_ARG, noudevsync_ARG, test_ARG)
+   interval_ARG, name_ARG, noudevsync_ARG, reportformat_ARG, test_ARG)
 
 xx(lvpoll,
    "Continue already initiated poll operation on a logical volume",
@@ -928,13 +944,14 @@ xx(pvremove,
    "\t[-d|--debug]\n"
    "\t[-f[f]|--force [--force]]\n"
    "\t[-h|-?|--help]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
    "\t[-y|--yes]\n"
    "\tPhysicalVolume [PhysicalVolume...]\n",
 
-   force_ARG, test_ARG)
+   force_ARG, reportformat_ARG, test_ARG)
 
 xx(pvs,
    "Display information about physical volumes",
@@ -988,6 +1005,7 @@ xx(pvscan,
    "\t[--ignorelockingfailure]\n"
    "\t[-P|--partial]\n"
    "\t[--readonly]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-s|--short]\n"
    "\t[-u|--uuid]\n"
    "\t[-v|--verbose]\n"
@@ -995,7 +1013,8 @@ xx(pvscan,
 
    activate_ARG, available_ARG, backgroundfork_ARG, cache_long_ARG,
    exported_ARG, ignorelockingfailure_ARG, major_ARG, minor_ARG,
-   novolumegroup_ARG, partial_ARG, readonly_ARG, short_ARG, uuid_ARG)
+   novolumegroup_ARG, partial_ARG, readonly_ARG, reportformat_ARG,
+   short_ARG, uuid_ARG)
 
 xx(segtypes,
    "List available segment types",
@@ -1024,11 +1043,13 @@ xx(vgcfgbackup,
    "\t[--ignorelockingfailure]\n"
    "\t[-P|--partial]\n"
    "\t[--readonly]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
    "\t[VolumeGroupName...]\n",
 
-   file_ARG, foreign_ARG, ignorelockingfailure_ARG, partial_ARG, readonly_ARG)
+   file_ARG, foreign_ARG, ignorelockingfailure_ARG, partial_ARG, readonly_ARG,
+   reportformat_ARG)
 
 xx(vgcfgrestore,
    "Restore volume group configuration",
@@ -1069,6 +1090,7 @@ xx(vgchange,
    "\t[--poll {y|n}]\n"
    "\t[--noudevsync]\n"
    "\t[--refresh]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-S|--select Selection]\n"
    "\t[--sysinit]\n"
    "\t[--systemid SystemID]\n"
@@ -1093,9 +1115,9 @@ xx(vgchange,
    ignoreskippedcluster_ARG, logicalvolume_ARG, maxphysicalvolumes_ARG,
    metadataprofile_ARG, monitor_ARG, noudevsync_ARG, metadatacopies_ARG,
    vgmetadatacopies_ARG, partial_ARG, physicalextentsize_ARG, poll_ARG,
-   refresh_ARG, resizeable_ARG, resizable_ARG, select_ARG, sysinit_ARG,
-   systemid_ARG, test_ARG, uuid_ARG, lockstart_ARG, lockstop_ARG, locktype_ARG, lockopt_ARG,
-   force_ARG)
+   refresh_ARG, reportformat_ARG, resizeable_ARG, resizable_ARG, select_ARG,
+   sysinit_ARG, systemid_ARG, test_ARG, uuid_ARG, lockstart_ARG, lockstop_ARG,
+   locktype_ARG, lockopt_ARG, force_ARG)
 
 xx(vgck,
    "Check the consistency of volume group(s)",
@@ -1104,9 +1126,12 @@ xx(vgck,
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
-   "\t[VolumeGroupName...]\n")
+   "\t[VolumeGroupName...]\n",
+
+   reportformat_ARG)
 
 xx(vgconvert,
    "Change volume group metadata format",
@@ -1120,6 +1145,7 @@ xx(vgconvert,
    "\t[--pvmetadatacopies #copies]\n"
    "\t[--metadatasize MetadataSize[bBsSkKmMgGtTpPeE]]\n"
    "\t[--bootloaderareasize BootLoaderAreaSize[bBsSkKmMgGtTpPeE]]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
@@ -1127,7 +1153,7 @@ xx(vgconvert,
 
    force_ARG, test_ARG, labelsector_ARG, bootloaderareasize_ARG,
    metadatatype_ARG, metadatacopies_ARG, pvmetadatacopies_ARG,
-   metadatasize_ARG)
+   metadatasize_ARG, reportformat_ARG)
 
 xx(vgcreate,
    "Create a volume group",
@@ -1145,6 +1171,7 @@ xx(vgcreate,
    "\t[-M|--metadatatype 1|2]\n"
    "\t[--[vg]metadatacopies #copies]\n"
    "\t[-p|--maxphysicalvolumes MaxPhysicalVolumes]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-s|--physicalextentsize PhysicalExtentSize[bBsSkKmMgGtTpPeE]]\n"
    "\t[--systemid SystemID]\n"
    "\t[-t|--test]\n"
@@ -1157,7 +1184,7 @@ xx(vgcreate,
    addtag_ARG, alloc_ARG, autobackup_ARG, clustered_ARG, maxlogicalvolumes_ARG,
    maxphysicalvolumes_ARG, metadataprofile_ARG, metadatatype_ARG,
    physicalextentsize_ARG, test_ARG, force_ARG, zero_ARG, labelsector_ARG,
-   metadatasize_ARG, pvmetadatacopies_ARG, metadatacopies_ARG,
+   metadatasize_ARG, pvmetadatacopies_ARG, reportformat_ARG, metadatacopies_ARG,
    vgmetadatacopies_ARG, dataalignment_ARG, dataalignmentoffset_ARG,
    shared_ARG, systemid_ARG, locktype_ARG, lockopt_ARG)
 
@@ -1195,6 +1222,7 @@ xx(vgdisplay,
    "\t[-o|--options [+|-|#]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-S|--select Selection]\n"
    "\t[--readonly]\n"
    "\t[--separator Separator]\n"
@@ -1207,7 +1235,8 @@ xx(vgdisplay,
    activevolumegroups_ARG, aligned_ARG, binary_ARG, colon_ARG, columns_ARG,
    foreign_ARG, ignorelockingfailure_ARG, ignoreskippedcluster_ARG,
    noheadings_ARG, nosuffix_ARG, options_ARG, partial_ARG, readonly_ARG,
-   select_ARG, shared_ARG, short_ARG, separator_ARG, sort_ARG, unbuffered_ARG, units_ARG)
+   reportformat_ARG, select_ARG, shared_ARG, short_ARG, separator_ARG,
+   sort_ARG, unbuffered_ARG, units_ARG)
 
 xx(vgexport,
    "Unregister volume group(s) from the system",
@@ -1217,12 +1246,13 @@ xx(vgexport,
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-S|--select Selection]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
    "\tVolumeGroupName [VolumeGroupName...]\n",
 
-   all_ARG, select_ARG, test_ARG)
+   all_ARG, reportformat_ARG, select_ARG, test_ARG)
 
 xx(vgextend,
    "Add physical volumes to a volume group",
@@ -1234,6 +1264,7 @@ xx(vgextend,
    "\t[-d|--debug]\n"
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
@@ -1245,7 +1276,7 @@ xx(vgextend,
    force_ARG, zero_ARG, labelsector_ARG, metadatatype_ARG,
    metadatasize_ARG, pvmetadatacopies_ARG, metadatacopies_ARG,
    metadataignore_ARG, dataalignment_ARG, dataalignmentoffset_ARG,
-   restoremissing_ARG)
+   reportformat_ARG, restoremissing_ARG)
 
 xx(vgimport,
    "Register exported volume group with system",
@@ -1256,13 +1287,14 @@ xx(vgimport,
    "\t[-d|--debug]\n"
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-S|--select Selection]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
    "\tVolumeGroupName...\n",
 
-   all_ARG, force_ARG, select_ARG, test_ARG)
+   all_ARG, force_ARG, reportformat_ARG, select_ARG, test_ARG)
 
 xx(vgmerge,
    "Merge volume groups",
@@ -1289,11 +1321,12 @@ xx(vgmknodes,
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--refresh]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
    "\t[VolumeGroupName...]\n",
 
-   ignorelockingfailure_ARG, refresh_ARG)
+   ignorelockingfailure_ARG, refresh_ARG, reportformat_ARG)
 
 xx(vgreduce,
    "Remove physical volume(s) from a volume group",
@@ -1306,6 +1339,7 @@ xx(vgreduce,
    "\t[-h|--help]\n"
    "\t[--mirrorsonly]\n"
    "\t[--removemissing]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-f|--force]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
@@ -1314,7 +1348,7 @@ xx(vgreduce,
    "\t[PhysicalVolumePath...]\n",
 
    all_ARG, autobackup_ARG, force_ARG, mirrorsonly_ARG, removemissing_ARG,
-   test_ARG)
+   reportformat_ARG, test_ARG)
 
 xx(vgremove,
    "Remove volume group(s)",
@@ -1325,13 +1359,14 @@ xx(vgremove,
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
    "\t[--noudevsync]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-S|--select Selection]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
    "\tVolumeGroupName [VolumeGroupName...]\n",
 
-   force_ARG, noudevsync_ARG, select_ARG, test_ARG)
+   force_ARG, noudevsync_ARG, reportformat_ARG, select_ARG, test_ARG)
 
 xx(vgrename,
    "Rename a volume group",
@@ -1341,13 +1376,14 @@ xx(vgrename,
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
    "\tOldVolumeGroupPath NewVolumeGroupPath |\n"
    "\tOldVolumeGroupName NewVolumeGroupName\n",
 
-   autobackup_ARG, force_ARG, test_ARG)
+   autobackup_ARG, force_ARG, reportformat_ARG, test_ARG)
 
 xx(vgs,
    "Display information about volume groups",
@@ -1399,10 +1435,12 @@ xx(vgscan,
    "\t[--mknodes]\n"
    "\t[--notifydbus]\n"
    "\t[-P|--partial]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n",
 
-   cache_long_ARG, ignorelockingfailure_ARG, mknodes_ARG, notifydbus_ARG, partial_ARG)
+   cache_long_ARG, ignorelockingfailure_ARG, mknodes_ARG, notifydbus_ARG,
+   partial_ARG, reportformat_ARG)
 
 xx(vgsplit,
    "Move physical volumes into a new or existing volume group",


