From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 31 Jul 2007 15:16:30 -0500
Subject: [PATCH 2 of 2] Mirror argument changes.
Message-ID: <1185912990.18824.15.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm2-mirror-argument-change.patch

 brassow

This patch changes the arguments that specify the mirror
log type.  Previously, we had a '--corelog' argument that
would change the default type from 'disk' to 'core'.  I
think that creates too much confusion - especially when
doing conversions on mirrors.

The new argument '--log' takes either "disk" or "core"
as a parameter.  This could be expanded in the future
for additional logging types as well.

Examples:
# Creating a 2-way mirror
$> lvcreate -m1 ... # implicitly use default disk logging
$> lvcreate -m1 --log disk ... # explicit disk logging
$> lvcreate -m1 --log core ... # specify core logging
$> lvcreate -m1 --corelog ... # old way still works

# Conversion examples
$> lvconvert --log core ... # convert to core logging
$> lvconvert --log disk ... # convert to disk logging
$> lvconvert -mX --corelog ... # old way still works
$> lvconvert -mX ... # old way of converting to disk logging still works

Changes are reflected in the man pages.

[Note: I did not update the WHATS_NEW file.]

Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>
Index: LVM2-cvs/tools/args.h
===================================================================
--- LVM2-cvs.orig/tools/args.h
+++ LVM2-cvs/tools/args.h
@@ -48,6 +48,7 @@ arg(mirrorsonly_ARG, '\0', "mirrorsonly"
 arg(nosync_ARG, '\0', "nosync", NULL)
 arg(resync_ARG, '\0', "resync", NULL)
 arg(corelog_ARG, '\0', "corelog", NULL)
+arg(log_ARG, '\0', "log", string_arg)
 arg(monitor_ARG, '\0', "monitor", yes_no_arg)
 arg(config_ARG, '\0', "config", string_arg)
 arg(trustcache_ARG, '\0', "trustcache", NULL)
Index: LVM2-cvs/tools/commands.h
===================================================================
--- LVM2-cvs.orig/tools/commands.h
+++ LVM2-cvs/tools/commands.h
@@ -88,7 +88,7 @@ xx(lvchange,
 xx(lvconvert,
    "Change logical volume layout",
    "lvconvert "
-   "[-m|--mirrors Mirrors [--corelog]]\n"
+   "[-m|--mirrors Mirrors [--log {disk|core}]]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
    "\t[--alloc AllocationPolicy]\n"
    "\t[-d|--debug]\n"
@@ -107,8 +107,8 @@ xx(lvconvert,
    "\t[--version]" "\n"
    "\tOriginalLogicalVolume[Path] SnapshotLogicalVolume[Path]\n",
 
-   alloc_ARG, chunksize_ARG, mirrors_ARG, corelog_ARG, regionsize_ARG,
-   snapshot_ARG, test_ARG, zero_ARG)
+   alloc_ARG, chunksize_ARG, mirrors_ARG, corelog_ARG, log_ARG,
+   regionsize_ARG, snapshot_ARG, test_ARG, zero_ARG)
 
 xx(lvcreate,
    "Create a logical volume",
@@ -123,7 +123,7 @@ xx(lvcreate,
    "\t{-l|--extents LogicalExtentsNumber |\n"
    "\t -L|--size LogicalVolumeSize[kKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
-   "\t[-m|--mirrors Mirrors [--nosync] [--corelog]]\n"
+   "\t[-m|--mirrors Mirrors [--nosync] [--log {disk|core}]]\n"
    "\t[-n|--name LogicalVolumeName]\n"
    "\t[-p|--permission {r|rw}]\n"
    "\t[-r|--readahead ReadAheadSectors]\n"
@@ -156,7 +156,7 @@ xx(lvcreate,
    "\tOriginalLogicalVolume[Path] [PhysicalVolumePath...]\n\n",
 
    addtag_ARG, alloc_ARG, autobackup_ARG, chunksize_ARG, contiguous_ARG,
-   corelog_ARG, extents_ARG, major_ARG, minor_ARG, mirrors_ARG, name_ARG,
+   corelog_ARG, log_ARG, extents_ARG, major_ARG, minor_ARG, mirrors_ARG, name_ARG,
    nosync_ARG, permission_ARG, persistent_ARG, readahead_ARG, regionsize_ARG,
    size_ARG, snapshot_ARG, stripes_ARG, stripesize_ARG, test_ARG, type_ARG,
    zero_ARG)
Index: LVM2-cvs/tools/lvcreate.c
===================================================================
--- LVM2-cvs.orig/tools/lvcreate.c
+++ LVM2-cvs/tools/lvcreate.c
@@ -241,6 +241,7 @@ static int _read_mirror_params(struct lv
 	int argc = *pargc;
 	int region_size;
 	int pagesize = lvm_getpagesize();
+	const char *log_arg;
 
 	if (argc && (unsigned) argc < lp->mirrors) {
 		log_error("Too few physical volumes on "
@@ -284,7 +285,25 @@ static int _read_mirror_params(struct lv
 		return 0;
 	}
 
-	lp->corelog = arg_count(cmd, corelog_ARG) ? 1 : 0;
+	if (arg_count(cmd, corelog_ARG)) {
+		log_verbose("Setting logging type to \"core\"");
+		lp->corelog = 1;
+	}
+
+	if (arg_count(cmd, log_ARG)) {
+		log_arg = arg_str_value(cmd, log_ARG, "disk");
+		if (!strcmp("disk", log_arg)) {
+			log_verbose("Setting logging type to \"disk\"");
+			lp->corelog = 0;
+		} else if (!strcmp("core", log_arg)) {
+			log_verbose("Setting logging type to \"core\"");
+			lp->corelog = 1;
+		} else {
+			log_error("Unknown logging type, \"%s\"", log_arg);
+			return 0;
+		}
+	}
+
 	lp->nosync = arg_count(cmd, nosync_ARG) ? 1 : 0;
 
 	return 1;
Index: LVM2-cvs/man/lvconvert.8
===================================================================
--- LVM2-cvs.orig/man/lvconvert.8
+++ LVM2-cvs/man/lvconvert.8
@@ -3,7 +3,7 @@
 lvconvert \- convert a logical volume from linear to mirror or snapshot
 .SH SYNOPSIS
 .B lvconvert
-\-m/\-\-mirrors Mirrors [\-\-corelog] [\-R/\-\-regionsize MirrorLogRegionSize]
+\-m/\-\-mirrors Mirrors [\-\-log {disk|core}] [\-R/\-\-regionsize MirrorLogRegionSize]
 [\-A/\-\-alloc AllocationPolicy]
 [\-h/\-?/\-\-help]
 [\-v/\-\-verbose]
@@ -37,12 +37,10 @@ For example, "-m 1" would convert the or
 volume to a mirror volume with 2-sides; that is, a
 linear volume plus one copy.
 .TP
-.I \-\-corelog
-This optional argument tells lvconvert to switch the
-mirror from using a disk-based (persistent) log to
-an in-memory log.  You may only specify this option
-when the \-\-mirror argument is the same degree of
-the mirror you are changing.
+.I \-\-log disk/core
+This optional argument gives the ability to switch the
+logging type that is used by a mirror.  The logging type
+can be either "disk" (persistent) or "core" (non-persistent).
 .TP
 .I \-R, \-\-regionsize MirrorLogRegionSize
 A mirror is divided into regions of this size (in MB), and the mirror log
@@ -64,14 +62,17 @@ If the volume is read-only the snapshot 
 "lvconvert -m1 vg00/lvol1"
 .br
 converts the linear logical volume "vg00/lvol1" to
-a mirror logical volume.  This command could also
-be used to convert a two-way mirror with an
-in-memory log to a two-way mirror with a disk log.
+a two-legged mirror logical volume.
 
-"lvconvert -m1 --corelog vg00/lvol1"
+"lvconvert --log core vg00/lvol1"
 .br
-converts a two-way mirror with a disk log to a
-two-way mirror with an in-memory log.
+converts a mirror with a disk log to a
+mirror with an in-memory log.
+
+"lvconvert --log disk vg00/lvol1"
+.br
+converts a mirror with an in-memory log
+to a mirror with a disk log.
 
 "lvconvert -m0 vg00/lvol1"
 .br
Index: LVM2-cvs/man/lvcreate.8
===================================================================
--- LVM2-cvs.orig/man/lvcreate.8
+++ LVM2-cvs/man/lvcreate.8
@@ -11,7 +11,7 @@ lvcreate \- create a logical volume in a
 {\-l/\-\-extents LogicalExtentsNumber[%{VG|FREE}] |
  \-L/\-\-size LogicalVolumeSize[kKmMgGtT]}
 [\-M/\-\-persistent y/n] [\-\-minor minor]
-[\-m/\-\-mirrors Mirrors [\-\-nosync] [\-\-corelog]
+[\-m/\-\-mirrors Mirrors [\-\-nosync] [\-\-log {disk|log}]
 [\-R/\-\-regionsize MirrorLogRegionSize]]
 [\-n/\-\-name LogicalVolumeName]
 [\-p/\-\-permission r/rw] [\-r/\-\-readahead ReadAheadSectors]
@@ -95,11 +95,13 @@ afterwards will be mirrored, but the ori
 copied.  This is useful for skipping a potentially long and resource
 intensive initial sync.
 
-Specifying the optional argument "--corelog" will create a mirror with
-an in-memory log verses a disk-based (persistent) log.  While this
-removes the need for an extra log device and *may* be slightly faster,
-it requires that the entire mirror be resynchronized upon each
-instantiation (e.g. a reboot).
+The optional argument "--log" gives the ability to specify the type
+of mirror log to be used.  The available types are "disk" and "core",
+where "disk" is the default.  The "disk" log is persistent and requires
+a small amount of storage space - usually on a separate device from the
+mirror legs.  While the "disk" log may cause the mirror to be slightly
+slower during writes, it prevents the need to completely resynchronize
+the mirror upon each instantiation (e.g. a reboot).
 .TP
 .I \-n, \-\-name LogicalVolumeName
 The name for the new logical volume.
@@ -157,6 +159,10 @@ with 2 sides with a useable size of 500 
 require 3 devices - two for the mirror devices and one for the disk
 log.
 
+"lvcreate -m1 --log core -L 500M vg00" tries to create a mirror logical volume
+with 2 sides with a useable size of 500 MiB.  This operation would
+require 2 devices - the log is "in-memory".
+
 "lvcreate --size 100m --snapshot --name snap /dev/vg00/lvol1"
 .br
 creates a snapshot logical volume named /dev/vg00/snap which has access to the
Index: LVM2-cvs/tools/lvconvert.c
===================================================================
--- LVM2-cvs.orig/tools/lvconvert.c
+++ LVM2-cvs/tools/lvconvert.c
@@ -101,14 +101,31 @@ static int _lvconvert_name_params(struct
 static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			int argc, char **argv)
 {
+	int count;
 	int region_size;
 	int pagesize = lvm_getpagesize();
 
 	memset(lp, 0, sizeof(*lp));
 
-	if (arg_count(cmd, mirrors_ARG) + arg_count(cmd, snapshot_ARG) != 1) {
-		log_error("Exactly one of --mirrors or --snapshot arguments "
-			  "required.");
+	if (arg_count(cmd, log_ARG) > 1) {
+		log_error("Too many --log arguments supplied.");
+		return 0;
+	}
+	if (arg_count(cmd, mirrors_ARG) > 1) {
+		log_error("Too many --mirrors arguments supplied.");
+		return 0;
+	}
+	if (arg_count(cmd, snapshot_ARG) > 1) {
+		log_error("Too many --snapshot arguments supplied.");
+		return 0;
+	}
+	if (arg_count(cmd, log_ARG) || arg_count(cmd, mirrors_ARG))
+		count = 1;
+	count += arg_count(cmd, snapshot_ARG);
+
+	if (count != 1) {
+		log_error("--snapshots argument cannot be mixed "
+			  "with --mirrors or --log");
 		return 0;
 	}
 
@@ -237,6 +254,8 @@ static int lvconvert_mirrors(struct cmd_
 	struct list *parallel_areas;
 	struct segment_type *segtype;  /* FIXME: could I just use lp->segtype */
 	float sync_percent;
+	const char *log_arg;
+	int corelog = 0;
 
 	seg = first_seg(lv);
 	existing_mirrors = seg->area_count;
@@ -267,6 +286,31 @@ static int lvconvert_mirrors(struct cmd_
 		return 0;
 	}
 
+	/*
+	 * Adjust log type
+	 */
+	if (arg_count(cmd, corelog_ARG)) {
+		log_verbose("Setting logging type to \"core\"");
+		corelog = 1;
+	}
+
+	if (arg_count(cmd, log_ARG)) {
+		log_arg = arg_str_value(cmd, log_ARG, "disk");
+		if (!strcmp("disk", log_arg)) {
+			log_verbose("Setting logging type to \"disk\"");
+			corelog = 0;
+		} else if (!strcmp("core", log_arg)) {
+			log_verbose("Setting logging type to \"core\"");
+			corelog = 1;
+		} else {
+			log_error("Unknown logging type, \"%s\"", log_arg);
+			return 0;
+		}
+	}
+
+	/*
+	 * Region size must not change on existing mirrors
+	 */
 	if (arg_count(cmd, regionsize_ARG) && (lv->status & MIRRORED) &&
 	    (lp->region_size != seg->region_size)) {
 		log_error("Mirror log region size cannot be changed on "
@@ -309,7 +353,7 @@ static int lvconvert_mirrors(struct cmd_
 
 		if (!(ah = allocate_extents(lv->vg, NULL, lp->segtype,
 					    1, lp->mirrors - 1,
-					    arg_count(cmd, corelog_ARG) ? 0 : 1,
+					    corelog ? 0 : 1,
 					    lv->le_count * (lp->mirrors - 1),
 					    NULL, 0, 0, lp->pvh,
 					    lp->alloc,
@@ -321,7 +365,7 @@ static int lvconvert_mirrors(struct cmd_
 							      lp->region_size);
 
 		log_lv = NULL;
-		if (!arg_count(cmd, corelog_ARG) &&
+		if (!corelog &&
 		    !(log_lv = create_mirror_log(cmd, lv->vg, ah,
 						 lp->alloc,
 						 lv->name, 0, &lv->tags))) {
@@ -348,7 +392,7 @@ static int lvconvert_mirrors(struct cmd_
 	}
 
 	if (lp->mirrors == existing_mirrors) {
-		if (!seg->log_lv && !arg_count(cmd, corelog_ARG)) {
+		if (!seg->log_lv && !corelog) {
 			/* No disk log present, add one. */
 			if (!(parallel_areas = build_parallel_areas_from_lv(cmd, lv)))
 				return_0;
@@ -383,7 +427,7 @@ static int lvconvert_mirrors(struct cmd_
 			seg->log_lv = log_lv;
 			log_lv->status |= MIRROR_LOG;
 			first_seg(log_lv)->mirror_seg = seg;
-		} else if (seg->log_lv && arg_count(cmd, corelog_ARG)) {
+		} else if (seg->log_lv && corelog) {
 			/* Had disk log, switch to core. */
 			if (!lv_mirror_percent(cmd, lv, 0, &sync_percent, NULL)) {
 				log_error("Unable to determine mirror sync status.");
@@ -543,7 +587,8 @@ static int lvconvert_single(struct cmd_c
 		return ECMD_FAILED;
 	}
 
-	if (arg_count(cmd, mirrors_ARG)) {
+	if (arg_count(cmd, mirrors_ARG) ||
+	    ((lv->status & MIRRORED) && arg_count(cmd, log_ARG))) {
 		if (!archive(lv->vg))
 			return ECMD_FAILED;
 		if (!lvconvert_mirrors(cmd, lv, lp))



