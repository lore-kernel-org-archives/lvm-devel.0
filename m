From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 6 Jul 2009 19:13:28 -0000
Subject: LVM2 ./WHATS_NEW man/lvcreate.8.in man/lvexten ...
Message-ID: <20090706191328.1731.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2009-07-06 19:13:27

Modified files:
	.              : WHATS_NEW 
	man            : lvcreate.8.in lvextend.8.in lvreduce.8.in 
	                 lvresize.8.in vgchange.8.in vgcreate.8.in 
	tools          : commands.h lvmcmdline.c 

Log message:
	Allow commandline sizes to be specified in terms of bytes and sectors.
	Update the man pages to document size units uniformly.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1164&r2=1.1165
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvextend.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvreduce.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvresize.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgchange.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgcreate.8.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.128&r2=1.129
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.96&r2=1.97

--- LVM2/WHATS_NEW	2009/07/06 19:04:24	1.1164
+++ LVM2/WHATS_NEW	2009/07/06 19:13:26	1.1165
@@ -1,5 +1,7 @@
 Version 2.02.49 - 
 ================================
+  Update the man pages to document size units uniformly.
+  Allow specifying commandline sizes in terms of bytes and sectors.
   Update 'md_chunk_alignment' to use stripe-width to align PV data area.
   Update test/t-inconsistent-metadata.sh to match new vg_read interface.
   Add lvmcache_init() to polldaemon initialization.
--- LVM2/man/lvcreate.8.in	2009/05/27 16:30:30	1.7
+++ LVM2/man/lvcreate.8.in	2009/07/06 19:13:26	1.8
@@ -9,7 +9,7 @@
 [\-h|\-?|\-\-help]
 [\-i|\-\-stripes Stripes [\-I|\-\-stripesize StripeSize]]
 {\-l|\-\-extents LogicalExtentsNumber[%{VG|PVS|FREE}] |
- \-L|\-\-size LogicalVolumeSize[kKmMgGtT]}
+ \-L|\-\-size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
 [\-M|\-\-persistent y|n] [\-\-minor minor]
 [\-m|\-\-mirrors Mirrors [\-\-nosync] [\-\-mirrorlog {disk|core}] [\-\-corelog]
 [\-R|\-\-regionsize MirrorLogRegionSize]]
