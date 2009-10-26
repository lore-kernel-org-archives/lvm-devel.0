From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Oct 2009 14:37:11 -0000
Subject: LVM2 ./WHATS_NEW man/lvdisplay.8.in man/lvs.8. ...
Message-ID: <20091026143711.17248.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-10-26 14:37:09

Modified files:
	.              : WHATS_NEW 
	man            : lvdisplay.8.in lvs.8.in lvscan.8.in 
	                 pvdisplay.8.in pvs.8.in vgdisplay.8.in vgs.8.in 
	tools          : args.h commands.h vgdisplay.c 

Log message:
	Document --all option in man pages, cleanup {pv|vg|lv}{s|display} man pages.
	
	Option --all is only partially documented currently, so document in all
	commands.  Also make {pv|vg|lv}{display|s} man pages consistent with help
	output.  Remove ununsed 'disk_ARG' parameter.  Leave --trustcache out of
	the man page output.  Update --units argument to show all possible units.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1303&r2=1.1304
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvdisplay.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvs.8.in.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvscan.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvdisplay.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvs.8.in.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgdisplay.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgs.8.in.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.68&r2=1.69
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.134&r2=1.135
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgdisplay.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27

--- LVM2/WHATS_NEW	2009/10/26 10:01:56	1.1303
+++ LVM2/WHATS_NEW	2009/10/26 14:37:09	1.1304
@@ -1,5 +1,7 @@
 Version 2.02.54 -
 =====================================
+  Update lvcreate/lvconvert man pages to explain PhysicalVolume parameter.
+  Document --all option in man pages, cleanup {pv|vg|lv}{s|display} man pages.
   Permit snapshots of mirrors.
   Cleanup mimagetmp LV if allocation fails for new lvconvert mimage.
   Fix clvmd segfault when refresh_toolcontext fails.
--- LVM2/man/lvdisplay.8.in	2008/11/12 15:01:36	1.2
+++ LVM2/man/lvdisplay.8.in	2009/10/26 14:37:09	1.3
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
@@ -16,7 +40,16 @@
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
@@ -44,6 +77,10 @@
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
--- LVM2/man/lvs.8.in	2009/07/07 19:28:57	1.10
+++ LVM2/man/lvs.8.in	2009/10/26 14:37:09	1.11
@@ -3,12 +3,14 @@
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
@@ -18,6 +20,15 @@
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
--- LVM2/man/lvscan.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/lvscan.8.in	2009/10/26 14:37:09	1.2
@@ -3,6 +3,7 @@
 lvscan \- scan (all disks) for logical volumes
 .SH SYNOPSIS
 .B lvscan
+.RB [ \-a | \-\-all]
 .RB [ \-b | \-\-blockdevice ]
 .RB [ \-d | \-\-debug ]
 .RB [ \-h | \-\-help ]
@@ -16,6 +17,14 @@
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
--- LVM2/man/pvdisplay.8.in	2008/11/12 15:01:36	1.2
+++ LVM2/man/pvdisplay.8.in	2009/10/26 14:37:09	1.3
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
@@ -14,7 +39,8 @@
 \fBpvs\fP (8) is an alternative that provides the same information 
 in the style of \fBps\fP (1).
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See \fBlvm\fP for common options and \fBpvs\fP for options given with
+\fB\-\-columns\fP.
 .TP
 .I \-c, \-\-colon
 Generate colon separated output for easier parsing in scripts or programs.
@@ -43,6 +69,11 @@
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
--- LVM2/man/pvs.8.in	2009/07/07 19:28:57	1.11
+++ LVM2/man/pvs.8.in	2009/10/26 14:37:09	1.12
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
@@ -17,6 +21,11 @@
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
--- LVM2/man/vgdisplay.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/vgdisplay.8.in	2009/10/26 14:37:09	1.2
@@ -4,15 +4,30 @@
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
@@ -23,7 +38,8 @@
 \fBvgs\fP (8) is an alternative that provides the same information 
 in the style of \fBps\fP (1).
 .SH OPTIONS
-See \fBlvm\fP for common options.
+See \fBlvm\fP for common options and \fBvgs\fP for options given with
+\fB\-\-columns\fP.
 .TP
 .BR \-A ", " \-\-activevolumegroups
 Only select the active volume groups.
@@ -65,6 +81,10 @@
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
--- LVM2/man/vgs.8.in	2009/09/14 19:42:13	1.10
+++ LVM2/man/vgs.8.in	2009/10/26 14:37:09	1.11
@@ -3,6 +3,7 @@
 vgs \- report information about volume groups
 .SH SYNOPSIS
 .B vgs
+[\-a|\-\-all]
 [\-\-aligned] [\-d|\-\-debug] [\-h|\-?|\-\-help]
 [\-\-ignorelockingfailure] [\-\-nameprefixes] [\-\-noheadings] [\-\-nosuffix]
 [\-o|\-\-options [+]Field[,Field]]
