From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:38:24 -0000
Subject: LVM2 man/lvm.conf.5.in man/vgcreate.8.in tools ...
Message-ID: <20100628203824.19805.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:38:23

Modified files:
	man            : lvm.conf.5.in vgcreate.8.in 
	tools          : commands.h toollib.c vgcreate.c 

Log message:
	Add --vgmetadatacopies to vgcreate man page, command, and lvm.conf.
	
	Allow parsing of --vgmetadatacopies for vgcreate.  Accept
	--metadatacopies as a synonym for --vgmetadatacopies.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.conf.5.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgcreate.8.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.148&r2=1.149
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.203&r2=1.204
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.78&r2=1.79

--- LVM2/man/lvm.conf.5.in	2010/05/20 13:47:22	1.8
+++ LVM2/man/lvm.conf.5.in	2010/06/28 20:38:23	1.9
@@ -386,7 +386,7 @@
 Currently it can be set to 0, 1 or 2.  The default is 1.  
 If set to 2, one copy is placed at the beginning of the disk
 and the other is placed at the end.
-It can be overridden on the command line with \fB--metadatacopies\fP.
+It can be overridden on the command line with \fB--pvmetadatacopies\fP.
 If creating a volume group with just one physical volume, it's a
 good idea to have 2 copies.  If creating a large volume group with
 many physical volumes, you may decide that 3 copies of the metadata
@@ -406,6 +406,26 @@
 unused space becomes filled with an archive of the most recent
 previous versions of the metadata.
 .IP
+\fBvgmetadatacopies\fP \(em When creating a volume group using the
+LVM2 metadata format, this is the default number of copies of metadata
+desired across all the physical volumes in the volume group.  If set to
+a non-zero value, LVM will automatically set or clear the metadataignore
+flag on the physical volumes (see \fBpvchange --metadataignore\fP) in order
+to achieve the desired number of metadata copies.  An LVM command that
+adds or removes physical volumes (for example, \fBvgextend\fP, \fBvgreduce\fP,
+\fBvgsplit\fP, or \fBvgmerge\fP), may cause LVM to automatically set or
+clear the metadataignore flags.  Also, if physical volumes go missing or
+reappear, or a new number of copies is explicitly set (see
+\fBvgchange --vgmetadatacopies\fP), LVM may adjust the metadataignore flags.
+Set \fBvgmetadatacopies\fP to 0 instructs LVM not to set or clear the
+metadataignore flags automatically.  You may set a value larger than the
+sum of all metadata areas on all physical volumes.  The value can
+be overridden on the command line with \fB--vgmetadatacopies\fP for various
+commands (for example, \fBvgcreate\fP and \fBvgchange\fP), and can be
+queryied with the \fBvg_mda_copies\fP field of \fBvgs\fP.  This option
+is useful for volume groups containing large numbers of physical volumes
+with metadata as it may be used to minimize metadata read and write overhead.
+.IP
 \fBdirs\fP \(em List of directories holding live copies of LVM2
 metadata as text files.  These directories must not be on logical
 volumes.  It is possible to use LVM2 with a couple of directories
--- LVM2/man/vgcreate.8.in	2010/06/24 08:36:57	1.7
+++ LVM2/man/vgcreate.8.in	2010/06/28 20:38:23	1.8
@@ -16,6 +16,8 @@
 .RB [ -M | \-\-metadatatype type]
 .RB [ -p | \-\-maxphysicalvolumes
 .IR MaxPhysicalVolumes ]
+.RB [ \-\-[vg]metadatacopies ]
+.IR NumberOfCopies|unmanaged|all ]
 .RB [ \-s | \-\-physicalextentsize
 .IR PhysicalExtentSize [ \fBbBsSkKmMgGtTpPeE\fR ]]
 .RB [ \-t | \-\-test ]
@@ -66,13 +68,24 @@
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
--- LVM2/tools/commands.h	2010/06/28 20:37:37	1.148
+++ LVM2/tools/commands.h	2010/06/28 20:38:23	1.149
@@ -776,6 +776,7 @@
    "\t[-h|--help]" "\n"
    "\t[-l|--maxlogicalvolumes MaxLogicalVolumes]" "\n"
    "\t[-M|--metadatatype 1|2] " "\n"
+   "\t[--[vg]metadatacopies #copies] " "\n"
    "\t[-p|--maxphysicalvolumes MaxPhysicalVolumes] " "\n"
    "\t[-s|--physicalextentsize PhysicalExtentSize[bBsSkKmMgGtTpPeE]] " "\n"
    "\t[-t|--test] " "\n"
@@ -787,8 +788,8 @@
    addtag_ARG, alloc_ARG, autobackup_ARG, clustered_ARG, maxlogicalvolumes_ARG,
    maxphysicalvolumes_ARG, metadatatype_ARG, physicalextentsize_ARG, test_ARG,
    force_ARG, yes_ARG, zero_ARG, labelsector_ARG, metadatasize_ARG,
-   pvmetadatacopies_ARG, metadatacopies_ARG, dataalignment_ARG,
-   dataalignmentoffset_ARG)
+   pvmetadatacopies_ARG, metadatacopies_ARG, vgmetadatacopies_ARG,
+   dataalignment_ARG, dataalignmentoffset_ARG)
 
 xx(vgdisplay,
    "Display volume group information",
--- LVM2/tools/toollib.c	2010/06/28 20:36:37	1.203
+++ LVM2/tools/toollib.c	2010/06/28 20:38:23	1.204
@@ -1243,6 +1243,18 @@
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
 
--- LVM2/tools/vgcreate.c	2010/02/24 18:15:40	1.78
+++ LVM2/tools/vgcreate.c	2010/06/28 20:38:23	1.79
@@ -35,11 +35,6 @@
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
@@ -68,7 +63,8 @@
 	    !vg_set_max_lv(vg, vp_new.max_lv) ||
 	    !vg_set_max_pv(vg, vp_new.max_pv) ||
 	    !vg_set_alloc_policy(vg, vp_new.alloc) ||
-	    !vg_set_clustered(vg, vp_new.clustered))
+	    !vg_set_clustered(vg, vp_new.clustered) ||
+	    !vg_set_mda_copies(vg, vp_new.metadata_copies))
 		goto bad_orphan;
 
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {


