From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 3 Feb 2010 03:58:10 -0000
Subject: LVM2 ./WHATS_NEW man/lvcreate.8.in man/lvexten ...
Message-ID: <20100203035810.28404.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-02-03 03:58:09

Modified files:
	.              : WHATS_NEW 
	man            : lvcreate.8.in lvextend.8.in lvreduce.8.in 
	                 lvresize.8.in 
	tools          : commands.h lvcreate.c lvmcmdline.c lvresize.c 
	                 tools.h 

Log message:
	Add %ORIGIN support to lv{create,extend,reduce,resize} --extents option
	
	Allow the number of logical extents to be expressed (for a snapshot) as
	a percentage of the total space in the Origin Logical Volume with the
	suffix %ORIGIN.
	
	Update the relevant man pages accordingly.  Eliminate inconsistencies
	between the man pages and tools/commands.h
	
	Signed-off-by: Mike Snitzer <snitzer@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1418&r2=1.1419
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.in.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvextend.8.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvreduce.8.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvresize.8.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.140&r2=1.141
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.214&r2=1.215
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.113&r2=1.114
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.118&r2=1.119
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/tools.h.diff?cvsroot=lvm2&r1=1.65&r2=1.66

--- LVM2/WHATS_NEW	2010/02/02 17:48:30	1.1418
+++ LVM2/WHATS_NEW	2010/02/03 03:58:08	1.1419
@@ -1,5 +1,6 @@
 Version 2.02.61 - 
 ===================================
+  Add %ORIGIN support to lv{create,extend,reduce,resize} --extents option.
   Add copy constructor for metadata_area.
   Remove pointless versioned symlinks to dmeventd plugin libraries.
   Fix dmeventd snapshot plugin build dependency.
--- LVM2/man/lvcreate.8.in	2010/01/12 14:00:51	1.14
+++ LVM2/man/lvcreate.8.in	2010/02/03 03:58:08	1.15
@@ -22,7 +22,7 @@
 
 .br
 .B lvcreate
-{\-l|\-\-extents LogicalExtentsNumber[%{VG|FREE}] |
+{\-l|\-\-extents LogicalExtentsNumber[%{VG|FREE|ORIGIN}] |
  \-L|\-\-size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
 [\-c|\-\-chunksize ChunkSize]
 [\-\-noudevsync]
@@ -70,14 +70,16 @@
 For metadata in LVM2 format, the stripe size may be a larger
 power of 2 but must not exceed the physical extent size.
 .TP
-.I \-l, \-\-extents LogicalExtentsNumber[%{VG|PVS|FREE}]
+.I \-l, \-\-extents LogicalExtentsNumber[%{VG|PVS|FREE|ORIGIN}]
 Gives the number of logical extents to allocate for the new
 logical volume.
-This can also be expressed as a percentage of the total space
-in the Volume Group with the suffix %VG, of the remaining
-free space in the Volume Group with the suffix %FREE, or
-of the remaining free space for the specified PhysicalVolume(s)
-with the suffix %PVS,
+The number can also be expressed as a percentage of the total space
+in the Volume Group with the suffix %VG, as a percentage of the
+remaining free space in the Volume Group with the suffix %FREE, as a
+percentage of the remaining free space for the specified
+PhysicalVolume(s) with the suffix %PVS, or (for a snapshot) as a
+percentage of the total space in the Origin Logical Volume with the
+suffix %ORIGIN.
 .TP
 .I \-L, \-\-size LogicalVolumeSize[bBsSkKmMgGtTpPeE]
 Gives the size to allocate for the new logical volume.
--- LVM2/man/lvextend.8.in	2009/08/10 17:23:04	1.5
+++ LVM2/man/lvextend.8.in	2010/02/03 03:58:08	1.6
@@ -7,7 +7,7 @@
 [\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-h|\-?|\-\-help]
 [\-\-noudevsync]
 [\-i|\-\-stripes Stripes [\-I|\-\-stripesize StripeSize]]
-{\-l|\-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |
+{\-l|\-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE|ORIGIN}] |
 \-L|\-\-size [+]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
 [\-t|\-\-test]
 [\-v|\-\-verbose] LogicalVolumePath [PhysicalVolumePath[:PE[-PE]]...]
@@ -29,7 +29,7 @@
 in the background.  You should only use this if udev is not running
 or has rules that ignore the devices LVM2 creates.
 .TP
-.I \-l, \-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE}]
+.I \-l, \-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE|ORIGIN}]
 Extend or set the logical volume size in units of logical extents.
 With the + sign the value is added to the actual size
 of the logical volume and without it, the value is taken as an absolute one.
@@ -37,8 +37,9 @@
 in the Volume Group with the suffix %VG, relative to the existing
 size of the Logical Volume with the suffix %LV, of the remaining
 free space for the specified PhysicalVolume(s) with the suffix %PVS,
-or as a percentage of the remaining free space in the Volume Group
-with the suffix %FREE.
+as a percentage of the remaining free space in the Volume Group
+with the suffix %FREE, or (for a snapshot) as a percentage of the total
+space in the Origin Logical Volume with the suffix %ORIGIN.
 .TP
 .I \-L, \-\-size [+]LogicalVolumeSize[bBsSkKmMgGtTpPeE]
 Extend or set the logical volume size in units of megabytes.
--- LVM2/man/lvreduce.8.in	2009/08/04 08:09:52	1.5
+++ LVM2/man/lvreduce.8.in	2010/02/03 03:58:08	1.6
@@ -6,7 +6,7 @@
 [\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-f|\-\-force]
 [\-h|\-?|\-\-help]
 [\-\-noudevsync]
-{\-l|\-\-extents [\-]LogicalExtentsNumber[%{VG|LV|FREE}] |
+{\-l|\-\-extents [\-]LogicalExtentsNumber[%{VG|LV|FREE|ORIGIN}] |
 \-L|\-\-size [\-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
 [\-t|\-\-test]
 [\-v|\-\-verbose] LogicalVolume[Path]
@@ -44,15 +44,17 @@
 in the background.  You should only use this if udev is not running
 or has rules that ignore the devices LVM2 creates.
 .TP
-.I \-l, \-\-extents [\-]LogicalExtentsNumber[%{VG|LV|FREE}]
+.I \-l, \-\-extents [\-]LogicalExtentsNumber[%{VG|LV|FREE|ORIGIN}]
 Reduce or set the logical volume size in units of logical extents.
 With the - sign the value will be subtracted from
-the logical volume's actual size and without it the will be taken as
-an absolute size.
+the logical volume's actual size and without it the value will be taken
+as an absolute size.
 The number can also be expressed as a percentage of the total space
-in the Volume Group with the suffix %VG or relative to the existing
-size of the Logical Volume with the suffix %LV or as a percentage of the remaining
-free space in the Volume Group with the suffix %FREE.
+in the Volume Group with the suffix %VG, relative to the existing
+size of the Logical Volume with the suffix %LV, as a percentage of the
+remaining free space in the Volume Group with the suffix %FREE, or (for
+a snapshot) as a percentage of the total space in the Origin Logical
+Volume with the suffix %ORIGIN.
 .TP
 .I \-L, \-\-size [\-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]
 Reduce or set the logical volume size in units of megabytes.
--- LVM2/man/lvresize.8.in	2009/08/10 17:23:04	1.6
+++ LVM2/man/lvresize.8.in	2010/02/03 03:58:08	1.7
@@ -7,7 +7,7 @@
 [\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-h|\-?|\-\-help]
 [\-\-noudevsync]
 [\-i|\-\-stripes Stripes [\-I|\-\-stripesize StripeSize]]
-{\-l|\-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |
+{\-l|\-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE|ORIGIN}] |
 \-L|\-\-size [+]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
 [\-t|\-\-test]
 [\-v|\-\-verbose] LogicalVolumePath [PhysicalVolumePath[:PE[-PE]]...]
@@ -33,7 +33,7 @@
 in the background.  You should only use this if udev is not running
 or has rules that ignore the devices LVM2 creates.
 .TP
-.I \-l, \-\-extents [+|-]LogicalExtentsNumber[%{VG|LV|PVS|FREE}]
+.I \-l, \-\-extents [+|-]LogicalExtentsNumber[%{VG|LV|PVS|FREE|ORIGIN}]
 Change or set the logical volume size in units of logical extents.
 With the + or - sign the value is added to or subtracted from the actual size
 of the logical volume and without it, the value is taken as an absolute one.
@@ -41,8 +41,9 @@
 in the Volume Group with the suffix %VG, relative to the existing
 size of the Logical Volume with the suffix %LV, as a percentage of
 the remaining free space of the PhysicalVolumes on the command line with the
-suffix %PVS, or as a percentage of the remaining free space in the
-Volume Group with the suffix %FREE.
+suffix %PVS, as a percentage of the remaining free space in the
+Volume Group with the suffix %FREE, or (for a snapshot) as a percentage
+of the total space in the Origin Logical Volume with the suffix %ORIGIN.
 .TP
 .I \-L, \-\-size [+|-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]
 Change or set the logical volume size in units of megabytes.
--- LVM2/tools/commands.h	2010/01/13 01:45:16	1.140
+++ LVM2/tools/commands.h	2010/02/03 03:58:08	1.141
@@ -151,7 +151,7 @@
    "\t[-d|--debug]\n"
    "\t[-h|-?|--help]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
-   "\t{-l|--extents LogicalExtentsNumber |\n"
+   "\t{-l|--extents LogicalExtentsNumber[%{VG|PVS|FREE}] |\n"
    "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
    "\t[-m|--mirrors Mirrors [--nosync] [{--mirrorlog {disk|core}|--corelog}]]\n"
@@ -178,7 +178,7 @@
    "\t[-d|--debug]\n"
    "\t[-h|-?|--help]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
-   "\t{-l|--extents LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |\n"
+   "\t{-l|--extents LogicalExtentsNumber[%{VG|FREE|ORIGIN}] |\n"
    "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
    "\t[-n|--name LogicalVolumeName]\n"
@@ -249,7 +249,7 @@
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
-   "\t{-l|--extents [+]LogicalExtentsNumber[%{VG|PVS|FREE}] |\n"
+   "\t{-l|--extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE|ORIGIN}] |\n"
    "\t -L|--size [+]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-m|--mirrors Mirrors]\n"
    "\t[-n|--nofsck]\n"
@@ -320,7 +320,7 @@
    "\t[-d|--debug]\n"
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
-   "\t{-l|--extents [-]LogicalExtentsNumber[%{VG|LV|FREE}] |\n"
+   "\t{-l|--extents [-]LogicalExtentsNumber[%{VG|LV|FREE|ORIGIN}] |\n"
    "\t -L|--size [-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-n|--nofsck]\n"
    "\t[--noudevsync]\n"
@@ -376,7 +376,7 @@
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
-   "\t{-l|--extents [+|-]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |\n"
+   "\t{-l|--extents [+|-]LogicalExtentsNumber[%{VG|LV|PVS|FREE|ORIGIN}] |\n"
    "\t -L|--size [+|-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-n|--nofsck]\n"
    "\t[--noudevsync]\n"
--- LVM2/tools/lvcreate.c	2010/01/12 14:00:52	1.214
+++ LVM2/tools/lvcreate.c	2010/02/03 03:58:08	1.215
@@ -130,6 +130,7 @@
 				  struct lvcreate_cmdline_params *lcp)
 {
 	uint32_t pv_extent_count;
+	struct logical_volume *origin = NULL;
 
 	if (lcp->size &&
 	    !(lp->extents = extents_from_size(vg->cmd, lcp->size,
@@ -171,6 +172,15 @@
 			log_error("Please express size as %%VG, %%PVS, or "
 				  "%%FREE.");
 			return 0;
+		case PERCENT_ORIGIN:
+			if (lp->snapshot && lp->origin &&
+			    !(origin = find_lv(vg, lp->origin))) {
+				log_error("Couldn't find origin volume '%s'.",
+					  lp->origin);
+				return 0;
+			}
+			lp->extents = lp->extents * origin->le_count / 100;
+			break;
 		case PERCENT_NONE:
 			break;
 	}
--- LVM2/tools/lvmcmdline.c	2010/01/22 09:45:29	1.113
+++ LVM2/tools/lvmcmdline.c	2010/02/03 03:58:08	1.114
@@ -358,6 +358,9 @@
 	else if (!strcasecmp(ptr, "F") || !strcasecmp(ptr, "FR") ||
 		 !strcasecmp(ptr, "FREE"))
 		a->percent = PERCENT_FREE;
+	else if (!strcasecmp(ptr, "O") || !strcasecmp(ptr, "OR") ||
+		 !strcasecmp(ptr, "ORIGIN"))
+		a->percent = PERCENT_ORIGIN;
 	else
 		return 0;
 
--- LVM2/tools/lvresize.c	2010/01/05 21:07:31	1.118
+++ LVM2/tools/lvresize.c	2010/02/03 03:58:08	1.119
@@ -373,6 +373,13 @@
 			} else
 				lp->extents = lp->extents * vg->extent_count / 100;
 			break;
+		case PERCENT_ORIGIN:
+			if (!lv_is_cow(lv)) {
+				log_error("Specified LV does not have an origin LV.");
+				return EINVALID_CMD_LINE;
+			}
+			lp->extents = lp->extents * origin_from_cow(lv)->le_count / 100;
+			break;
 		case PERCENT_NONE:
 			break;
 	}
--- LVM2/tools/tools.h	2009/11/03 15:50:44	1.65
+++ LVM2/tools/tools.h	2010/02/03 03:58:08	1.66
@@ -83,7 +83,8 @@
 	PERCENT_VG,
 	PERCENT_FREE,
 	PERCENT_LV,
-	PERCENT_PVS
+	PERCENT_PVS,
+	PERCENT_ORIGIN
 } percent_t;
 
 enum {


