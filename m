From: bmr@sourceware.org <bmr@sourceware.org>
Date: 2 Nov 2007 13:06:44 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/form ...
Message-ID: <20071102130644.21386.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	bmr at sourceware.org	2007-11-02 13:06:42

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c 
	lib/format1    : disk-rep.c 
	lib/format_text: format-text.c 
	lib/locking    : locking.c 
	lib/metadata   : metadata-exported.h metadata.c metadata.h 
	                 pv_manip.c 
	tools          : toollib.c vgrename.c 

Log message:
	Add is_orphan_vg() and change all hardcoded checks to use it.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.722&r2=1.723
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/disk-rep.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.83&r2=1.84
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.140&r2=1.141
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.172&r2=1.173
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_manip.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.108&r2=1.109
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47

--- LVM2/WHATS_NEW	2007/10/24 00:51:05	1.722
+++ LVM2/WHATS_NEW	2007/11/02 13:06:41	1.723
@@ -1,5 +1,6 @@
 Version 2.02.29 -
 ==================================
+  Add is_orphan_vg() and change all hardcoded checks to use it.
   Detect md superblocks version 1.0, 1.1 and 1.2.
   Add _alloc_pv() and _free_pv() from _pv_create() code and fix error paths.
   Add pv_dev_name() to access PV device name.
--- LVM2/lib/cache/lvmcache.c	2007/08/20 20:55:24	1.31
+++ LVM2/lib/cache/lvmcache.c	2007/11/02 13:06:41	1.32
@@ -633,7 +633,7 @@
 			return 0;
 		}
 		/* Ensure orphans appear last on list_iterate */
-		if (!*vgname)
+		if (is_orphan_vg(vgname))
 			list_add(&_vginfos, &vginfo->list);
 		else
 			list_add_h(&_vginfos, &vginfo->list);
@@ -649,7 +649,7 @@
 	vginfo->fmt = info->fmt;
 
 	log_debug("lvmcache: %s: now %s%s%s%s%s", dev_name(info->dev),
-		  *vgname ? "in VG " : "orphaned", vgname,
+		  is_orphan_vg(vgname) ? "in VG " : "orphaned", vgname,
 		  vginfo->vgid[0] ? " (" : "",
 		  vginfo->vgid[0] ? vginfo->vgid : "",
 		  vginfo->vgid[0] ? ")" : "");
--- LVM2/lib/format1/disk-rep.c	2007/08/22 14:38:16	1.68
+++ LVM2/lib/format1/disk-rep.c	2007/11/02 13:06:41	1.69
@@ -480,7 +480,7 @@
 		}
 
 		/* Did we find the whole VG? */
