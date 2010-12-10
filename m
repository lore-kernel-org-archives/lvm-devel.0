From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Dec 2010 22:40:07 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/cach ...
Message-ID: <20101210224007.2340.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-12-10 22:39:57

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c lvmcache.h 
	lib/commands   : toolcontext.c toolcontext.h 
	lib/format_text: format-text.c 
	lib/metadata   : metadata.c metadata.h 

Log message:
	Fix scanning of VGs without in-PV mdas.
	
	Set cmd->independent_metadata_areas if metadata/dirs or disk_areas in use.
	- Identify and record this state.
	
	Don't skip full scan when independent mdas are present even if memlock is set.
	- Clusters and OOM aren't supported, so no problem doing the proper scans.
	
	Avoid revalidating the label cache immediately after scanning.
	- A simple optimisation.
	
	Support scanning for a single VG in independent mdas.
	- Not used by the fix but I left it in anyway as later patches might use it.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1834&r2=1.1835
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.99&r2=1.100
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.h.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.110&r2=1.111
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.h.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.150&r2=1.151
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.415&r2=1.416
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.224&r2=1.225

--- LVM2/WHATS_NEW	2010/12/09 00:10:24	1.1834
+++ LVM2/WHATS_NEW	2010/12/10 22:39:52	1.1835
@@ -1,5 +1,9 @@
 Version 2.02.79 -  
 ===================================
+  Avoid revalidating the label cache immediately after scanning.
+  Support scanning for a single VG in independent mdas.
+  Don't skip full scan when independent mdas are present even if memlock is set.
+  Set cmd->independent_metadata_areas if metadata/dirs or disk_areas in use.
   Cope better with an undefined target_percent operation in _percent_run.
   Fix write to released memory in vg_release and rename to free_vg.  (2.02.78)
 
--- LVM2/lib/cache/lvmcache.c	2010/12/08 20:50:49	1.99
+++ LVM2/lib/cache/lvmcache.c	2010/12/10 22:39:54	1.100
@@ -366,7 +366,7 @@
 	return vginfo;
 }
 
-const struct format_type *fmt_from_vgname(const char *vgname, const char *vgid)
+const struct format_type *fmt_from_vgname(const char *vgname, const char *vgid, unsigned revalidate_labels)
 {
 	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_info *info;
@@ -379,8 +379,16 @@
 	if (!(vginfo = vginfo_from_vgname(vgname, vgid)))
 		return NULL;
 
-	/* This function is normally called before reading metadata so
- 	 * we check cached labels here. Unfortunately vginfo is volatile. */
+	/*
+	 * If this function is called repeatedly, only the first one needs to revalidate.
+	 */
+	if (!revalidate_labels)
+		goto out;
+
+	/*
+	 * This function is normally called before reading metadata so
+ 	 * we check cached labels here. Unfortunately vginfo is volatile.
+ 	 */
 	dm_list_init(&devs);
 	dm_list_iterate_items(info, &vginfo->infos) {
 		if (!(devl = dm_malloc(sizeof(*devl)))) {
@@ -405,6 +413,7 @@
 	    strncmp(vginfo->vgid, vgid_found, ID_LEN))
 		return NULL;
 
+out:
 	return vginfo->fmt;
 }
 
@@ -588,10 +597,10 @@
 	_has_scanned = 1;
 
 	/* Perform any format-specific scanning e.g. text files */
-	dm_list_iterate_items(fmt, &cmd->formats) {
-		if (fmt->ops->scan && !fmt->ops->scan(fmt))
-			goto out;
-	}
+	if (cmd->independent_metadata_areas)
+		dm_list_iterate_items(fmt, &cmd->formats)
+			if (fmt->ops->scan && !fmt->ops->scan(fmt, NULL))
+				goto out;
 
 	/*
 	 * If we are a long-lived process, write out the updated persistent
--- LVM2/lib/cache/lvmcache.h	2010/10/25 13:02:26	1.34
+++ LVM2/lib/cache/lvmcache.h	2010/12/10 22:39:54	1.35
@@ -88,7 +88,7 @@
 int lvmcache_verify_lock_order(const char *vgname);
 
 /* Queries */
-const struct format_type *fmt_from_vgname(const char *vgname, const char *vgid);
+const struct format_type *fmt_from_vgname(const char *vgname, const char *vgid, unsigned revalidate_labels);
 struct lvmcache_vginfo *vginfo_from_vgname(const char *vgname,
 					   const char *vgid);
 struct lvmcache_vginfo *vginfo_from_vgid(const char *vgid);
--- LVM2/lib/commands/toolcontext.c	2010/11/29 10:58:32	1.110
+++ LVM2/lib/commands/toolcontext.c	2010/12/10 22:39:54	1.111
@@ -1138,6 +1138,7 @@
 	cmd->is_long_lived = is_long_lived;
 	cmd->handles_missing_pvs = 0;
 	cmd->handles_unknown_segments = 0;
+	cmd->independent_metadata_areas = 0;
 	cmd->hosttags = 0;
 	dm_list_init(&cmd->arg_value_groups);
 	dm_list_init(&cmd->formats);
@@ -1246,6 +1247,8 @@
 			dlclose(lib);
 #endif
 	}
