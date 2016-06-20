From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:40:46 +0000 (UTC)
Subject: master - args: add priorities for grouping args
Message-ID: <20160620094046.4F05B6031C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d23c5b93183675199ff78ff288e4bbd12f935515
Commit:        d23c5b93183675199ff78ff288e4bbd12f935515
Parent:        9c37b7ed7c33bb6e66daf369fd563c52f6743282
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jun 17 11:03:14 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:42 2016 +0200

args: add priorities for grouping args

Groupable args (the ones marked with ARG_GROUPABLE flag) start a new
group of args if:
  - this is the first time we hit such a groupable arg,
  - or if non-countable arg is repeated.

However, there may be cases where we want to give priorities when
forming groups and hence force new group creation if we hit an arg
with higher grouping priority.

For example, let's assume (for now) hypothetical sequence of args used:

  lvs -o lv_name --configreport log -o log_type --configreport lv -o +vg_name

Without giving any priorites, we end up with:

  lvs -o lv_name --configreport log -o log_type --configreport lv -o +vg_name
     |                            | |                           | |          |
     \__________GROUP1___________/   \________GROUP2___________/   \_GROUP3_/

This is because we hit "-o" as the first groupable arg. The --configreport,
even though it's groupable too, it falls into the previous "-o" group.

While we may need to give priority to the --configreport arg that should
always start a new group in this scenario instead:

  lvs -o lv_name --configreport log -o log_type --configreport lv -o +vg_name
      |         | |                            | |                           |
      \_GROUP1_/   \_________GROUP2___________/   \_________GROUP3__________/

So here "-o" started a new group but since "--configreport" has higher
priority than "-o", it starts fresh new group now and hence the rest of
the command line's args are grouped by --configreport now.
---
 WHATS_NEW          |    1 +
 tools/args.h       |  396 ++++++++++++++++++++++++++--------------------------
 tools/lvmcmdline.c |   14 ++-
 tools/tools.h      |    4 +-
 4 files changed, 213 insertions(+), 202 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4e87e47..626851e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.158 - 
 =================================
+  Add support for priorities on grouping command arguments.
   Add report/{pvs,vgs,lvs,pvsegs,segs}_{cols,sort}_full to lvm.conf.
   Add lvm fullreport command for joined PV, VG, LV and segment report per VG.
   Integrate report group handling and cmd log report into cmd processing code.
diff --git a/tools/args.h b/tools/args.h
index 049ea5a..8d66809 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2016 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -17,209 +17,209 @@
  * Put all long args that don't have a corresponding short option first.
  */
 /* *INDENT-OFF* */
