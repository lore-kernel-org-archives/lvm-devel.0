From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 20 Sep 2007 21:39:09 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata-exporte ...
Message-ID: <20070920213909.27755.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-09-20 21:39:08

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata-exported.h pv_manip.c 
	lib/misc       : util.h 
	man            : lvcreate.8 lvextend.8 lvresize.8 
	tools          : commands.h lvcreate.c lvmcmdline.c lvresize.c 
	                 tools.h 

Log message:
	Add %PVS extents option to lvresize, lvextend, and lvcreate.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.710&r2=1.711
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_manip.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/util.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvcreate.8.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvextend.8.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvresize.8.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.102&r2=1.103
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.145&r2=1.146
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.82&r2=1.83
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/tools.h.diff?cvsroot=lvm2&r1=1.57&r2=1.58

--- LVM2/WHATS_NEW	2007/09/17 19:51:02	1.710
+++ LVM2/WHATS_NEW	2007/09/20 21:39:07	1.711
@@ -1,5 +1,6 @@
 Version 2.02.29 -
 ==================================
+  Add %PVS extents option to lvresize, lvextend, and lvcreate.
   Moved the obsolete test subdirectory to old-tests.
   Remove no-longer-correct restrictions on PV arg count with stripes/mirrors.
   Fix strdup memory leak in str_list_dup().
--- LVM2/lib/metadata/metadata-exported.h	2007/08/30 20:30:41	1.14
+++ LVM2/lib/metadata/metadata-exported.h	2007/09/20 21:39:07	1.15
@@ -329,6 +329,9 @@
 int pv_analyze(struct cmd_context *cmd, const char *pv_name,
 	       uint64_t label_sector);
 
+/* FIXME: move internal to library */
+uint32_t pv_list_extents_free(struct list *pvh);
+
 struct volume_group *vg_create(struct cmd_context *cmd, const char *name,
 			       uint32_t extent_size, uint32_t max_pv,
 			       uint32_t max_lv, alloc_policy_t alloc,
--- LVM2/lib/metadata/pv_manip.c	2007/08/30 20:30:41	1.12
+++ LVM2/lib/metadata/pv_manip.c	2007/09/20 21:39:07	1.13
@@ -215,6 +215,46 @@
 }
 
 /*
+ * Calculate the overlap, in extents, between a struct pv_segment and
+ * a struct pe_range.
+ */
+static uint32_t _overlap_pe(struct pv_segment *pvseg,
+			    struct pe_range *per)
+{
+	uint32_t start;
+	uint32_t end;
+
+	start = max(pvseg->pe, per->start);
+	end = min(pvseg->pe + pvseg->len, per->start + per->count);
+	if (end < start)
+		return 0;
+	else
+		return end - start;
+}
+
+/*
+ * Returns: number of free PEs in a struct pv_list
+ */
+uint32_t pv_list_extents_free(struct list *pvh)
+{
+	struct pv_list *pvl;
+	struct pe_range *per;
+	uint32_t extents = 0;
+	struct pv_segment *pvseg;
+
+	list_iterate_items(pvl, pvh) {
+		list_iterate_items(per, pvl->pe_ranges) {
+			list_iterate_items(pvseg, &pvl->pv->segments) {
+				if (!pvseg->lvseg) /* free space */
+					extents += _overlap_pe(pvseg, per);
+			}
+		}
+	}
+
+	return extents;
+}
+
+/*
  * Check all pv_segments in VG for consistency
  */
 int check_pv_segments(struct volume_group *vg)
--- LVM2/lib/misc/util.h	2007/08/20 20:55:27	1.2
+++ LVM2/lib/misc/util.h	2007/09/20 21:39:07	1.3
@@ -15,6 +15,16 @@
 #ifndef _LVM_UTIL_H
 #define _LVM_UTIL_H
 
+#define min(a, b) ({ typeof(a) _a = (a); \
+		     typeof(b) _b = (b); \
+		     (void) (&_a == &_b); \
+		     _a < _b ? _a : _b; })
+
+#define max(a, b) ({ typeof(a) _a = @; \
+		     typeof(b) _b = (b); \
+		     (void) (&_a == &_b); \
+		     _a > _b ? _a : _b; })
+
 char *last_path_component(char const *name);
 
 #endif
