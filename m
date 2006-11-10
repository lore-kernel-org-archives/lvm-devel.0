From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Nov 2006 18:24:14 -0000
Subject: LVM2 ./WHATS_NEW lib/display/display.c lib/for ...
Message-ID: <20061110182414.2173.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-11-10 18:24:11

Modified files:
	.              : WHATS_NEW 
	lib/display    : display.c 
	lib/format_text: export.c format-text.c 
	lib/metadata   : metadata.c 
	man            : lvcreate.8 lvextend.8 lvreduce.8 lvresize.8 
	tools          : commands.h lvcreate.c lvmcmdline.c 

Log message:
	Add some missing bounds checks on 32 bit extent counters.
	Add Petabyte and Exabyte support.
	Fix lvcreate error message when 0 extents requested.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.491&r2=1.492
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.100&r2=1.101
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvextend.8.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvreduce.8.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvresize.8.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.91&r2=1.92
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.130&r2=1.131
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37

--- LVM2/WHATS_NEW	2006/11/06 14:11:39	1.491
+++ LVM2/WHATS_NEW	2006/11/10 18:24:11	1.492
@@ -1,5 +1,8 @@
 Version 2.02.14 - 
 ===================================
+  Add some missing bounds checks on 32 bit extent counters.
+  Add Petabyte and Exabyte support.
+  Fix lvcreate error message when 0 extents requested.
   lvremove man page: volumes must be cluster inactive before being removed.
   Protect .cache manipulations with fcntl locking.
   Change .cache timestamp comparisons to use ctime.
--- LVM2/lib/display/display.c	2006/10/08 12:01:12	1.68
+++ LVM2/lib/display/display.c	2006/11/10 18:24:11	1.69
@@ -82,6 +82,12 @@
 	case 't':
 		v *= KILO * KILO * KILO * KILO;
 		break;
+	case 'p':
+		v *= KILO * KILO * KILO * KILO * KILO;
+		break;
+	case 'e':
+		v *= KILO * KILO * KILO * KILO * KILO * KILO;
+		break;
 #undef KILO
 #define KILO UINT64_C(1000)
 	case 'K':
@@ -96,6 +102,12 @@
 	case 'T':
 		v *= KILO * KILO * KILO * KILO;
 		break;
+	case 'P':
+		v *= KILO * KILO * KILO * KILO * KILO;
+		break;
+	case 'E':
+		v *= KILO * KILO * KILO * KILO * KILO * KILO;
+		break;
 #undef KILO
 	default:
 		return 0;
@@ -143,6 +155,8 @@
 	uint64_t units = UINT64_C(1024);
 	char *size_buf = NULL;
 	const char *size_str[][3] = {
+		{" Exabyte", " EB", "E"},
+		{" Petabyte", " PB", "P"},
 		{" Terabyte", " TB", "T"},
 		{" Gigabyte", " GB", "G"},
 		{" Megabyte", " MB", "M"},
@@ -161,7 +175,7 @@
 
 	suffix = cmd->current_settings.suffix;
 
-	for (s = 0; s < 8; s++)
+	for (s = 0; s < 10; s++)
 		if (toupper((int) cmd->current_settings.unit_type) ==
 		    *size_str[s][2])
 			break;
@@ -171,7 +185,7 @@
 		return size_buf;
 	}
 
