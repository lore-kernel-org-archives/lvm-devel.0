From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  2 Jul 2013 13:32:54 +0000 (UTC)
Subject: master - tools: add support for changing configuration profile for existing volumes (vgchange/lvchange)
Message-ID: <20130702133254.2655460DA8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0cd47947359d2ba093dc7da5e489cafb34b038d0
Commit:        0cd47947359d2ba093dc7da5e489cafb34b038d0
Parent:        e21e38cf740b5b174e59fe400663bf6847f2f547
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 25 12:33:06 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 2 15:22:10 2013 +0200

tools: add support for changing configuration profile for existing volumes (vgchange/lvchange)

The command to change the profile for existing VG/LV:
	"vgchange/lvchange --profile <profile_name>"

The command to detach any existing profile from VG/LV:
	"vgchange/lvchange --detachprofile"
---
 tools/args.h     |    1 +
 tools/commands.h |   24 +++++++++++++-----------
 tools/lvchange.c |   51 ++++++++++++++++++++++++++++++++++++++++++++++-----
 tools/vgchange.c |   35 ++++++++++++++++++++++++++++++++++-
 4 files changed, 94 insertions(+), 17 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index cadd211..73312ca 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -92,6 +92,7 @@ arg(writebehind_ARG, '\0', "writebehind", int_arg, 0)
 arg(minrecoveryrate_ARG, '\0', "minrecoveryrate", size_kb_arg, 0)
 arg(maxrecoveryrate_ARG, '\0', "maxrecoveryrate", size_kb_arg, 0)
 arg(profile_ARG, '\0', "profile", string_arg, 0)
