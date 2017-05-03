From: David Teigland <teigland@sourceware.org>
Date: Wed, 3 May 2017 17:26:25 -0400
Subject: master - man: reference other man pages with bold
Message-ID: <201705032126.v43LQPGD006746@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a7a28bd9985c5630990215045adb8d76c9b099e1
Commit:        a7a28bd9985c5630990215045adb8d76c9b099e1
Parent:        596fd0b106c2044c45827a9f71bc42f1917eba46
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 3 16:21:01 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 3 16:21:01 2017 -0500

man: reference other man pages with bold

There were a handful of references to other man
pages using the standard command(N) form which were
not in bold, so they were not turned into links
in html formats.
---
 tools/args.h |   56 ++++++++++++++++++++++++++++----------------------------
 1 files changed, 28 insertions(+), 28 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 2dc738f..23eaf5c 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -42,7 +42,7 @@ arg(activationmode_ARG, '\0', "activationmode", activationmode_VAL, 0, 0,
 
 arg(addtag_ARG, '\0', "addtag", tag_VAL, ARG_GROUPABLE, 0,
     "Adds a tag to a PV, VG or LV. This option can be repeated to add\n"
-    "multiple tags at once. See lvm(8) for information about tags.\n")
+    "multiple tags at once. See \\fBlvm\\fP(8) for information about tags.\n")
 
 arg(aligned_ARG, '\0', "aligned", 0, 0, 0,
     "Use with --separator to align the output columns\n")
@@ -132,10 +132,10 @@ arg(config_ARG, '\0', "config", string_VAL, 0, 0,
     "See \\fBlvm.conf\\fP(5) for more information about config.\n")
 
 arg(configreport_ARG, '\0', "configreport", configreport_VAL, ARG_GROUPABLE, 1,
-    "See lvmreport(7).\n")
+    "See \\fBlvmreport\\fP(7).\n")
 
 arg(configtype_ARG, '\0', "typeconfig", configtype_VAL, 0, 0,
-    "See lvmreport(7).\n")
+    "See \\fBlvmreport\\fP(7).\n")
 
 arg(dataalignment_ARG, '\0', "dataalignment", sizekb_VAL, 0, 0,
     "Align the start of the data to a multiple of this number.\n"
@@ -149,7 +149,7 @@ arg(dataalignmentoffset_ARG, '\0', "dataalignmentoffset", sizekb_VAL, 0, 0,
 
 arg(deltag_ARG, '\0', "deltag", tag_VAL, ARG_GROUPABLE, 0,
     "Deletes a tag from a PV, VG or LV. This option can be repeated to delete\n"
-    "multiple tags at once. See lvm(8) for information about tags.\n")
+    "multiple tags at once. See \\fBlvm\\fP(8) for information about tags.\n")
 
 arg(detachprofile_ARG, '\0', "detachprofile", 0, 0, 0,
     "Detaches a metadata profile from a VG or LV.\n"
@@ -188,7 +188,7 @@ arg(force_long_ARG, '\0', "force", 0, ARG_COUNTABLE, 0,
 
 arg(foreign_ARG, '\0', "foreign", 0, 0, 0,
     "Report/display foreign VGs that would otherwise be skipped.\n"
-    "See lvmsystemid(7) for more information about foreign VGs.\n")
+    "See \\fBlvmsystemid\\fP(7) for more information about foreign VGs.\n")
 
 arg(handlemissingpvs_ARG, '\0', "handlemissingpvs", 0, 0, 0,
     "Allows a polling operation to continue when PVs are missing,\n"
@@ -227,25 +227,25 @@ arg(labelsector_ARG, '\0', "labelsector", number_VAL, 0, 0,
 
 arg(lockopt_ARG, '\0', "lockopt", string_VAL, 0, 0,
     "Used to pass options for special cases to lvmlockd.\n"
-    "See lvmlockd(8) for more information.\n")
+    "See \\fBlvmlockd\\fP(8) for more information.\n")
 
 arg(lockstart_ARG, '\0', "lockstart", 0, 0, 0,
     "Start the lockspace of a shared VG in lvmlockd.\n"
     "lvmlockd locks becomes available for the VG, allowing LVM to use the VG.\n"
-    "See lvmlockd(8) for more information.\n")
+    "See \\fBlvmlockd\\fP(8) for more information.\n")
 
 arg(lockstop_ARG, '\0', "lockstop", 0, 0, 0,
     "Stop the lockspace of a shared VG in lvmlockd.\n"
     "lvmlockd locks become unavailable for the VG, preventing LVM from using the VG.\n"
-    "See lvmlockd(8) for more information.\n")
+    "See \\fBlvmlockd\\fP(8) for more information.\n")
 
 arg(locktype_ARG, '\0', "locktype", locktype_VAL, 0, 0,
     "#vgchange\n"
     "Change the VG lock type to or from a shared lock type used with lvmlockd.\n"
-    "See lvmlockd(8) for more information.\n"
+    "See \\fBlvmlockd\\fP(8) for more information.\n"
     "#vgcreate\n"
     "Specify the VG lock type directly in place of using --shared.\n"
-    "See lvmlockd(8) for more information.\n")
+    "See \\fBlvmlockd\\fP(8) for more information.\n")
 
 arg(logonly_ARG, '\0', "logonly", 0, 0, 0,
     "Suppress command report and display only log report.\n")
