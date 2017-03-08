From: David Teigland <teigland@sourceware.org>
Date: Wed, 8 Mar 2017 15:44:10 -0500
Subject: master - man: add more references to topical man pages
Message-ID: <201703082044.v28Ki8BZ025383@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3d5182c81946bb7e7e0a704ce3e4585968055dc8
Commit:        3d5182c81946bb7e7e0a704ce3e4585968055dc8
Parent:        14c7912f45ec9df0fc72e1e3844f04faf6590edf
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Mar 8 14:43:30 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 8 14:43:30 2017 -0600

man: add more references to topical man pages

---
 tools/args.h |   65 ++++++++++++++++++++++++++++++++++-----------------------
 1 files changed, 39 insertions(+), 26 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 821c56d..a9ffe5b 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -37,7 +37,8 @@ arg(activationmode_ARG, '\0', "activationmode", activationmode_VAL, 0, 0,
     "(This does not include the \"mirror\" type, see \"raid1\" instead.)\n"
     "\\fBpartial\\fP allows any LV with missing PVs to be activated, and\n"
     "should only be used for recovery or repair.\n"
-    "For default, see lvm.conf/activation_mode.\n")
+    "For default, see lvm.conf/activation_mode.\n"
+    "See \\fBlvmraid\\fP(7) for more information.\n")
 
 arg(addtag_ARG, '\0', "addtag", tag_VAL, ARG_GROUPABLE, 0,
     "Adds a tag to a PV, VG or LV. This option can be repeated to add\n"
@@ -62,7 +63,7 @@ arg(alloc_ARG, '\0', "alloc", alloc_VAL, 0, 0,
     "e.g. by placing two stripes on the same PV.\n"
     "Optional positional PV args on the command line can also be used to limit\n"
     "which PVs the command will use for allocation.\n"
-    "See lvm(8) for more information about allocation.\n")
+    "See \\fBlvm\\fP(8) for more information about allocation.\n")
 
 arg(atomic_ARG, '\0', "atomic", 0, 0, 0,
     "Makes a pvmove operation atomic, ensuring that all affected LVs are\n"
@@ -119,13 +120,13 @@ arg(cachepool_ARG, '\0', "cachepool", lv_VAL, 0, 0,
 
 arg(commandprofile_ARG, '\0', "commandprofile", string_VAL, 0, 0,
     "The command profile to use for command configuration.\n"
-    "See lvm.conf(5) for more information about profiles.\n")
+    "See \\fBlvm.conf\\fP(5) for more information about profiles.\n")
 
 arg(config_ARG, '\0', "config", string_VAL, 0, 0,
     "Config settings for the command. These override lvm.conf settings.\n"
     "The String arg uses the same format as lvm.conf,\n"
     "or may use section/field syntax.\n"
-    "See lvm.conf(5) for more information about config.\n")
+    "See \\fBlvm.conf\\fP(5) for more information about config.\n")
 
 arg(configreport_ARG, '\0', "configreport", configreport_VAL, ARG_GROUPABLE, 1,
     "See lvmreport(7).\n")