@@ -23,7 +23,7 @@
 .br
 .B lvcreate
 {\-l|\-\-extents LogicalExtentsNumber[%{VG|FREE}] |
- \-L|\-\-size LogicalVolumeSize[kKmMgGtT]}
+ \-L|\-\-size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
 [\-c|\-\-chunksize ChunkSize]
 \-n|\-\-name SnapshotLogicalVolumeName
 {{\-s|\-\-snapshot}
@@ -76,7 +76,7 @@
 of the remaining free space for the specified PhysicalVolume(s)
 with the suffix %PVS,
 .TP
-.I \-L, \-\-size LogicalVolumeSize[kKmMgGtTpPeE]
+.I \-L, \-\-size LogicalVolumeSize[bBsSkKmMgGtTpPeE]
 Gives the size to allocate for the new logical volume.
 A size suffix of K for kilobytes, M for megabytes,
 G for gigabytes, T for terabytes, P for petabytes
--- LVM2/man/lvextend.8.in	2008/11/12 15:01:36	1.2
+++ LVM2/man/lvextend.8.in	2009/07/06 19:13:26	1.3
@@ -7,7 +7,7 @@
 [\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-h|\-?|\-\-help]
 [\-i|\-\-stripes Stripes [\-I|\-\-stripesize StripeSize]]
 {\-l|\-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |
-\-L|\-\-size [+]LogicalVolumeSize[kKmMgGtT]}
+\-L|\-\-size [+]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
 [\-t|\-\-test]
 [\-v|\-\-verbose] LogicalVolumePath [PhysicalVolumePath...]
 .SH DESCRIPTION
@@ -32,7 +32,7 @@
 or as a percentage of the remaining free space in the Volume Group
 with the suffix %FREE.
 .TP
-.I \-L, \-\-size [+]LogicalVolumeSize[kKmMgGtTpPeE]
+.I \-L, \-\-size [+]LogicalVolumeSize[bBsSkKmMgGtTpPeE]
 Extend or set the logical volume size in units of megabytes.
 A size suffix of M for megabytes,
 G for gigabytes, T for terabytes, P for petabytes 
--- LVM2/man/lvreduce.8.in	2008/11/12 15:01:36	1.2
+++ LVM2/man/lvreduce.8.in	2009/07/06 19:13:26	1.3
@@ -6,7 +6,7 @@
 [\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-f|\-\-force]
 [\-h|\-?|\-\-help]
 {\-l|\-\-extents [\-]LogicalExtentsNumber[%{VG|LV|FREE}] |
-\-L|\-\-size [\-]LogicalVolumeSize[kKmMgGtT]}
+\-L|\-\-size [\-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
 [\-t|\-\-test]
 [\-v|\-\-verbose] LogicalVolume[Path]
 .SH DESCRIPTION
@@ -46,7 +46,7 @@
 size of the Logical Volume with the suffix %LV or as a percentage of the remaining
 free space in the Volume Group with the suffix %FREE.
 .TP
-.I \-L, \-\-size [\-]LogicalVolumeSize[kKmMgGtTpPeE]
+.I \-L, \-\-size [\-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]
 Reduce or set the logical volume size in units of megabyte by default.
 A size suffix of k for kilobyte, m for megabyte, 
 g for gigabytes, t for terabytes, p for petabytes 
--- LVM2/man/lvresize.8.in	2008/11/12 15:16:58	1.3
+++ LVM2/man/lvresize.8.in	2009/07/06 19:13:26	1.4
@@ -7,7 +7,7 @@
 [\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-h|\-?|\-\-help]
 [\-i|\-\-stripes Stripes [\-I|\-\-stripesize StripeSize]]
 {\-l|\-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |
-\-L|\-\-size [+]LogicalVolumeSize[kKmMgGtT]}
+\-L|\-\-size [+]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
 [\-t|\-\-test]
 [\-v|\-\-verbose] LogicalVolumePath [PhysicalVolumePath...]
 .SH DESCRIPTION
@@ -36,7 +36,7 @@
 suffix %PVS, or as a percentage of the remaining free space in the
 Volume Group with the suffix %FREE.
 .TP
-.I \-L, \-\-size [+|-]LogicalVolumeSize[kKmMgGtTpPeE]
+.I \-L, \-\-size [+|-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]
 Change or set the logical volume size in units of megabytes.
 A size suffix of M for megabytes,
 G for gigabytes, T for terabytes, P for petabytes 
--- LVM2/man/vgchange.8.in	2009/02/25 13:17:41	1.2
+++ LVM2/man/vgchange.8.in	2009/07/06 19:13:26	1.3
@@ -24,7 +24,7 @@
 .IR MaxPhysicalVolumes ]
 .RB [ \-P | \-\-partial]
 .RB [ \-s | \-\-physicalextentsize
-.IR PhysicalExtentSize [ \fBkKmMgGtT\fR ]]
+.IR PhysicalExtentSize [ \fBbBsSkKmMgGtTpPeE\fR ]]
 .RB [ \-\-refresh]
 .RB [ -t | \-\-test]
 .RB [ \-v | \-\-verbose]
@@ -108,7 +108,7 @@
 some use of \fB--metadatacopies 0\fP
 as described in \fBpvcreate(8)\fP.
 .TP
-.BR \-s ", " \-\-physicalextentsize " " \fIPhysicalExtentSize\fR[\fBkKmMgGtT\fR]
+.BR \-s ", " \-\-physicalextentsize " " \fIPhysicalExtentSize\fR[\fBbBsSkKmMgGtTpPeE\fR]
 Changes the physical extent size on physical volumes of this volume group.
 A size suffix (k for kilobytes up to t for terabytes) is optional, megabytes
 is the default if no suffix is present.
--- LVM2/man/vgcreate.8.in	2008/10/08 12:50:13	1.1
+++ LVM2/man/vgcreate.8.in	2009/07/06 19:13:26	1.2
@@ -17,7 +17,7 @@
 .RB [ -p | \-\-maxphysicalvolumes
 .IR MaxPhysicalVolumes ]
 .RB [ \-s | \-\-physicalextentsize
-.IR PhysicalExtentSize [ \fBkKmMgGtT\fR ]]
+.IR PhysicalExtentSize [ \fBbBsSkKmMgGtTpPeE\fR ]]
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
@@ -66,7 +66,7 @@
 some use of \fB--metadatacopies 0\fP
 as described in \fBpvcreate(8)\fP.
 .TP