@@ -345,7 +345,7 @@ arg(monitor_ARG, '\0', "monitor", bool_VAL, 0, 0,
     "Start (yes) or stop (no) monitoring an LV with dmeventd.\n"
     "dmeventd monitors kernel events for an LV, and performs\n"
     "automated maintenance for the LV in reponse to specific events.\n"
-    "See dmeventd(8) for more information.\n")
+    "See \\fBdmeventd\\fP(8) for more information.\n")
 
 arg(nameprefixes_ARG, '\0', "nameprefixes", 0, 0, 0,
     "Add an \"LVM2_\" prefix plus the field name to the output. Useful\n"
@@ -552,7 +552,7 @@ arg(shared_ARG, '\0', "shared", 0, 0, 0,
     "manager is running. This allows multiple hosts to share a VG on shared\n"
     "devices. lvmlockd and a lock manager must be configured and running.\n"
     "(A shared VG using lvmlockd is different from a clustered VG using clvmd.)\n"
-    "See lvmlockd(8) for more information about shared VGs.\n"
+    "See \\fBlvmlockd\\fP(8) for more information about shared VGs.\n"
     "#vgs\n"
     "#lvs\n"
     "#pvs\n"
@@ -562,7 +562,7 @@ arg(shared_ARG, '\0', "shared", 0, 0, 0,
     "#pvdisplay\n"
     "Report/display shared VGs that would otherwise be skipped when\n"
     "lvmlockd is not being used on the host.\n"
-    "See lvmlockd(8) for more information about shared VGs.\n")
+    "See \\fBlvmlockd\\fP(8) for more information about shared VGs.\n")
 
 arg(sinceversion_ARG, '\0', "sinceversion", string_VAL, 0, 0,
     "Specify an LVM version in x.y.z format where x is the major version,\n"
@@ -644,12 +644,12 @@ arg(systemid_ARG, '\0', "systemid", string_VAL, 0, 0,
     "the host creating it. Using this option requires caution because the\n"
     "system ID of the new VG may not match the system ID of the host running\n"
     "the command, leaving the VG inaccessible to the host.\n"
-    "See lvmsystemid(7) for more information.\n"
+    "See \\fBlvmsystemid\\fP(7) for more information.\n"
     "#vgchange\n"
     "Changes the system ID of the VG.  Using this option requires caution\n"
     "because the VG may become foreign to the host running the command,\n"
     "leaving the host unable to access it.\n"
-    "See lvmsystemid(7) for more information.\n")
+    "See \\fBlvmsystemid\\fP(7) for more information.\n")
 
 arg(thinpool_ARG, '\0', "thinpool", lv_VAL, 0, 0,
     "The name of a thin pool LV.\n")
@@ -831,8 +831,8 @@ arg(activate_ARG, 'a', "activate", activation_VAL, 0, 0,
     "if the list is set but empty, no LVs match.\n"
     "Autoactivation should be used during system boot to make it possible\n"
     "to select which LVs should be automatically activated by the system.\n"
-    "See lvmlockd(8) for more information about activation options \\fBey\\fP and \\fBsy\\fP for shared VGs.\n"
-    "See clvmd(8) for more information about activation options \\fBey\\fP, \\fBsy\\fP, \\fBly\\fP and \\fBln\\fP for clustered VGs.\n"
+    "See \\fBlvmlockd\\fP(8) for more information about activation options \\fBey\\fP and \\fBsy\\fP for shared VGs.\n"
+    "See \\fBclvmd\\fP(8) for more information about activation options \\fBey\\fP, \\fBsy\\fP, \\fBly\\fP and \\fBln\\fP for clustered VGs.\n"
     "#lvcreate\n"
     "Controls the active state of the new LV.\n"
     "\\fBy\\fP makes the LV active, or available.\n"
@@ -845,8 +845,8 @@ arg(activate_ARG, 'a', "activate", activation_VAL, 0, 0,
     "If autoactivation \\fBay\\fP is used, the LV is only activated\n"
     "if it matches an item in lvm.conf activation/auto_activation_volume_list.\n"
     "\\fBay\\fP implies --zero n and --wipesignatures n.\n"
-    "See lvmlockd(8) for more information about activation options for shared VGs.\n"
-    "See clvmd(8) for more information about activation options for clustered VGs.\n")
+    "See \\fBlvmlockd\\fP(8) for more information about activation options for shared VGs.\n"
+    "See \\fBclvmd\\fP(8) for more information about activation options for clustered VGs.\n")
 
 arg(all_ARG, 'a', "all", 0, 0, 0,
     "#vgreduce\n"
@@ -870,7 +870,7 @@ arg(all_ARG, 'a', "all", 0, 0, 0,
 
 arg(autobackup_ARG, 'A', "autobackup", bool_VAL, 0, 0,
     "Specifies if metadata should be backed up automatically after a change.\n"
-    "Enabling this is strongly advised! See vgcfgbackup(8) for more information.\n")
+    "Enabling this is strongly advised! See \\fBvgcfgbackup\\fP(8) for more information.\n")
 
 arg(activevolumegroups_ARG, 'A', "activevolumegroups", 0, 0, 0,
     "Only select active VGs. The VG is considered active\n"
@@ -914,20 +914,20 @@ arg(clustered_ARG, 'c', "clustered", bool_VAL, 0, 0,
     "This allows multiple hosts to share a VG on shared devices.\n"
     "clvmd and a lock manager must be configured and running.\n"
     "(A clustered VG using clvmd is different from a shared VG using lvmlockd.)\n"
-    "See clvmd(8) for more information about clustered VGs.\n"
+    "See \\fBclvmd\\fP(8) for more information about clustered VGs.\n"
     "#vgchange\n"
     "Change the clustered property of a VG using clvmd.\n"
-    "See clvmd(8) for more information about clustered VGs.\n"
+    "See \\fBclvmd\\fP(8) for more information about clustered VGs.\n"
     "#vgsplit\n"
     "Specifies the clustered property of the new VG.\n")
 
 arg(colon_ARG, 'c', "colon", 0, 0, 0,
     "Generate colon separated output for easier parsing in scripts or programs.\n"
-    "Also see vgs(8) which provides considerably more control over the output.\n")
+    "Also see \\fBvgs\\fP(8) which provides considerably more control over the output.\n")
 
 arg(columns_ARG, 'C', "columns", 0, 0, 0,
-    "Display output in columns, the equivalent of vgs(8).\n"
-    "Options listed are the same as options given in vgs(8).\n")
+    "Display output in columns, the equivalent of \\fBvgs\\fP(8).\n"
+    "Options listed are the same as options given in \\fBvgs\\fP(8).\n")
 
 arg(contiguous_ARG, 'C', "contiguous", bool_VAL, 0, 0,
     "Sets or resets the contiguous allocation policy for LVs.\n"
@@ -1215,7 +1215,7 @@ arg(options_ARG, 'o', "options", string_VAL, ARG_GROUPABLE, 0,
     "\\fBseg_all\\fP all LV segment fields, and\n"
     "\\fBpvseg_all\\fP all PV segment columns.\n"
     "See the lvm.conf report section for more config options.\n"
-    "See lvmreport(7) for more information about reporting.\n")
+    "See \\fBlvmreport\\fP(7) for more information about reporting.\n")
 
 arg(sort_ARG, 'O', "sort", string_VAL, ARG_GROUPABLE, 0,
     "Comma-separated ordered list of columns to sort by. Replaces the default\n"
@@ -1355,11 +1355,11 @@ arg(uuidstr_ARG, 'u', "uuid", string_VAL, 0, 0,
     "Specify a UUID for the device.\n"
     "Without this option, a random UUID is generated.\n"
     "This option is needed before restoring a backup of LVM metadata\n"
-    "onto a replacement device; see vgcfgrestore(8). As such, use of\n"
+    "onto a replacement device; see \\fBvgcfgrestore\\fP(8). As such, use of\n"
     "--restorefile is compulsory unless the --norestorefile is used.\n"
     "All PVs must have unique UUIDs, and LVM will prevent certain operations\n"
     "if multiple devices are seen with the same UUID.\n"
-    "See vgimportclone(8) for more information.\n")
+    "See \\fBvgimportclone\\fP(8) for more information.\n")
 
 /* Not used */
 arg(uuidlist_ARG, 'U', "uuidlist", 0, 0, 0, NULL)