@@ -149,7 +150,7 @@ arg(deltag_ARG, '\0', "deltag", tag_VAL, ARG_GROUPABLE, 0,
 
 arg(detachprofile_ARG, '\0', "detachprofile", 0, 0, 0,
     "Detaches a metadata profile from a VG or LV.\n"
-    "See lvm.conf(5) for more information about profiles.\n")
+    "See \\fBlvm.conf\\fP(5) for more information about profiles.\n")
 
 arg(discards_ARG, '\0', "discards", discards_VAL, 0, 0,
     "Specifies how the device-mapper thin pool layer in the kernel should\n"
@@ -158,7 +159,8 @@ arg(discards_ARG, '\0', "discards", discards_VAL, 0, 0,
     "\\fBnopassdown\\fP causes the thin pool to process discards itself to\n"
     "allow reuse of unneeded extents in the thin pool.\n"
     "\\fBpassdown\\fP causes the thin pool to process discards itself\n"
-    "(like nopassdown) and pass the discards to the underlying device.\n")
+    "(like nopassdown) and pass the discards to the underlying device.\n"
+    "See \\fBlvmthin\\fP(7) for more information.\n")
 
 arg(driverloaded_ARG, '\0', "driverloaded", bool_VAL, 0, 0,
     "If set to no, the command will not attempt to use device-mapper.\n"
@@ -171,7 +173,8 @@ arg(errorwhenfull_ARG, '\0', "errorwhenfull", bool_VAL, 0, 0,
     "When no, device-mapper will queue these I/O requests for a\n"
     "period of time to allow the thin pool to be extended.\n"
     "Errors are returned if no space is available after the timeout.\n"
-    "(Also see dm-thin-pool kernel module option no_space_timeout.)\n")
+    "(Also see dm-thin-pool kernel module option no_space_timeout.)\n"
+    "See \\fBlvmthin\\fP(7) for more information.\n")
 
 arg(force_long_ARG, '\0', "force", 0, ARG_COUNTABLE, 0,
     "Force metadata restore even with thin pool LVs.\n"
@@ -250,7 +253,8 @@ arg(longhelp_ARG, '\0', "longhelp", 0, 0, 0,
 arg(maxrecoveryrate_ARG, '\0', "maxrecoveryrate", sizekb_VAL, 0, 0,
     "Sets the maximum recovery rate for a RAID LV.  The rate value\n"
     "is an amount of data per second for each device in the array.\n"
-    "Setting the rate to 0 means it will be unbounded.\n")
+    "Setting the rate to 0 means it will be unbounded.\n"
+    "See \\fBlvmraid\\fP(7) for more information.\n")
 
 arg(merge_ARG, '\0', "merge", 0, 0, 0,
     "An alias for --mergethin, --mergemirrors, or --mergesnapshot,\n"
@@ -277,7 +281,8 @@ arg(mergesnapshot_ARG, '\0', "mergesnapshot", 0, 0, 0,
 arg(mergethin_ARG, '\0', "mergethin", 0, 0, 0,
     "Merge thin LV into its origin LV.\n"
     "The origin thin LV takes the content of the thin snapshot,\n"
-    "and the thin snapshot LV is removed.\n")
+    "and the thin snapshot LV is removed.\n"
+    "See \\fBlvmthin\\fP(7) for more information.\n")
 
 arg(mergedconfig_ARG, '\0', "mergedconfig", 0, 0, 0,
     "When the command is run with --config\n"
@@ -286,7 +291,7 @@ arg(mergedconfig_ARG, '\0', "mergedconfig", 0, 0, 0,
     "merge all the contents of the \"config cascade\" before displaying it.\n"
     "Without merging, only the configuration at the front of the\n"
     "cascade is displayed.\n"
-    "See lvm.conf(5) for more information about config.\n")
+    "See \\fBlvm.conf\\fP(5) for more information about config.\n")
 
 arg(metadataignore_ARG, '\0', "metadataignore", bool_VAL, 0, 0,
     "Specifies the metadataignore property of a PV.\n"
@@ -296,7 +301,7 @@ arg(metadataignore_ARG, '\0', "metadataignore", bool_VAL, 0, 0,
 
 arg(metadataprofile_ARG, '\0', "metadataprofile", string_VAL, 0, 0,
     "The metadata profile to use for command configuration.\n"
-    "See lvm.conf(5) for more information about profiles.\n")
+    "See \\fBlvm.conf\\fP(5) for more information about profiles.\n")
 
 arg(metadatasize_ARG, '\0', "metadatasize", sizemb_VAL, 0, 0,
     "The approximate amount of space used for each VG metadata area.\n"
@@ -312,7 +317,8 @@ arg(minor_ARG, '\0', "minor", number_VAL, ARG_GROUPABLE, 0,
 arg(minrecoveryrate_ARG, '\0', "minrecoveryrate", sizekb_VAL, 0, 0,
     "Sets the minimum recovery rate for a RAID LV.  The rate value\n"
     "is an amount of data per second for each device in the array.\n"
-    "Setting the rate to 0 means it will be unbounded.\n")
+    "Setting the rate to 0 means it will be unbounded.\n"
+    "See \\fBlvmraid\\fP(7) for more information.\n")
 
 arg(mirrorlog_ARG, '\0', "mirrorlog", mirrorlog_VAL, 0, 0,
     "Specifies the type of mirror log for LVs with the \"mirror\" type\n"
@@ -477,16 +483,19 @@ arg(rebuild_ARG, '\0', "rebuild", pv_VAL, ARG_GROUPABLE, 0,
     "repeating this option.\n"
     "Use this option in place of --resync or --syncaction repair when the\n"
     "PVs with corrupted data are known, and their data should be reconstructed\n"
-    "rather than reconstructing default (rotating) data.\n")
+    "rather than reconstructing default (rotating) data.\n"
+    "See \\fBlvmraid\\fP(7) for more information.\n")
 
 arg(repair_ARG, '\0', "repair", 0, 0, 0,
     "Replace failed PVs in a raid or mirror LV, or run a repair\n"
-    "utility on a thin pool.\n")
+    "utility on a thin pool. See \\fBlvmraid\\fP(7) and \\fBlvmthin\\fP(7)\n"
+    "for more information.\n")
 
 arg(replace_ARG, '\0', "replace", pv_VAL, ARG_GROUPABLE, 0,
     "Replace a specific PV in a raid LV with another PV.\n"
     "The new PV to use can be optionally specified after the LV.\n"
-    "Multiple PVs can be replaced by repeating this option.\n")
+    "Multiple PVs can be replaced by repeating this option.\n"
+    "See \\fBlvmraid\\fP(7) for more information.\n")
 
 arg(reportformat_ARG, '\0', "reportformat", reportformat_VAL, 0, 0,
     "Overrides current output format for reports which is defined globally by\n"
@@ -494,7 +503,7 @@ arg(reportformat_ARG, '\0', "reportformat", reportformat_VAL, 0, 0,
     "\\fBbasic\\fP is the original format with columns and rows.\n"
     "If there is more than one report per command, each report is prefixed\n"
     "with the report name for identification. \\fBjson\\fP produces report\n"
-    "output in JSON format.\n")
+    "output in JSON format. See \\fBlvmreport\\fP(7) for more information.\n")
 
 arg(restorefile_ARG, '\0', "restorefile", string_VAL, 0, 0,
     "In conjunction with --uuid, this reads the file (produced by\n"
@@ -515,7 +524,8 @@ arg(resync_ARG, '\0', "resync", 0, 0, 0,
     "Also see --rebuild to synchronize a specific PV.\n"
     "During synchronization, data is read from the primary mirror device\n"
     "and copied to the others. This can take considerable time, during\n"
-    "which the LV is without a complete redundant copy of the data.\n")
+    "which the LV is without a complete redundant copy of the data.\n"
+    "See \\fBlvmraid\\fP(7) for more information.\n")
 
 arg(rows_ARG, '\0', "rows", 0, 0, 0,
     "Output columns as rows.\n")
@@ -653,8 +663,8 @@ arg(trustcache_ARG, '\0', "trustcache", 0, 0, 0,
     "Avoids certain device scanning during command processing. Do not use.\n")
 
 arg(type_ARG, '\0', "type", segtype_VAL, 0, 0,
-    "Specifies an LV type, or \"segment type\".\n"
-    "See usage definitions for specific ways to use these types.\n"
+    "The LV type, also known as \"segment type\" or \"segtype\".\n"
+    "See usage descriptions for the specific ways to use these types.\n"
     "For more information about redundancy and performance (\\fBraid\\fP<N>, \\fBmirror\\fP, \\fBstriped\\fP, \\fBlinear\\fP) see \\fBlvmraid\\fP(7).\n"
     "For thin provisioning (\\fBthin\\fP, \\fBthin-pool\\fP) see \\fBlvmthin\\fP(7).\n"
     "For performance caching (\\fBcache\\fP, \\fBcache-pool\\fP) see \\fBlvmcache\\fP(7).\n"
@@ -673,7 +683,7 @@ arg(uncache_ARG, '\0', "uncache", 0, 0, 0,
 
 arg(cachepolicy_ARG, '\0', "cachepolicy", string_VAL, 0, 0,
     "Specifies the cache policy for a cache LV.\n"
-    "See lvmcache(7) for more information.\n")
+    "See \\fBlvmcache\\fP(7) for more information.\n")
 
 arg(cachesettings_ARG, '\0', "cachesettings", string_VAL, ARG_GROUPABLE, 0,
     "Specifies tunable values for a cache LV in \"Key = Value\" form.\n"
@@ -682,7 +692,7 @@ arg(cachesettings_ARG, '\0', "cachesettings", string_VAL, ARG_GROUPABLE, 0,
     "The special string value \\fBdefault\\fP switches\n"
     "settings back to their default kernel values and removes\n"
     "them from the list of settings stored in LVM metadata.\n"
-    "See lvmcache(7) for more information.\n")
+    "See \\fBlvmcache\\fP(7) for more information.\n")
 
 arg(unconfigured_ARG, '\0', "unconfigured", 0, 0, 0,
     "Internal option used for generating config file during build.\n")
@@ -884,7 +894,8 @@ arg(chunksize_ARG, 'c', "chunksize", sizekb_VAL, 0, 0,
     "For a thin pool the value must be between 64KiB and 1GiB\n"
     "and the default value starts with 64 and scales up to fit the\n"
     "pool metadata size within 128MiB, if the pool metadata size is not specified.\n"
-    "The value must be a multiple of 64KiB.\n")
+    "The value must be a multiple of 64KiB.\n"
+    "See \\fBlvmthin\\fP(7) and \\fBlvmcache\\fP(7) for more information.\n")
 
 arg(clustered_ARG, 'c', "clustered", bool_VAL, 0, 0,
     "#vgcreate\n"
@@ -950,7 +961,7 @@ arg(help_ARG, 'h', "help", 0, 0, 0,
 arg(cache_ARG, 'H', "cache", 0, 0, 0,
     "Specifies the command is handling a cache LV or cache pool.\n"
     "See --type cache and --type cache-pool.\n"
-    "See lvmcache(7) for more information about LVM caching.\n")
+    "See \\fBlvmcache\\fP(7) for more information about LVM caching.\n")
 
 arg(history_ARG, 'H', "history", 0, 0, 0,
     "Include historical LVs in the output.\n"
@@ -1121,6 +1132,7 @@ arg(mirrors_ARG, 'm', "mirrors", snumber_VAL, 0, 0,
     "Use lvm.conf global/mirror_segtype_default and\n"
     "global/raid10_segtype_default to configure the default types.\n"
     "See the --nosync option for avoiding initial image synchronization.\n"
+    "See \\fBlvmraid\\fP(7) for more information.\n"
     "#lvconvert\n"
     "Specifies the number of mirror images in addition to the original LV\n"
     "image, e.g. --mirrors 1 means there are two images of the data, the\n"
@@ -1137,6 +1149,7 @@ arg(mirrors_ARG, 'm', "mirrors", snumber_VAL, 0, 0,
     "the number is added to the current number of images,\n"
     "or the minus prefix \\fB-\\fP can be used, in which case\n"
     "the number is subtracted from the current number of images.\n"
+    "See \\fBlvmraid\\fP(7) for more information.\n"
     "#lvextend\n"
     "Not used.\n")
 
@@ -1272,7 +1285,7 @@ arg(snapshot_ARG, 's', "snapshot", 0, 0, 0,
     "when a thin pool is specified. Unprovisioned blocks in the thin snapshot\n"
     "LV are read from the external origin LV. The external origin LV must\n"
     "be read-only.\n"
-    "See lvmthin(7) for more information about LVM thin provisioning.\n"
+    "See \\fBlvmthin\\fP(7) for more information about LVM thin provisioning.\n"
     "COW snapshots are created when a size is specified. The size is allocated\n"
     "from space in the VG, and is the amount of space that can be used\n"
     "for saving COW blocks as writes occur to the origin or snapshot.\n"
@@ -1318,7 +1331,7 @@ arg(test_ARG, 't', "test", 0, 0, 0,
 arg(thin_ARG, 'T', "thin", 0, 0, 0,
     "Specifies the command is handling a thin LV or thin pool.\n"
     "See --type thin, --type thin-pool, and --virtualsize.\n"
-    "See lvmthin(7) for more information about LVM thin provisioning.\n")
+    "See \\fBlvmthin\\fP(7) for more information about LVM thin provisioning.\n")
 
 arg(uuid_ARG, 'u', "uuid", 0, 0, 0,
     "#pvchange\n"
@@ -1350,7 +1363,7 @@ arg(volumegroup_ARG, 'V', "volumegroup", 0, 0, 0, NULL)
 
 arg(virtualsize_ARG, 'V', "virtualsize", sizemb_VAL, 0, 0,
     "The virtual size of a new thin LV.\n"
-    "See lvmthin(7) for more information about LVM thin provisioning.\n"
+    "See \\fBlvmthin\\fP(7) for more information about LVM thin provisioning.\n"
     "Using virtual size (-V) and actual size (-L) together creates\n"
     "a sparse LV.\n"
     "lvm.conf global/sparse_segtype_default determines the\n"


