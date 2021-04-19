From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Apr 2021 13:00:56 +0000 (GMT)
Subject: main - args: documentation enhancements
Message-ID: <20210419130056.3FB813969019@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0f87b015b5f4251f9584244176b9f7c0579755e3
Commit:        0f87b015b5f4251f9584244176b9f7c0579755e3
Parent:        b1ad32acd63dedbd94b995f0d76f50343b751eff
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 15 21:41:33 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 19 14:40:14 2021 +0200

args: documentation enhancements

Use #DEFAULT_SYS_DIR# replaceable string for devicesfile
so the man pages installation respects configured settings.

Update some missing lvm.conf(5) references.
---
 tools/args.h | 48 ++++++++++++++++++++++++------------------------
 1 file changed, 24 insertions(+), 24 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 3dcffe224..93ee737ce 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -37,7 +37,7 @@ arg(activationmode_ARG, '\0', "activationmode", activationmode_VAL, 0, 0,
     "(This does not include the \"mirror\" type, see \"raid1\" instead.)\n"
     "\\fBpartial\\fP allows any LV with missing PVs to be activated, and\n"
     "should only be used for recovery or repair.\n"
-    "For default, see lvm.conf/activation_mode.\n"
+    "For default, see \\fBlvm.conf\\fP(5) activation_mode.\n"
     "See \\fBlvmraid\\fP(7) for more information.\n")
 
 arg(addtag_ARG, '\0', "addtag", tag_VAL, ARG_GROUPABLE, 0,
@@ -164,8 +164,8 @@ arg(compression_ARG, '\0', "compression", bool_VAL, 0, 0,
     "See \\fBlvmvdo\\fP(7) for more information about VDO usage.\n")
 
 arg(config_ARG, '\0', "config", string_VAL, 0, 0,
-    "Config settings for the command. These override lvm.conf settings.\n"
-    "The String arg uses the same format as lvm.conf,\n"
+    "Config settings for the command. These override \\fBlvm.conf\\fP(5) settings.\n"
+    "The String arg uses the same format as \\fBlvm.conf\\fP(5),\n"
     "or may use section/field syntax.\n"
     "See \\fBlvm.conf\\fP(5) for more information about config.\n")
 
@@ -235,10 +235,10 @@ arg(devices_ARG, '\0', "devices", pv_VAL, ARG_GROUPABLE, 0,
 
 arg(devicesfile_ARG, '\0', "devicesfile", string_VAL, 0, 0,
     "A file listing devices that LVM should use.\n"
-    "The file must exist in /etc/lvm/devices/ and is managed\n"
-    "with the lvmdevices(8) command.\n"
-    "This overrides the lvm.conf devices/devicesfile and\n"
-    "devices/use_devicesfile settings.\n")
+    "The file must exist in \\fI#DEFAULT_SYS_DIR#/devices/\\fP and is managed\n"
+    "with the \\fBlvmdevices\\fP(8) command.\n"
+    "This overrides the \\fBlvm.conf\\fP(5) \\fBdevices/devicesfile\\fP and\n"
+    "\\fBdevices/use_devicesfile\\fP settings.\n")
 
 arg(discards_ARG, '\0', "discards", discards_VAL, 0, 0,
     "Specifies how the device-mapper thin pool layer in the kernel should\n"
@@ -629,7 +629,7 @@ arg(replace_ARG, '\0', "replace", pv_VAL, ARG_GROUPABLE, 0,
 
 arg(reportformat_ARG, '\0', "reportformat", reportformat_VAL, 0, 0,
     "Overrides current output format for reports which is defined globally by\n"
-    "the report/output_format setting in lvm.conf.\n"
+    "the report/output_format setting in \\fBlvm.conf\\fP(5).\n"
     "\\fBbasic\\fP is the original format with columns and rows.\n"
     "If there is more than one report per command, each report is prefixed\n"
     "with the report name for identification. \\fBjson\\fP produces report\n"
@@ -751,7 +751,7 @@ arg(syncaction_ARG, '\0', "syncaction", syncaction_VAL, 0, 0,
     "(mismatches between mirrors or incorrect parity values).\n"
     "\\fBcheck\\fP will count but not correct discrepancies.\n"
     "\\fBrepair\\fP will correct discrepancies.\n"
-    "See lvs for reporting discrepancies found or repaired.\n")
+    "See \\fBlvs\\fP(8) for reporting discrepancies found or repaired.\n")
     
 arg(sysinit_ARG, '\0', "sysinit", 0, 0, 0,
     "Indicates that vgchange/lvchange is being invoked from early system initialisation\n"
@@ -845,7 +845,7 @@ arg(unquoted_ARG, '\0', "unquoted", 0, 0, 0,
     "pairs are not quoted.\n")
 
 arg(usepolicies_ARG, '\0', "usepolicies", 0, 0, 0,
-    "Perform an operation according to the policy configured in lvm.conf\n"
+    "Perform an operation according to the policy configured in \\fBlvm.conf\\fP(5)\n"
     "or a profile.\n")
 
 arg(validate_ARG, '\0', "validate", 0, 0, 0,
@@ -853,7 +853,7 @@ arg(validate_ARG, '\0', "validate", 0, 0, 0,
     "return code. The validation is done only for the configuration\n"
     "at the front of the \"config cascade\". To validate the whole\n"
     "merged configuration tree, also use --mergedconfig.\n"
-    "The validation is done even if lvm.conf config/checks is disabled.\n")
+    "The validation is done even if \\fBlvm.conf\\fP(5) \\fBconfig/checks\\fP is disabled.\n")
 
 arg(vdo_ARG, '\0', "vdo", 0, 0, 0,
     "Specifies the command is handling VDO LV.\n"
@@ -976,7 +976,7 @@ arg(activate_ARG, 'a', "activate", activation_VAL, 0, 0,
     "An autoactivation property can be set on a VG or LV to disable autoactivation,\n"
     "see --setautoactivation y|n in vgchange, lvchange, vgcreate, and lvcreate.\n"
     "Display the property with vgs or lvs \"-o autoactivation\".\n"
-    "The lvm.conf auto_activation_volume_list includes names of VGs or LVs\n"
+    "The \\fBlvm.conf\\fP(5) auto_activation_volume_list includes names of VGs or LVs\n"
     "that should be autoactivated, and anything not listed is not autoactivated.\n"
     "When auto_activation_volume_list is undefined (the default), it has no effect.\n"
     "If auto_activation_volume_list is defined and empty, no LVs are autoactivated.\n"
@@ -993,7 +993,7 @@ arg(activate_ARG, 'a', "activate", activation_VAL, 0, 0,
     "be created in the active state (this does not apply to thin snapshots).\n"
     "The --zero option normally requires the LV to be active.\n"
     "If autoactivation \\fBay\\fP is used, the LV is only activated\n"
-    "if it matches an item in lvm.conf activation/auto_activation_volume_list.\n"
+    "if it matches an item in \\fBlvm.conf\\fP(5) \\fBactivation/auto_activation_volume_list\\fP.\n"
     "\\fBay\\fP implies --zero n and --wipesignatures n.\n"
     "See \\fBlvmlockd\\fP(8) for more information about activation options for shared VGs.\n")
 
@@ -1114,7 +1114,7 @@ arg(cache_ARG, 'H', "cache", 0, 0, 0,
 arg(history_ARG, 'H', "history", 0, 0, 0,
     "Include historical LVs in the output.\n"
     "(This has no effect unless LVs were removed while\n"
-    "lvm.conf metadata/record_lvs_history was enabled.\n")
+    "\\fBlvm.conf\\fP(5) \\fBmetadata/record_lvs_history\\fP was enabled.\n")
 
 /* Not used */
 arg(help2_ARG, '?', "", 0, 0, 0, NULL)
@@ -1141,7 +1141,7 @@ arg(stripes_ARG, 'i', "stripes", number_VAL, 0, 0,
     "when unspecified, the default depends on the RAID type\n"
     "(raid0: 2, raid10: 2, raid4/5: 3, raid6: 5.)\n"
     "To stripe a new raid LV across all PVs by default,\n"
-    "see lvm.conf allocation/raid_stripe_all_devices.\n")
+    "see \\fBlvm.conf\\fP(5) \\fBallocation/raid_stripe_all_devices\\fP.\n")
 
 arg(stripesize_ARG, 'I', "stripesize", sizekb_VAL, 0, 0,
     "The amount of data that is written to one device before\n"
@@ -1277,7 +1277,7 @@ arg(mirrors_ARG, 'm', "mirrors", number_VAL, 0, 0,
     "These are the names of the corresponding LV types, or \"segment types\".\n"
     "Use the --type option to specify which to use (raid1 is default,\n"
     "and mirror is legacy)\n"
-    "Use lvm.conf global/mirror_segtype_default and\n"
+    "Use \\fBlvm.conf\\fP(5) \\fBglobal/mirror_segtype_default\\fP and\n"
     "global/raid10_segtype_default to configure the default types.\n"
     "See the --nosync option for avoiding initial image synchronization.\n"
     "See \\fBlvmraid\\fP(7) for more information.\n"
@@ -1291,7 +1291,7 @@ arg(mirrors_ARG, 'm', "mirrors", number_VAL, 0, 0,
     "These are the names of the corresponding LV types, or \"segment types\".\n"
     "Use the --type option to specify which to use (raid1 is default,\n"
     "and mirror is legacy)\n"
-    "Use lvm.conf global/mirror_segtype_default and\n"
+    "Use \\fBlvm.conf\\fP(5) \\fBglobal/mirror_segtype_default\\fP and\n"
     "global/raid10_segtype_default to configure the default types.\n"
     "The plus prefix \\fB+\\fP can be used, in which case\n"
     "the number is added to the current number of images,\n"
@@ -1336,7 +1336,7 @@ arg(oldpath_ARG, 'n', "oldpath", 0, 0, 0, NULL)
 
 arg(options_ARG, 'o', "options", string_VAL, ARG_GROUPABLE, 0,
     "Comma-separated, ordered list of fields to display in columns.\n"
-    "String arg syntax is: [+|-|#]Field1[,Field2 ...]\n"
+    "String arg syntax is: [\\fB+\\fP|\\fB-\\fP|\\fB#\\fP]\\fIField1\\fP[\\fB,\\fP\\fIField2\\fP ...]\n"
     "The prefix \\fB+\\fP will append the specified fields to the default fields,\n"
     "\\fB-\\fP will remove the specified fields from the default fields, and\n"
     "\\fB#\\fP will compact specified fields (removing them when empty for all rows.)\n"
@@ -1350,7 +1350,7 @@ arg(options_ARG, 'o', "options", string_VAL, ARG_GROUPABLE, 0,
     "\\fBpvseg_all\\fP all PV segment fields,\n"
     "\\fBseg_all\\fP all LV segment fields, and\n"
     "\\fBpvseg_all\\fP all PV segment columns.\n"
-    "See the lvm.conf report section for more config options.\n"
+    "See the \\fBlvm.conf\\fP(5) report section for more config options.\n"
     "See \\fBlvmreport\\fP(7) for more information about reporting.\n")
 
 arg(sort_ARG, 'O', "sort", string_VAL, ARG_GROUPABLE, 0,
@@ -1369,7 +1369,7 @@ arg(permission_ARG, 'p', "permission", permission_VAL, 0, 0,
 arg(partial_ARG, 'P', "partial", 0, 0, 0,
     "Commands will do their best to activate LVs with missing PV extents.\n"
     "Missing extents may be replaced with error or zero segments\n"
-    "according to the lvm.conf missing_stripe_filler setting.\n"
+    "according to the  missing_stripe_filler setting.\n"
     "Metadata may not be changed with this option.\n")
 
 /* Not used */
@@ -1393,7 +1393,7 @@ arg(reset_ARG, 'R', "reset", 0, 0, 0, NULL)
 
 arg(regionsize_ARG, 'R', "regionsize", regionsizemb_VAL, 0, 0,
     "Size of each raid or mirror synchronization region.\n"
-    "lvm.conf activation/raid_region_size can be used to\n"
+    "\\fBlvm.conf\\fP(5) \\fBactivation/raid_region_size\\fP can be used to\n"
     "configure a default.\n")
 
 arg(physicalextentsize_ARG, 's', "physicalextentsize", sizemb_VAL, 0, 0,
@@ -1524,7 +1524,7 @@ arg(virtualsize_ARG, 'V', "virtualsize", sizemb_VAL, 0, 0,
     "See \\fBlvmthin\\fP(7) for more information about LVM thin provisioning.\n"
     "Using virtual size (-V) and actual size (-L) together creates\n"
     "a sparse LV.\n"
-    "lvm.conf global/sparse_segtype_default determines the\n"
+    "\\fBlvm.conf\\fP(5) \\fBglobal/sparse_segtype_default\\fP determines the\n"
     "default segment type used to create a sparse LV.\n"
     "Anything written to a sparse LV will be returned when reading from it.\n"
     "Reading from other areas of the LV will return blocks of zeros.\n"
@@ -1539,8 +1539,8 @@ arg(wipesignatures_ARG, 'W', "wipesignatures", bool_VAL, 0, 0,
     "(unless --yes is used to override confirmations.)\n"
     "When not specified, signatures are wiped whenever zeroing is done\n"
     "(see --zero). This behaviour can be configured with\n"
-    "lvm.conf allocation/wipe_signatures_when_zeroing_new_lvs.\n"
-    "If blkid wiping is used (lvm.conf allocation/use_blkid_wiping)\n"
+    "\\fBlvm.conf\\fP(5) \\fBallocation/wipe_signatures_when_zeroing_new_lvs\\fP.\n"
+    "If blkid wiping is used (\\fBlvm.conf\\fP(5) \\fBallocation/use_blkid_wiping\\fP)\n"
     "and LVM is compiled with blkid wiping support, then the blkid(8)\n"
     "library is used to detect the signatures (use blkid -k to list the\n"
     "signatures that are recognized).\n"


