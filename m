From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 19 Jul 2013 18:26:45 +0000 (UTC)
Subject: master - commandline: add prefix aliases for raid options
Message-ID: <20130719182645.EC22561292@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=90a09559ed689cbd62021ef0ff875913d43bc989
Commit:        90a09559ed689cbd62021ef0ff875913d43bc989
Parent:        4eea66019157abd992c8802564b675fd97420c01
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jul 19 19:24:54 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jul 19 19:24:54 2013 +0100

commandline: add prefix aliases for raid options

Accept --raidwritemostly as well as --writemostly etc.
---
 WHATS_NEW          |    5 ++-
 tools/args.h       |    7 +++-
 tools/commands.h   |   88 ++++++++++++++++++++++++++-------------------------
 tools/lvmcmdline.c |    7 +++-
 4 files changed, 60 insertions(+), 47 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 46d7d23..83a593e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -92,10 +92,11 @@ Version 2.02.99 -
   Add explicit message about unsupported pvmove for thin/thinpool volumes.
   Fix lvmetad error path in lvmetad_vg_lookup() for null vgname.
   Fix clvmd _cluster_request() return code in memory fail path.
-  Add writemostly/writebehind support for RAID1
+  Add lvcreate/lvchange --[raid]{min|max}recoveryrate for raid LVs.
+  Add lvchange --[raid]writemostly/writebehind support for RAID1
   Add lv_change_activate() for common activation code in vg/lvchange.
   Revert change that allowed identical table reload for RAID.
-  New lvchange arg, '--syncaction' allows scrubbing of RAID LVs.
+  Add lvchange --[raid]syncaction for scrubbing of RAID LVs.
   Improve RAID kernel status retrieval to include sync_action/mismatch_cnt.
   Add external origin support for lvcreate.
   Improve lvcreate, lvconvert and lvm man pages.
diff --git a/tools/args.h b/tools/args.h
index bac507c..4b89ebd 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -87,11 +87,16 @@ arg(ignoreadvanced_ARG, '\0', "ignoreadvanced", NULL, 0)
 arg(ignoreunsupported_ARG, '\0', "ignoreunsupported", NULL, 0)
 arg(atversion_ARG, '\0', "atversion", string_arg, 0)
 arg(validate_ARG, '\0', "validate", NULL, 0)
-arg(syncaction_ARG, '\0', "syncaction", string_arg, 0)
+arg(syncaction_ARG, '\0', "syncaction", string_arg, 0)	/* FIXME Use custom validation fn */
+arg(raidsyncaction_ARG, '\0', "raidsyncaction", string_arg, 0)
 arg(writemostly_ARG, '\0', "writemostly", string_arg, ARG_GROUPABLE)
+arg(raidwritemostly_ARG, '\0', "raidwritemostly", string_arg, ARG_GROUPABLE)
 arg(writebehind_ARG, '\0', "writebehind", int_arg, 0)
+arg(raidwritebehind_ARG, '\0', "raidwritebehind", int_arg, 0)
 arg(minrecoveryrate_ARG, '\0', "minrecoveryrate", size_kb_arg, 0)
+arg(raidminrecoveryrate_ARG, '\0', "raidminrecoveryrate", size_kb_arg, 0)
 arg(maxrecoveryrate_ARG, '\0', "maxrecoveryrate", size_kb_arg, 0)
+arg(raidmaxrecoveryrate_ARG, '\0', "raidmaxrecoveryrate", size_kb_arg, 0)
 arg(profile_ARG, '\0', "profile", string_arg, 0)
 arg(detachprofile_ARG, '\0', "detachprofile", NULL, 0)
 arg(mergedconfig_ARG, '\0', "mergedconfig", NULL, 0)