-.BR \-s ", " \-\-physicalextentsize " " \fIPhysicalExtentSize\fR[\fBkKmMgGtT\fR]
+.BR \-s ", " \-\-physicalextentsize " " \fIPhysicalExtentSize\fR[\fBbBsSkKmMgGtTpPeE\fR]
 Sets the physical extent size on physical volumes of this volume group.
 A size suffix (k for kilobytes up to t for terabytes) is optional, megabytes
 is the default if no suffix is present.  
--- LVM2/tools/commands.h	2009/06/30 18:39:32	1.128
+++ LVM2/tools/commands.h	2009/07/06 19:13:26	1.129
@@ -19,7 +19,7 @@
    "e2fsadm "
    "[-d|--debug] " "[-h|--help] " "[-n|--nofsck]" "\n"
    "\t{[-l|--extents] [+|-]LogicalExtentsNumber |" "\n"
-   "\t [-L|--size] [+|-]LogicalVolumeSize[kKmMgGtTpPeE]}" "\n"
+   "\t [-L|--size] [+|-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}" "\n"
    "\t[-t|--test] "  "\n"
    "\t[-v|--verbose] "  "\n"
    "\t[--version] " "\n"
@@ -133,7 +133,7 @@
    "\t[-h|-?|--help]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
    "\t{-l|--extents LogicalExtentsNumber |\n"
-   "\t -L|--size LogicalVolumeSize[kKmMgGtTpPeE]}\n"
+   "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
    "\t[-m|--mirrors Mirrors [--nosync] [{--mirrorlog {disk|core}|--corelog}]]\n"
    "\t[-n|--name LogicalVolumeName]\n"
@@ -159,7 +159,7 @@
    "\t[-h|-?|--help]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
    "\t{-l|--extents LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |\n"
-   "\t -L|--size LogicalVolumeSize[kKmMgGtTpPeE]}\n"
+   "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
    "\t[-n|--name LogicalVolumeName]\n"
    "\t[-p|--permission {r|rw}]\n"
@@ -228,7 +228,7 @@
    "\t[-h|--help]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
    "\t{-l|--extents [+]LogicalExtentsNumber[%{VG|PVS|FREE}] |\n"
-   "\t -L|--size [+]LogicalVolumeSize[kKmMgGtTpPeE]}\n"
+   "\t -L|--size [+]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-m|--mirrors Mirrors]\n"
    "\t[-n|--nofsck]\n"
    "\t[-r|--resizefs]\n"
@@ -298,7 +298,7 @@
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
    "\t{-l|--extents [-]LogicalExtentsNumber[%{VG|LV|FREE}] |\n"
-   "\t -L|--size [-]LogicalVolumeSize[kKmMgGtTpPeE]}\n"
+   "\t -L|--size [-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-n|--nofsck]\n"
    "\t[-r|--resizefs]\n"
    "\t[-t|--test]\n"
@@ -351,7 +351,7 @@
    "\t[-h|--help]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
    "\t{-l|--extents [+|-]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |\n"
-   "\t -L|--size [+|-]LogicalVolumeSize[kKmMgGtTpPeE]}\n"
+   "\t -L|--size [+|-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-n|--nofsck]\n"
    "\t[-r|--resizefs]\n"
    "\t[-t|--test]\n"
@@ -436,7 +436,7 @@
    "pvresize " "\n"
    "\t[-d|--debug]" "\n"
    "\t[-h|-?|--help] " "\n"
-   "\t[--setphysicalvolumesize PhysicalVolumeSize[kKmMgGtTpPeE]" "\n"
+   "\t[--setphysicalvolumesize PhysicalVolumeSize[bBsSkKmMgGtTpPeE]" "\n"
    "\t[-t|--test] " "\n"
    "\t[-v|--verbose] " "\n"
    "\t[--version] " "\n"