+
+	cmd->independent_metadata_areas = 0;
 }
 
 static void _destroy_segtypes(struct dm_list *segtypes)
--- LVM2/lib/commands/toolcontext.h	2010/11/11 17:29:06	1.41
+++ LVM2/lib/commands/toolcontext.h	2010/12/10 22:39:54	1.42
@@ -78,6 +78,8 @@
 	unsigned si_unit_consistency:1;
 	unsigned metadata_read_only:1;
 
+	unsigned independent_metadata_areas:1;	/* Active formats have MDAs outside PVs */
+
 	struct dev_filter *filter;
 	int dump_filter;	/* Dump filter when exiting? */
 
--- LVM2/lib/format_text/format-text.c	2010/12/08 20:50:49	1.150
+++ LVM2/lib/format_text/format-text.c	2010/12/10 22:39:55	1.151
@@ -1045,7 +1045,7 @@
 	return 1;
 }
 
-static int _scan_file(const struct format_type *fmt)
+static int _scan_file(const struct format_type *fmt, const char *vgname)
 {
 	struct dirent *dirent;
 	struct dir_list *dl;
@@ -1055,7 +1055,7 @@
 	struct volume_group *vg;
 	struct format_instance *fid;
 	char path[PATH_MAX];
-	char *vgname;
+	char *scanned_vgname;
 
 	dir_list = &((struct mda_lists *) fmt->private)->dirs;
 
@@ -1070,18 +1070,23 @@
 			    (!(tmp = strstr(dirent->d_name, ".tmp")) ||
 			     tmp != dirent->d_name + strlen(dirent->d_name)
 			     - 4)) {
-				vgname = dirent->d_name;
+				scanned_vgname = dirent->d_name;
+
+				/* If vgname supplied, only scan that one VG */
+				if (vgname && strcmp(vgname, scanned_vgname))
+					continue;
+
 				if (dm_snprintf(path, PATH_MAX, "%s/%s",
-						 dl->dir, vgname) < 0) {
+						 dl->dir, scanned_vgname) < 0) {
 					log_error("Name too long %s/%s",
-						  dl->dir, vgname);
+						  dl->dir, scanned_vgname);
 					break;
 				}
 
 				/* FIXME stat file to see if it's changed */
 				fid = _text_create_text_instance(fmt, NULL, NULL,
 							    NULL);