@@ -18,6 +19,9 @@
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .TP
+.I \-\-all
+List all volume groups.  Equivalent to not specifying any volume groups.
+.TP
 .I \-\-aligned
 Use with \-\-separator to align the output columns.
 .TP
--- LVM2/tools/args.h	2009/10/05 20:55:57	1.68
+++ LVM2/tools/args.h	2009/10/26 14:37:09	1.69
@@ -84,7 +84,6 @@
 arg(columns_ARG, 'C', "columns", NULL, 0)
 arg(contiguous_ARG, 'C', "contiguous", yes_no_arg, 0)
 arg(debug_ARG, 'd', "debug", NULL, ARG_REPEATABLE)
-arg(disk_ARG, 'D', "disk", NULL, 0)
 arg(exported_ARG, 'e', "exported", NULL, 0)
 arg(physicalextent_ARG, 'E', "physicalextent", NULL, 0)
 arg(file_ARG, 'f', "file", string_arg, 0)
--- LVM2/tools/commands.h	2009/10/05 20:55:57	1.134
+++ LVM2/tools/commands.h	2009/10/26 14:37:09	1.135
@@ -195,7 +195,7 @@
    "\t[-m|--maps]\n"
    "\t[--nosuffix]\n"
    "\t[-P|--partial] " "\n"
-   "\t[--units hsbkmgtHKMGT]\n"
+   "\t[--units hHbBsSkKmMgGtTpPeE]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n"
    "\t[LogicalVolume[Path] [LogicalVolume[Path]...]]\n"
@@ -214,12 +214,12 @@
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
@@ -396,7 +396,7 @@
    "\t[--separator Separator]\n"
    "\t[--trustcache]\n"
    "\t[--unbuffered]\n"
-   "\t[--units hsbkmgtHKMGT]\n"
+   "\t[--units hHbBsSkKmMgGtTpPeE]\n"
    "\t[--unquoted]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n"
@@ -420,7 +420,7 @@
    "\t[-v|--verbose] " "\n"
    "\t[--version]\n",
 
-   all_ARG, blockdevice_ARG, disk_ARG, ignorelockingfailure_ARG, partial_ARG)
+   all_ARG, blockdevice_ARG, ignorelockingfailure_ARG, partial_ARG)
 
 xx(pvchange,
    "Change attributes of physical volume(s)",
@@ -527,7 +527,7 @@
    "\t[-m|--maps]\n"
    "\t[--nosuffix]\n"
    "\t[-s|--short]\n"
-   "\t[--units hsbkmgtHKMGT]\n"
+   "\t[--units hHbBsSkKmMgGtTpPeE]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n"
    "\t[PhysicalVolumePath [PhysicalVolumePath...]]\n"
@@ -544,7 +544,7 @@
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[--separator Separator]\n"
    "\t[--unbuffered]\n"
-   "\t[--units hsbkmgtHKMGT]\n"
+   "\t[--units hHbBsSkKmMgGtTpPeE]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n"
    "\t[PhysicalVolumePath [PhysicalVolumePath...]]\n",
@@ -595,8 +595,8 @@
    "Display information about physical volumes",
    CACHE_VGMETADATA,
    "pvs" "\n"
-   "\t[--aligned]\n"
    "\t[-a|--all]\n"
+   "\t[--aligned]\n"
    "\t[-d|--debug]" "\n"
    "\t[-h|-?|--help] " "\n"
    "\t[--ignorelockingfailure]\n"
@@ -611,7 +611,7 @@
    "\t[--separator Separator]\n"
    "\t[--trustcache]\n"
    "\t[--unbuffered]\n"
-   "\t[--units hsbkmgtHKMGT]\n"
+   "\t[--units hHbBsSkKmMgGtTpPeE]\n"
    "\t[--unquoted]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
@@ -768,14 +768,14 @@
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
@@ -791,12 +791,12 @@
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
 
@@ -944,7 +944,7 @@
    "\t[--separator Separator]\n"
    "\t[--trustcache]\n"
    "\t[--unbuffered]\n"
-   "\t[--units hsbkmgtHKMGT]\n"
+   "\t[--units hHbBsSkKmMgGtTpPeE]\n"
    "\t[--unquoted]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
--- LVM2/tools/vgdisplay.c	2009/09/15 01:38:59	1.26
+++ LVM2/tools/vgdisplay.c	2009/10/26 14:37:09	1.27
@@ -79,8 +79,6 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	/* FIXME -D disk_ARG is now redundant */
-
 /********* FIXME: Do without this - or else 2(+) passes!
 	   Figure out longest volume group name
 	for (c = opt; opt < argc; opt++) {