+arg(detachprofile_ARG, '\0', "detachprofile", NULL, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 2d99d5a..f84aa35 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -76,6 +76,7 @@ xx(lvchange,
    "\t[-C|--contiguous y|n]\n"
    "\t[-d|--debug]\n"
    "\t[--deltag Tag]\n"
+   "\t[--detachprofile]\n"
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
    "\t[--discards {ignore|nopassdown|passdown}]\n"
@@ -104,12 +105,12 @@ xx(lvchange,
    "\tLogicalVolume[Path] [LogicalVolume[Path]...]\n",
 
    alloc_ARG, autobackup_ARG, activate_ARG, available_ARG, contiguous_ARG,
-   discards_ARG, force_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG,
-   major_ARG, minor_ARG, monitor_ARG, minrecoveryrate_ARG, maxrecoveryrate_ARG,
-   noudevsync_ARG, partial_ARG,
-   permission_ARG, persistent_ARG, poll_ARG, readahead_ARG, resync_ARG,
-   refresh_ARG, addtag_ARG, deltag_ARG, syncaction_ARG, sysinit_ARG, test_ARG,
-   writebehind_ARG, writemostly_ARG, zero_ARG)
+   discards_ARG, detachprofile_ARG, force_ARG, ignorelockingfailure_ARG,
+   ignoremonitoring_ARG, major_ARG, minor_ARG, monitor_ARG, minrecoveryrate_ARG,
+   maxrecoveryrate_ARG, noudevsync_ARG, partial_ARG, permission_ARG,
+   persistent_ARG, poll_ARG, readahead_ARG, resync_ARG, refresh_ARG, addtag_ARG,
+   deltag_ARG, syncaction_ARG, sysinit_ARG, test_ARG, writebehind_ARG,
+   writemostly_ARG, zero_ARG)
 
 xx(lvconvert,
    "Change logical volume layout",
@@ -770,6 +771,7 @@ xx(vgchange,
    "\t[--alloc AllocationPolicy] " "\n"
    "\t[-P|--partial] " "\n"
    "\t[-d|--debug] " "\n"
+   "\t[--detachprofile] " "\n"
    "\t[-h|--help] " "\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--ignoremonitoring]\n"
@@ -794,11 +796,11 @@ xx(vgchange,
    "\t[VolumeGroupName...]\n",
 
    addtag_ARG, alloc_ARG, allocation_ARG, autobackup_ARG, activate_ARG,
-   available_ARG, clustered_ARG, deltag_ARG, ignorelockingfailure_ARG,
-   ignoremonitoring_ARG, logicalvolume_ARG, maxphysicalvolumes_ARG,
-   monitor_ARG, noudevsync_ARG, metadatacopies_ARG, vgmetadatacopies_ARG,
-   partial_ARG, physicalextentsize_ARG, poll_ARG, refresh_ARG, resizeable_ARG,
-   resizable_ARG, sysinit_ARG, test_ARG, uuid_ARG)
+   available_ARG, clustered_ARG, deltag_ARG, detachprofile_ARG,
+   ignorelockingfailure_ARG, ignoremonitoring_ARG, logicalvolume_ARG,
+   maxphysicalvolumes_ARG, monitor_ARG, noudevsync_ARG, metadatacopies_ARG,
+   vgmetadatacopies_ARG, partial_ARG, physicalextentsize_ARG, poll_ARG,
+   refresh_ARG, resizeable_ARG, resizable_ARG, sysinit_ARG, test_ARG, uuid_ARG)
 
 xx(vgck,
    "Check the consistency of volume group(s)",
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 5fc3585..4b88a51 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -859,6 +859,33 @@ static int lvchange_recovery_rate(struct logical_volume *lv)
 	return 1;
 }
 
+static int lvchange_profile(struct logical_volume *lv)
+{
+	const char *old_profile_name, *new_profile_name;
+	struct profile *new_profile;
+
+	old_profile_name = lv->profile ? lv->profile->name : "(inherited)";
+
+	if (arg_count(lv->vg->cmd, detachprofile_ARG)) {
+		new_profile_name = "(inherited)";
+		lv->profile = NULL;
+	} else {
+		new_profile_name = arg_str_value(lv->vg->cmd, profile_ARG, NULL);
+		if (!(new_profile = add_profile(lv->vg->cmd, new_profile_name)))
+			return_0;
+		lv->profile = new_profile;
+	}
+
+	log_verbose("Changing configuration profile for LV %s: %s -> %s.",
+		    lv->name, old_profile_name, new_profile_name);
+
+	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
+		return_0;
+
+	return 1;
+}
+
+
 static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 			   void *handle __attribute__((unused)))
 {
@@ -869,9 +896,8 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!(lv->vg->status & LVM_WRITE) &&
 	    (arg_count(cmd, contiguous_ARG) || arg_count(cmd, permission_ARG) ||
 	     arg_count(cmd, readahead_ARG) || arg_count(cmd, persistent_ARG) ||
-	     arg_count(cmd, discards_ARG) ||
-	     arg_count(cmd, zero_ARG) ||
-	     arg_count(cmd, alloc_ARG))) {
+	     arg_count(cmd, discards_ARG) || arg_count(cmd, zero_ARG) ||
+	     arg_count(cmd, alloc_ARG) || arg_count(cmd, profile_ARG))) {
 		log_error("Only -a permitted with read-only volume "
 			  "group \"%s\"", lv->vg->name);
 		return EINVALID_CMD_LINE;
@@ -880,7 +906,7 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (lv_is_origin(lv) && !lv_is_thin_volume(lv) &&
 	    (arg_count(cmd, contiguous_ARG) || arg_count(cmd, permission_ARG) ||
 	     arg_count(cmd, readahead_ARG) || arg_count(cmd, persistent_ARG) ||
-	     arg_count(cmd, alloc_ARG))) {
+	     arg_count(cmd, alloc_ARG) || arg_count(cmd, profile_ARG))) {
 		log_error("Can't change logical volume \"%s\" under snapshot",
 			  lv->name);
 		return ECMD_FAILED;
@@ -1023,6 +1049,14 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		docmds++;
 	}
 
