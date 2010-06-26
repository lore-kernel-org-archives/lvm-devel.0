From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 25 Jun 2010 22:53:01 -0400
Subject: [PATCH 30/38] Add --vgmetadatacopies to vgcreate man page, command, and lvm.conf.
In-Reply-To: <1277520789-6808-30-git-send-email-dwysocha@redhat.com>
References: <1277520789-6808-1-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-2-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-3-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-4-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-5-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-6-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-7-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-8-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-9-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-10-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-11-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-12-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-13-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-14-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-15-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-16-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-17-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-18-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-19-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-20-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-21-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-22-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-23-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-24-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-25-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-26-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-27-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-28-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-29-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-30-git-send-email-dwysocha@redhat.com>
Message-ID: <1277520789-6808-31-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Allow parsing of --vgmetadatacopies for vgcreate.  Accept
--metadatacopies as a synonym for --vgmetadatacopies.  Other
patches will add balancing algorithm before the metadata is
written in vg_write().

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/config/defaults.h |    1 +
 man/lvm.conf.5.in     |   24 +++++++++++++++++++++++-
 man/vgcreate.8.in     |   27 ++++++++++++++++++++-------
 tools/commands.h      |    5 +++--
 tools/toollib.c       |   20 ++++++++++++++++++++
 tools/vgcreate.c      |    8 ++------
 6 files changed, 69 insertions(+), 16 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 0d8cb9c..d7539de 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -62,6 +62,7 @@
 #define DEFAULT_PVMETADATASIZE 255
 #define DEFAULT_PVMETADATACOPIES 1
 #define DEFAULT_VGMETADATACOPIES 0
+#define DEFAULT_VGMETADATACOPIES_STR "unmanaged"
 #define DEFAULT_LABELSECTOR UINT64_C(1)
 #define DEFAULT_READ_AHEAD "auto"
 #define DEFAULT_UDEV_RULES 1
diff --git a/man/lvm.conf.5.in b/man/lvm.conf.5.in
index 02ebb2a..b787e74 100644
--- a/man/lvm.conf.5.in
+++ b/man/lvm.conf.5.in
@@ -386,7 +386,7 @@ to store on each physical volume.
 Currently it can be set to 0, 1 or 2.  The default is 1.  
 If set to 2, one copy is placed at the beginning of the disk
 and the other is placed at the end.
-It can be overridden on the command line with \fB--metadatacopies\fP.
+It can be overridden on the command line with \fB--pvmetadatacopies\fP.
 If creating a volume group with just one physical volume, it's a
 good idea to have 2 copies.  If creating a large volume group with
 many physical volumes, you may decide that 3 copies of the metadata
@@ -406,6 +406,28 @@ The metadata areas are treated as circular buffers, so
 unused space becomes filled with an archive of the most recent
 previous versions of the metadata.
 .IP