-arg(abort_ARG, '\0', "abort", NULL, 0)
-arg(activationmode_ARG, '\0', "activationmode", string_arg, 0)
-arg(addtag_ARG, '\0', "addtag", tag_arg, ARG_GROUPABLE)
-arg(aligned_ARG, '\0', "aligned", NULL, 0)
-arg(alloc_ARG, '\0', "alloc", alloc_arg, 0)
-arg(atomic_ARG, '\0', "atomic", NULL, 0)
-arg(atversion_ARG, '\0', "atversion", string_arg, 0)
-arg(binary_ARG, '\0', "binary", NULL, 0)
-arg(bootloaderareasize_ARG, '\0', "bootloaderareasize", size_mb_arg, 0)
-arg(cache_long_ARG, '\0', "cache", NULL, 0)
-arg(cachemode_ARG, '\0', "cachemode", cachemode_arg, 0)
-arg(cachepool_ARG, '\0', "cachepool", string_arg, 0)
-arg(commandprofile_ARG, '\0', "commandprofile", string_arg, 0)
-arg(config_ARG, '\0', "config", string_arg, 0)
-arg(configtype_ARG, '\0', "type", string_arg, 0)
-arg(corelog_ARG, '\0', "corelog", NULL, 0)
-arg(dataalignment_ARG, '\0', "dataalignment", size_kb_arg, 0)
-arg(dataalignmentoffset_ARG, '\0', "dataalignmentoffset", size_kb_arg, 0)
-arg(deltag_ARG, '\0', "deltag", tag_arg, ARG_GROUPABLE)
-arg(detachprofile_ARG, '\0', "detachprofile", NULL, 0)
-arg(discards_ARG, '\0', "discards", discards_arg, 0)
-arg(driverloaded_ARG, '\0', "driverloaded", yes_no_arg, 0)
-arg(errorwhenfull_ARG, '\0', "errorwhenfull", yes_no_arg, 0)
-arg(force_long_ARG, '\0', "force", NULL, ARG_COUNTABLE)
-arg(foreign_ARG, '\0', "foreign", NULL, 0)
-arg(handlemissingpvs_ARG, '\0', "handlemissingpvs", NULL, 0)
-arg(ignoreadvanced_ARG, '\0', "ignoreadvanced", NULL, 0)
-arg(ignorelocal_ARG, '\0', "ignorelocal", NULL, 0)
-arg(ignorelockingfailure_ARG, '\0', "ignorelockingfailure", NULL, 0)
-arg(ignoremonitoring_ARG, '\0', "ignoremonitoring", NULL, 0)
-arg(ignoreskippedcluster_ARG, '\0', "ignoreskippedcluster", NULL, 0)
-arg(ignoreunsupported_ARG, '\0', "ignoreunsupported", NULL, 0)
-arg(labelsector_ARG, '\0', "labelsector", int_arg, 0)
-arg(lockopt_ARG, '\0', "lockopt", string_arg, 0)
-arg(lockstart_ARG, '\0', "lockstart", NULL, 0)
-arg(lockstop_ARG, '\0', "lockstop", NULL, 0)
-arg(locktype_ARG, '\0', "locktype", locktype_arg, 0)
-arg(maxrecoveryrate_ARG, '\0', "maxrecoveryrate", size_kb_arg, 0)
-arg(merge_ARG, '\0', "merge", NULL, 0)
-arg(mergedconfig_ARG, '\0', "mergedconfig", NULL, 0)
-arg(metadatacopies_ARG, '\0', "metadatacopies", metadatacopies_arg, 0)
-arg(metadataignore_ARG, '\0', "metadataignore", yes_no_arg, 0)
-arg(metadataprofile_ARG, '\0', "metadataprofile", string_arg, 0)
-arg(metadatasize_ARG, '\0', "metadatasize", size_mb_arg, 0)
-arg(minor_ARG, '\0', "minor", int_arg, ARG_GROUPABLE)
-arg(minrecoveryrate_ARG, '\0', "minrecoveryrate", size_kb_arg, 0)
-arg(mirrorlog_ARG, '\0', "mirrorlog", mirrorlog_arg, 0)
-arg(mirrorsonly_ARG, '\0', "mirrorsonly", NULL, 0)
-arg(mknodes_ARG, '\0', "mknodes", NULL, 0)
-arg(monitor_ARG, '\0', "monitor", yes_no_arg, 0)
-arg(nameprefixes_ARG, '\0', "nameprefixes", NULL, 0)
-arg(noheadings_ARG, '\0', "noheadings", NULL, 0)
-arg(nohistory_ARG, '\0', "nohistory", NULL, 0)
-arg(nolocking_ARG, '\0', "nolocking", NULL, 0)
-arg(norestorefile_ARG, '\0', "norestorefile", NULL, 0)
-arg(nosuffix_ARG, '\0', "nosuffix", NULL, 0)
-arg(nosync_ARG, '\0', "nosync", NULL, 0)
-arg(notifydbus_ARG, '\0', "notifydbus", NULL, 0)
-arg(noudevsync_ARG, '\0', "noudevsync", NULL, 0)
-arg(originname_ARG, '\0', "originname", string_arg, 0)
-arg(physicalvolumesize_ARG, '\0', "setphysicalvolumesize", size_mb_arg, 0)
-arg(poll_ARG, '\0', "poll", yes_no_arg, 0)
-arg(polloperation_ARG, '\0', "polloperation", string_arg, 0)
-arg(pooldatasize_ARG, '\0', "pooldatasize", size_mb_arg, 0)
-arg(poolmetadata_ARG, '\0', "poolmetadata", string_arg, 0)
-arg(poolmetadatasize_ARG, '\0', "poolmetadatasize", size_mb_arg, 0)
-arg(poolmetadataspare_ARG, '\0', "poolmetadataspare", yes_no_arg, 0)
-arg(profile_ARG, '\0', "profile", string_arg, 0)
-arg(pvmetadatacopies_ARG, '\0', "pvmetadatacopies", int_arg, 0)
-arg(raidmaxrecoveryrate_ARG, '\0', "raidmaxrecoveryrate", size_kb_arg, 0)
-arg(raidminrecoveryrate_ARG, '\0', "raidminrecoveryrate", size_kb_arg, 0)
-arg(raidsyncaction_ARG, '\0', "raidsyncaction", string_arg, 0)
-arg(raidwritebehind_ARG, '\0', "raidwritebehind", int_arg, 0)
-arg(raidwritemostly_ARG, '\0', "raidwritemostly", string_arg, ARG_GROUPABLE)
-arg(readonly_ARG, '\0', "readonly", NULL, 0)
-arg(refresh_ARG, '\0', "refresh", NULL, 0)
-arg(removemissing_ARG, '\0', "removemissing", NULL, 0)
-arg(repair_ARG, '\0', "repair", NULL, 0)
-arg(replace_ARG, '\0', "replace", string_arg, ARG_GROUPABLE)
-arg(reportformat_ARG, '\0', "reportformat", string_arg, 0)
-arg(restorefile_ARG, '\0', "restorefile", string_arg, 0)
-arg(restoremissing_ARG, '\0', "restoremissing", NULL, 0)
-arg(resync_ARG, '\0', "resync", NULL, 0)
-arg(rows_ARG, '\0', "rows", NULL, 0)
-arg(segments_ARG, '\0', "segments", NULL, 0)
-arg(separator_ARG, '\0', "separator", string_arg, 0)
-arg(shared_ARG, '\0', "shared", NULL, 0)
-arg(sinceversion_ARG, '\0', "sinceversion", string_arg, 0)
-arg(split_ARG, '\0', "split", NULL, 0)
-arg(splitcache_ARG, '\0', "splitcache", NULL, 0)
-arg(splitmirrors_ARG, '\0', "splitmirrors", int_arg, 0)
-arg(splitsnapshot_ARG, '\0', "splitsnapshot", NULL, 0)
-arg(showdeprecated_ARG, '\0', "showdeprecated", NULL, 0)
-arg(showunsupported_ARG, '\0', "showunsupported", NULL, 0)
-arg(stripes_long_ARG, '\0', "stripes", int_arg, 0)
-arg(syncaction_ARG, '\0', "syncaction", string_arg, 0)	/* FIXME Use custom validation fn */
-arg(sysinit_ARG, '\0', "sysinit", NULL, 0)
-arg(systemid_ARG, '\0', "systemid", string_arg, 0)
-arg(thinpool_ARG, '\0', "thinpool", string_arg, 0)
-arg(trackchanges_ARG, '\0', "trackchanges", NULL, 0)
-arg(trustcache_ARG, '\0', "trustcache", NULL, 0)
-arg(type_ARG, '\0', "type", segtype_arg, 0)
-arg(unbuffered_ARG, '\0', "unbuffered", NULL, 0)
-arg(uncache_ARG, '\0', "uncache", NULL, 0)
-arg(cachepolicy_ARG, '\0', "cachepolicy", string_arg, 0)
-arg(cachesettings_ARG, '\0', "cachesettings", string_arg, ARG_GROUPABLE)
-arg(unconfigured_ARG, '\0', "unconfigured", NULL, 0)
-arg(units_ARG, '\0', "units", string_arg, 0)
-arg(unquoted_ARG, '\0', "unquoted", NULL, 0)
-arg(usepolicies_ARG, '\0', "usepolicies", NULL, 0)
-arg(validate_ARG, '\0', "validate", NULL, 0)
-arg(version_ARG, '\0', "version", NULL, 0)
-arg(vgmetadatacopies_ARG, '\0', "vgmetadatacopies", metadatacopies_arg, 0)
-arg(virtualoriginsize_ARG, '\0', "virtualoriginsize", size_mb_arg, 0)
-arg(withsummary_ARG, '\0', "withsummary", NULL, 0)
-arg(withcomments_ARG, '\0', "withcomments", NULL, 0)
-arg(withspaces_ARG, '\0', "withspaces", NULL, 0)
-arg(withversions_ARG, '\0', "withversions", NULL, 0)
-arg(writebehind_ARG, '\0', "writebehind", int_arg, 0)
-arg(writemostly_ARG, '\0', "writemostly", string_arg, ARG_GROUPABLE)
+arg(abort_ARG, '\0', "abort", NULL, 0, 0)
+arg(activationmode_ARG, '\0', "activationmode", string_arg, 0, 0)
+arg(addtag_ARG, '\0', "addtag", tag_arg, ARG_GROUPABLE, 0)
+arg(aligned_ARG, '\0', "aligned", NULL, 0, 0)
+arg(alloc_ARG, '\0', "alloc", alloc_arg, 0, 0)
+arg(atomic_ARG, '\0', "atomic", NULL, 0, 0)
+arg(atversion_ARG, '\0', "atversion", string_arg, 0, 0)
+arg(binary_ARG, '\0', "binary", NULL, 0, 0)
+arg(bootloaderareasize_ARG, '\0', "bootloaderareasize", size_mb_arg, 0, 0)
+arg(cache_long_ARG, '\0', "cache", NULL, 0, 0)
+arg(cachemode_ARG, '\0', "cachemode", cachemode_arg, 0, 0)
+arg(cachepool_ARG, '\0', "cachepool", string_arg, 0, 0)
+arg(commandprofile_ARG, '\0', "commandprofile", string_arg, 0, 0)
+arg(config_ARG, '\0', "config", string_arg, 0, 0)
+arg(configtype_ARG, '\0', "type", string_arg, 0, 0)
+arg(corelog_ARG, '\0', "corelog", NULL, 0, 0)
+arg(dataalignment_ARG, '\0', "dataalignment", size_kb_arg, 0, 0)
+arg(dataalignmentoffset_ARG, '\0', "dataalignmentoffset", size_kb_arg, 0, 0)
+arg(deltag_ARG, '\0', "deltag", tag_arg, ARG_GROUPABLE, 0)
+arg(detachprofile_ARG, '\0', "detachprofile", NULL, 0, 0)
+arg(discards_ARG, '\0', "discards", discards_arg, 0, 0)
+arg(driverloaded_ARG, '\0', "driverloaded", yes_no_arg, 0, 0)
+arg(errorwhenfull_ARG, '\0', "errorwhenfull", yes_no_arg, 0, 0)
+arg(force_long_ARG, '\0', "force", NULL, ARG_COUNTABLE, 0)
+arg(foreign_ARG, '\0', "foreign", NULL, 0, 0)
+arg(handlemissingpvs_ARG, '\0', "handlemissingpvs", NULL, 0, 0)
+arg(ignoreadvanced_ARG, '\0', "ignoreadvanced", NULL, 0, 0)
+arg(ignorelocal_ARG, '\0', "ignorelocal", NULL, 0, 0)
+arg(ignorelockingfailure_ARG, '\0', "ignorelockingfailure", NULL, 0, 0)
+arg(ignoremonitoring_ARG, '\0', "ignoremonitoring", NULL, 0, 0)
+arg(ignoreskippedcluster_ARG, '\0', "ignoreskippedcluster", NULL, 0, 0)
+arg(ignoreunsupported_ARG, '\0', "ignoreunsupported", NULL, 0, 0)
+arg(labelsector_ARG, '\0', "labelsector", int_arg, 0, 0)
+arg(lockopt_ARG, '\0', "lockopt", string_arg, 0, 0)
+arg(lockstart_ARG, '\0', "lockstart", NULL, 0, 0)
+arg(lockstop_ARG, '\0', "lockstop", NULL, 0, 0)
+arg(locktype_ARG, '\0', "locktype", locktype_arg, 0, 0)
+arg(maxrecoveryrate_ARG, '\0', "maxrecoveryrate", size_kb_arg, 0, 0)
+arg(merge_ARG, '\0', "merge", NULL, 0, 0)
+arg(mergedconfig_ARG, '\0', "mergedconfig", NULL, 0, 0)
+arg(metadatacopies_ARG, '\0', "metadatacopies", metadatacopies_arg, 0, 0)
+arg(metadataignore_ARG, '\0', "metadataignore", yes_no_arg, 0, 0)
+arg(metadataprofile_ARG, '\0', "metadataprofile", string_arg, 0, 0)
+arg(metadatasize_ARG, '\0', "metadatasize", size_mb_arg, 0, 0)
+arg(minor_ARG, '\0', "minor", int_arg, ARG_GROUPABLE, 0)
+arg(minrecoveryrate_ARG, '\0', "minrecoveryrate", size_kb_arg, 0, 0)
+arg(mirrorlog_ARG, '\0', "mirrorlog", mirrorlog_arg, 0, 0)
+arg(mirrorsonly_ARG, '\0', "mirrorsonly", NULL, 0, 0)
+arg(mknodes_ARG, '\0', "mknodes", NULL, 0, 0)
+arg(monitor_ARG, '\0', "monitor", yes_no_arg, 0, 0)
+arg(nameprefixes_ARG, '\0', "nameprefixes", NULL, 0, 0)
+arg(noheadings_ARG, '\0', "noheadings", NULL, 0, 0)
+arg(nohistory_ARG, '\0', "nohistory", NULL, 0, 0)
+arg(nolocking_ARG, '\0', "nolocking", NULL, 0, 0)
+arg(norestorefile_ARG, '\0', "norestorefile", NULL, 0, 0)
+arg(nosuffix_ARG, '\0', "nosuffix", NULL, 0, 0)
+arg(nosync_ARG, '\0', "nosync", NULL, 0, 0)
+arg(notifydbus_ARG, '\0', "notifydbus", NULL, 0, 0)
+arg(noudevsync_ARG, '\0', "noudevsync", NULL, 0, 0)
+arg(originname_ARG, '\0', "originname", string_arg, 0, 0)
+arg(physicalvolumesize_ARG, '\0', "setphysicalvolumesize", size_mb_arg, 0, 0)
+arg(poll_ARG, '\0', "poll", yes_no_arg, 0, 0)
+arg(polloperation_ARG, '\0', "polloperation", string_arg, 0, 0)
+arg(pooldatasize_ARG, '\0', "pooldatasize", size_mb_arg, 0, 0)
+arg(poolmetadata_ARG, '\0', "poolmetadata", string_arg, 0, 0)
+arg(poolmetadatasize_ARG, '\0', "poolmetadatasize", size_mb_arg, 0, 0)
+arg(poolmetadataspare_ARG, '\0', "poolmetadataspare", yes_no_arg, 0, 0)
+arg(profile_ARG, '\0', "profile", string_arg, 0, 0)
+arg(pvmetadatacopies_ARG, '\0', "pvmetadatacopies", int_arg, 0, 0)
+arg(raidmaxrecoveryrate_ARG, '\0', "raidmaxrecoveryrate", size_kb_arg, 0, 0)
+arg(raidminrecoveryrate_ARG, '\0', "raidminrecoveryrate", size_kb_arg, 0, 0)
+arg(raidsyncaction_ARG, '\0', "raidsyncaction", string_arg, 0, 0)
+arg(raidwritebehind_ARG, '\0', "raidwritebehind", int_arg, 0, 0)
+arg(raidwritemostly_ARG, '\0', "raidwritemostly", string_arg, ARG_GROUPABLE, 0)
+arg(readonly_ARG, '\0', "readonly", NULL, 0, 0)
+arg(refresh_ARG, '\0', "refresh", NULL, 0, 0)
+arg(removemissing_ARG, '\0', "removemissing", NULL, 0, 0)
+arg(repair_ARG, '\0', "repair", NULL, 0, 0)
+arg(replace_ARG, '\0', "replace", string_arg, ARG_GROUPABLE, 0)
+arg(reportformat_ARG, '\0', "reportformat", string_arg, 0, 0)
+arg(restorefile_ARG, '\0', "restorefile", string_arg, 0, 0)
+arg(restoremissing_ARG, '\0', "restoremissing", NULL, 0, 0)
+arg(resync_ARG, '\0', "resync", NULL, 0, 0)
+arg(rows_ARG, '\0', "rows", NULL, 0, 0)
+arg(segments_ARG, '\0', "segments", NULL, 0, 0)
+arg(separator_ARG, '\0', "separator", string_arg, 0, 0)
+arg(shared_ARG, '\0', "shared", NULL, 0, 0)
+arg(sinceversion_ARG, '\0', "sinceversion", string_arg, 0, 0)
+arg(split_ARG, '\0', "split", NULL, 0, 0)
+arg(splitcache_ARG, '\0', "splitcache", NULL, 0, 0)
+arg(splitmirrors_ARG, '\0', "splitmirrors", int_arg, 0, 0)
+arg(splitsnapshot_ARG, '\0', "splitsnapshot", NULL, 0, 0)
+arg(showdeprecated_ARG, '\0', "showdeprecated", NULL, 0, 0)
+arg(showunsupported_ARG, '\0', "showunsupported", NULL, 0, 0)
+arg(stripes_long_ARG, '\0', "stripes", int_arg, 0, 0)
+arg(syncaction_ARG, '\0', "syncaction", string_arg, 0, 0)	/* FIXME Use custom validation fn */
+arg(sysinit_ARG, '\0', "sysinit", NULL, 0, 0)
+arg(systemid_ARG, '\0', "systemid", string_arg, 0, 0)
+arg(thinpool_ARG, '\0', "thinpool", string_arg, 0, 0)
+arg(trackchanges_ARG, '\0', "trackchanges", NULL, 0, 0)
+arg(trustcache_ARG, '\0', "trustcache", NULL, 0, 0)
+arg(type_ARG, '\0', "type", segtype_arg, 0, 0)
+arg(unbuffered_ARG, '\0', "unbuffered", NULL, 0, 0)
+arg(uncache_ARG, '\0', "uncache", NULL, 0, 0)
+arg(cachepolicy_ARG, '\0', "cachepolicy", string_arg, 0, 0)
+arg(cachesettings_ARG, '\0', "cachesettings", string_arg, ARG_GROUPABLE, 0)
+arg(unconfigured_ARG, '\0', "unconfigured", NULL, 0, 0)
+arg(units_ARG, '\0', "units", string_arg, 0, 0)
+arg(unquoted_ARG, '\0', "unquoted", NULL, 0, 0)
+arg(usepolicies_ARG, '\0', "usepolicies", NULL, 0, 0)
+arg(validate_ARG, '\0', "validate", NULL, 0, 0)
+arg(version_ARG, '\0', "version", NULL, 0, 0)
+arg(vgmetadatacopies_ARG, '\0', "vgmetadatacopies", metadatacopies_arg, 0, 0)
+arg(virtualoriginsize_ARG, '\0', "virtualoriginsize", size_mb_arg, 0, 0)
+arg(withsummary_ARG, '\0', "withsummary", NULL, 0, 0)
+arg(withcomments_ARG, '\0', "withcomments", NULL, 0, 0)
+arg(withspaces_ARG, '\0', "withspaces", NULL, 0, 0)
+arg(withversions_ARG, '\0', "withversions", NULL, 0, 0)
+arg(writebehind_ARG, '\0', "writebehind", int_arg, 0, 0)
+arg(writemostly_ARG, '\0', "writemostly", string_arg, ARG_GROUPABLE, 0)
 
 /* Allow some variations */