+	/* change configuration profile */
+	if (arg_count(cmd, profile_ARG) || arg_count(cmd, detachprofile_ARG)) {
+		if (!archive(lv->vg))
+			return_ECMD_FAILED;
+		doit += lvchange_profile(lv);
+		docmds++;
+	}
+
 	if (doit)
 		log_print_unless_silent("Logical volume \"%s\" changed.", lv->name);
 
@@ -1070,7 +1104,9 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		arg_count(cmd, readahead_ARG) ||
 		arg_count(cmd, persistent_ARG) ||
 		arg_count(cmd, addtag_ARG) ||
-		arg_count(cmd, deltag_ARG);
+		arg_count(cmd, deltag_ARG) ||
+		arg_count(cmd, profile_ARG) ||
+		arg_count(cmd, detachprofile_ARG);
 	int update_partial_unsafe =
 		arg_count(cmd, resync_ARG) ||
 		arg_count(cmd, alloc_ARG) ||
@@ -1090,6 +1126,11 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
+	if (arg_count(cmd, profile_ARG) && arg_count(cmd, detachprofile_ARG)) {
+		log_error("Only one of --profile and --detachprofile permitted.");
+		return EINVALID_CMD_LINE;
+	}
+
 	if (arg_count(cmd, activate_ARG) && arg_count(cmd, refresh_ARG)) {
 		log_error("Only one of -a and --refresh permitted.");
 		return EINVALID_CMD_LINE;
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 6831597..e55c404 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -419,6 +419,30 @@ static int _vgchange_metadata_copies(struct cmd_context *cmd,
 	return 1;
 }
 
+static int _vgchange_profile(struct cmd_context *cmd,
+			     struct volume_group *vg)
+{
+	const char *old_profile_name, *new_profile_name;
+	struct profile *new_profile;
+
+	old_profile_name = vg->profile ? vg->profile->name : "(no profile)";
+
+	if (arg_count(cmd, detachprofile_ARG)) {
+		new_profile_name = "(no profile)";
+		vg->profile = NULL;
+	} else {
+		new_profile_name = arg_str_value(cmd, profile_ARG, NULL);
+		if (!(new_profile = add_profile(cmd, new_profile_name)))
+			return_0;
+		vg->profile = new_profile;
+	}
+
+	log_verbose("Changing configuration profile for VG %s: %s -> %s.",
+		    vg->name, old_profile_name, new_profile_name);
+
+	return 1;
+}
+
 static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 			   struct volume_group *vg,
 			   void *handle __attribute__((unused)))
@@ -439,6 +463,8 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 		{ alloc_ARG, &_vgchange_alloc },
 		{ clustered_ARG, &_vgchange_clustered },
 		{ vgmetadatacopies_ARG, &_vgchange_metadata_copies },
+		{ profile_ARG, &_vgchange_profile},
+		{ detachprofile_ARG, &_vgchange_profile},
 		{ -1, NULL },
 	};
 
@@ -511,7 +537,9 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 	/* Update commands that can be combined */
 	int update_partial_safe =
 		arg_count(cmd, deltag_ARG) ||
-		arg_count(cmd, addtag_ARG);
+		arg_count(cmd, addtag_ARG) ||
+		arg_count(cmd, profile_ARG) ||
+		arg_count(cmd, detachprofile_ARG);
 	int update_partial_unsafe =
 		arg_count(cmd, logicalvolume_ARG) ||
 		arg_count(cmd, maxphysicalvolumes_ARG) ||
@@ -535,6 +563,11 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
+	if (arg_count(cmd, profile_ARG) && arg_count(cmd, detachprofile_ARG)) {
+		log_error("Only one of --profile and --detachprofile permitted.");
+		return EINVALID_CMD_LINE;
+	}
+
 	if (arg_count(cmd, activate_ARG) && arg_count(cmd, refresh_ARG)) {
 		log_error("Only one of -a and --refresh permitted.");
 		return EINVALID_CMD_LINE;


