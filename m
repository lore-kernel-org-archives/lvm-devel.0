From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Apr 2008 15:58:26 -0000
Subject: LVM2 ./VERSION ./WHATS_NEW lib/metadata/metada ...
Message-ID: <20080429155826.7501.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-29 15:58:25

Modified files:
	.              : VERSION WHATS_NEW 
	lib/metadata   : metadata.c 
	lib/report     : report.c 
	scripts        : fsadm.sh 
	tools          : commands.h 

Log message:
	pre-release (bug fixes only - enhancements excluded)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.172&r2=1.173
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.864&r2=1.865
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.172&r2=1.173
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.80&r2=1.81
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/fsadm.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.111&r2=1.112

--- LVM2/VERSION	2008/04/15 15:01:18	1.172
+++ LVM2/VERSION	2008/04/29 15:58:23	1.173
@@ -1 +1 @@
-2.02.36-cvs (2008-04-15)
+2.02.36-cvs (2008-04-29)
--- LVM2/WHATS_NEW	2008/04/29 15:25:25	1.864
+++ LVM2/WHATS_NEW	2008/04/29 15:58:24	1.865
@@ -1,18 +1,16 @@
-Version 2.02.36 - 
+Version 2.02.36 - 29th April 2008
 =================================
+  Fix fsadm.sh to work with older blockdev, blkid & readlink binaries.
+  Fix lvresize to pass new size to fsadm when extending device.
   Remove unused struct in clvmd-openais, and use correct node count.
   Fix nodes list in clvmd-openais, and allow for broadcast messages.
   Exclude VG_GLOBAL from internal concurrent VG lock counter.
   Fix vgsplit internal counting of snapshot LVs.
   Fix vgmerge snapshot_count when source VG contains snapshots.
   Simplify clvmd-openais by using non-async saLckResourceLock.
-  Check lv_count in vg_validate.
   Fix internal LV counter when a snapshot is removed.
   Fix metadata corruption writing lvm1-formatted metadata with snapshots.
-  Add --prefixes to reporting tools for field name prefix output format.
   Fix lvconvert -m0 allocatable space check.
-  Fix fsadm.sh to work with older blockdev,blkid,readlink
-  Fix lvresize - extension was not passing new size to fsadm
 
 Version 2.02.35 - 15th April 2008
 =================================
--- LVM2/lib/metadata/metadata.c	2008/04/22 12:54:33	1.172
+++ LVM2/lib/metadata/metadata.c	2008/04/29 15:58:24	1.173
@@ -1213,11 +1213,10 @@
 
 	if ((lv_count = (uint32_t) list_size(&vg->lvs)) !=
 	    vg->lv_count + 2 * vg->snapshot_count) {
-		log_error("Internal error: #internal LVs (%u) != #LVs (%"
+		log_debug("Internal error: #internal LVs (%u) != #LVs (%"
 			  PRIu32 ") + 2 * #snapshots (%" PRIu32 ") in VG %s",
 			  list_size(&vg->lvs), vg->lv_count,
 			  vg->snapshot_count, vg->name);
-		r = 0;
 	}
 
 	list_iterate_items(lvl, &vg->lvs) {
--- LVM2/lib/report/report.c	2008/04/20 00:15:08	1.80
+++ LVM2/lib/report/report.c	2008/04/29 15:58:24	1.81
@@ -1091,15 +1091,9 @@
 	if (headings)
 		report_flags |= DM_REPORT_OUTPUT_HEADINGS;
 
-	if (field_prefixes)
-		report_flags |= DM_REPORT_OUTPUT_FIELD_NAME_PREFIX;
-
 	rh = dm_report_init(report_type, _report_types, _fields, format,
 			    separator, report_flags, keys, cmd);
 
-	if (field_prefixes)
-		dm_report_set_output_field_name_prefix(rh, "lvm2_");
-
 	return rh;
 }
 
--- LVM2/scripts/fsadm.sh	2008/04/29 15:25:27	1.6
+++ LVM2/scripts/fsadm.sh	2008/04/29 15:58:24	1.7
@@ -159,7 +159,7 @@
 	VOLUME=$($READLINK $READLINK_E -n "/dev/$VOLUME") || error "Cannot get readlink $1"
 	# use /dev/null as cache file to be sure about the result
 	# use 'cut' to be compatible with older version of blkid that does not provide option '-o value'
-	FSTYPE=$($BLKID -c /dev/null -s TYPE "$VOLUME" | cut -d \" -f 2) || error "Cannot get FSTYPE of \"$VOLUME\""
+	FSTYPE=$($BLKID -c /dev/null -s TYPE "$VOLUME" | $CUT -d \" -f 2) || error "Cannot get FSTYPE of \"$VOLUME\""
 	verbose "\"$FSTYPE\" filesystem found on \"$VOLUME\""
 }
 
--- LVM2/tools/commands.h	2008/04/20 00:15:08	1.111
+++ LVM2/tools/commands.h	2008/04/29 15:58:25	1.112
@@ -368,7 +368,6 @@
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial] " "\n"
-   "\t[--prefixes]\n"
    "\t[--segments]\n"
    "\t[--separator Separator]\n"
    "\t[--trustcache]\n"
@@ -379,7 +378,7 @@
    "\t[LogicalVolume[Path] [LogicalVolume[Path]...]]\n",
 
    aligned_ARG, all_ARG, ignorelockingfailure_ARG, noheadings_ARG,
-   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, prefixes_ARG,
+   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, 
    segments_ARG, separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG,
    units_ARG)
 
@@ -577,7 +576,6 @@
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial] " "\n"
-   "\t[--prefixes]\n"
    "\t[--segments]\n"
    "\t[--separator Separator]\n"
    "\t[--trustcache]\n"
@@ -588,7 +586,7 @@
    "\t[PhysicalVolume [PhysicalVolume...]]\n",
 
    aligned_ARG, all_ARG, ignorelockingfailure_ARG, noheadings_ARG,
-   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, prefixes_ARG,
+   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, 
    segments_ARG, separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG,
    units_ARG)
 
@@ -894,7 +892,6 @@
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial] " "\n"
-   "\t[--prefixes]\n"
    "\t[--separator Separator]\n"
    "\t[--trustcache]\n"
    "\t[--unbuffered]\n"
@@ -904,7 +901,7 @@
    "\t[VolumeGroupName [VolumeGroupName...]]\n",
 
    aligned_ARG, all_ARG, ignorelockingfailure_ARG, noheadings_ARG,
-   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, prefixes_ARG,
+   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, 
    separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG)
 
 xx(vgscan,