-arg(allocation_ARG, '\0', "allocation", yes_no_arg, 0)
-arg(available_ARG, '\0', "available", activation_arg, 0)
-arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
+arg(allocation_ARG, '\0', "allocation", yes_no_arg, 0, 0)
+arg(available_ARG, '\0', "available", activation_arg, 0, 0)
+arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0, 0)
 
 /*
  * ... and now the short args.
  */
-arg(activate_ARG, 'a', "activate", activation_arg, 0)
-arg(all_ARG, 'a', "all", NULL, 0)
-arg(autobackup_ARG, 'A', "autobackup", yes_no_arg, 0)
-arg(activevolumegroups_ARG, 'A', "activevolumegroups", NULL, 0)
-arg(background_ARG, 'b', "background", NULL, 0)
-arg(backgroundfork_ARG, 'b', "background", NULL, 0)
-arg(blockdevice_ARG, 'b', "blockdevice", NULL, 0)
-arg(chunksize_ARG, 'c', "chunksize", size_kb_arg, 0)
-arg(clustered_ARG, 'c', "clustered", yes_no_arg, 0)
-arg(colon_ARG, 'c', "colon", NULL, 0)
-arg(columns_ARG, 'C', "columns", NULL, 0)
-arg(contiguous_ARG, 'C', "contiguous", yes_no_arg, 0)
-arg(debug_ARG, 'd', "debug", NULL, ARG_COUNTABLE)
-arg(exported_ARG, 'e', "exported", NULL, 0)
-arg(physicalextent_ARG, 'E', "physicalextent", NULL, 0)
-arg(file_ARG, 'f', "file", string_arg, 0)
-arg(force_ARG, 'f', "force", NULL, ARG_COUNTABLE)
-arg(full_ARG, 'f', "full", NULL, 0)
-arg(help_ARG, 'h', "help", NULL, 0)
-arg(cache_ARG, 'H', "cache", NULL, 0)
-arg(history_ARG, 'H', "history", NULL, 0)
-arg(help2_ARG, '?', "", NULL, 0)
-arg(interval_ARG, 'i', "interval", int_arg, 0)
-arg(iop_version_ARG, 'i', "iop_version", NULL, 0)
-arg(stripes_ARG, 'i', "stripes", int_arg, 0)
-arg(stripesize_ARG, 'I', "stripesize", size_kb_arg, 0)
-arg(logicalvolume_ARG, 'l', "logicalvolume", int_arg, 0)
-arg(maxlogicalvolumes_ARG, 'l', "maxlogicalvolumes", int_arg, 0)
-arg(extents_ARG, 'l', "extents", int_arg_with_sign_and_percent, 0)
-arg(list_ARG, 'l', "list", NULL, 0)
-arg(lvmpartition_ARG, 'l', "lvmpartition", NULL, 0)
-arg(logicalextent_ARG, 'L', "logicalextent", int_arg_with_sign, 0)
-arg(size_ARG, 'L', "size", size_mb_arg, 0)
-arg(persistent_ARG, 'M', "persistent", yes_no_arg, 0)
-arg(major_ARG, 'j', "major", int_arg, ARG_GROUPABLE)
-arg(setactivationskip_ARG, 'k', "setactivationskip", yes_no_arg, 0)
-arg(ignoreactivationskip_ARG, 'K', "ignoreactivationskip", NULL, 0)
-arg(maps_ARG, 'm', "maps", NULL, 0)
-arg(mirrors_ARG, 'm', "mirrors", int_arg_with_sign, 0)
-arg(metadatatype_ARG, 'M', "metadatatype", metadatatype_arg, 0)
-arg(name_ARG, 'n', "name", string_arg, 0)
-arg(nofsck_ARG, 'n', "nofsck", NULL, 0)
-arg(novolumegroup_ARG, 'n', "novolumegroup", NULL, 0)
-arg(oldpath_ARG, 'n', "oldpath", NULL, 0)
-arg(options_ARG, 'o', "options", string_arg, ARG_GROUPABLE)
-arg(sort_ARG, 'O', "sort", string_arg, 0)
-arg(maxphysicalvolumes_ARG, 'p', "maxphysicalvolumes", int_arg, 0)
-arg(permission_ARG, 'p', "permission", permission_arg, 0)
-arg(partial_ARG, 'P', "partial", NULL, 0)
-arg(physicalvolume_ARG, 'P', "physicalvolume", NULL, 0)
-arg(quiet_ARG, 'q', "quiet", NULL, ARG_COUNTABLE)
-arg(readahead_ARG, 'r', "readahead", readahead_arg, 0)
-arg(resizefs_ARG, 'r', "resizefs", NULL, 0)
-arg(reset_ARG, 'R', "reset", NULL, 0)
-arg(regionsize_ARG, 'R', "regionsize", size_mb_arg, 0)
-arg(physicalextentsize_ARG, 's', "physicalextentsize", size_mb_arg, 0)
-arg(snapshot_ARG, 's', "snapshot", NULL, 0)
-arg(short_ARG, 's', "short", NULL, 0)
-arg(stdin_ARG, 's', "stdin", NULL, 0)
-arg(select_ARG, 'S', "select", string_arg, 0)
-arg(test_ARG, 't', "test", NULL, 0)
-arg(thin_ARG, 'T', "thin", NULL, 0)
-arg(uuid_ARG, 'u', "uuid", NULL, 0)
-arg(uuidstr_ARG, 'u', "uuid", string_arg, 0)
-arg(uuidlist_ARG, 'U', "uuidlist", NULL, 0)
-arg(verbose_ARG, 'v', "verbose", NULL, ARG_COUNTABLE)
-arg(volumegroup_ARG, 'V', "volumegroup", NULL, 0)
-arg(virtualsize_ARG, 'V', "virtualsize", size_mb_arg, 0)
-arg(wipesignatures_ARG, 'W', "wipesignatures", yes_no_arg, 0)
-arg(allocatable_ARG, 'x', "allocatable", yes_no_arg, 0)
-arg(resizeable_ARG, 'x', "resizeable", yes_no_arg, 0)
-arg(yes_ARG, 'y', "yes", NULL, 0)
-arg(zero_ARG, 'Z', "zero", yes_no_arg, 0)
+arg(activate_ARG, 'a', "activate", activation_arg, 0, 0)
+arg(all_ARG, 'a', "all", NULL, 0, 0)
+arg(autobackup_ARG, 'A', "autobackup", yes_no_arg, 0, 0)
+arg(activevolumegroups_ARG, 'A', "activevolumegroups", NULL, 0, 0)
+arg(background_ARG, 'b', "background", NULL, 0, 0)
+arg(backgroundfork_ARG, 'b', "background", NULL, 0, 0)
+arg(blockdevice_ARG, 'b', "blockdevice", NULL, 0, 0)
+arg(chunksize_ARG, 'c', "chunksize", size_kb_arg, 0, 0)
+arg(clustered_ARG, 'c', "clustered", yes_no_arg, 0, 0)
+arg(colon_ARG, 'c', "colon", NULL, 0, 0)
+arg(columns_ARG, 'C', "columns", NULL, 0, 0)
+arg(contiguous_ARG, 'C', "contiguous", yes_no_arg, 0, 0)
+arg(debug_ARG, 'd', "debug", NULL, ARG_COUNTABLE, 0)
+arg(exported_ARG, 'e', "exported", NULL, 0, 0)
+arg(physicalextent_ARG, 'E', "physicalextent", NULL, 0, 0)
+arg(file_ARG, 'f', "file", string_arg, 0, 0)
+arg(force_ARG, 'f', "force", NULL, ARG_COUNTABLE, 0)
+arg(full_ARG, 'f', "full", NULL, 0, 0)
+arg(help_ARG, 'h', "help", NULL, 0, 0)
+arg(cache_ARG, 'H', "cache", NULL, 0, 0)
+arg(history_ARG, 'H', "history", NULL, 0, 0)
+arg(help2_ARG, '?', "", NULL, 0, 0)
+arg(interval_ARG, 'i', "interval", int_arg, 0, 0)
+arg(iop_version_ARG, 'i', "iop_version", NULL, 0, 0)
+arg(stripes_ARG, 'i', "stripes", int_arg, 0, 0)
+arg(stripesize_ARG, 'I', "stripesize", size_kb_arg, 0, 0)
+arg(logicalvolume_ARG, 'l', "logicalvolume", int_arg, 0, 0)
+arg(maxlogicalvolumes_ARG, 'l', "maxlogicalvolumes", int_arg, 0, 0)
+arg(extents_ARG, 'l', "extents", int_arg_with_sign_and_percent, 0, 0)
+arg(list_ARG, 'l', "list", NULL, 0, 0)
+arg(lvmpartition_ARG, 'l', "lvmpartition", NULL, 0, 0)
+arg(logicalextent_ARG, 'L', "logicalextent", int_arg_with_sign, 0, 0)
+arg(size_ARG, 'L', "size", size_mb_arg, 0, 0)
+arg(persistent_ARG, 'M', "persistent", yes_no_arg, 0, 0)
+arg(major_ARG, 'j', "major", int_arg, ARG_GROUPABLE, 0)
+arg(setactivationskip_ARG, 'k', "setactivationskip", yes_no_arg, 0, 0)
+arg(ignoreactivationskip_ARG, 'K', "ignoreactivationskip", NULL, 0, 0)
+arg(maps_ARG, 'm', "maps", NULL, 0, 0)
+arg(mirrors_ARG, 'm', "mirrors", int_arg_with_sign, 0, 0)
+arg(metadatatype_ARG, 'M', "metadatatype", metadatatype_arg, 0, 0)
+arg(name_ARG, 'n', "name", string_arg, 0, 0)
+arg(nofsck_ARG, 'n', "nofsck", NULL, 0, 0)
+arg(novolumegroup_ARG, 'n', "novolumegroup", NULL, 0, 0)
+arg(oldpath_ARG, 'n', "oldpath", NULL, 0, 0)
+arg(options_ARG, 'o', "options", string_arg, ARG_GROUPABLE, 0)
+arg(sort_ARG, 'O', "sort", string_arg, 0, 0)
+arg(maxphysicalvolumes_ARG, 'p', "maxphysicalvolumes", int_arg, 0, 0)
+arg(permission_ARG, 'p', "permission", permission_arg, 0, 0)
+arg(partial_ARG, 'P', "partial", NULL, 0, 0)
+arg(physicalvolume_ARG, 'P', "physicalvolume", NULL, 0, 0)
+arg(quiet_ARG, 'q', "quiet", NULL, ARG_COUNTABLE, 0)
+arg(readahead_ARG, 'r', "readahead", readahead_arg, 0, 0)
+arg(resizefs_ARG, 'r', "resizefs", NULL, 0, 0)
+arg(reset_ARG, 'R', "reset", NULL, 0, 0)
+arg(regionsize_ARG, 'R', "regionsize", size_mb_arg, 0, 0)
+arg(physicalextentsize_ARG, 's', "physicalextentsize", size_mb_arg, 0, 0)
+arg(snapshot_ARG, 's', "snapshot", NULL, 0, 0)
+arg(short_ARG, 's', "short", NULL, 0, 0)
+arg(stdin_ARG, 's', "stdin", NULL, 0, 0)
+arg(select_ARG, 'S', "select", string_arg, 0, 0)
+arg(test_ARG, 't', "test", NULL, 0, 0)
+arg(thin_ARG, 'T', "thin", NULL, 0, 0)
+arg(uuid_ARG, 'u', "uuid", NULL, 0, 0)
+arg(uuidstr_ARG, 'u', "uuid", string_arg, 0, 0)
+arg(uuidlist_ARG, 'U', "uuidlist", NULL, 0, 0)
+arg(verbose_ARG, 'v', "verbose", NULL, ARG_COUNTABLE, 0)
+arg(volumegroup_ARG, 'V', "volumegroup", NULL, 0, 0)
+arg(virtualsize_ARG, 'V', "virtualsize", size_mb_arg, 0, 0)
+arg(wipesignatures_ARG, 'W', "wipesignatures", yes_no_arg, 0, 0)
+arg(allocatable_ARG, 'x', "allocatable", yes_no_arg, 0, 0)
+arg(resizeable_ARG, 'x', "resizeable", yes_no_arg, 0, 0)
+arg(yes_ARG, 'y', "yes", NULL, 0, 0)
+arg(zero_ARG, 'Z', "zero", yes_no_arg, 0, 0)
 
 /* this should always be last */
