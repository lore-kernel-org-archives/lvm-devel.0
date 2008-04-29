From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Apr 2008 16:11:30 -0000
Subject: LVM2 ./VERSION ./WHATS_NEW lib/metadata/metada ...
Message-ID: <20080429161130.27932.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-29 16:11:29

Modified files:
	.              : VERSION WHATS_NEW 
	lib/metadata   : metadata.c 
	lib/report     : report.c 
	tools          : commands.h 

Log message:
	post-release - reinstate incomplete enhancements

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.173&r2=1.174
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.865&r2=1.866
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.173&r2=1.174
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.81&r2=1.82
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.112&r2=1.113

--- LVM2/VERSION	2008/04/29 15:58:23	1.173
+++ LVM2/VERSION	2008/04/29 16:11:26	1.174
@@ -1 +1 @@
-2.02.36-cvs (2008-04-29)
+2.02.37-cvs (2008-04-29)
--- LVM2/WHATS_NEW	2008/04/29 15:58:24	1.865
+++ LVM2/WHATS_NEW	2008/04/29 16:11:26	1.866
@@ -1,3 +1,8 @@
+Version 2.02.37 - 
+=================================
+  Check lv_count in vg_validate.
+  Add --prefixes to reporting tools for field name prefix output format.
+
 Version 2.02.36 - 29th April 2008
 =================================
   Fix fsadm.sh to work with older blockdev, blkid & readlink binaries.
--- LVM2/lib/metadata/metadata.c	2008/04/29 15:58:24	1.173
+++ LVM2/lib/metadata/metadata.c	2008/04/29 16:11:27	1.174
@@ -1213,10 +1213,11 @@
 
 	if ((lv_count = (uint32_t) list_size(&vg->lvs)) !=
 	    vg->lv_count + 2 * vg->snapshot_count) {
-		log_debug("Internal error: #internal LVs (%u) != #LVs (%"
+		log_error("Internal error: #internal LVs (%u) != #LVs (%"
 			  PRIu32 ") + 2 * #snapshots (%" PRIu32 ") in VG %s",
 			  list_size(&vg->lvs), vg->lv_count,
 			  vg->snapshot_count, vg->name);
+		r = 0;
 	}
 
 	list_iterate_items(lvl, &vg->lvs) {
--- LVM2/lib/report/report.c	2008/04/29 15:58:24	1.81
+++ LVM2/lib/report/report.c	2008/04/29 16:11:27	1.82
@@ -1091,9 +1091,15 @@
 	if (headings)
 		report_flags |= DM_REPORT_OUTPUT_HEADINGS;
 
+	if (field_prefixes)
+		report_flags |= DM_REPORT_OUTPUT_FIELD_NAME_PREFIX;
+
 	rh = dm_report_init(report_type, _report_types, _fields, format,
 			    separator, report_flags, keys, cmd);
 
+	if (field_prefixes)
+		dm_report_set_output_field_name_prefix(rh, "lvm2_");
+
 	return rh;
 }
 
--- LVM2/tools/commands.h	2008/04/29 15:58:25	1.112
+++ LVM2/tools/commands.h	2008/04/29 16:11:28	1.113
@@ -368,6 +368,7 @@
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--prefixes]\n"
    "\t[--segments]\n"
    "\t[--separator Separator]\n"
    "\t[--trustcache]\n"
@@ -378,7 +379,7 @@
    "\t[LogicalVolume[Path] [LogicalVolume[Path]...]]\n",
 
    aligned_ARG, all_ARG, ignorelockingfailure_ARG, noheadings_ARG,
-   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, 
+   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, prefixes_ARG,
    segments_ARG, separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG,
    units_ARG)
 
@@ -576,6 +577,7 @@
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--prefixes]\n"
    "\t[--segments]\n"
    "\t[--separator Separator]\n"
    "\t[--trustcache]\n"
@@ -586,7 +588,7 @@
    "\t[PhysicalVolume [PhysicalVolume...]]\n",
 
    aligned_ARG, all_ARG, ignorelockingfailure_ARG, noheadings_ARG,
-   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, 
+   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, prefixes_ARG,
    segments_ARG, separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG,
    units_ARG)
 
@@ -892,6 +894,7 @@
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--prefixes]\n"
    "\t[--separator Separator]\n"
    "\t[--trustcache]\n"
    "\t[--unbuffered]\n"
@@ -901,7 +904,7 @@
    "\t[VolumeGroupName [VolumeGroupName...]]\n",
 
    aligned_ARG, all_ARG, ignorelockingfailure_ARG, noheadings_ARG,
-   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, 
+   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, prefixes_ARG,
    separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG)
 
 xx(vgscan,