--- LVM2/man/lvcreate.8	2007/08/30 19:34:19	1.18
+++ LVM2/man/lvcreate.8	2007/09/20 21:39:08	1.19
@@ -8,7 +8,7 @@
 [\-A/\-\-autobackup y/n] [\-C/\-\-contiguous y/n] [\-d/\-\-debug]
 [\-h/\-?/\-\-help]
 [\-i/\-\-stripes Stripes [\-I/\-\-stripesize StripeSize]]
-{\-l/\-\-extents LogicalExtentsNumber[%{VG|FREE}] |
+{\-l/\-\-extents LogicalExtentsNumber[%{VG|PVS|FREE}] |
  \-L/\-\-size LogicalVolumeSize[kKmMgGtT]}
 [\-M/\-\-persistent y/n] [\-\-minor minor]
 [\-m/\-\-mirrors Mirrors [\-\-nosync] [\-\-mirrorlog {disk|log}] [\-\-corelog]
@@ -63,12 +63,14 @@
 For metadata in LVM2 format, the stripe size may be a larger
 power of 2 but must not exceed the physical extent size.
 .TP
-.I \-l, \-\-extents LogicalExtentsNumber[%{VG|FREE}]
+.I \-l, \-\-extents LogicalExtentsNumber[%{VG|PVS|FREE}]
 Gives the number of logical extents to allocate for the new
 logical volume.
 This can also be expressed as a percentage of the total space
-in the Volume Group with the suffix %VG or of the remaining free space
-with the suffix %FREE.
+in the Volume Group with the suffix %VG, of the remaining
+free space in the Volume Group with the suffix %FREE, or
+of the remaining free space for the specified PhysicalVolume(s)
+with the suffix %PVS,
 .TP
 .I \-L, \-\-size LogicalVolumeSize[kKmMgGtTpPeE]
 Gives the size to allocate for the new logical volume.
--- LVM2/man/lvextend.8	2007/01/09 21:12:41	1.9
+++ LVM2/man/lvextend.8	2007/09/20 21:39:08	1.10
@@ -6,7 +6,7 @@
 [\-\-alloc AllocationPolicy]
 [\-A/\-\-autobackup y/n] [\-d/\-\-debug] [\-h/\-?/\-\-help]
 [\-i/\-\-stripes Stripes [\-I/\-\-stripesize StripeSize]]
-{\-l/\-\-extents [+]LogicalExtentsNumber[%{VG|LV|FREE}] |
+{\-l/\-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |
 \-L/\-\-size [+]LogicalVolumeSize[kKmMgGtT]}
 [\-t/\-\-test]
 [\-v/\-\-verbose] LogicalVolumePath [PhysicalVolumePath...]
@@ -21,14 +21,16 @@
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .TP
-.I \-l, \-\-extents [+]LogicalExtentsNumber[%{VG|LV|FREE}]
+.I \-l, \-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE}]
 Extend or set the logical volume size in units of logical extents.
 With the + sign the value is added to the actual size
 of the logical volume and without it, the value is taken as an absolute one.
 The number can also be expressed as a percentage of the total space
-in the Volume Group with the suffix %VG or relative to the existing
-size of the Logical Volume with the suffix %LV or as a percentage of the remaining
-free space in the Volume Group with the suffix %FREE.
+in the Volume Group with the suffix %VG, relative to the existing
+size of the Logical Volume with the suffix %LV, of the remaining
+free space for the specified PhysicalVolume(s) with the suffix %PVS,
+or as a percentage of the remaining free space in the Volume Group
+with the suffix %FREE.
 .TP
 .I \-L, \-\-size [+]LogicalVolumeSize[kKmMgGtTpPeE]
 Extend or set the logical volume size in units of megabytes.
@@ -54,6 +56,10 @@
 that logical volume by 54MB on physical volume /dev/sdk3.
 This is only possible if /dev/sdk3 is a member of volume group vg01 and
 there are enough free physical extents in it.
+
+"lvextend /dev/vg01/lvol01 /dev/sdk3" tries to extend the size of that
+logical volume by the amount of free space on physical volume /dev/sdk3.
+This is equivalent to specifying "-l +100%PVS" on the command line.
 .SH SEE ALSO
 .BR lvm (8), 
 .BR lvcreate (8), 
--- LVM2/man/lvresize.8	2006/11/10 18:24:11	1.5
+++ LVM2/man/lvresize.8	2007/09/20 21:39:08	1.6
@@ -6,7 +6,7 @@
 [\-\-alloc AllocationPolicy]
 [\-A/\-\-autobackup y/n] [\-d/\-\-debug] [\-h/\-?/\-\-help]
 [\-i/\-\-stripes Stripes [\-I/\-\-stripesize StripeSize]]
-{\-l/\-\-extents [+]LogicalExtentsNumber[%{VG|LV|FREE}] |
+{\-l/\-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |
 \-L/\-\-size [+]LogicalVolumeSize[kKmMgGtT]}
 [\-t/\-\-test]
 [\-v/\-\-verbose] LogicalVolumePath [PhysicalVolumePath...]
@@ -25,14 +25,16 @@
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .TP
-.I \-l, \-\-extents [+/-]LogicalExtentsNumber[%{VG|LV|FREE}]
+.I \-l, \-\-extents [+/-]LogicalExtentsNumber[%{VG|LV|PVS|FREE}]
 Change or set the logical volume size in units of logical extents.
 With the + or - sign the value is added to or subtracted from the actual size
 of the logical volume and without it, the value is taken as an absolute one.
 The number can also be expressed as a percentage of the total space
-in the Volume Group with the suffix %VG or relative to the existing
-size of the Logical Volume with the suffix %LV or as a percentage of the remaining 
-free space in the Volume Group with the suffix %FREE.
+in the Volume Group with the suffix %VG, relative to the existing
+size of the Logical Volume with the suffix %LV, as a percentage of
+the remaining free space of the PhysicalVolumes on the command line with the
+suffix %PVS, or as a percentage of the remaining free space in the
+Volume Group with the suffix %FREE.
 .TP
 .I \-L, \-\-size [+/-]LogicalVolumeSize[kKmMgGtTpPeE]
 Change or set the logical volume size in units of megabytes.
--- LVM2/tools/commands.h	2007/08/28 16:14:49	1.102
+++ LVM2/tools/commands.h	2007/09/20 21:39:08	1.103
@@ -144,7 +144,7 @@
    "\t[-d|--debug]\n"
    "\t[-h|-?|--help]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
-   "\t{-l|--extents LogicalExtentsNumber[%{VG|LV|FREE}] |\n"
+   "\t{-l|--extents LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |\n"
    "\t -L|--size LogicalVolumeSize[kKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
    "\t[-n|--name LogicalVolumeName]\n"
@@ -209,7 +209,7 @@
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
-   "\t{-l|--extents [+]LogicalExtentsNumber[%{VG|FREE}] |\n"
+   "\t{-l|--extents [+]LogicalExtentsNumber[%{VG|PVS|FREE}] |\n"
    "\t -L|--size [+]LogicalVolumeSize[kKmMgGtTpPeE]}\n"
    "\t[-m|--mirrors Mirrors]\n"
    "\t[-n|--nofsck]\n"
@@ -323,7 +323,7 @@
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
-   "\t{-l|--extents [+|-]LogicalExtentsNumber[%{VG|LV|FREE}] |\n"
+   "\t{-l|--extents [+|-]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |\n"
    "\t -L|--size [+|-]LogicalVolumeSize[kKmMgGtTpPeE]}\n"
    "\t[-n|--nofsck]\n"
    "\t[-r|--resizefs]\n"
--- LVM2/tools/lvcreate.c	2007/09/17 17:18:37	1.145
+++ LVM2/tools/lvcreate.c	2007/09/20 21:39:08	1.146
@@ -490,6 +490,7 @@
 	char lv_name_buf[128];
 	const char *lv_name;
 	struct lvinfo info;
+	uint32_t pv_extent_count;
 
 	status |= lp->permission | VISIBLE_LV;
 
@@ -574,8 +575,18 @@
 		case PERCENT_FREE:
 			lp->extents = lp->extents * vg->free_count / 100;
 			break;
+		case PERCENT_PVS:
+			if (!lp->pv_count) {
+				log_error("Please specify physical volume(s) "
+					  "with %%PVS");
+				return 0;
+			}
+			pv_extent_count = pv_list_extents_free(pvh);
+			lp->extents = lp->extents * pv_extent_count / 100;
+			break;
 		case PERCENT_LV:
-			log_error("Please express size as %%VG or %%FREE.");
+			log_error("Please express size as %%VG, %%PVS, or "
+				  "%%FREE.");
 			return 0;
 		case PERCENT_NONE:
 			break;
--- LVM2/tools/lvmcmdline.c	2007/08/21 19:46:36	1.48
+++ LVM2/tools/lvmcmdline.c	2007/09/20 21:39:08	1.49
@@ -269,6 +269,9 @@
 		a->percent = PERCENT_VG;
 	else if (!strcasecmp(ptr, "L") || !strcasecmp(ptr, "LV"))
 		a->percent = PERCENT_LV;
+	else if (!strcasecmp(ptr, "P") || !strcasecmp(ptr, "PV") ||
+		 !strcasecmp(ptr, "PVS"))
+		a->percent = PERCENT_PVS;
 	else if (!strcasecmp(ptr, "F") || !strcasecmp(ptr, "FR") ||
 		 !strcasecmp(ptr, "FREE"))
 		a->percent = PERCENT_FREE;
--- LVM2/tools/lvresize.c	2007/09/06 22:35:01	1.82
+++ LVM2/tools/lvresize.c	2007/09/20 21:39:08	1.83
@@ -182,8 +182,20 @@
 	if (!strcmp(cmd_name, "lvextend"))
 		lp->resize = LV_EXTEND;
 
-	if (arg_count(cmd, extents_ARG) + arg_count(cmd, size_ARG) != 1) {
-		log_error("Please specify either size or extents (not both)");
+	/*
+	 * Allow omission of extents and size if the user has given us
+	 * one or more PVs.  Most likely, the intent was "resize this
+	 * LV the best you can with these PVs"
+	 */
+	if ((arg_count(cmd, extents_ARG) + arg_count(cmd, size_ARG) == 0) &&
+	    (argc >= 2)) {
+		lp->extents = 100;
+		lp->percent = PERCENT_PVS;
+		lp->sign = SIGN_PLUS;
+	} else if ((arg_count(cmd, extents_ARG) +
+		    arg_count(cmd, size_ARG) != 1)) {
+		log_error("Please specify either size or extents but not "
+			  "both.");
 		return 0;
 	}
 
@@ -246,6 +258,7 @@
 	uint32_t seg_mirrors = 0;
 	uint32_t extents_used = 0;
 	uint32_t size_rest;
+	uint32_t pv_extent_count = 0;
 	alloc_policy_t alloc;
 	struct logical_volume *lock_lv;
 	struct lv_list *lvl;
@@ -319,6 +332,12 @@
 		lp->extents = lp->size / vg->extent_size;
 	}
 
+	if (!(pvh = lp->argc ? create_pv_list(cmd->mem, vg, lp->argc,
+						     lp->argv, 1) : &vg->pvs)) {
+		stack;
+		return ECMD_FAILED;
+	}
+
 	switch(lp->percent) {
 		case PERCENT_VG:
 			lp->extents = lp->extents * vg->extent_count / 100;
@@ -329,6 +348,10 @@
 		case PERCENT_LV:
 			lp->extents = lp->extents * lv->le_count / 100;
 			break;
+		case PERCENT_PVS:
+			pv_extent_count = pv_list_extents_free(pvh);
+			lp->extents = lp->extents * pv_extent_count / 100;
+			break;
 		case PERCENT_NONE:
 			break;
 	}
@@ -539,10 +562,6 @@
 	if (lp->resize == LV_REDUCE) {
 		if (lp->argc)
 			log_warn("Ignoring PVs on command line when reducing");
-	} else if (!(pvh = lp->argc ? create_pv_list(cmd->mem, vg, lp->argc,
-						     lp->argv, 1) : &vg->pvs)) {
-		stack;
-		return ECMD_FAILED;
 	}
 
 	if (lp->resize == LV_REDUCE || lp->resizefs) {
--- LVM2/tools/tools.h	2007/08/21 19:46:36	1.57
+++ LVM2/tools/tools.h	2007/09/20 21:39:08	1.58
@@ -83,7 +83,8 @@
 	PERCENT_NONE = 0,
 	PERCENT_VG,
 	PERCENT_FREE,
-	PERCENT_LV
+	PERCENT_LV,
+	PERCENT_PVS
 } percent_t;
 
 enum {


