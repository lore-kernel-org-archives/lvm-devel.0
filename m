From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 21 Oct 2009 14:41:43 -0400
Subject: [PATCH] Document --all option in man pages, cleanup {pv|vg|lv}{s|display} man pages.
Message-ID: <1256150503-10901-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Option --all is only partially documented currently, so document in all
commands.  Also make {pv|vg|lv}{display|s} man pages consistent with help
output.  Remove ununsed 'disk_ARG' parameter.  Leave --trustcache out of
the man page output.  Update --units argument to show all possible units.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 man/lvdisplay.8.in |   43 ++++++++++++++++++++++++++++++++++++++++---
 man/lvs.8.in       |   15 +++++++++++++--
 man/lvscan.8.in    |    9 +++++++++
 man/pvdisplay.8.in |   37 ++++++++++++++++++++++++++++++++++---
 man/pvs.8.in       |   13 +++++++++++--
 man/vgdisplay.8.in |   30 +++++++++++++++++++++++++-----
 man/vgs.8.in       |    4 ++++
 tools/args.h       |    1 -
 tools/commands.h   |   28 ++++++++++++++--------------
 tools/vgdisplay.c  |    2 --
 10 files changed, 150 insertions(+), 32 deletions(-)

diff --git a/man/lvdisplay.8.in b/man/lvdisplay.8.in
index 56d33f2..1c169fc 100644
--- a/man/lvdisplay.8.in
+++ b/man/lvdisplay.8.in
@@ -3,10 +3,34 @@
 lvdisplay \- display attributes of a logical volume
 .SH SYNOPSIS
 .B lvdisplay
+[\-a|\-\-all]
 [\-c|\-\-colon] [\-d|\-\-debug] [\-h|\-?|\-\-help]
 [\-\-ignorelockingfailure]
-[\-\-maps] [\-P|\-\-partial]
-[\-v|\-\-verbose] LogicalVolumePath [LogicalVolumePath...]
+[\-\-maps]
+[\-\-nosuffix]
+[\-P|\-\-partial]
+[\-\-units hHbBsSkKmMgGtTpPeE]
+[\-v|\-\-verbose]
+[\-\-version] [LogicalVolumePath [LogicalVolumePath...]]
+.br
+
+.br
+.B lvdisplay \-\-columns | \-C
+[\-\-aligned]
+[\-a|\-\-all]
+[\-d|\-\-debug] [\-h|\-?|\-\-help]
+[\-\-ignorelockingfailure]
+[\-\-noheadings]
+[\-\-nosuffix]
+[\-o|\-\-options [+]Field[,Field]]
+[\-O|\-\-sort [+|-]Key1[,[+|-]Key2[,...]]]
+[\-P|\-\-partial]
+[\-\-segments]
+[\-\-separator Separator]
+[\-\-unbuffered]
+[\-\-units hHbBsSkKmMgGtTpPeE]
+[\-v|\-\-verbose]
+[\-\-version] [LogicalVolumePath [LogicalVolumePath...]]
 .SH DESCRIPTION
 lvdisplay allows you to see the attributes of a logical volume
 like size, read/write status, snapshot information etc.
@@ -16,7 +40,16 @@ in the style of \fBps\fP (1).  \fBlvs\fP is recommended over
 \fBlvdisplay\fP.
 
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See \fBlvm\fP for common options and \fBlvs\fP for options given with
+\fB\-\-columns\fP.
+.TP
+.I \-\-all
+Include information in the output about internal Logical Volumes that
+are components of normally-accessible Logical Volumes, such as mirrors,
+but which are not independently accessible (e.g. not mountable).
+For example, after creating a mirror using 'lvcreate -m1 --mirrorlog disk',
+this option will reveal three internal Logical Volumes, with suffixes
+mimage_0, mimage_1, and mlog.
 .TP
 .I \-c, \-\-colon
 Generate colon separated output for easier parsing in scripts or programs.
@@ -44,6 +77,10 @@ The values are:
 .I \-m, \-\-maps
 Display the mapping of logical extents to physical volumes and
 physical extents.
+.TP
+.I \-\-columns | \-C
+Display output in columns, the equivalent of \fBlvs\fP.  Options listed
+are the same as options given in \fBlvs (8)\fP.
 .SH Examples
 "lvdisplay -v /dev/vg00/lvol2" shows attributes of that logical volume.
 If snapshot