+\fBvgmetadatacopies\fP \(em When creating a volume group using the
+LVM2 metadata format, this is the default number of copies of metadata
+desired across all the physical volumes in the volume group.  If set to
+a non-zero value, LVM will automatically set or clear the metadataignore
+flag on the physical volumes (see \fBpvchange --metadataignore\fP) in order
+to achieve the desired number of metadata copies.  In order to maintain
+the desired number of copies, automatic set or clear of the metadataignore
+flags may be triggered by an LVM command that adds or removes physical
+volumes (\fBvgextend\fP or \fBvgreduce\fP, \fBvgsplit\fP, \fBvgmerge\fP),
+when physical volumes go missing or reappear, or when a new value is
+explicity set (See \fBvgchange --vgmetadatacopies\fP).  Setting
+\fBvgmetadatacopies\fP to "unmanaged" indicates to LVM not to automatically
+manage the metadata ignore flags.  It is not an error to set a value larger
+than the sum of all metadata areas on all physical volumes.  The value can
+be overridden on the command line with \fB--vgmetadatacopies\fP for various
+commands (for example, \fBvgcreate\fP and \fBvgchange\fP), and can be
+queryied with the \fBvg_mda_copies\fP field of \fBvgs\fP.  This option
+is useful for volume groups containing large numbers of physical volumes
+with metadata as it may be used to minimize metadata read and write overhead.
+Note that this is a string value, so any numbers must be enclosed in '"'s,
+for example, vgmetadatacopies = "5".
+.IP
 \fBdirs\fP \(em List of directories holding live copies of LVM2
 metadata as text files.  These directories must not be on logical
 volumes.  It is possible to use LVM2 with a couple of directories
diff --git a/man/vgcreate.8.in b/man/vgcreate.8.in
index 06e0006..e3d970e 100644
--- a/man/vgcreate.8.in
+++ b/man/vgcreate.8.in
@@ -16,6 +16,8 @@ vgcreate \- create a volume group
 .RB [ -M | \-\-metadatatype type]
 .RB [ -p | \-\-maxphysicalvolumes
 .IR MaxPhysicalVolumes ]
+.RB [ \-\-[vg]metadatacopies ]
+.IR NumberOfCopies|unmanaged|all ]
 .RB [ \-s | \-\-physicalextentsize
 .IR PhysicalExtentSize [ \fBbBsSkKmMgGtTpPeE\fR ]]
 .RB [ \-t | \-\-test ]
@@ -66,13 +68,24 @@ to this volume group.
 The setting can be changed with \fBvgchange\fP.
 For volume groups with metadata in lvm1 format, the limit
 and default value is 255.  
-If the metadata uses lvm2 format, the default value is 0
-which removes this restriction: there is then no limit.
-If you have a large number of physical volumes in
-a volume group with metadata in lvm2 format, 
-for tool performance reasons, you should consider 
-some use of \fB--pvmetadatacopies 0\fP
-as described in \fBpvcreate(8)\fP.
+If the metadata uses lvm2 format, the value 0 removes this restriction:
+there is then no limit.  If you have a large number of physical volumes in
+a volume group with metadata in lvm2 format, for tool performance reasons,
+you should consider some use of \fB--pvmetadatacopies 0\fP as described in
+\fBpvcreate(8)\fP, and/or use \fB--vgmetadatacopies\fP.
+.TP
+.BR \-\-vgmetadatacopies " " \fINumberOfCopies|unmanaged|all\fP
+Sets the desired number of metadata copies in the volume group.  If set to
+a non-zero value, LVM will automatically manage the 'metadataignore'
+flags on the physical volumes (see \fBpvchange --metadataignore\fP) in order
+to achieve \fINumberOfCopies\fP copies of metadata.  If set to \fIunmanaged\fP,
+LVM will not automatically manage the 'metadataignore' flags.  If set to
+\fIall\fP, LVM will first clear all of the 'metadataignore' flags on all
+metadata areas in the volume group, then set the value to \fIunmanaged\fP.
+The \fBvgmetadatacopies\fP option is useful for volume groups containing
+large numbers of physical volumes with metadata as it may be used to
+minimize metadata read and write overhead.
+The default value is \fIunmanaged\fP.
 .TP
 .BR \-s ", " \-\-physicalextentsize " " \fIPhysicalExtentSize\fR[\fBbBsSkKmMgGtTpPeE\fR]
 Sets the physical extent size on physical volumes of this volume group.
diff --git a/tools/commands.h b/tools/commands.h
index 62a684b..8f5ff3a 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -776,6 +776,7 @@ xx(vgcreate,
    "\t[-h|--help]" "\n"
    "\t[-l|--maxlogicalvolumes MaxLogicalVolumes]" "\n"
    "\t[-M|--metadatatype 1|2] " "\n"
+   "\t[--[vg]metadatacopies #copies] " "\n"
    "\t[-p|--maxphysicalvolumes MaxPhysicalVolumes] " "\n"
    "\t[-s|--physicalextentsize PhysicalExtentSize[bBsSkKmMgGtTpPeE]] " "\n"
    "\t[-t|--test] " "\n"
@@ -787,8 +788,8 @@ xx(vgcreate,
    addtag_ARG, alloc_ARG, autobackup_ARG, clustered_ARG, maxlogicalvolumes_ARG,
    maxphysicalvolumes_ARG, metadatatype_ARG, physicalextentsize_ARG, test_ARG,
    force_ARG, yes_ARG, zero_ARG, labelsector_ARG, metadatasize_ARG,
-   pvmetadatacopies_ARG, metadatacopies_ARG, dataalignment_ARG,
-   dataalignmentoffset_ARG)
+   pvmetadatacopies_ARG, metadatacopies_ARG, vgmetadatacopies_ARG,
+   dataalignment_ARG, dataalignmentoffset_ARG)
 
 xx(vgdisplay,
    "Display volume group information",
diff --git a/tools/toollib.c b/tools/toollib.c
index 02b06fd..a41c113 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1209,6 +1209,8 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 				  struct vgcreate_params *vp_new,
 				  struct vgcreate_params *vp_def)
 {
+	const char *metadata_copies_str;
+
 	vp_new->vg_name = skip_dev_dir(cmd, vp_def->vg_name, NULL);
 	vp_new->max_lv = arg_uint_value(cmd, maxlogicalvolumes_ARG,
 					vp_def->max_lv);
@@ -1243,6 +1245,24 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 		return 1;
 	}
 
+	if (arg_count(cmd, metadatacopies_ARG)) {
+		vp_new->metadata_copies = arg_int_value(cmd, metadatacopies_ARG,
+							DEFAULT_VGMETADATACOPIES);
+	} else if (arg_count(cmd, vgmetadatacopies_ARG)) {
+		vp_new->metadata_copies = arg_int_value(cmd, vgmetadatacopies_ARG,
+							DEFAULT_VGMETADATACOPIES);
+	} else {
+		metadata_copies_str = find_config_tree_str(cmd,
+						   "metadata/vgmetadatacopies",
+						   DEFAULT_VGMETADATACOPIES_STR);
+		if (!strcmp(metadata_copies_str, DEFAULT_VGMETADATACOPIES_STR))
+			vp_new->metadata_copies = DEFAULT_VGMETADATACOPIES;
+		else
+			vp_new->metadata_copies = strtoul(metadata_copies_str,
+							  NULL,
+							  10);
+	}
+
 	return 0;
 }
 
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 6087145..3bb500f 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -35,11 +35,6 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	argc--;
 	argv++;
 
-	if (arg_count(cmd, metadatacopies_ARG)) {
-		log_error("Invalid option --metadatacopies, "
-			  "use --pvmetadatacopies instead.");
-		return EINVALID_CMD_LINE;
-	}
 	pvcreate_params_set_defaults(&pp);
 	if (!pvcreate_params_validate(cmd, argc, argv, &pp)) {
 		return EINVALID_CMD_LINE;
@@ -68,7 +63,8 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	    !vg_set_max_lv(vg, vp_new.max_lv) ||
 	    !vg_set_max_pv(vg, vp_new.max_pv) ||
 	    !vg_set_alloc_policy(vg, vp_new.alloc) ||
-	    !vg_set_clustered(vg, vp_new.clustered))
+	    !vg_set_clustered(vg, vp_new.clustered) ||
+	    !vg_set_mda_copies(vg, vp_new.metadata_copies))
 		goto bad_orphan;
 
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
-- 
1.6.0.6


