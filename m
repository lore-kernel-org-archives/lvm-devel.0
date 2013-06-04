From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:26:18 +0000 (UTC)
Subject: dev-mornfall-activate - commands: accept --yes globally
Message-ID: <20130604192618.C23D461084@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c6cf2ed7fd29d1860df511ac897367af646a6fb3
Commit:        c6cf2ed7fd29d1860df511ac897367af646a6fb3
Parent:        8ad7865b421459553a05e220f992ba2d26bd60e6
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue May 14 18:45:37 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue May 14 18:45:37 2013 +0100

commands: accept --yes globally

Accept --yes on all commands, even ones that don't today have prompts,
so that test scripts that don't care about interactive prompts no
longer need to deal with them.

But continue to mention --yes only in the command prototypes that
actually use it.
---
 WHATS_NEW          |    1 +
 man/lvm.8.in       |    4 ++++
 tools/commands.h   |   22 ++++++++++++----------
 tools/lvmcmdline.c |    1 +
 4 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 513210c..626a354 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Accept --yes in all commands so test scripts can be simpler.
   Fix alignment of PV data area if detected alignment less than 1 MB (2.02.74).
   Fix memory resource leak in memlocking error path.
   Fix premature DM version checking which caused useless mapper/control access.
diff --git a/man/lvm.8.in b/man/lvm.8.in
index d15e86b..37a60e4 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -171,6 +171,10 @@ Overrides config file setting.
 Suppress output and log messages.
 Overrides \fB\-d\fP and \fB\-v\fP.
 .TP
+.BR \-\-yes
+Don't prompt for confirmation interactively but instead always assume the
+answer is 'yes'.  Take great care if you use this!
+.TP
 .BR \-t ", " \-\-test
 Run in test mode. Commands will not update metadata.
 This is implemented by disabling all metadata writing but nevertheless
diff --git a/tools/commands.h b/tools/commands.h
index ace077f..8950243 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -94,10 +94,10 @@ xx(lvchange,
    "\t[--sysinit]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
-   "\t[-y|--yes]\n"
    "\t[--version]\n"
    "\t[--writebehind BehindCount\n"
    "\t[--writemostly PhysicalVolume]\n"
+   "\t[-y|--yes]\n"
    "\t[-Z|--zero {y|n}]\n"
    "\tLogicalVolume[Path] [LogicalVolume[Path]...]\n",
 
@@ -106,7 +106,7 @@ xx(lvchange,
    major_ARG, minor_ARG, monitor_ARG, noudevsync_ARG, partial_ARG,
    permission_ARG, persistent_ARG, poll_ARG, readahead_ARG, resync_ARG,
    refresh_ARG, addtag_ARG, deltag_ARG, syncaction_ARG, sysinit_ARG, test_ARG,
-   yes_ARG, writebehind_ARG, writemostly_ARG, zero_ARG)
+   writebehind_ARG, writemostly_ARG, zero_ARG)
 
 xx(lvconvert,
    "Change logical volume layout",
@@ -174,7 +174,7 @@ xx(lvconvert,
    trackchanges_ARG, type_ARG, stripes_long_ARG, stripesize_ARG, test_ARG,
    chunksize_ARG, discards_ARG, poolmetadata_ARG, poolmetadatasize_ARG,
    originname_ARG, thin_ARG, thinpool_ARG,
-   use_policies_ARG, yes_ARG, force_ARG, zero_ARG)
+   use_policies_ARG, force_ARG, zero_ARG)
 
 xx(lvcreate,
    "Create a logical volume",
@@ -380,12 +380,12 @@ xx(lvreduce,
    "\t[-r|--resizefs]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
-   "\t[-y|--yes]\n"
    "\t[--version]" "\n"
+   "\t[-y|--yes]\n"
    "\tLogicalVolume[Path]\n",
 
    autobackup_ARG, force_ARG,  extents_ARG, nofsck_ARG, noudevsync_ARG,
-   resizefs_ARG, size_ARG, test_ARG, yes_ARG)
+   resizefs_ARG, size_ARG, test_ARG)
 
 xx(lvremove,
    "Remove logical volume(s) from the system",
@@ -568,7 +568,7 @@ xx(pvcreate,
    force_ARG, test_ARG, labelsector_ARG, metadatatype_ARG,
    metadatacopies_ARG, metadatasize_ARG, metadataignore_ARG,
    norestorefile_ARG, physicalvolumesize_ARG, pvmetadatacopies_ARG,
-   restorefile_ARG, uuidstr_ARG, yes_ARG, zero_ARG)
+   restorefile_ARG, uuidstr_ARG, zero_ARG)
 
 xx(pvdata,
    "Display the on-disk metadata for physical volume(s)",
@@ -658,11 +658,11 @@ xx(pvremove,
    "\t[-h|-?|--help] " "\n"
    "\t[-t|--test] " "\n"
    "\t[-v|--verbose] " "\n"
-   "\t[-y|--yes]" "\n"
    "\t[--version] " "\n"
+   "\t[-y|--yes]" "\n"
    "\tPhysicalVolume [PhysicalVolume...]\n",
 
-   force_ARG, test_ARG, yes_ARG)
+   force_ARG, test_ARG)
 
 xx(pvs,
    "Display information about physical volumes",
@@ -838,12 +838,13 @@ xx(vgcreate,
    "\t[-t|--test] " "\n"
    "\t[-v|--verbose]" "\n"
    "\t[--version] " "\n"
+   "\t[-y|--yes]" "\n"
    "\t[ PHYSICAL DEVICE OPTIONS ] " "\n"
    "\tVolumeGroupName PhysicalDevicePath [PhysicalDevicePath...]\n",
 
    addtag_ARG, alloc_ARG, autobackup_ARG, clustered_ARG, maxlogicalvolumes_ARG,
    maxphysicalvolumes_ARG, metadatatype_ARG, physicalextentsize_ARG, test_ARG,
-   force_ARG, yes_ARG, zero_ARG, labelsector_ARG, metadatasize_ARG,
+   force_ARG, zero_ARG, labelsector_ARG, metadatasize_ARG,
    pvmetadatacopies_ARG, metadatacopies_ARG, vgmetadatacopies_ARG,
    dataalignment_ARG, dataalignmentoffset_ARG)
 
@@ -908,11 +909,12 @@ xx(vgextend,
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n"
+   "\t[-y|--yes]\n"
    "\t[ PHYSICAL DEVICE OPTIONS ] " "\n"
    "\tVolumeGroupName PhysicalDevicePath [PhysicalDevicePath...]\n",
 
    autobackup_ARG, test_ARG,
-   force_ARG, yes_ARG, zero_ARG, labelsector_ARG, metadatatype_ARG,
+   force_ARG, zero_ARG, labelsector_ARG, metadatatype_ARG,
    metadatasize_ARG, pvmetadatacopies_ARG, metadatacopies_ARG,
    metadataignore_ARG, dataalignment_ARG, dataalignmentoffset_ARG,
    restoremissing_ARG)
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index c03e9ef..0b64ed8 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -615,6 +615,7 @@ void lvm_register_commands(void)
 					    driverloaded_ARG, \
 					    debug_ARG, help_ARG, help2_ARG, \
 					    version_ARG, verbose_ARG, \
+					    yes_ARG, \
 					    quiet_ARG, config_ARG, -1);
 #include "commands.h"
 #undef xx