diff --git a/man/lvs.8.in b/man/lvs.8.in
index ff37a99..87d6205 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -3,21 +3,32 @@
 lvs \- report information about logical volumes
 .SH SYNOPSIS
 .B lvs
+[\-a|\-\-all]
 [\-\-aligned] [\-d|\-\-debug] [\-h|\-?|\-\-help]
 [\-\-ignorelockingfailure] [\-\-nameprefixes] [\-\-noheadings] [\-\-nosuffix]
 [\-o|\-\-options [+]Field[,Field]]
 [\-O|\-\-sort [+|-]Key1[,[+|-]Key2[,...]]]
 [\-P|\-\-partial] [\-\-rows] [\-\-segments]
-[\-\-separator Separator] [\-\-unbuffered]
+[\-\-separator Separator]
+[\-\-unbuffered]
 [\-\-units hHbBsSkKmMgGtTpPeE]
 [\-\-unquoted]
 [\-v|\-\-verbose] 
-[\-\-version] [VolumeGroupName [VolumeGroupName...]]
+[\-\-version] [LogicalVolumePath [LogicalVolumePath...]]
 .SH DESCRIPTION
 lvs produces formatted output about logical volumes.
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .TP
+.I \-\-all
+Include information in the output about internal Logical Volumes that
+are components of normally-accessible Logical Volumes, such as mirrors,
+but which are not independently accessible (e.g. not mountable).
+The names of such Logical Volumes are enclosed within square brackets
+in the output.  For example, after creating a mirror using 'lvcreate -m1
+--mirrorlog disk', this option will reveal three internal Logical
+Volumes, with suffixes mimage_0, mimage_1, and mlog.
+.TP
 .I \-\-aligned
 Use with \-\-separator to align the output columns.
 .TP
diff --git a/man/lvscan.8.in b/man/lvscan.8.in
index cdcdc1d..3dbe9d8 100644
--- a/man/lvscan.8.in
+++ b/man/lvscan.8.in
@@ -3,6 +3,7 @@
 lvscan \- scan (all disks) for logical volumes
 .SH SYNOPSIS
 .B lvscan