-	if (s < 8) {
+	if (s < 10) {
 		byte = cmd->current_settings.unit_factor;
 		size *= UINT64_C(512);
 	} else {
@@ -181,7 +195,7 @@
 			units = UINT64_C(1000);
 		else
 			units = UINT64_C(1024);
-		byte = units * units * units;
+		byte = units * units * units * units * units;
 		s = 0;
 		while (size_str[s] && size < byte)
 			s++, byte /= units;
--- LVM2/lib/format_text/export.c	2006/10/07 23:17:17	1.53
+++ LVM2/lib/format_text/export.c	2006/11/10 18:24:11	1.54
@@ -221,6 +221,8 @@
 		"Megabytes",
 		"Gigabytes",
 		"Terabytes",
+		"Petabytes",
+		"Exabytes",
 		NULL
 	};
 
--- LVM2/lib/format_text/format-text.c	2006/10/07 23:17:17	1.68
+++ LVM2/lib/format_text/format-text.c	2006/11/10 18:24:11	1.69
@@ -1408,6 +1408,7 @@
 	uint64_t pe_end = 0;
 	unsigned mda_count = 0;
 	uint64_t mda_size2 = 0;
+	uint64_t pe_count;
 
 	/* FIXME Cope with pvchange */
 	/* FIXME Merge code with _text_create_text_instance */
@@ -1473,8 +1474,17 @@
 				   pv->pe_start + mda_size2;
 
 		/* Recalculate number of extents that will fit */
-		if (!pv->pe_count)
-			pv->pe_count = (pv->size - pv->pe_start - mda_size2) / vg->extent_size;
+		if (!pv->pe_count) {
+			pe_count = (pv->size - pv->pe_start - mda_size2) /
+				   vg->extent_size;
+			if (pe_count > UINT32_MAX) {
+				log_error("PV %s too large for extent size %s.",
+					  dev_name(pv->dev),
+					  display_size(vg->cmd, (uint64_t) vg->extent_size));
+				return 0;
+			}
+			pv->pe_count = (uint32_t) pe_count;
+		}
 
 		/* Unlike LVM1, we don't store this outside a VG */
 		/* FIXME Default from config file? vgextend cmdline flag? */
--- LVM2/lib/metadata/metadata.c	2006/10/07 23:06:18	1.100
+++ LVM2/lib/metadata/metadata.c	2006/11/10 18:24:11	1.101
@@ -23,6 +23,7 @@
 #include "str_list.h"
 #include "pv_alloc.h"
 #include "activate.h"
+#include "display.h"
 
 #include <sys/param.h>
 
@@ -122,6 +123,15 @@
 	pvl->pv = pv;
 	list_add(&vg->pvs, &pvl->list);
 
+	if ((uint64_t) vg->extent_count + pv->pe_count > UINT32_MAX) {
+		log_error("Unable to add %s to %s: new extent count (%"
+			  PRIu64 ") exceeds limit (%" PRIu32 ").",
+			  pv_name, vg->name,
+			  (uint64_t) vg->extent_count + pv->pe_count,
+			  UINT32_MAX);
+		return 0;
+	}
+
 	vg->pv_count++;
 	vg->extent_count += pv->pe_count;
 	vg->free_count += pv->pe_count;
--- LVM2/man/lvcreate.8	2006/10/07 10:43:40	1.12
+++ LVM2/man/lvcreate.8	2006/11/10 18:24:11	1.13
@@ -70,10 +70,11 @@
 in the Volume Group with the suffix %VG or of the remaining free space
 with the suffix %FREE.
 .TP
-.I \-L, \-\-size LogicalVolumeSize[kKmMgGtT]
+.I \-L, \-\-size LogicalVolumeSize[kKmMgGtTpPeE]
 Gives the size to allocate for the new logical volume.
 A size suffix of K for kilobytes, M for megabytes,
-G for gigabytes or T for terabytes is optional.
+G for gigabytes, T for terabytes, P for petabytes
+or E for exabytes is optional.
 .br
 Default unit is megabytes.
 .TP
--- LVM2/man/lvextend.8	2006/09/26 09:35:42	1.7
+++ LVM2/man/lvextend.8	2006/11/10 18:24:11	1.8
@@ -30,10 +30,12 @@
 size of the Logical Volume with the suffix %LV or as a percentage of the remaining
 free space in the Volume Group with the suffix %FREE.
 .TP
-.I \-L, \-\-size [+]LogicalVolumeSize[kKmMgGtT]
+.I \-L, \-\-size [+]LogicalVolumeSize[kKmMgGtTpPeE]
 Extend or set the logical volume size in units in units of megabytes.
-A size suffix of M for megabytes, G for gigabytes or T for terabytes is
-optional.  With the + sign the value is added to the actual size
+A size suffix of M for megabytes,
+G for gigabytes, T for terabytes, P for petabytes 
+or E for exabytes is optional.
+With the + sign the value is added to the actual size
 of the logical volume and without it, the value is taken as an absolute one.
 .TP
 .I \-i, \-\-stripes Stripes
--- LVM2/man/lvreduce.8	2006/09/26 09:35:42	1.10
+++ LVM2/man/lvreduce.8	2006/11/10 18:24:11	1.11
@@ -46,10 +46,11 @@
 size of the Logical Volume with the suffix %LV or as a percentage of the remaining
 free space in the Volume Group with the suffix %FREE.
 .TP
-.I \-L, \-\-size [\-]LogicalVolumeSize[kKmMgGtT]
+.I \-L, \-\-size [\-]LogicalVolumeSize[kKmMgGtTpPeE]
 Reduce or set the logical volume size in units of megabyte by default.
-A size suffix of k for kilobyte, m for megabyte, g for gigabyte or
-t for terabyte is optional.
+A size suffix of k for kilobyte, m for megabyte, 
+g for gigabytes, t for terabytes, p for petabytes 
+or e for exabytes is optional.
 With the - sign the value will be subtracted from
 the logical volume's actual size and without it it will be taken as
 an absolute size.
--- LVM2/man/lvresize.8	2006/09/26 09:35:42	1.4
+++ LVM2/man/lvresize.8	2006/11/10 18:24:11	1.5
@@ -34,10 +34,12 @@
 size of the Logical Volume with the suffix %LV or as a percentage of the remaining 
 free space in the Volume Group with the suffix %FREE.
 .TP
-.I \-L, \-\-size [+/-]LogicalVolumeSize[kKmMgGtT]
+.I \-L, \-\-size [+/-]LogicalVolumeSize[kKmMgGtTpPeE]
 Change or set the logical volume size in units of megabytes.
-A size suffix of M for megabytes, G for gigabytes or T for terabytes is
-optional.  With the + or - sign the value is added to or subtracted from
+A size suffix of M for megabytes,
+G for gigabytes, T for terabytes, P for petabytes 
+or E for exabytes is optional.
+With the + or - sign the value is added to or subtracted from
 the actual size of the logical volume and without it, the value is taken as an
 absolute one.
 .TP
--- LVM2/tools/commands.h	2006/10/24 17:19:48	1.91
+++ LVM2/tools/commands.h	2006/11/10 18:24:11	1.92
@@ -19,7 +19,7 @@
    "e2fsadm "
    "[-d|--debug] " "[-h|--help] " "[-n|--nofsck]" "\n"
    "\t{[-l|--extents] [+|-]LogicalExtentsNumber |" "\n"
-   "\t [-L|--size] [+|-]LogicalVolumeSize[kKmMgGtT]}" "\n"
+   "\t [-L|--size] [+|-]LogicalVolumeSize[kKmMgGtTpPeE]}" "\n"
    "\t[-t|--test] "  "\n"
    "\t[-v|--verbose] "  "\n"
    "\t[--version] " "\n"
@@ -117,7 +117,7 @@
    "\t[-h|-?|--help]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
    "\t{-l|--extents LogicalExtentsNumber |\n"
-   "\t -L|--size LogicalVolumeSize[kKmMgGtT]}\n"
+   "\t -L|--size LogicalVolumeSize[kKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
    "\t[-m|--mirrors Mirrors [--nosync] [--corelog]]\n"
    "\t[-n|--name LogicalVolumeName]\n"
@@ -141,7 +141,7 @@
    "\t[-h|-?|--help]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
    "\t{-l|--extents LogicalExtentsNumber[%{VG|LV|FREE}] |\n"
-   "\t -L|--size LogicalVolumeSize[kKmMgGtT]}\n"
+   "\t -L|--size LogicalVolumeSize[kKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
    "\t[-n|--name LogicalVolumeName]\n"
    "\t[-p|--permission {r|rw}]\n"
@@ -206,7 +206,7 @@
    "\t[-h|--help]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
    "\t{-l|--extents [+]LogicalExtentsNumber[%{VG|FREE}] |\n"
-   "\t -L|--size [+]LogicalVolumeSize[kKmMgGtT]}\n"
+   "\t -L|--size [+]LogicalVolumeSize[kKmMgGtTpPeE]}\n"
    "\t[-m|--mirrors Mirrors]\n"
    "\t[-n|--nofsck]\n"
    "\t[-r|--resizefs]\n"
@@ -271,7 +271,7 @@
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
    "\t{-l|--extents [-]LogicalExtentsNumber[%{VG|LV|FREE}] |\n"
-   "\t -L|--size [-]LogicalVolumeSize[kKmMgGtT]}\n"
+   "\t -L|--size [-]LogicalVolumeSize[kKmMgGtTpPeE]}\n"
    "\t[-n|--nofsck]\n"
    "\t[-r|--resizefs]\n"
    "\t[-t|--test]\n"
@@ -320,7 +320,7 @@
    "\t[-h|--help]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
    "\t{-l|--extents [+|-]LogicalExtentsNumber[%{VG|LV|FREE}] |\n"
-   "\t -L|--size [+|-]LogicalVolumeSize[kKmMgGtT]}\n"
+   "\t -L|--size [+|-]LogicalVolumeSize[kKmMgGtTpPeE]}\n"
    "\t[-n|--nofsck]\n"
    "\t[-r|--resizefs]\n"
    "\t[-t|--test]\n"
@@ -396,7 +396,7 @@
    "pvresize " "\n"
    "\t[-d|--debug]" "\n"
    "\t[-h|-?|--help] " "\n"
-   "\t[--setphysicalvolumesize PhysicalVolumeSize[kKmMgGtT]" "\n"
+   "\t[--setphysicalvolumesize PhysicalVolumeSize[kKmMgGtTpPeE]" "\n"
    "\t[-t|--test] " "\n"
    "\t[-v|--verbose] " "\n"
    "\t[--version] " "\n"
@@ -414,8 +414,8 @@
    "\t[--labelsector sector] " "\n"
    "\t[-M|--metadatatype 1|2]" "\n"
    "\t[--metadatacopies #copies]" "\n"
-   "\t[--metadatasize MetadataSize[kKmMgGtT]]" "\n"
-   "\t[--setphysicalvolumesize PhysicalVolumeSize[kKmMgGtT]" "\n"
+   "\t[--metadatasize MetadataSize[kKmMgGtTpPeE]]" "\n"
+   "\t[--setphysicalvolumesize PhysicalVolumeSize[kKmMgGtTpPeE]" "\n"
    "\t[-t|--test] " "\n"
    "\t[-u|--uuid uuid] " "\n"
    "\t[-v|--verbose] " "\n"
@@ -612,7 +612,7 @@
    "\t -x|--resizeable {y|n} |" "\n"
    "\t -l|--logicalvolume MaxLogicalVolumes |" "\n"
    "\t -p|--maxphysicalvolumes MaxPhysicalVolumes |" "\n"
-   "\t -s|--physicalextentsize PhysicalExtentSize[kKmMgGtT] |" "\n"
+   "\t -s|--physicalextentsize PhysicalExtentSize[kKmMgGtTpPeE] |" "\n"
    "\t --addtag Tag |\n"
    "\t --deltag Tag}\n"
    "\t[VolumeGroupName...]\n",
@@ -639,7 +639,7 @@
    "\t[--labelsector sector] " "\n"
    "\t[-M|--metadatatype 1|2]" "\n"
    "\t[--metadatacopies #copies]" "\n"
-   "\t[--metadatasize MetadataSize[kKmMgGtT]]" "\n"
+   "\t[--metadatasize MetadataSize[kKmMgGtTpPeE]]" "\n"
    "\t[-t|--test] " "\n"
    "\t[-v|--verbose] " "\n"
    "\t[--version] " "\n"
@@ -660,7 +660,7 @@
    "\t[-l|--maxlogicalvolumes MaxLogicalVolumes]" "\n"
    "\t[-M|--metadatatype 1|2] " "\n"
    "\t[-p|--maxphysicalvolumes MaxPhysicalVolumes] " "\n"
-   "\t[-s|--physicalextentsize PhysicalExtentSize[kKmMgGtT]] " "\n"
+   "\t[-s|--physicalextentsize PhysicalExtentSize[kKmMgGtTpPeE]] " "\n"
    "\t[-t|--test] " "\n"
    "\t[-v|--verbose]" "\n"
    "\t[--version] " "\n"
--- LVM2/tools/lvcreate.c	2006/11/02 23:33:20	1.130
+++ LVM2/tools/lvcreate.c	2006/11/10 18:24:11	1.131
@@ -556,7 +556,16 @@
 				  display_size(cmd, tmp_size));
 		}
 
-		lp->extents = tmp_size / vg->extent_size;
+		if (tmp_size > (uint64_t) UINT32_MAX * vg->extent_size) {
+			log_error("Volume too large (%s) for extent size %s. "
+				  "Upper limit is %s.",
+				  display_size(cmd, tmp_size),
+				  display_size(cmd, vg->extent_size),
+				  display_size(cmd, (uint64_t) UINT32_MAX *
+						   vg->extent_size));
+			return 0;
+		}
+		lp->extents = (uint64_t) tmp_size / vg->extent_size;
 	}
 
 	switch(lp->percent) {
@@ -618,8 +627,7 @@
 	}
 
 	if (!lp->extents) {
-		log_error("Unable to create logical volume %s with no extents",
-			  lp->lv_name);
+		log_error("Unable to create new logical volume with no extents");
 		return 0;
 	}
 
--- LVM2/tools/lvmcmdline.c	2006/10/02 16:15:03	1.36
+++ LVM2/tools/lvmcmdline.c	2006/11/10 18:24:11	1.37
@@ -186,7 +186,7 @@
 {
 	char *ptr;
 	int i;
-	static const char *suffixes = "kmgt";
+	static const char *suffixes = "kmgtpe";
 	char *val;
 	double v;
 