@@ -468,9 +468,9 @@
    "\t[--labelsector sector] " "\n"
    "\t[-M|--metadatatype 1|2]" "\n"
    "\t[--metadatacopies #copies]" "\n"
-   "\t[--metadatasize MetadataSize[kKmMgGtTpPeE]]" "\n"
-   "\t[--dataalignment Alignment[kKmMgGtTpPeE]]" "\n"
-   "\t[--setphysicalvolumesize PhysicalVolumeSize[kKmMgGtTpPeE]" "\n"
+   "\t[--metadatasize MetadataSize[bBsSkKmMgGtTpPeE]]" "\n"
+   "\t[--dataalignment Alignment[bBsSkKmMgGtTpPeE]]" "\n"
+   "\t[--setphysicalvolumesize PhysicalVolumeSize[bBsSkKmMgGtTpPeE]" "\n"
    "\t[-t|--test] " "\n"
    "\t[-u|--uuid uuid] " "\n"
    "\t[-v|--verbose] " "\n"
@@ -683,7 +683,7 @@
    "\t -x|--resizeable {y|n} |" "\n"
    "\t -l|--logicalvolume MaxLogicalVolumes |" "\n"
    "\t -p|--maxphysicalvolumes MaxPhysicalVolumes |" "\n"
-   "\t -s|--physicalextentsize PhysicalExtentSize[kKmMgGtTpPeE] |" "\n"
+   "\t -s|--physicalextentsize PhysicalExtentSize[bBsSkKmMgGtTpPeE] |" "\n"
    "\t --addtag Tag |\n"
    "\t --deltag Tag}\n"
    "\t[VolumeGroupName...]\n",
@@ -713,7 +713,7 @@
    "\t[--labelsector sector] " "\n"
    "\t[-M|--metadatatype 1|2]" "\n"
    "\t[--metadatacopies #copies]" "\n"
-   "\t[--metadatasize MetadataSize[kKmMgGtTpPeE]]" "\n"
+   "\t[--metadatasize MetadataSize[bBsSkKmMgGtTpPeE]]" "\n"
    "\t[-t|--test] " "\n"
    "\t[-v|--verbose] " "\n"
    "\t[--version] " "\n"
@@ -735,7 +735,7 @@
    "\t[-l|--maxlogicalvolumes MaxLogicalVolumes]" "\n"
    "\t[-M|--metadatatype 1|2] " "\n"
    "\t[-p|--maxphysicalvolumes MaxPhysicalVolumes] " "\n"
-   "\t[-s|--physicalextentsize PhysicalExtentSize[kKmMgGtTpPeE]] " "\n"
+   "\t[-s|--physicalextentsize PhysicalExtentSize[bBsSkKmMgGtTpPeE]] " "\n"
    "\t[-t|--test] " "\n"
    "\t[-v|--verbose]" "\n"
    "\t[--version] " "\n"
--- LVM2/tools/lvmcmdline.c	2009/05/27 16:30:30	1.96
+++ LVM2/tools/lvmcmdline.c	2009/07/06 19:13:26	1.97
@@ -239,9 +239,10 @@
 {
 	char *ptr;
 	int i;
-	static const char *suffixes = "kmgtpe";
+	static const char *suffixes = "kmgtpebs";
 	char *val;
 	double v;
+	uint64_t v_tmp, adjustment;
 
 	a->percent = PERCENT_NONE;
 
@@ -272,13 +273,29 @@
 			if (suffixes[i] == tolower((int) *ptr))
 				break;
 
-		if (i < 0)
+		if (i < 0) {
 			return 0;
-
-		while (i-- > 0)
-			v *= 1024;
-
-		v *= 2;
+		} else if (i == 7) {
+			/* sectors */
+			v = v;
+		} else if (i == 6) {
+			/* bytes */
+			v_tmp = (uint64_t) v;
+			adjustment = v_tmp % 512;
+			if (adjustment) {
+				v_tmp += (512 - adjustment);
+				log_error("Size is not a multiple of 512. "
+					  "Try using %lu or %lu.",
+					  v_tmp - 512, v_tmp);
+				return 0;
+			}
+			v /= 512;
+		} else {
+			/* all other units: kmgtpe */
+			while (i-- > 0)
+				v *= 1024;
+			v *= 2;
+		}
 	} else
 		v *= factor;
 