diff --git a/tools/commands.h b/tools/commands.h
index fc4f7ef..1330c8d 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -34,17 +34,17 @@ xx(dumpconfig,
    "dumpconfig\n"
    "\t[-f|--file filename] \n"
    "\t[--type {current|default|missing|new|profilable} \n"
-   "\t[--withcomments] \n"
-   "\t[--withversions] \n"
+   "\t[--atversion version]] \n"
    "\t[--ignoreadvanced] \n"
    "\t[--ignoreunsupported] \n"
    "\t[--mergedconfig] \n"
-   "\t[--atversion version]] \n"
    "\t[--validate]\n"
+   "\t[--withcomments] \n"
+   "\t[--withversions] \n"
    "\t[ConfigurationNode...]\n",
-   file_ARG, configtype_ARG, withcomments_ARG, atversion_ARG,
-   withversions_ARG, ignoreadvanced_ARG, ignoreunsupported_ARG,
-   mergedconfig_ARG, validate_ARG)
+   atversion_ARG, configtype_ARG, file_ARG, ignoreadvanced_ARG,
+   ignoreunsupported_ARG, mergedconfig_ARG, validate_ARG,
+   withcomments_ARG, withversions_ARG)
 
 xx(formats,
    "List available metadata formats",
@@ -88,33 +88,35 @@ xx(lvchange,
    "\t[--monitor {y|n}]\n"
    "\t[--poll {y|n}]\n"
    "\t[--noudevsync]\n"
-   "\t[--minrecoveryrate Rate]\n"
-   "\t[--maxrecoveryrate Rate]\n"
    "\t[-M|--persistent y|n] [--major major] [--minor minor]\n"
    "\t[-P|--partial] " "\n"
    "\t[-p|--permission r|rw]\n"
+   "\t[--profile ProfileName\n"
+   "\t[--[raid]minrecoveryrate Rate]\n"
+   "\t[--[raid]maxrecoveryrate Rate]\n"
+   "\t[--[raid]syncaction {check|repair}\n"
+   "\t[--[raid]writebehind IOCount]\n"
+   "\t[--[raid]writemostly PhysicalVolume]\n"
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[--refresh]\n"
    "\t[--resync]\n"
-   "\t[--syncaction {check|repair}\n"
    "\t[--sysinit]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
-   "\t[--writebehind BehindCount]\n"
-   "\t[--writemostly PhysicalVolume]\n"
    "\t[-y|--yes]\n"
    "\t[-Z|--zero {y|n}]\n"
    "\tLogicalVolume[Path] [LogicalVolume[Path]...]\n",
 
-   alloc_ARG, autobackup_ARG, activate_ARG, available_ARG, contiguous_ARG,
-   discards_ARG, detachprofile_ARG, force_ARG, ignorelockingfailure_ARG,
-   ignoremonitoring_ARG, major_ARG, minor_ARG, monitor_ARG, minrecoveryrate_ARG,
-   maxrecoveryrate_ARG, noudevsync_ARG, partial_ARG, permission_ARG,
-   persistent_ARG, poll_ARG, readahead_ARG, resync_ARG, refresh_ARG,
-   setactivationskip_ARG, ignoreactivationskip_ARG, addtag_ARG,
-   deltag_ARG, syncaction_ARG, sysinit_ARG, test_ARG, writebehind_ARG,
-   writemostly_ARG, zero_ARG)
+   addtag_ARG, alloc_ARG, autobackup_ARG, activate_ARG, available_ARG,
+   contiguous_ARG, deltag_ARG, discards_ARG, detachprofile_ARG, force_ARG,
+   ignorelockingfailure_ARG, ignoremonitoring_ARG, ignoreactivationskip_ARG,
+   major_ARG, minor_ARG, monitor_ARG, minrecoveryrate_ARG, maxrecoveryrate_ARG,
+   noudevsync_ARG, partial_ARG, permission_ARG, persistent_ARG, poll_ARG,
+   profile_ARG, raidminrecoveryrate_ARG, raidmaxrecoveryrate_ARG,
+   raidsyncaction_ARG, raidwritebehind_ARG, raidwritemostly_ARG, readahead_ARG,
+   resync_ARG, refresh_ARG, setactivationskip_ARG, syncaction_ARG, sysinit_ARG,
+   test_ARG, writebehind_ARG, writemostly_ARG, zero_ARG)
 
 xx(lvconvert,
    "Change logical volume layout",
@@ -169,22 +171,21 @@ xx(lvconvert,
    "\t[--discards {ignore|nopassdown|passdown}]\n"
    "\t[--poolmetadata ThinMetadataLogicalVolume[Path] |\n"
    "\t [--poolmetadatasize size]\n"
-   "\t [-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t [--poolmetadataspare {y|n}]\n"
+   "\t [-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t [--stripes Stripes [-I|--stripesize StripeSize]]]\n"
    "\t[-T|--thin ExternalLogicalVolume[Path]\n"
    "\t [--originname NewExternalOriginVolumeName]]\n"
    "\t[-Z|--zero {y|n}]\n"
    "\t[-d|--debug] [-h|-?|--help] [-v|--verbose]\n",
 
-   alloc_ARG, background_ARG, chunksize_ARG, corelog_ARG, interval_ARG,
-   merge_ARG, mirrorlog_ARG, mirrors_ARG, name_ARG, noudevsync_ARG,
-   readahead_ARG, regionsize_ARG, repair_ARG, replace_ARG, snapshot_ARG, splitmirrors_ARG,
-   trackchanges_ARG, type_ARG, stripes_long_ARG, stripesize_ARG, test_ARG,
-   chunksize_ARG, discards_ARG, originname_ARG,
-   poolmetadata_ARG, poolmetadatasize_ARG, poolmetadataspare_ARG,
-   thin_ARG, thinpool_ARG,
-   use_policies_ARG, force_ARG, zero_ARG)
+   alloc_ARG, background_ARG, chunksize_ARG, corelog_ARG, discards_ARG,
+   force_ARG, interval_ARG, merge_ARG, mirrorlog_ARG, mirrors_ARG, name_ARG,
+   noudevsync_ARG, originname_ARG, poolmetadata_ARG, poolmetadatasize_ARG,
+   poolmetadataspare_ARG, readahead_ARG, regionsize_ARG, repair_ARG,
+   replace_ARG, snapshot_ARG, splitmirrors_ARG, stripes_long_ARG,
+   stripesize_ARG, test_ARG, thin_ARG, thinpool_ARG, trackchanges_ARG,
+   type_ARG, use_policies_ARG, zero_ARG)
 
 xx(lvcreate,
    "Create a logical volume",
@@ -206,11 +207,11 @@ xx(lvcreate,
    "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
    "\t[-m|--mirrors Mirrors [--nosync] [{--mirrorlog {disk|core|mirrored}|--corelog}]]\n"
-   "\t[--minrecoveryrate Rate]\n"
-   "\t[--maxrecoveryrate Rate]\n"
    "\t[-n|--name LogicalVolumeName]\n"
    "\t[--noudevsync]\n"
    "\t[-p|--permission {r|rw}]\n"
+   "\t[--[raid]minrecoveryrate Rate]\n"
+   "\t[--[raid]maxrecoveryrate Rate]\n"
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
    "\t[-T|--thin  [-c|--chunksize  ChunkSize]\n"
@@ -241,7 +242,7 @@ xx(lvcreate,
    "\t[--ignoremonitoring]\n"
    "\t[--monitor {y|n}]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
-   "\t[-k|--activationskip {y|n}]\n"
+   "\t[-k|--setactivationskip {y|n}]\n"
    "\t[-K|--ignoreactivationskip] \n"
    "\t{-l|--extents LogicalExtentsNumber[%{VG|FREE|ORIGIN}] |\n"
    "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
@@ -260,14 +261,14 @@ xx(lvcreate,
 
    addtag_ARG, alloc_ARG, autobackup_ARG, activate_ARG, available_ARG,
    chunksize_ARG, contiguous_ARG, corelog_ARG, discards_ARG, extents_ARG,
-   ignoremonitoring_ARG, major_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG,
-   monitor_ARG, minrecoveryrate_ARG, maxrecoveryrate_ARG, name_ARG, nosync_ARG,
-   noudevsync_ARG, ignoreactivationskip_ARG, setactivationskip_ARG,
-   poolmetadatasize_ARG, poolmetadataspare_ARG,
-   permission_ARG, persistent_ARG, readahead_ARG, regionsize_ARG, size_ARG,
-   snapshot_ARG, stripes_ARG, stripesize_ARG, test_ARG, thin_ARG, thinpool_ARG,
-   type_ARG, virtualoriginsize_ARG, virtualsize_ARG,
-   zero_ARG)
+   ignoreactivationskip_ARG, ignoremonitoring_ARG, major_ARG, minor_ARG,
+   mirrorlog_ARG, mirrors_ARG, monitor_ARG, minrecoveryrate_ARG,
+   maxrecoveryrate_ARG, name_ARG, nosync_ARG, noudevsync_ARG,
+   permission_ARG, persistent_ARG, poolmetadatasize_ARG, poolmetadataspare_ARG,
+   raidminrecoveryrate_ARG, raidmaxrecoveryrate_ARG, readahead_ARG,
+   regionsize_ARG, setactivationskip_ARG, size_ARG, snapshot_ARG, stripes_ARG,
+   stripesize_ARG, test_ARG, thin_ARG, thinpool_ARG,
+   type_ARG, virtualoriginsize_ARG, virtualsize_ARG, zero_ARG)
 
 xx(lvdisplay,
    "Display information about a logical volume",
@@ -495,7 +496,7 @@ xx(lvs,
    "\t[LogicalVolume[Path] [LogicalVolume[Path]...]]\n",
 
    aligned_ARG, all_ARG, ignorelockingfailure_ARG, nameprefixes_ARG,
-   noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, 
+   noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG,
    rows_ARG, segments_ARG, separator_ARG, sort_ARG, trustcache_ARG,
    unbuffered_ARG, units_ARG, unquoted_ARG)
 
@@ -575,8 +576,8 @@ xx(pvcreate,
    "\t[--labelsector sector] " "\n"
    "\t[-M|--metadatatype 1|2]" "\n"
    "\t[--pvmetadatacopies #copies]" "\n"
-   "\t[--metadatasize MetadataSize[bBsSkKmMgGtTpPeE]]" "\n"
    "\t[--bootloaderareasize BootLoaderAreaSize[bBsSkKmMgGtTpPeE]]" "\n"
+   "\t[--metadatasize MetadataSize[bBsSkKmMgGtTpPeE]]" "\n"
    "\t[--dataalignment Alignment[bBsSkKmMgGtTpPeE]]" "\n"
    "\t[--dataalignmentoffset AlignmentOffset[bBsSkKmMgGtTpPeE]]" "\n"
    "\t[--setphysicalvolumesize PhysicalVolumeSize[bBsSkKmMgGtTpPeE]" "\n"
@@ -805,6 +806,7 @@ xx(vgchange,
    "\t -l|--logicalvolume MaxLogicalVolumes |" "\n"
    "\t -p|--maxphysicalvolumes MaxPhysicalVolumes |" "\n"
    "\t -s|--physicalextentsize PhysicalExtentSize[bBsSkKmMgGtTpPeE] |" "\n"
+   "\t[--profile ProfileName\n"
    "\t --addtag Tag |\n"
    "\t --deltag Tag}\n"
    "\t[VolumeGroupName...]\n",
@@ -813,7 +815,7 @@ xx(vgchange,
    available_ARG, clustered_ARG, deltag_ARG, detachprofile_ARG,
    ignoreactivationskip_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG,
    logicalvolume_ARG, maxphysicalvolumes_ARG, monitor_ARG, noudevsync_ARG,
-   metadatacopies_ARG, vgmetadatacopies_ARG, partial_ARG,
+   metadatacopies_ARG, vgmetadatacopies_ARG, partial_ARG, profile_ARG,
    physicalextentsize_ARG, poll_ARG, refresh_ARG, resizeable_ARG,
    resizable_ARG, sysinit_ARG, test_ARG, uuid_ARG)
 
@@ -1066,7 +1068,7 @@ xx(vgs,
    "\t[VolumeGroupName [VolumeGroupName...]]\n",
 
    aligned_ARG, all_ARG, ignorelockingfailure_ARG, nameprefixes_ARG,
-   noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, 
+   noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG,
    rows_ARG, separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG,
    unquoted_ARG)
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 3aa4206..66c4536 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -920,7 +920,12 @@ static int _get_settings(struct cmd_context *cmd)
 	    !_merge_synonym(cmd, allocation_ARG, allocatable_ARG) ||
 	    !_merge_synonym(cmd, allocation_ARG, resizeable_ARG) ||
 	    !_merge_synonym(cmd, virtualoriginsize_ARG, virtualsize_ARG) ||
-	    !_merge_synonym(cmd, available_ARG, activate_ARG))
+	    !_merge_synonym(cmd, available_ARG, activate_ARG) ||
+	    !_merge_synonym(cmd, raidsyncaction_ARG, syncaction_ARG) ||
+	    !_merge_synonym(cmd, raidwritemostly_ARG, writemostly_ARG) ||
+	    !_merge_synonym(cmd, raidminrecoveryrate_ARG, minrecoveryrate_ARG) ||
+	    !_merge_synonym(cmd, raidmaxrecoveryrate_ARG, maxrecoveryrate_ARG) ||
+	    !_merge_synonym(cmd, raidwritebehind_ARG, writebehind_ARG))
 		return EINVALID_CMD_LINE;
 
 	if ((!strncmp(cmd->command->name, "pv", 2) &&


