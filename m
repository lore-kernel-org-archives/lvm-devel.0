From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 10 Feb 2015 15:13:09 +0000 (UTC)
Subject: master - tools: allow -S|--select for vgchange, lvchange and pvchange
Message-ID: <20150210151309.D54BF60F24@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f784c60cd65d14d107e957338af041c3a507ef8d
Commit:        f784c60cd65d14d107e957338af041c3a507ef8d
Parent:        d6c8f0de280653d0d15f491f776046b09d7dc635
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Dec 3 10:03:48 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 10 16:08:04 2015 +0100

tools: allow -S|--select for vgchange, lvchange and pvchange

---
 WHATS_NEW        |    1 +
 tools/commands.h |   20 +++++++++++---------
 tools/lvchange.c |    4 ++--
 tools/pvchange.c |    3 ++-
 4 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 860f92d..f02ac8b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.117 - 
 ====================================
+  Add support for -S/--select to vgchange,lvchange and pvchange.
   Add infrastructure to support selection for non-reporting tools.
   Add LVM_COMMAND_PROFILE env var to set default command profile name to use.
   set CLOEXEC flag on file descriptors originating in libdaemon
diff --git a/tools/commands.h b/tools/commands.h
index 7bfc800..6df7f7d 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -135,6 +135,7 @@ xx(lvchange,
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[--refresh]\n"
    "\t[--resync]\n"
+   "\t[-S|--select Selection]\n"
    "\t[--sysinit]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
@@ -144,17 +145,16 @@ xx(lvchange,
    "\tLogicalVolume[Path] [LogicalVolume[Path]...]\n",
 
    activationmode_ARG, addtag_ARG, alloc_ARG, autobackup_ARG, activate_ARG,
-   available_ARG,
-   cachepolicy_ARG, cachesettings_ARG, contiguous_ARG, deltag_ARG, discards_ARG,
-   detachprofile_ARG, errorwhenfull_ARG, force_ARG,
+   available_ARG, cachepolicy_ARG, cachesettings_ARG, contiguous_ARG, deltag_ARG,
+   discards_ARG, detachprofile_ARG, errorwhenfull_ARG, force_ARG,
    ignorelockingfailure_ARG, ignoremonitoring_ARG, ignoreactivationskip_ARG,
    ignoreskippedcluster_ARG, major_ARG, metadataprofile_ARG, minor_ARG,
    monitor_ARG, minrecoveryrate_ARG, maxrecoveryrate_ARG, noudevsync_ARG,
    partial_ARG, permission_ARG, persistent_ARG, poll_ARG,
    raidminrecoveryrate_ARG, raidmaxrecoveryrate_ARG, raidsyncaction_ARG,
    raidwritebehind_ARG, raidwritemostly_ARG, readahead_ARG, resync_ARG,
-   refresh_ARG, setactivationskip_ARG, syncaction_ARG, sysinit_ARG, test_ARG,
-   writebehind_ARG, writemostly_ARG, zero_ARG)
+   refresh_ARG, select_ARG, setactivationskip_ARG, syncaction_ARG, sysinit_ARG,
+   test_ARG, writebehind_ARG, writemostly_ARG, zero_ARG)
 
 #define COMMON_OPTS \
 	"\t[--commandprofile ProfileName] [-d|--debug] [-h|-?|--help]\n" \
@@ -638,6 +638,7 @@ xx(pvchange,
    "\t[-d|--debug]\n"
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
+   "\t[-S|--select Selection]\n"
    "\t[-t|--test]\n"
    "\t[-u|--uuid]\n"
    "\t[-x|--allocatable y|n]\n"
@@ -649,7 +650,7 @@ xx(pvchange,
    "\t[PhysicalVolumePath...]\n",
 
    all_ARG, allocatable_ARG, allocation_ARG, autobackup_ARG, deltag_ARG,
-   addtag_ARG, force_ARG, metadataignore_ARG, test_ARG, uuid_ARG)
+   addtag_ARG, force_ARG, metadataignore_ARG, select_ARG, test_ARG, uuid_ARG)
 
 xx(pvresize,
    "Resize physical volume(s)",
@@ -945,6 +946,7 @@ xx(vgchange,
    "\t[--poll {y|n}]\n"
    "\t[--noudevsync]\n"
    "\t[--refresh]\n"
+   "\t[-S|--select Selection]\n"
    "\t[--sysinit]\n"
    "\t[-t|--test]\n"
    "\t[-u|--uuid]\n"
@@ -962,13 +964,13 @@ xx(vgchange,
    "\t[VolumeGroupName...]\n",
 
    activationmode_ARG, addtag_ARG, alloc_ARG, allocation_ARG, autobackup_ARG,
-   activate_ARG,
-   available_ARG, clustered_ARG, deltag_ARG, detachprofile_ARG,
+   activate_ARG, available_ARG, clustered_ARG, deltag_ARG, detachprofile_ARG,
    ignoreactivationskip_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG,
    ignoreskippedcluster_ARG, logicalvolume_ARG, maxphysicalvolumes_ARG,
    metadataprofile_ARG, monitor_ARG, noudevsync_ARG, metadatacopies_ARG,
    vgmetadatacopies_ARG, partial_ARG, physicalextentsize_ARG, poll_ARG,
-   refresh_ARG, resizeable_ARG, resizable_ARG, sysinit_ARG, test_ARG, uuid_ARG)
+   refresh_ARG, resizeable_ARG, resizable_ARG, select_ARG, sysinit_ARG,
+   test_ARG, uuid_ARG)
 
 xx(vgck,
    "Check the consistency of volume group(s)",
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 17e977f..f45469e 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1152,8 +1152,8 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 	if (!update || !update_partial_unsafe)
 		cmd->handles_missing_pvs = 1;
 
-	if (!argc) {
-		log_error("Please give logical volume path(s)");
+	if (!argc && !arg_is_set(cmd, select_ARG)) {
+		log_error("Please give logical volume path(s) or provide selection criteria.");
 		return EINVALID_CMD_LINE;
 	}
 
diff --git a/tools/pvchange.c b/tools/pvchange.c
index f0342a6..b164509 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -177,7 +177,8 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (!(arg_count(cmd, all_ARG)) && !argc && !handle->internal_report_for_select) {
-		log_error("Please give a physical volume path");
+		log_error("Please give a physical volume path "
+			  "or use -S for selection.");
 		r = EINVALID_CMD_LINE;
 		goto out;
 	}


