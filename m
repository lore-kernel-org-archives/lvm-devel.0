From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 29 Jun 2009 14:25:26 -0400
Subject: [PATCH v3 1/4] cmdline: support for bytes and sectors
In-Reply-To: <1246299929-5327-1-git-send-email-snitzer@redhat.com>
References: <1246299929-5327-1-git-send-email-snitzer@redhat.com>
Message-ID: <1246299929-5327-2-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Allow specifying commandline sizes in terms of bytes and sectors.

Update the man pages to uniformly document size units.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 WHATS_NEW          |    5 +++++
 man/lvcreate.8.in  |    6 +++---
 man/lvextend.8.in  |    4 ++--
 man/lvreduce.8.in  |    4 ++--
 man/lvresize.8.in  |    4 ++--
 man/vgchange.8.in  |    4 ++--
 man/vgcreate.8.in  |    4 ++--
 tools/commands.h   |   26 +++++++++++++-------------
 tools/lvmcmdline.c |   20 ++++++++++++++------
 9 files changed, 45 insertions(+), 32 deletions(-)

Index: LVM2/WHATS_NEW
===================================================================
--- LVM2.orig/WHATS_NEW
+++ LVM2/WHATS_NEW
@@ -1,3 +1,8 @@
+Version 2.02.49 -
+===============================
+  Update the man pages to uniformly document size units.
+  Allow specifying commandline sizes in terms of bytes and sectors.
+
 Version 2.02.48 - 26th June 2009
 ================================
   Abort if automatic metadata correction fails when reading VG to update it.
Index: LVM2/man/lvcreate.8.in
===================================================================
--- LVM2.orig/man/lvcreate.8.in
+++ LVM2/man/lvcreate.8.in
@@ -9,7 +9,7 @@ lvcreate \- create a logical volume in a
 [\-h|\-?|\-\-help]
 [\-i|\-\-stripes Stripes [\-I|\-\-stripesize StripeSize]]
 {\-l|\-\-extents LogicalExtentsNumber[%{VG|PVS|FREE}] |
- \-L|\-\-size LogicalVolumeSize[kKmMgGtT]}
+ \-L|\-\-size LogicalVolumeSize[sSbBkKmMgGtTpPeE]}
 [\-M|\-\-persistent y|n] [\-\-minor minor]
 [\-m|\-\-mirrors Mirrors [\-\-nosync] [\-\-mirrorlog {disk|core}] [\-\-corelog]
 [\-R|\-\-regionsize MirrorLogRegionSize]]
@@ -23,7 +23,7 @@ VolumeGroupName [PhysicalVolumePath...]
 .br
 .B lvcreate
 {\-l|\-\-extents LogicalExtentsNumber[%{VG|FREE}] |
- \-L|\-\-size LogicalVolumeSize[kKmMgGtT]}
+ \-L|\-\-size LogicalVolumeSize[sSbBkKmMgGtTpPeE]}
 [\-c|\-\-chunksize ChunkSize]
 \-n|\-\-name SnapshotLogicalVolumeName
 {{\-s|\-\-snapshot}
@@ -76,7 +76,7 @@ free space in the Volume Group with the 
 of the remaining free space for the specified PhysicalVolume(s)
 with the suffix %PVS,
 .TP
-.I \-L, \-\-size LogicalVolumeSize[kKmMgGtTpPeE]
+.I \-L, \-\-size LogicalVolumeSize[sSbBkKmMgGtTpPeE]
 Gives the size to allocate for the new logical volume.
 A size suffix of K for kilobytes, M for megabytes,
 G for gigabytes, T for terabytes, P for petabytes
Index: LVM2/man/lvextend.8.in
===================================================================
--- LVM2.orig/man/lvextend.8.in
+++ LVM2/man/lvextend.8.in
@@ -7,7 +7,7 @@ lvextend \- extend the size of a logical
 [\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-h|\-?|\-\-help]
 [\-i|\-\-stripes Stripes [\-I|\-\-stripesize StripeSize]]
 {\-l|\-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |
-\-L|\-\-size [+]LogicalVolumeSize[kKmMgGtT]}
+\-L|\-\-size [+]LogicalVolumeSize[sSbBkKmMgGtTpPeE]}
 [\-t|\-\-test]
 [\-v|\-\-verbose] LogicalVolumePath [PhysicalVolumePath...]
 .SH DESCRIPTION
@@ -32,7 +32,7 @@ free space for the specified PhysicalVol
 or as a percentage of the remaining free space in the Volume Group
 with the suffix %FREE.
 .TP