-				if ((vg = _vg_read_file_name(fid, vgname,
+				if ((vg = _vg_read_file_name(fid, scanned_vgname,
 							     path))) {
 					/* FIXME Store creation host in vg */
 					lvmcache_update_vg(vg, 0);
@@ -1195,11 +1200,11 @@
 	return vgname;
 }
 
-static int _scan_raw(const struct format_type *fmt)
+static int _scan_raw(const struct format_type *fmt, const char *vgname __attribute__((unused)))
 {
 	struct raw_list *rl;
 	struct dm_list *raw_list;
-	const char *vgname;
+	const char *scanned_vgname;
 	struct volume_group *vg;
 	struct format_instance fid;
 	struct id vgid;
@@ -1224,10 +1229,10 @@
 			goto close_dev;
 		}
 
-		if ((vgname = vgname_from_mda(fmt, mdah,
+		if ((scanned_vgname = vgname_from_mda(fmt, mdah,
 					      &rl->dev_area, &vgid, &vgstatus,
 					      NULL, NULL))) {
-			vg = _vg_read_raw_area(&fid, vgname, &rl->dev_area, 0);
+			vg = _vg_read_raw_area(&fid, scanned_vgname, &rl->dev_area, 0);
 			if (vg)
 				lvmcache_update_vg(vg, 0);
 
@@ -1240,9 +1245,9 @@
 	return 1;
 }
 
-static int _text_scan(const struct format_type *fmt)
+static int _text_scan(const struct format_type *fmt, const char *vgname)
 {
-	return (_scan_file(fmt) & _scan_raw(fmt));
+	return (_scan_file(fmt, vgname) & _scan_raw(fmt, vgname));
 }
 
 /* For orphan, creates new mdas according to policy.
@@ -2181,6 +2186,7 @@
 					  "metadata directory list ", cv->v.str);
 				goto err;
 			}
+			cmd->independent_metadata_areas = 1;
 		}
 	}
 
@@ -2188,6 +2194,7 @@
 		for (cn = cn->child; cn; cn = cn->sib) {
 			if (!_get_config_disk_area(cmd, cn, &mda_lists->raws))
 				goto err;
+			cmd->independent_metadata_areas = 1;
 		}
 	}
 
--- LVM2/lib/metadata/metadata.c	2010/12/08 20:50:50	1.415
+++ LVM2/lib/metadata/metadata.c	2010/12/10 22:39:55	1.416
@@ -2706,13 +2706,14 @@
 
 	/* Find the vgname in the cache */
 	/* If it's not there we must do full scan to be completely sure */
-	if (!(fmt = fmt_from_vgname(vgname, vgid))) {
+	if (!(fmt = fmt_from_vgname(vgname, vgid, 1))) {
 		lvmcache_label_scan(cmd, 0);
-		if (!(fmt = fmt_from_vgname(vgname, vgid))) {
-			if (memlock())
+		if (!(fmt = fmt_from_vgname(vgname, vgid, 1))) {
+			/* Independent MDAs aren't supported under low memory */
+			if (!cmd->independent_metadata_areas && memlock())
 				return_NULL;
 			lvmcache_label_scan(cmd, 2);
-			if (!(fmt = fmt_from_vgname(vgname, vgid)))
+			if (!(fmt = fmt_from_vgname(vgname, vgid, 0)))
 				return_NULL;
 		}
 	}
@@ -2868,10 +2869,11 @@
 	if (!correct_vg) {
 		inconsistent = 0;
 
-		if (memlock())
+		/* Independent MDAs aren't supported under low memory */
+		if (!cmd->independent_metadata_areas && memlock())
 			return_NULL;
 		lvmcache_label_scan(cmd, 2);
-		if (!(fmt = fmt_from_vgname(vgname, vgid)))
+		if (!(fmt = fmt_from_vgname(vgname, vgid, 0)))
 			return_NULL;
 
 		if (precommitted && !(fmt->features & FMT_PRECOMMIT))
@@ -3795,10 +3797,11 @@
 
 	/* Find the vgname in the cache */
 	/* If it's not there we must do full scan to be completely sure */
-	if (!fmt_from_vgname(vgname, NULL)) {
+	if (!fmt_from_vgname(vgname, NULL, 1)) {
 		lvmcache_label_scan(cmd, 0);
-		if (!fmt_from_vgname(vgname, NULL)) {
-			if (memlock()) {
+		if (!fmt_from_vgname(vgname, NULL, 1)) {
+			/* Independent MDAs aren't supported under low memory */
+			if (!cmd->independent_metadata_areas && memlock()) {
 				/*
 				 * FIXME: Disallow calling this function if
 				 * memlock() is true.
@@ -3807,7 +3810,7 @@
 				return FAILED_LOCKING;
 			}
 			lvmcache_label_scan(cmd, 2);
-			if (!fmt_from_vgname(vgname, NULL)) {
+			if (!fmt_from_vgname(vgname, NULL, 0)) {
 				/* vgname not found after scanning */
 				return SUCCESS;
 			}
--- LVM2/lib/metadata/metadata.h	2010/10/25 13:54:29	1.224
+++ LVM2/lib/metadata/metadata.h	2010/12/10 22:39:55	1.225
@@ -227,7 +227,7 @@
 	/*
 	 * Scan any metadata areas that aren't referenced in PV labels
 	 */
-	int (*scan) (const struct format_type * fmt);
+	int (*scan) (const struct format_type * fmt, const char *vgname);
 
 	/*
 	 * Return PV with given path.