+.RB [ \-a | \-\-all]
 .RB [ \-b | \-\-blockdevice ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
@@ -16,6 +17,14 @@ in the system for defined logical volumes.
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .TP
+.BR \-\-all
+Include information in the output about internal Logical Volumes that
+are components of normally-accessible Logical Volumes, such as mirrors,
+but which are not independently accessible (e.g. not mountable).
+For example, after creating a mirror using 'lvcreate -m1 --mirrorlog disk',
+this option will reveal three internal Logical Volumes, with suffixes
+mimage_0, mimage_1, and mlog.
+.TP
 .BR \-b ", " \-\-blockdevice
 Adds the device major and minor numbers to the display
 of each logical volume.
diff --git a/man/pvdisplay.8.in b/man/pvdisplay.8.in
index 40d68ad..efa3894 100644
--- a/man/pvdisplay.8.in
+++ b/man/pvdisplay.8.in
@@ -3,9 +3,34 @@
 pvdisplay \- display attributes of a physical volume
 .SH SYNOPSIS
 .B pvdisplay
-[\-c|\-\-colon] [\-d|\-\-debug] [\-h|\-?|\-\-help] [\-s|\-\-short]
+[\-c|\-\-colon]
+[\-d|\-\-debug] [\-h|\-?|\-\-help]
+[\-\-ignorelockingfailure]
+[\-\-maps]
+[\-\-nosuffix]
+[\-s|\-\-short]
+[\-\-units hsbkmgtHKMGT]
 [\-v[v]|\-\-verbose [\-\-verbose]]
-PhysicalVolumePath [PhysicalVolumePath...]
+[\-\-version]
+[PhysicalVolumePath [PhysicalVolumePath...]]
+.br
+
+.br
+.B pvdisplay \-\-columns | \-C
+[\-\-aligned]
+[\-a|\-\-all]
+[\-d|\-\-debug] [\-h|\-?|\-\-help]
+[\-\-ignorelockingfailure]
+[\-\-noheadings]
+[\-\-nosuffix]
+[\-o|\-\-options [+]Field[,Field]]
+[\-O|\-\-sort [+|-]Key1[,[+|-]Key2[,...]]]
+[\-\-separator Separator]
+[\-\-unbuffered]
+[\-\-units hHbBsSkKmMgGtTpPeE]
+[\-v[v]|\-\-verbose [\-\-verbose]]
+[\-\-version]
+[PhysicalVolumePath [PhysicalVolumePath...]]
 .SH DESCRIPTION
 pvdisplay allows you to see the attributes of one or more physical volumes
 like size, physical extent size, space used for the volume group descriptor
@@ -14,7 +39,8 @@ area and so on.
 \fBpvs\fP (8) is an alternative that provides the same information 
 in the style of \fBps\fP (1).
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See \fBlvm\fP for common options and \fBpvs\fP for options given with
+\fB\-\-columns\fP.
 .TP
 .I \-c, \-\-colon
 Generate colon separated output for easier parsing in scripts or programs.
@@ -43,6 +69,11 @@ Only display the size of the given physical volumes.
 .I \-m, \-\-maps
 Display the mapping of physical extents to logical volumes and
 logical extents.
+.TP
+.I \-\-columns | \-C
+Display output in columns, the equivalent of \fBpvs\fP (8).  See
+\fBpvs (8)\fP for a description of other options with this form of
+\fBpvdisplay\fP.
 .SH SEE ALSO
 .BR lvm (8),
 .BR pvcreate (8),
diff --git a/man/pvs.8.in b/man/pvs.8.in
index 6bd693f..fe00d2a 100644
--- a/man/pvs.8.in
+++ b/man/pvs.8.in
@@ -3,12 +3,16 @@
 pvs \- report information about physical volumes
 .SH SYNOPSIS
 .B pvs
+[\-a|\-\-all]
 [\-\-aligned] [\-d|\-\-debug] [\-h|\-?|\-\-help]
 [\-\-ignorelockingfailure] [\-\-nameprefixes] [\-\-noheadings] [\-\-nosuffix]
 [\-o|\-\-options [+]Field[,Field]]
 [\-O|\-\-sort [+|-]Key1[,[+|-]Key2[,...]]]
-[\-\-rows] [\-\-segments]
-[\-\-separator Separator] [\-\-unbuffered]
+[\-P|\-\-partial]
+[\-\-rows]
+[\-\-segments]
+[\-\-separator Separator]
+[\-\-unbuffered]
 [\-\-units hHbBsSkKmMgGtTpPeE]
 [\-\-unquoted]
 [\-v|\-\-verbose] 
@@ -17,6 +21,11 @@ pvs \- report information about physical volumes
 pvs produces formatted output about physical volumes.
 .SH OPTIONS
 See \fBlvm\fP for common options.
+\fB\-\-columns\fP.
+.TP
+.I \-\-all
+Include information in the output about devices that have not been
+initialized with \fBpvcreate\fP.
 .TP
 .I \-\-aligned
 Use with \-\-separator to align the output columns.
diff --git a/man/vgdisplay.8.in b/man/vgdisplay.8.in
index 98f6372..96dfe8c 100644
--- a/man/vgdisplay.8.in
+++ b/man/vgdisplay.8.in
@@ -4,15 +4,30 @@ vgdisplay \- display attributes of volume groups
 .SH SYNOPSIS
 .B vgdisplay
 .RB [ \-A | \-\-activevolumegroups ]
-.RB [ \-c | \-\-colon ]
+.RB [ \-c | \-\-colon | \-s | \-\-short | \-v|\-\-verbose ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
 .RB [ \-\-ignorelockingfailure ]
+.RB [ \-\-nosuffix ]
 .RB [ \-P | \-\-partial ]
-.RB [ \-s | \-\-short ]
-.RB [ \-v [ v ]| \-\-verbose " [" \-\-verbose ]]
+.RB [\-\-units hHbBsSkKmMgGtTpPeE]
 .RB [ \-\-version ]
-.RI [ VolumeGroupName ...]
+.RI [VolumeGroupName [VolumeGroupName...]]
+.br
+
+.br
+.B vgdisplay \-\-columns | \-C
+.RB [ \-\-aligned ] [ \-d|\-\-debug ] [ \-h|\-?|\-\-help ]
+.RB [ \-\-ignorelockingfailure ] [ \-\-noheadings ] [ \-\-nosuffix ]
+.RB [ \-o|\-\-options [+]Field[,Field] ]
+.RB [ \-O|\-\-sort [+|-]Key1[,[+|-]Key2[,...]] ]
+.RB [ \-P|\-\-partial ]
+.RB [ \-\-separator Separator ]
+.RB [ \-\-unbuffered ]
+.RB [ \-\-units hHbBsSkKmMgGtTpPeE ]
+.RB [ \-v|\-\-verbose ]
+.RB [ \-\-version ]
+.RI [VolumeGroupName [VolumeGroupName...]]
 .SH DESCRIPTION
 .B vgdisplay
 allows you to see the attributes of
@@ -23,7 +38,8 @@ volumes and their sizes etc.
 \fBvgs\fP (8) is an alternative that provides the same information 
 in the style of \fBps\fP (1).
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See \fBlvm\fP for common options and \fBvgs\fP for options given with
+\fB\-\-columns\fP.
 .TP
 .BR \-A ", " \-\-activevolumegroups
 Only select the active volume groups.
@@ -65,6 +81,10 @@ information of vgdisplay's activities.
 .TP
 .BR \-\-version
 Display version and exit successfully.
+.TP
+.BR \-\-columns | \-C
+Display output in columns, the equivalent of \fBvgs\fP.  Options listed
+are the same as options given in \fPvgs (8)\fP.
 .SH SEE ALSO
 .BR lvm (8),
 .BR vgs (8),
diff --git a/man/vgs.8.in b/man/vgs.8.in
index b9abaa8..b22d08b 100644
--- a/man/vgs.8.in
+++ b/man/vgs.8.in
@@ -3,6 +3,7 @@
 vgs \- report information about volume groups
 .SH SYNOPSIS
 .B vgs
+[\-a|\-\-all]
 [\-\-aligned] [\-d|\-\-debug] [\-h|\-?|\-\-help]
 [\-\-ignorelockingfailure] [\-\-nameprefixes] [\-\-noheadings] [\-\-nosuffix]
 [\-o|\-\-options [+]Field[,Field]]
@@ -18,6 +19,9 @@ vgs produces formatted output about volume groups.
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .TP
+.I \-\-all
+List all volume groups.  Equivalent to not specifying any volume groups.
+.TP
 .I \-\-aligned
 Use with \-\-separator to align the output columns.
 .TP
diff --git a/tools/args.h b/tools/args.h
index 3f8cda5..1f2427b 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -84,7 +84,6 @@ arg(colon_ARG, 'c', "colon", NULL, 0)
 arg(columns_ARG, 'C', "columns", NULL, 0)
 arg(contiguous_ARG, 'C', "contiguous", yes_no_arg, 0)
 arg(debug_ARG, 'd', "debug", NULL, ARG_REPEATABLE)
-arg(disk_ARG, 'D', "disk", NULL, 0)
 arg(exported_ARG, 'e', "exported", NULL, 0)
 arg(physicalextent_ARG, 'E', "physicalextent", NULL, 0)
 arg(file_ARG, 'f', "file", string_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index b54809b..85222e4 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -195,7 +195,7 @@ xx(lvdisplay,
    "\t[-m|--maps]\n"
    "\t[--nosuffix]\n"
    "\t[-P|--partial] " "\n"
-   "\t[--units hsbkmgtHKMGT]\n"
+   "\t[--units hHbBsSkKmMgGtTpPeE]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n"
    "\t[LogicalVolume[Path] [LogicalVolume[Path]...]]\n"
@@ -214,12 +214,12 @@ xx(lvdisplay,
    "\t[--segments]\n"
    "\t[--separator Separator]\n"
    "\t[--unbuffered]\n"
-   "\t[--units hsbkmgtHKMGT]\n"
+   "\t[--units hHbBsSkKmMgGtTpPeE]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n"
    "\t[LogicalVolume[Path] [LogicalVolume[Path]...]]\n",
 
-    aligned_ARG, all_ARG, colon_ARG, columns_ARG, disk_ARG,
+    aligned_ARG, all_ARG, colon_ARG, columns_ARG,
     ignorelockingfailure_ARG, maps_ARG, noheadings_ARG, nosuffix_ARG,
     options_ARG, sort_ARG, partial_ARG, segments_ARG, separator_ARG,
     unbuffered_ARG, units_ARG)
@@ -396,7 +396,7 @@ xx(lvs,
    "\t[--separator Separator]\n"
    "\t[--trustcache]\n"
    "\t[--unbuffered]\n"
-   "\t[--units hsbkmgtHKMGT]\n"
+   "\t[--units hHbBsSkKmMgGtTpPeE]\n"
    "\t[--unquoted]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n"
@@ -420,7 +420,7 @@ xx(lvscan,
    "\t[-v|--verbose] " "\n"
    "\t[--version]\n",
 
-   all_ARG, blockdevice_ARG, disk_ARG, ignorelockingfailure_ARG, partial_ARG)
+   all_ARG, blockdevice_ARG, ignorelockingfailure_ARG, partial_ARG)
 
 xx(pvchange,
    "Change attributes of physical volume(s)",
@@ -527,7 +527,7 @@ xx(pvdisplay,
    "\t[-m|--maps]\n"
    "\t[--nosuffix]\n"
    "\t[-s|--short]\n"
-   "\t[--units hsbkmgtHKMGT]\n"
+   "\t[--units hHbBsSkKmMgGtTpPeE]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n"
    "\t[PhysicalVolumePath [PhysicalVolumePath...]]\n"
@@ -544,7 +544,7 @@ xx(pvdisplay,
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[--separator Separator]\n"
    "\t[--unbuffered]\n"
-   "\t[--units hsbkmgtHKMGT]\n"
+   "\t[--units hHbBsSkKmMgGtTpPeE]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n"
    "\t[PhysicalVolumePath [PhysicalVolumePath...]]\n",
@@ -595,8 +595,8 @@ xx(pvs,
    "Display information about physical volumes",
    CACHE_VGMETADATA,
    "pvs" "\n"
-   "\t[--aligned]\n"
    "\t[-a|--all]\n"
+   "\t[--aligned]\n"
    "\t[-d|--debug]" "\n"
    "\t[-h|-?|--help] " "\n"
    "\t[--ignorelockingfailure]\n"
@@ -611,7 +611,7 @@ xx(pvs,
    "\t[--separator Separator]\n"
    "\t[--trustcache]\n"
    "\t[--unbuffered]\n"
-   "\t[--units hsbkmgtHKMGT]\n"
+   "\t[--units hHbBsSkKmMgGtTpPeE]\n"
    "\t[--unquoted]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
@@ -768,14 +768,14 @@ xx(vgdisplay,
    "Display volume group information",
    0,
    "vgdisplay " "\n"
+   "\t[-A|--activevolumegroups]" "\n"
    "\t[-c|--colon | -s|--short | -v|--verbose]" "\n"
    "\t[-d|--debug] " "\n"
    "\t[-h|--help] " "\n"
    "\t[--ignorelockingfailure]" "\n"
    "\t[--nosuffix]\n"
    "\t[-P|--partial] " "\n"
-   "\t[--units hsbkmgtHKMGT]\n"
-   "\t[-A|--activevolumegroups | [-D|--disk]" "\n"
+   "\t[--units hHbBsSkKmMgGtTpPeE]\n"
    "\t[--version]" "\n"
    "\t[VolumeGroupName [VolumeGroupName...]]\n"
    "\n"
@@ -791,12 +791,12 @@ xx(vgdisplay,
    "\t[-P|--partial] " "\n"
    "\t[--separator Separator]\n"
    "\t[--unbuffered]\n"
-   "\t[--units hsbkmgtHKMGT]\n"
+   "\t[--units hHbBsSkKmMgGtTpPeE]\n"
    "\t[--verbose]" "\n"
    "\t[--version]" "\n"
    "\t[VolumeGroupName [VolumeGroupName...]]\n",
 
-   activevolumegroups_ARG, aligned_ARG, colon_ARG, columns_ARG, disk_ARG,
+   activevolumegroups_ARG, aligned_ARG, colon_ARG, columns_ARG,
    ignorelockingfailure_ARG, noheadings_ARG, nosuffix_ARG, options_ARG,
    partial_ARG, short_ARG, separator_ARG, sort_ARG, unbuffered_ARG, units_ARG)
 
@@ -944,7 +944,7 @@ xx(vgs,
    "\t[--separator Separator]\n"
    "\t[--trustcache]\n"
    "\t[--unbuffered]\n"
-   "\t[--units hsbkmgtHKMGT]\n"
+   "\t[--units hHbBsSkKmMgGtTpPeE]\n"
    "\t[--unquoted]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
diff --git a/tools/vgdisplay.c b/tools/vgdisplay.c
index 06965bf..29bc7f1 100644
--- a/tools/vgdisplay.c
+++ b/tools/vgdisplay.c
@@ -79,8 +79,6 @@ int vgdisplay(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	/* FIXME -D disk_ARG is now redundant */
-
 /********* FIXME: Do without this - or else 2(+) passes!
 	   Figure out longest volume group name
 	for (c = opt; opt < argc; opt++) {
-- 
1.6.0.6


