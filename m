From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 9 Jul 2018 09:35:23 -0400
Subject: master - args: new options for vdo segment
Message-ID: <201807091335.w69DZNmh030778@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=96e9929f2f2d23d2113920efd67431d0272aba5f
Commit:        96e9929f2f2d23d2113920efd67431d0272aba5f
Parent:        a821b88a439dd2d0f22e5bb1c4d6671ab517198b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 29 11:31:08 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 15:28:35 2018 +0200

args: new options for vdo segment

Introduce new options usable with commands supporting VDO:
 --compression, --deduplication, --vdo, --vdopool
---
 tools/args.h |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index e574bc7..0d4d3bc 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -125,6 +125,10 @@ arg(commandprofile_ARG, '\0', "commandprofile", string_VAL, 0, 0,
     "The command profile to use for command configuration.\n"
     "See \\fBlvm.conf\\fP(5) for more information about profiles.\n")
 
+arg(compression_ARG, '\0', "compression", bool_VAL, 0, 0,
+    "Controls whether compression is enabled or disable for VDO volume.\n"
+    "See \\fBlvmvdo\\fP(7) for more information about VDO usage.\n")
+
 arg(config_ARG, '\0', "config", string_VAL, 0, 0,
     "Config settings for the command. These override lvm.conf settings.\n"
     "The String arg uses the same format as lvm.conf,\n"
@@ -178,6 +182,10 @@ arg(dataalignment_ARG, '\0', "dataalignment", sizekb_VAL, 0, 0,
 arg(dataalignmentoffset_ARG, '\0', "dataalignmentoffset", sizekb_VAL, 0, 0,
     "Shift the start of the data area by this additional offset.\n")
 
+arg(deduplication_ARG, '\0', "deduplication", bool_VAL, 0, 0,
+    "Controls whether deduplication is enabled or disable for VDO volume.\n"
+    "See \\fBlvmvdo\\fP(7) for more information about VDO usage.\n")
+
 arg(deltag_ARG, '\0', "deltag", tag_VAL, ARG_GROUPABLE, 0,
     "Deletes a tag from a PV, VG or LV. This option can be repeated to delete\n"
     "multiple tags at once. See \\fBlvm\\fP(8) for information about tags.\n")
@@ -757,6 +765,15 @@ arg(validate_ARG, '\0', "validate", 0, 0, 0,
     "merged configuration tree, also use --mergedconfig.\n"
     "The validation is done even if lvm.conf config/checks is disabled.\n")
 
+arg(vdo_ARG, '\0', "vdo", 0, 0, 0,
+    "Specifies the command is handling VDO LV.\n"
+    "See --type vdo.\n"
+    "See \\fBlvmvdo\\fP(7) for more information about VDO usage.\n")
+
+arg(vdopool_ARG, '\0', "vdopool", lv_VAL, 0, 0,
+    "The name of a VDO pool LV.\n"
+    "See \\fBlvmvdo\\fP(7) for more information about VDO usage.\n")
+
 arg(version_ARG, '\0', "version", 0, 0, 0,
     "Display version information.\n")
 