-.I \-L, \-\-size [+]LogicalVolumeSize[kKmMgGtTpPeE]
+.I \-L, \-\-size [+]LogicalVolumeSize[sSbBkKmMgGtTpPeE]
 Extend or set the logical volume size in units of megabytes.
 A size suffix of M for megabytes,
 G for gigabytes, T for terabytes, P for petabytes 
Index: LVM2/man/lvreduce.8.in
===================================================================
--- LVM2.orig/man/lvreduce.8.in
+++ LVM2/man/lvreduce.8.in
@@ -6,7 +6,7 @@ lvreduce \- reduce the size of a logical
 [\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-f|\-\-force]
 [\-h|\-?|\-\-help]
 {\-l|\-\-extents [\-]LogicalExtentsNumber[%{VG|LV|FREE}] |
-\-L|\-\-size [\-]LogicalVolumeSize[kKmMgGtT]}
+\-L|\-\-size [\-]LogicalVolumeSize[sSbBkKmMgGtTpPeE]}
 [\-t|\-\-test]
 [\-v|\-\-verbose] LogicalVolume[Path]
 .SH DESCRIPTION
@@ -46,7 +46,7 @@ in the Volume Group with the suffix %VG 
 size of the Logical Volume with the suffix %LV or as a percentage of the remaining
 free space in the Volume Group with the suffix %FREE.
 .TP
-.I \-L, \-\-size [\-]LogicalVolumeSize[kKmMgGtTpPeE]
+.I \-L, \-\-size [\-]LogicalVolumeSize[sSbBkKmMgGtTpPeE]
 Reduce or set the logical volume size in units of megabyte by default.
 A size suffix of k for kilobyte, m for megabyte, 
 g for gigabytes, t for terabytes, p for petabytes 
Index: LVM2/man/lvresize.8.in
===================================================================
--- LVM2.orig/man/lvresize.8.in
+++ LVM2/man/lvresize.8.in
@@ -7,7 +7,7 @@ lvresize \- resize a logical volume
 [\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-h|\-?|\-\-help]
 [\-i|\-\-stripes Stripes [\-I|\-\-stripesize StripeSize]]
 {\-l|\-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |
-\-L|\-\-size [+]LogicalVolumeSize[kKmMgGtT]}
+\-L|\-\-size [+]LogicalVolumeSize[sSbBkKmMgGtTpPeE]}
 [\-t|\-\-test]
 [\-v|\-\-verbose] LogicalVolumePath [PhysicalVolumePath...]
 .SH DESCRIPTION
@@ -36,7 +36,7 @@ the remaining free space of the Physical
 suffix %PVS, or as a percentage of the remaining free space in the
 Volume Group with the suffix %FREE.
 .TP
-.I \-L, \-\-size [+|-]LogicalVolumeSize[kKmMgGtTpPeE]
+.I \-L, \-\-size [+|-]LogicalVolumeSize[sSbBkKmMgGtTpPeE]
 Change or set the logical volume size in units of megabytes.
 A size suffix of M for megabytes,
 G for gigabytes, T for terabytes, P for petabytes 
Index: LVM2/man/vgchange.8.in
===================================================================
--- LVM2.orig/man/vgchange.8.in
+++ LVM2/man/vgchange.8.in
@@ -24,7 +24,7 @@ vgchange \- change attributes of a volum
 .IR MaxPhysicalVolumes ]
 .RB [ \-P | \-\-partial]
 .RB [ \-s | \-\-physicalextentsize
-.IR PhysicalExtentSize [ \fBkKmMgGtT\fR ]]
+.IR PhysicalExtentSize [ \fBsSbBkKmMgGtTpPeE\fR ]]
 .RB [ \-\-refresh]
 .RB [ -t | \-\-test]
 .RB [ \-v | \-\-verbose]
@@ -108,7 +108,7 @@ for tool performance reasons, you should
 some use of \fB--metadatacopies 0\fP
 as described in \fBpvcreate(8)\fP.
 .TP
-.BR \-s ", " \-\-physicalextentsize " " \fIPhysicalExtentSize\fR[\fBkKmMgGtT\fR]
+.BR \-s ", " \-\-physicalextentsize " " \fIPhysicalExtentSize\fR[\fBsSbBkKmMgGtTpPeE\fR]
 Changes the physical extent size on physical volumes of this volume group.
 A size suffix (k for kilobytes up to t for terabytes) is optional, megabytes
 is the default if no suffix is present.
