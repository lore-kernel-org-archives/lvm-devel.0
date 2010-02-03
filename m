From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 3 Feb 2010 14:08:42 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/cach ...
Message-ID: <20100203140842.4024.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-02-03 14:08:40

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c lvmcache.h 
	lib/metadata   : metadata-exported.h metadata.c 
	liblvm         : lvm_vg.c 
	tools          : toollib.c vgrename.c 

Log message:
	This is related to liblvm and its lvm_list_vg_names() and lvm_list_vg_uuids() functions
	where we should not expose internal VG names/uuids (the ones with "#" prefix )through the
	interface. Otherwise, we could end up with library users opening internal VGs which will
	initiate locking mechanism that won't be cleaned up properly.
	
	"#orphans_{lvm1, lvm2, pool}" names are treated in a special way, they are truncated first
	to "orphans" and this is used as a part of the lock name then (e.g. while calling lvm_vg_open()).
	When library user calls lvm_vg_close(), the original name "orphans_{lvm1, lvm2, pool}"
	is used directly and therefore no unlock occurs.
	
	We should exclude internal VG names and uuids in the lists provided by lvmcache:
	lvmcache_get_vgids() and lvmcache_get_vgnames().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1419&r2=1.1420
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.h.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.128&r2=1.129
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.312&r2=1.313
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.184&r2=1.185
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69

--- LVM2/WHATS_NEW	2010/02/03 03:58:08	1.1419
+++ LVM2/WHATS_NEW	2010/02/03 14:08:39	1.1420
@@ -1,5 +1,6 @@
 Version 2.02.61 - 
 ===================================
+  Exclude internal VG names and uuids in lists returned via liblvm interface.
   Add %ORIGIN support to lv{create,extend,reduce,resize} --extents option.
   Add copy constructor for metadata_area.
   Remove pointless versioned symlinks to dmeventd plugin libraries.
--- LVM2/lib/cache/lvmcache.c	2010/01/11 19:12:25	1.77
+++ LVM2/lib/cache/lvmcache.c	2010/02/03 14:08:39	1.78
@@ -623,7 +623,8 @@
 	return vg;
 }
 
-struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd, int full_scan)
+struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd, int full_scan,
+				    int include_internal)
 {
 	struct dm_list *vgids;
 	struct lvmcache_vginfo *vginfo;
@@ -636,6 +637,9 @@
 	}
 
 	dm_list_iterate_items(vginfo, &_vginfos) {
+		if (!include_internal && is_orphan_vg(vginfo->vgname))
+			continue;
+
 		if (!str_list_add(cmd->mem, vgids,
 				  dm_pool_strdup(cmd->mem, vginfo->vgid))) {
 			log_error("strlist allocation failed");
@@ -646,7 +650,8 @@
 	return vgids;
 }
 
-struct dm_list *lvmcache_get_vgnames(struct cmd_context *cmd, int full_scan)
+struct dm_list *lvmcache_get_vgnames(struct cmd_context *cmd, int full_scan,
+				      int include_internal)
 {
 	struct dm_list *vgnames;
 	struct lvmcache_vginfo *vginfo;
@@ -659,6 +664,9 @@
 	}
 
 	dm_list_iterate_items(vginfo, &_vginfos) {
+		if (!include_internal && is_orphan_vg(vginfo->vgname))
+			continue;
+
 		if (!str_list_add(cmd->mem, vgnames,
 				  dm_pool_strdup(cmd->mem, vginfo->vgname))) {
 			log_errno(ENOMEM, "strlist allocation failed");
--- LVM2/lib/cache/lvmcache.h	2010/01/05 16:06:43	1.26
+++ LVM2/lib/cache/lvmcache.h	2010/02/03 14:08:39	1.27
@@ -98,12 +98,16 @@
 int vgname_is_locked(const char *vgname);
 
 /* Returns list of struct str_lists containing pool-allocated copy of vgnames */
-/* Set full_scan to 1 to reread every filtered device label */
-struct dm_list *lvmcache_get_vgnames(struct cmd_context *cmd, int full_scan);
+/* Set full_scan to 1 to reread every filtered device label. If include_internal
+ * is not set, return only proper vg names. */
+struct dm_list *lvmcache_get_vgnames(struct cmd_context *cmd, int full_scan,
+				      int include_internal);
 
 /* Returns list of struct str_lists containing pool-allocated copy of vgids */
-/* Set full_scan to 1 to reread every filtered device label */
-struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd, int full_scan);
+/* Set full_scan to 1 to reread every filtered device label. If include_internal
+ * is not set, return only proper vg ids. */
+struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd, int full_scan,
+				    int include_internal);
 
 /* Returns list of struct str_lists containing pool-allocated copy of pvids */
 struct dm_list *lvmcache_get_pvids(struct cmd_context *cmd, const char *vgname,
--- LVM2/lib/metadata/metadata-exported.h	2010/01/13 01:56:18	1.128
+++ LVM2/lib/metadata/metadata-exported.h	2010/02/03 14:08:40	1.129
@@ -398,8 +398,10 @@
 void lv_set_hidden(struct logical_volume *lv);
 
 /* Set full_scan to 1 to re-read every (filtered) device label */
-struct dm_list *get_vgnames(struct cmd_context *cmd, int full_scan);
-struct dm_list *get_vgids(struct cmd_context *cmd, int full_scan);
+struct dm_list *get_vgnames(struct cmd_context *cmd, int full_scan,
+			     int include_internal);
+struct dm_list *get_vgids(struct cmd_context *cmd, int full_scan,
+			   int include_internal);
 int scan_vgs_for_pvs(struct cmd_context *cmd);
 
 int pv_write(struct cmd_context *cmd, struct physical_volume *pv,
--- LVM2/lib/metadata/metadata.c	2010/01/21 21:09:23	1.312
+++ LVM2/lib/metadata/metadata.c	2010/02/03 14:08:40	1.313
@@ -2911,14 +2911,14 @@
 	 *       allowed to do a full scan here any more. */
 
 	// The slow way - full scan required to cope with vgrename
-	if (!(vgnames = get_vgnames(cmd, 2))) {
+	if (!(vgnames = get_vgnames(cmd, 2, 0))) {
 		log_error("vg_read_by_vgid: get_vgnames failed");
 		goto out;
 	}
 
 	dm_list_iterate_items(strl, vgnames) {
 		vgname = strl->str;
-		if (!vgname || is_orphan_vg(vgname))
+		if (!vgname)
 			continue;	// FIXME Unnecessary?
 		consistent = 0;
 		if ((vg = _vg_read(cmd, vgname, vgid, &consistent,
@@ -3047,14 +3047,16 @@
 }
 
 /* May return empty list */
-struct dm_list *get_vgnames(struct cmd_context *cmd, int full_scan)
+struct dm_list *get_vgnames(struct cmd_context *cmd, int full_scan,
+			     int include_internal)
 {
-	return lvmcache_get_vgnames(cmd, full_scan);
+	return lvmcache_get_vgnames(cmd, full_scan, include_internal);
 }
 
-struct dm_list *get_vgids(struct cmd_context *cmd, int full_scan)
+struct dm_list *get_vgids(struct cmd_context *cmd, int full_scan,
+			   int include_internal)
 {
-	return lvmcache_get_vgids(cmd, full_scan);
+	return lvmcache_get_vgids(cmd, full_scan, include_internal);
 }
 
 static int _get_pvs(struct cmd_context *cmd, struct dm_list **pvslist)
@@ -3080,7 +3082,7 @@
 	}
 
 	/* Get list of VGs */
-	if (!(vgids = get_vgids(cmd, 0))) {
+	if (!(vgids = get_vgids(cmd, 0, 1))) {
 		log_error("get_pvs: get_vgids failed");
 		return 0;
 	}
--- LVM2/liblvm/lvm_vg.c	2009/11/01 19:51:55	1.33
+++ LVM2/liblvm/lvm_vg.c	2010/02/03 14:08:40	1.34
@@ -315,19 +315,14 @@
 	return name;
 }
 
-/*
- * FIXME: These functions currently return hidden VGs.  We should either filter
- * these out and not return them in the list, or export something like
- * is_orphan_vg and tell the caller to filter.
- */
 struct dm_list *lvm_list_vg_names(lvm_t libh)
 {
-	return get_vgnames((struct cmd_context *)libh, 0);
+	return get_vgnames((struct cmd_context *)libh, 0, 0);
 }
 
 struct dm_list *lvm_list_vg_uuids(lvm_t libh)
 {
-	return get_vgids((struct cmd_context *)libh, 0);
+	return get_vgids((struct cmd_context *)libh, 0, 0);
 }
 
 /*
--- LVM2/tools/toollib.c	2010/01/13 01:56:18	1.184
+++ LVM2/tools/toollib.c	2010/02/03 14:08:40	1.185
@@ -275,7 +275,7 @@
 
 	if (!argc || !dm_list_empty(&tags)) {
 		log_verbose("Finding all logical volumes");
-		if (!(vgnames = get_vgnames(cmd, 0)) || dm_list_empty(vgnames)) {
+		if (!(vgnames = get_vgnames(cmd, 0, 0)) || dm_list_empty(vgnames)) {
 			log_error("No volume groups found");
 			return ret_max;
 		}
@@ -284,8 +284,6 @@
 	vg = NULL;
 	dm_list_iterate_items(strl, vgnames) {
 		vgname = strl->str;
-		if (is_orphan_vg(vgname))
-			continue;	/* FIXME Unnecessary? */
 		vg = vg_read(cmd, vgname, NULL, flags);
 
 		if (vg_read_error(vg)) {
@@ -520,14 +518,13 @@
 
 	if (!argc || !dm_list_empty(&tags)) {
 		log_verbose("Finding all volume groups");
-		if (!(vgids = get_vgids(cmd, 0)) || dm_list_empty(vgids)) {
+		if (!(vgids = get_vgids(cmd, 0, 0)) || dm_list_empty(vgids)) {
 			log_error("No volume groups found");
 			return ret_max;
 		}
 		dm_list_iterate_items(sl, vgids) {
 			vgid = sl->str;
-			if (!vgid || !(vg_name = vgname_from_vgid(cmd->mem, vgid)) ||
-			    is_orphan_vg(vg_name))
+			if (!(vgid) || !(vg_name = vgname_from_vgid(cmd->mem, vgid)))
 				continue;
 			ret_max = _process_one_vg(cmd, vg_name, vgid, &tags,
 						  &arg_vgnames,
@@ -726,7 +723,7 @@
 			if (sigint_caught())
 				goto out;
 		}
-		if (!dm_list_empty(&tags) && (vgnames = get_vgnames(cmd, 0)) &&
+		if (!dm_list_empty(&tags) && (vgnames = get_vgnames(cmd, 0, 1)) &&
 			   !dm_list_empty(vgnames)) {
 			dm_list_iterate_items(sll, vgnames) {
 				vg = vg_read(cmd, sll->str, NULL, flags);
--- LVM2/tools/vgrename.c	2009/09/14 22:47:50	1.68
+++ LVM2/tools/vgrename.c	2010/02/03 14:08:40	1.69
@@ -87,15 +87,14 @@
 	log_verbose("Checking for existing volume group \"%s\"", vg_name_old);
 
 	/* Avoid duplicates */
-	if (!(vgids = get_vgids(cmd, 0)) || dm_list_empty(vgids)) {
+	if (!(vgids = get_vgids(cmd, 0, 0)) || dm_list_empty(vgids)) {
 		log_error("No complete volume groups found");
 		return 0;
 	}
 
 	dm_list_iterate_items(sl, vgids) {
 		vgid = sl->str;
-		if (!vgid || !(vg_name = vgname_from_vgid(NULL, vgid)) ||
-		    is_orphan_vg(vg_name))
+		if (!vgid || !(vg_name = vgname_from_vgid(NULL, vgid)))
 			continue;
 		if (!strcmp(vg_name, vg_name_old)) {
 			if (match) {


