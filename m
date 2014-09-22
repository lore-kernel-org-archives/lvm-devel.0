From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:39:50 +0000 (UTC)
Subject: dev-dct-process-latest - toollib: add ALL_VGS_IS_DEFAULT flag
Message-ID: <20140922153950.CFCEE60228@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=35fb6744e08b67463b9d48d3e7e140c78f44d0c9
Commit:        35fb6744e08b67463b9d48d3e7e140c78f44d0c9
Parent:        aa33c4245b312cc883890d19e5d769a3d3c441ba
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 28 14:05:40 2013 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 22 10:32:23 2014 -0500

toollib: add ALL_VGS_IS_DEFAULT flag

The ALL_VGS_IS_DEFAULT flag is added to the command structure
for commands that should process all vgs when they call
process_each_vg or process_each_lv with no args.
This will be used in later patches to process_each functions.
---
 tools/commands.h |   34 ++++++++++++++++++++--------------
 tools/tools.h    |    1 +
 2 files changed, 21 insertions(+), 14 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 6e115d9..f723246 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -324,7 +324,7 @@ xx(lvcreate,
 
 xx(lvdisplay,
    "Display information about a logical volume",
-   PERMITTED_READ_ONLY,
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT,
    "lvdisplay\n"
    "\t[-a|--all]\n"
    "\t[-c|--colon]\n"
@@ -540,7 +540,7 @@ xx(lvresize,
 
 xx(lvs,
    "Display information about logical volumes",
-   PERMITTED_READ_ONLY,
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT,
    "lvs" "\n"
    "\t[-a|--all]\n"
    "\t[--aligned]\n"
@@ -577,7 +577,7 @@ xx(lvs,
 
 xx(lvscan,
    "List all logical volumes in all volume groups",
-   PERMITTED_READ_ONLY,
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT,
    "lvscan " "\n"
    "\t[-a|--all]\n"
    "\t[-b|--blockdevice] " "\n"
@@ -743,9 +743,15 @@ xx(pvdisplay,
    options_ARG, readonly_ARG, select_ARG, separator_ARG, short_ARG, sort_ARG,
    unbuffered_ARG, units_ARG)
 
+/*
+ * When pvmove is called with no PV arguments, the polldaemon uses
+ * process_each_vg to search all VGs for pvmoves still in progress.
+ * This search of all vgs requires ALL_VGS_IS_DEFAULT.
+ */
+
 xx(pvmove,
    "Move extents from one physical volume to another",
-   0,
+   ALL_VGS_IS_DEFAULT,
    "pvmove " "\n"
    "\t[--abort]\n"
    "\t[--alloc AllocationPolicy]\n"
@@ -786,7 +792,7 @@ xx(pvremove,
 
 xx(pvs,
    "Display information about physical volumes",
-   CACHE_VGMETADATA | PERMITTED_READ_ONLY,
+   CACHE_VGMETADATA | PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT,
    "pvs" "\n"
    "\t[-a|--all]\n"
    "\t[--aligned]\n"
@@ -855,7 +861,7 @@ xx(tags,
 
 xx(vgcfgbackup,
    "Backup volume group configuration(s)",
-   PERMITTED_READ_ONLY,
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT,
    "vgcfgbackup " "\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug] " "\n"
@@ -890,7 +896,7 @@ xx(vgcfgrestore,
 
 xx(vgchange,
    "Change volume group attributes",
-   CACHE_VGMETADATA | PERMITTED_READ_ONLY,
+   CACHE_VGMETADATA | PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT,
    "vgchange" "\n"
    "\t[-A|--autobackup {y|n}] " "\n"
    "\t[--alloc AllocationPolicy] " "\n"
@@ -936,7 +942,7 @@ xx(vgchange,
 
 xx(vgck,
    "Check the consistency of volume group(s)",
-   0,
+   ALL_VGS_IS_DEFAULT,
    "vgck "
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
@@ -998,7 +1004,7 @@ xx(vgcreate,
 
 xx(vgdisplay,
    "Display volume group information",
-   PERMITTED_READ_ONLY,
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT,
    "vgdisplay " "\n"
    "\t[-A|--activevolumegroups]" "\n"
    "\t[-c|--colon | -s|--short | -v|--verbose]" "\n"
@@ -1042,7 +1048,7 @@ xx(vgdisplay,
 
 xx(vgexport,
    "Unregister volume group(s) from the system",
-   0,
+   ALL_VGS_IS_DEFAULT,
    "vgexport " "\n"
    "\t[-a|--all] " "\n"
    "\t[--commandprofile ProfileName]\n"
@@ -1079,7 +1085,7 @@ xx(vgextend,
 
 xx(vgimport,
    "Register exported volume group with system",
-   0,
+   ALL_VGS_IS_DEFAULT,
    "vgimport " "\n"
    "\t[-a|--all]\n"
    "\t[--commandprofile ProfileName]\n"
@@ -1111,7 +1117,7 @@ xx(vgmerge,
 
 xx(vgmknodes,
    "Create the special files for volume group devices in /dev",
-   0,
+   ALL_VGS_IS_DEFAULT,
    "vgmknodes\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
@@ -1179,7 +1185,7 @@ xx(vgrename,
 
 xx(vgs,
    "Display information about volume groups",
-   PERMITTED_READ_ONLY,
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT,
    "vgs" "\n"
    "\t[--aligned]\n"
    "\t[--binary]\n"
@@ -1215,7 +1221,7 @@ xx(vgs,
 
 xx(vgscan,
    "Search for all volume groups",
-   PERMITTED_READ_ONLY,
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT,
    "vgscan "
    "\t[--cache]\n"
    "\t[--commandprofile ProfileName]\n"
diff --git a/tools/tools.h b/tools/tools.h
index cbea1fa..7b12797 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -102,6 +102,7 @@ struct arg_value_group_list {
 
 #define CACHE_VGMETADATA	0x00000001
 #define PERMITTED_READ_ONLY 	0x00000002
+#define ALL_VGS_IS_DEFAULT	0x00000004 /* run cmd on all vgs if none are named */
 
 /* a register of the lvm commands */
 struct command {