-		if (!vg_name || !*vg_name ||
+		if (!vg_name || is_orphan_vg(vg_name) ||
 		    (data && *data->pvd.vg_name &&
 		     list_size(head) == data->vgd.pv_cur))
 			return 1;
--- LVM2/lib/format_text/format-text.c	2007/10/12 14:29:32	1.83
+++ LVM2/lib/format_text/format-text.c	2007/11/02 13:06:41	1.84
@@ -1438,7 +1438,8 @@
 	info = (struct lvmcache_info *) label->info;
 
 	/* Have we already cached vgname? */
-	if (info->vginfo && info->vginfo->vgname && *info->vginfo->vgname &&
+	if (info->vginfo && info->vginfo->vgname &&
+	    !is_orphan_vg(info->vginfo->vgname) &&
 	    get_pv_from_vg_by_id(info->fmt, info->vginfo->vgname,
 				 info->vginfo->vgid, info->dev->pvid, pv)) {
 		return 1;
@@ -1449,7 +1450,7 @@
 		lvmcache_label_scan(fmt->cmd, 2);
 
 		if (info->vginfo && info->vginfo->vgname &&
-		    *info->vginfo->vgname &&
+		    !is_orphan_vg(info->vginfo->vgname) &&
 		    get_pv_from_vg_by_id(info->fmt, info->vginfo->vgname,
 					 info->vginfo->vgid,
 					 info->dev->pvid, pv)) {
--- LVM2/lib/locking/locking.c	2007/08/22 14:38:17	1.40
+++ LVM2/lib/locking/locking.c	2007/11/02 13:06:41	1.41
@@ -288,7 +288,7 @@
 	char path[PATH_MAX];
 
 	/* We'll allow operations on orphans */
-	if (!*vgname)
+	if (is_orphan_vg(vgname))
 		return 1;
 
 	if (dm_snprintf(path, sizeof(path), "%s/lvm/VGs/%s", cmd->proc_dir,
--- LVM2/lib/metadata/metadata-exported.h	2007/10/12 14:29:32	1.20
+++ LVM2/lib/metadata/metadata-exported.h	2007/11/02 13:06:41	1.21
@@ -304,6 +304,7 @@
 
 int pv_write(struct cmd_context *cmd, struct physical_volume *pv,
 	     struct list *mdas, int64_t label_sector);
+int is_orphan_vg(const char *vg_name);
 int is_orphan(pv_t *pv);
 vg_t *vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
 		       uint32_t lock_flags, uint32_t status_flags,
--- LVM2/lib/metadata/metadata.c	2007/10/12 21:08:38	1.140
+++ LVM2/lib/metadata/metadata.c	2007/11/02 13:06:41	1.141
@@ -93,7 +93,7 @@
 		return 0;
 	}
 
-	if (*pv->vg_name) {
+	if (!is_orphan_vg(pv->vg_name)) {
 		log_error("Physical volume '%s' is already in volume group "
 			  "'%s'", pv_name, pv->vg_name);
 		return 0;
@@ -928,7 +928,7 @@
 	}
 
 	/* FIXME Can fail when no PV mda */
-	if (!pv->vg_name[0]) {
+	if (is_orphan_vg(pv->vg_name)) {
 		log_error("Physical volume %s not in a volume group", pv_name);
 		return NULL;
 	}
@@ -1272,7 +1272,7 @@
 	struct list all_pvs;
 	char uuid[64] __attribute((aligned(8)));
 
-	if (!*vgname) {
+	if (is_orphan_vg(vgname)) {
 		if (use_precommitted) {
 			log_error("Internal error: vg_read requires vgname "
 				  "with pre-commit.");
@@ -1536,7 +1536,7 @@
 
 	/* Is corresponding vgname already cached? */
 	if ((vginfo = vginfo_from_vgid(vgid)) &&
-	    vginfo->vgname && *vginfo->vgname) {
+	    vginfo->vgname && !is_orphan_vg(vginfo->vgname)) {
 		if ((vg = _vg_read(cmd, vginfo->vgname, vgid,
 				   &consistent, precommitted)) &&
 		    !strncmp((char *)vg->id.uuid, vgid, ID_LEN)) {
@@ -1566,7 +1566,7 @@
 
 	list_iterate_items(strl, vgnames) {
 		vgname = strl->str;
-		if (!vgname || !*vgname)
+		if (!vgname || is_orphan_vg(vgname))
 			continue;	// FIXME Unnecessary? 
 		consistent = 0;
 		if ((vg = _vg_read(cmd, vgname, vgid, &consistent,
@@ -1778,7 +1778,7 @@
 		return 0;
 	}
 
-	if (*pv->vg_name || pv->pe_alloc_count) {
+	if (!is_orphan_vg(pv->vg_name) || pv->pe_alloc_count) {
 		log_error("Assertion failed: can't _pv_write non-orphan PV "
 			  "(in VG %s)", pv->vg_name);
 		return 0;
@@ -1815,15 +1815,23 @@
 }
 
 /**
+ * is_orphan_vg - Determine whether a vg_name is an orphan
+ * @vg_name: pointer to the vg_name
+ */
+int is_orphan_vg(const char *vg_name)
+{
+	return (vg_name[0] ? 0 : 1);
+}
+
+/**
  * is_orphan - Determine whether a pv is an orphan based on its vg_name
  * @pv: handle to the physical volume
  */
 int is_orphan(pv_t *pv)
 {
-	return (pv_field(pv, vg_name)[0] ? 0 : 1);
+	return is_orphan_vg(pv_field(pv, vg_name));
 }
 
-
 /*
  * Returns:
  *  0 - fail
--- LVM2/lib/metadata/metadata.h	2007/10/12 14:08:10	1.172
+++ LVM2/lib/metadata/metadata.h	2007/11/02 13:06:41	1.173
@@ -180,7 +180,7 @@
 
 	/*
 	 * Write a PV structure to disk. Fails if the PV is in a VG ie
-	 * pv->vg_name must be null.
+	 * pv->vg_name must be a valid orphan VG name
 	 */
 	int (*pv_write) (const struct format_type * fmt,
 			 struct physical_volume * pv, struct list * mdas,
--- LVM2/lib/metadata/pv_manip.c	2007/10/12 14:29:32	1.15
+++ LVM2/lib/metadata/pv_manip.c	2007/11/02 13:06:41	1.16
@@ -455,7 +455,7 @@
 
 	list_init(&mdas);
 
-	if (!*pv_vg_name(pv)) {
+	if (is_orphan_vg(pv_vg_name(pv))) {
 		vg_name = ORPHAN;
 
 		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
@@ -572,7 +572,7 @@
 		    pv_name, pv_size(pv));
 
 	log_verbose("Updating physical volume \"%s\"", pv_name);
-	if (*pv_vg_name(pv)) {
+	if (!is_orphan_vg(pv_vg_name(pv))) {
 		if (!vg_write(vg) || !vg_commit(vg)) {
 			unlock_vg(cmd, pv_vg_name(pv));
 			log_error("Failed to store physical volume \"%s\" in "
--- LVM2/tools/toollib.c	2007/10/12 14:29:32	1.108
+++ LVM2/tools/toollib.c	2007/11/02 13:06:42	1.109
@@ -341,7 +341,7 @@
 
 	list_iterate_items(strl, vgnames) {
 		vgname = strl->str;
-		if (!vgname || !*vgname)
+		if (!vgname || is_orphan_vg(vgname))
 			continue;	/* FIXME Unnecessary? */
 		if (!lock_vol(cmd, vgname, lock_type)) {
 			log_error("Can't lock %s: skipping", vgname);
@@ -576,7 +576,7 @@
 		list_iterate_items(sl, vgids) {
 			vgid = sl->str;
 			if (!vgid || !(vg_name = vgname_from_vgid(cmd->mem, vgid)) ||
-			    !*vg_name)
+			    is_orphan_vg(vg_name))
 				continue;
 			ret_max = _process_one_vg(cmd, vg_name, vgid, &tags,
 						  &arg_vgnames,
@@ -588,7 +588,7 @@
 	} else {
 		list_iterate_items(sl, vgnames) {
 			vg_name = sl->str;
-			if (!vg_name || !*vg_name)
+			if (!vg_name || is_orphan_vg(vg_name))
 				continue;	/* FIXME Unnecessary? */
 			ret_max = _process_one_vg(cmd, vg_name, NULL, &tags,
 						  &arg_vgnames,
@@ -1199,6 +1199,9 @@
 	if (!validate_name(vg_name))
 		return 0;
 
+	if (is_orphan_vg(vg_name))
+		return 0;
+
 	snprintf(vg_path, PATH_MAX, "%s%s", cmd->dev_dir, vg_name);
 	if (path_exists(vg_path)) {
 		log_error("%s: already exists in filesystem", vg_path);
--- LVM2/tools/vgrename.c	2007/08/31 19:09:49	1.46
+++ LVM2/tools/vgrename.c	2007/11/02 13:06:42	1.47
@@ -65,7 +65,8 @@
 
 	list_iterate_items(sl, vgids) {
 		vgid = sl->str;
-		if (!vgid || !(vg_name = vgname_from_vgid(NULL, vgid)) || !*vg_name)
+		if (!vgid || !(vg_name = vgname_from_vgid(NULL, vgid))
+					|| is_orphan_vg(vg_name))
 			continue;
 		if (!strcmp(vg_name, vg_name_old)) {
 			if (match) {