-arg(ARG_COUNT, '-', "", NULL, 0)
+arg(ARG_COUNT, '-', "", NULL, 0, 0)
 /* *INDENT-ON* */
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 452e6aa..5533cb1 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -53,7 +53,7 @@ extern char *optarg;
  * Table of valid switches
  */
 static struct arg_props _arg_props[ARG_COUNT + 1] = {
-#define arg(a, b, c, d, e) {b, "", "--" c, d, e},
+#define arg(a, b, c, d, e, f) {b, "", "--" c, d, e, f},
 #include "args.h"
 #undef arg
 };
@@ -920,14 +920,22 @@ static int _process_command_line(struct cmd_context *cmd, int *argc,
 		av = &cmd->arg_values[arg];
 
 		if (a->flags & ARG_GROUPABLE) {
-			/* Start a new group of arguments the first time or if a non-countable argument is repeated. */
-			if (!current_group || (current_group->arg_values[arg].count && !(a->flags & ARG_COUNTABLE))) {
+			/*
+			 * Start a new group of arguments:
+			 *   - the first time,
+			 *   - or if a non-countable argument is repeated,
+			 *   - or if argument has higher priority than current group.
+			 */
+			if (!current_group ||
+			    (current_group->arg_values[arg].count && !(a->flags & ARG_COUNTABLE)) ||
+			    (current_group->prio < a->prio)) {
 				/* FIXME Reduce size including only groupable args */
 				if (!(current_group = dm_pool_zalloc(cmd->mem, sizeof(struct arg_value_group_list) + sizeof(*cmd->arg_values) * ARG_COUNT))) {
 					log_fatal("Unable to allocate memory for command line arguments.");
 					return 0;
 				}
 
+				current_group->prio = a->prio;
 				dm_list_add(&cmd->arg_value_groups, &current_group->list);
 			}
 			/* Maintain total argument count as well as count within each group */
diff --git a/tools/tools.h b/tools/tools.h
index 8704749..f6d224f 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -59,7 +59,7 @@ typedef int (*command_fn) (struct cmd_context * cmd, int argc, char **argv);
 
 /* define the enums for the command line switches */
 enum {
-#define arg(a, b, c, d, e) a ,
+#define arg(a, b, c, d, e, f) a ,
 #include "args.h"
 #undef arg
 };
@@ -87,11 +87,13 @@ struct arg_props {
 
 	int (*fn) (struct cmd_context *cmd, struct arg_values *av);
 	uint32_t flags;
+	uint32_t prio;
 };
 
 struct arg_value_group_list {
         struct dm_list list;
         struct arg_values arg_values[0];
+	uint32_t prio;
 };
 
 #define CACHE_VGMETADATA	0x00000001