Index: LVM2/man/vgcreate.8.in
===================================================================
--- LVM2.orig/man/vgcreate.8.in
+++ LVM2/man/vgcreate.8.in
@@ -17,7 +17,7 @@ vgcreate \- create a volume group
 .RB [ -p | \-\-maxphysicalvolumes
 .IR MaxPhysicalVolumes ]
 .RB [ \-s | \-\-physicalextentsize
-.IR PhysicalExtentSize [ \fBkKmMgGtT\fR ]]
+.IR PhysicalExtentSize [ \fBsSbBkKmMgGtTpPeE\fR ]]
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
@@ -66,7 +66,7 @@ for tool performance reasons, you should
 some use of \fB--metadatacopies 0\fP
 as described in \fBpvcreate(8)\fP.
 .TP
-.BR \-s ", " \-\-physicalextentsize " " \fIPhysicalExtentSize\fR[\fBkKmMgGtT\fR]
+.BR \-s ", " \-\-physicalextentsize " " \fIPhysicalExtentSize\fR[\fBsSbBkKmMgGtTpPeE\fR]
 Sets the physical extent size on physical volumes of this volume group.
 A size suffix (k for kilobytes up to t for terabytes) is optional, megabytes
 is the default if no suffix is present.  
Index: LVM2/tools/commands.h
===================================================================
--- LVM2.orig/tools/commands.h
+++ LVM2/tools/commands.h
@@ -19,7 +19,7 @@ xx(e2fsadm,
    "e2fsadm "
    "[-d|--debug] " "[-h|--help] " "[-n|--nofsck]" "\n"
    "\t{[-l|--extents] [+|-]LogicalExtentsNumber |" "\n"
-   "\t [-L|--size] [+|-]LogicalVolumeSize[kKmMgGtTpPeE]}" "\n"
+   "\t [-L|--size] [+|-]LogicalVolumeSize[sSbBkKmMgGtTpPeE]}" "\n"
    "\t[-t|--test] "  "\n"
    "\t[-v|--verbose] "  "\n"
    "\t[--version] " "\n"
@@ -131,7 +131,7 @@ xx(lvcreate,
    "\t[-h|-?|--help]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
    "\t{-l|--extents LogicalExtentsNumber |\n"
-   "\t -L|--size LogicalVolumeSize[kKmMgGtTpPeE]}\n"
+   "\t -L|--size LogicalVolumeSize[sSbBkKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
    "\t[-m|--mirrors Mirrors [--nosync] [{--mirrorlog {disk|core}|--corelog}]]\n"
    "\t[-n|--name LogicalVolumeName]\n"
@@ -157,7 +157,7 @@ xx(lvcreate,
    "\t[-h|-?|--help]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
    "\t{-l|--extents LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |\n"
-   "\t -L|--size LogicalVolumeSize[kKmMgGtTpPeE]}\n"
+   "\t -L|--size LogicalVolumeSize[sSbBkKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
    "\t[-n|--name LogicalVolumeName]\n"
    "\t[-p|--permission {r|rw}]\n"
@@ -226,7 +226,7 @@ xx(lvextend,
    "\t[-h|--help]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
    "\t{-l|--extents [+]LogicalExtentsNumber[%{VG|PVS|FREE}] |\n"
-   "\t -L|--size [+]LogicalVolumeSize[kKmMgGtTpPeE]}\n"
+   "\t -L|--size [+]LogicalVolumeSize[sSbBkKmMgGtTpPeE]}\n"
    "\t[-m|--mirrors Mirrors]\n"
    "\t[-n|--nofsck]\n"
    "\t[-r|--resizefs]\n"
@@ -296,7 +296,7 @@ xx(lvreduce,
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
    "\t{-l|--extents [-]LogicalExtentsNumber[%{VG|LV|FREE}] |\n"
-   "\t -L|--size [-]LogicalVolumeSize[kKmMgGtTpPeE]}\n"
+   "\t -L|--size [-]LogicalVolumeSize[sSbBkKmMgGtTpPeE]}\n"
    "\t[-n|--nofsck]\n"
    "\t[-r|--resizefs]\n"
    "\t[-t|--test]\n"
@@ -349,7 +349,7 @@ xx(lvresize,
    "\t[-h|--help]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
    "\t{-l|--extents [+|-]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |\n"
-   "\t -L|--size [+|-]LogicalVolumeSize[kKmMgGtTpPeE]}\n"
+   "\t -L|--size [+|-]LogicalVolumeSize[sSbBkKmMgGtTpPeE]}\n"
    "\t[-n|--nofsck]\n"
    "\t[-r|--resizefs]\n"
    "\t[-t|--test]\n"
@@ -434,7 +434,7 @@ xx(pvresize,
    "pvresize " "\n"
    "\t[-d|--debug]" "\n"
    "\t[-h|-?|--help] " "\n"
-   "\t[--setphysicalvolumesize PhysicalVolumeSize[kKmMgGtTpPeE]" "\n"
+   "\t[--setphysicalvolumesize PhysicalVolumeSize[sSbBkKmMgGtTpPeE]" "\n"
    "\t[-t|--test] " "\n"
    "\t[-v|--verbose] " "\n"
    "\t[--version] " "\n"
@@ -466,9 +466,9 @@ xx(pvcreate,
    "\t[--labelsector sector] " "\n"
    "\t[-M|--metadatatype 1|2]" "\n"
    "\t[--metadatacopies #copies]" "\n"
-   "\t[--metadatasize MetadataSize[kKmMgGtTpPeE]]" "\n"
-   "\t[--dataalignment Alignment[kKmMgGtTpPeE]]" "\n"
-   "\t[--setphysicalvolumesize PhysicalVolumeSize[kKmMgGtTpPeE]" "\n"
+   "\t[--metadatasize MetadataSize[sSbBkKmMgGtTpPeE]]" "\n"
+   "\t[--dataalignment Alignment[sSbBkKmMgGtTpPeE]]" "\n"
+   "\t[--setphysicalvolumesize PhysicalVolumeSize[sSbBkKmMgGtTpPeE]" "\n"
    "\t[-t|--test] " "\n"
    "\t[-u|--uuid uuid] " "\n"
    "\t[-v|--verbose] " "\n"
@@ -681,7 +681,7 @@ xx(vgchange,
    "\t -x|--resizeable {y|n} |" "\n"
    "\t -l|--logicalvolume MaxLogicalVolumes |" "\n"
    "\t -p|--maxphysicalvolumes MaxPhysicalVolumes |" "\n"
-   "\t -s|--physicalextentsize PhysicalExtentSize[kKmMgGtTpPeE] |" "\n"
+   "\t -s|--physicalextentsize PhysicalExtentSize[sSbBkKmMgGtTpPeE] |" "\n"
    "\t --addtag Tag |\n"
    "\t --deltag Tag}\n"
    "\t[VolumeGroupName...]\n",
@@ -711,7 +711,7 @@ xx(vgconvert,
    "\t[--labelsector sector] " "\n"
    "\t[-M|--metadatatype 1|2]" "\n"
    "\t[--metadatacopies #copies]" "\n"
-   "\t[--metadatasize MetadataSize[kKmMgGtTpPeE]]" "\n"
+   "\t[--metadatasize MetadataSize[sSbBkKmMgGtTpPeE]]" "\n"
    "\t[-t|--test] " "\n"
    "\t[-v|--verbose] " "\n"
    "\t[--version] " "\n"
@@ -733,7 +733,7 @@ xx(vgcreate,
    "\t[-l|--maxlogicalvolumes MaxLogicalVolumes]" "\n"
    "\t[-M|--metadatatype 1|2] " "\n"
    "\t[-p|--maxphysicalvolumes MaxPhysicalVolumes] " "\n"
-   "\t[-s|--physicalextentsize PhysicalExtentSize[kKmMgGtTpPeE]] " "\n"
+   "\t[-s|--physicalextentsize PhysicalExtentSize[sSbBkKmMgGtTpPeE]] " "\n"
    "\t[-t|--test] " "\n"
    "\t[-v|--verbose]" "\n"
    "\t[--version] " "\n"
Index: LVM2/tools/lvmcmdline.c
===================================================================
--- LVM2.orig/tools/lvmcmdline.c
+++ LVM2/tools/lvmcmdline.c
@@ -239,7 +239,7 @@ static int _size_arg(struct cmd_context 
 {
 	char *ptr;
 	int i;
-	static const char *suffixes = "kmgtpe";
+	static const char *suffixes = "kmgtpebs";
 	char *val;
 	double v;
 
@@ -274,11 +274,19 @@ static int _size_arg(struct cmd_context 
 
 		if (i < 0)
 			return 0;
-
-		while (i-- > 0)
-			v *= 1024;
-
-		v *= 2;
+		else if (i == 7) {
+			/* sectors */
+			v = v;
+		} else if (i == 6) {
+			/* bytes */
+			if (v < 512)
+				return 0;
+			v /= 512;
+		} else {
+			while (i-- > 0)
+				v *= 1024;
+			v *= 2;
+		}
 	} else
 		v *= factor;
 


