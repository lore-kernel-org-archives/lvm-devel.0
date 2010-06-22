From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 21 Jun 2010 23:06:03 -0400
Subject: [PATCH 30/35] Add --vgmetadatacopies to vgcreate man page, command, and lvm.conf.
In-Reply-To: <1277175968-9661-30-git-send-email-dwysocha@redhat.com>
References: <1277175968-9661-1-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-2-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-3-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-4-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-5-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-6-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-7-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-8-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-9-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-10-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-11-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-12-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-13-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-14-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-15-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-16-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-17-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-18-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-19-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-20-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-21-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-22-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-23-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-24-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-25-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-26-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-27-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-28-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-29-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-30-git-send-email-dwysocha@redhat.com>
Message-ID: <1277175968-9661-31-git-send-email-dwysocha@redhat.com>
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
 man/lvm.conf.5.in |   23 +++++++++++++++++++++++
 man/vgcreate.8.in |   15 +++++++++++++++
 tools/commands.h  |    5 +++--
 tools/toollib.c   |   12 ++++++++++++
 tools/vgcreate.c  |    8 ++------
 5 files changed, 55 insertions(+), 8 deletions(-)

diff --git a/man/lvm.conf.5.in b/man/lvm.conf.5.in
index 02ebb2a..ff0c35e 100644
--- a/man/lvm.conf.5.in
+++ b/man/lvm.conf.5.in
@@ -406,6 +406,29 @@ The metadata areas are treated as circular buffers, so
 unused space becomes filled with an archive of the most recent
 previous versions of the metadata.
 .IP
+\fBvgmetadatacopies\fP \(em When creating a volume group using the
+LVM2 metadata format, this is the default number of copies of metadata
+desired across all the physical volumes in the volume group.  If set to
+a non-zero value, LVM will attempt to balance metadata areas across
+the physical volumes in the volume group to achieve the number
+of metadata copies specified.  LVM implements the balancing through
+automatically setting and clearing metadata ignore
+(See \fBpvchange --metadataignore\fP) on physical volumes created with
+a non-zero value of \fBpvmetadatacopies\fP. Balancing may be triggered
+by an LVM command that adds or removes physical volumes (\fBvgextend\fP
+or \fBvgreduce\fP, \fBvgsplit\fP, \fBvgmerge\fP), when physical
+volumes go missing or reappear, or when a new value is explicity set
+(See \fBvgchange --vgmetadatacopies\fP).
+Setting \fBvgmetadatacopies\fP to 0 disables metadata balancing.  It
+is not an error to set a value larger than the sum of all metadata areas
+on all physical volumes.  The value can be overridden on the command line
+with \fB--vgmetadatacopies\fP.  This option may be useful for volume groups
+containing large numbers of physical volumes.   It offers a simple way
+to specify a reasonable number of metadata copies (for example 5) without
+having to know ahead of time which physical volumes should have metadata.
+Having a smaller number of metadata areas offers better performance
+than the default of reading and writing metadata on all physical volumes.
+.IP
 \fBdirs\fP \(em List of directories holding live copies of LVM2
 metadata as text files.  These directories must not be on logical
 volumes.  It is possible to use LVM2 with a couple of directories
diff --git a/man/vgcreate.8.in b/man/vgcreate.8.in
index 24d1642..2c8ce34 100644
--- a/man/vgcreate.8.in
+++ b/man/vgcreate.8.in
@@ -16,6 +16,8 @@ vgcreate \- create a volume group
 .RB [ -M | \-\-metadatatype type]
 .RB [ -p | \-\-maxphysicalvolumes
 .IR MaxPhysicalVolumes ]
+.RB [ \-\-[vg]metadatacopies ]
+.IR copies ]
 .RB [ \-s | \-\-physicalextentsize
 .IR PhysicalExtentSize [ \fBbBsSkKmMgGtTpPeE\fR ]]
 .RB [ \-t | \-\-test ]
@@ -74,6 +76,19 @@ for tool performance reasons, you should consider
 some use of \fB--pvmetadatacopies 0\fP
 as described in \fBpvcreate(8)\fP.
 .TP
+.BR \-\-vgmetadatacopies " " \fI#copies\fR
+Sets the targetted number of metadata copies in the volume group.
+If set to a non-zero value, LVM will attempt to use \fB#copies\fP to
+determine the set of physical volumes on which to read and write metadata.
+LVM manages the set automatically by setting or clearing the 'metadataignore'
+flag on the physical volumes (see \fBpvchange\fP), and in this way balances
+metadata across PVs in the volume group.  Only physical volumes created
+with a non-zero value of \fBmetadatacopies\fP are used in the set of physical
+volumes.  This option is useful for volume groups containing large numbers
+of physical volumes containing metadata as it may be used to minimize metadata
+read and write overhead.
+The default value is 0, which disables LVM metadata balancing.
+.TP
 .BR \-s ", " \-\-physicalextentsize " " \fIPhysicalExtentSize\fR[\fBbBsSkKmMgGtTpPeE\fR]
 Sets the physical extent size on physical volumes of this volume group.
 A size suffix (k for kilobytes up to t for terabytes) is optional, megabytes
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
index 02b06fd..e56a3e5 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1243,6 +1243,18 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 		return 1;
 	}
 
+	if (arg_count(cmd, metadatacopies_ARG)) {
+		vp_new->metadata_copies = arg_int_value(cmd, metadatacopies_ARG,
+							DEFAULT_VGMETADATACOPIES);
+	} else if (arg_count(cmd, vgmetadatacopies_ARG)) {
+		vp_new->metadata_copies = arg_int_value(cmd, vgmetadatacopies_ARG,
+							DEFAULT_VGMETADATACOPIES);
+	} else {
+		vp_new->metadata_copies = find_config_tree_int(cmd,
+						   "metadata/vgmetadatacopies",
+						   DEFAULT_VGMETADATACOPIES);
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


