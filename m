From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Mar 2010 16:57:08 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/cach ...
Message-ID: <20100316165708.6987.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-03-16 16:57:05

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c lvmcache.h 
	lib/metadata   : metadata-exported.h metadata.c 
	liblvm         : lvm_vg.c 
	tools          : toollib.c vgrename.c 

Log message:
	Remove unnecessary full_scan parameter from get_vgids and get_vgnames calls.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1462&r2=1.1463
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.78&r2=1.79
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.h.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.135&r2=1.136
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.320&r2=1.321
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.186&r2=1.187
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.70&r2=1.71

--- LVM2/WHATS_NEW	2010/03/16 15:30:48	1.1462
+++ LVM2/WHATS_NEW	2010/03/16 16:57:03	1.1463
@@ -1,5 +1,6 @@
 Version 2.02.63 - 
 ================================
+  Remove unnecessary full_scan parameter from get_vgids and get_vgnames calls.
   Look up missing PVs by uuid not dev_name in _pvs_single to avoid invalid stat.
   Make find_pv_in_vg_by_uuid() return same type as related functions.
   Introduce is_missing_pv().
--- LVM2/lib/cache/lvmcache.c	2010/02/03 14:08:39	1.78
+++ LVM2/lib/cache/lvmcache.c	2010/03/16 16:57:04	1.79
@@ -623,13 +623,13 @@
 	return vg;
 }
 
-struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd, int full_scan,
-				    int include_internal)
+struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd,
+				   int include_internal)
 {
 	struct dm_list *vgids;
 	struct lvmcache_vginfo *vginfo;
 
-	lvmcache_label_scan(cmd, full_scan);
+	lvmcache_label_scan(cmd, 0);
 
 	if (!(vgids = str_list_create(cmd->mem))) {
 		log_error("vgids list allocation failed");
@@ -650,13 +650,13 @@
 	return vgids;
 }
 
-struct dm_list *lvmcache_get_vgnames(struct cmd_context *cmd, int full_scan,
-				      int include_internal)
+struct dm_list *lvmcache_get_vgnames(struct cmd_context *cmd,
+				     int include_internal)
 {
 	struct dm_list *vgnames;
 	struct lvmcache_vginfo *vginfo;
 
-	lvmcache_label_scan(cmd, full_scan);
+	lvmcache_label_scan(cmd, 0);
 
 	if (!(vgnames = str_list_create(cmd->mem))) {
 		log_errno(ENOMEM, "vgnames list allocation failed");
--- LVM2/lib/cache/lvmcache.h	2010/02/03 14:08:39	1.27
+++ LVM2/lib/cache/lvmcache.h	2010/03/16 16:57:04	1.28
@@ -98,16 +98,14 @@
 int vgname_is_locked(const char *vgname);
 
 /* Returns list of struct str_lists containing pool-allocated copy of vgnames */
-/* Set full_scan to 1 to reread every filtered device label. If include_internal
- * is not set, return only proper vg names. */
-struct dm_list *lvmcache_get_vgnames(struct cmd_context *cmd, int full_scan,
-				      int include_internal);
+/* If include_internal is not set, return only proper vg names. */
+struct dm_list *lvmcache_get_vgnames(struct cmd_context *cmd,
+				     int include_internal);
 
 /* Returns list of struct str_lists containing pool-allocated copy of vgids */
-/* Set full_scan to 1 to reread every filtered device label. If include_internal
- * is not set, return only proper vg ids. */
-struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd, int full_scan,
-				    int include_internal);
+/* If include_internal is not set, return only proper vg ids. */
+struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd,
+				   int include_internal);
 
 /* Returns list of struct str_lists containing pool-allocated copy of pvids */
 struct dm_list *lvmcache_get_pvids(struct cmd_context *cmd, const char *vgname,
--- LVM2/lib/metadata/metadata-exported.h	2010/03/16 15:30:49	1.135
+++ LVM2/lib/metadata/metadata-exported.h	2010/03/16 16:57:04	1.136
@@ -398,11 +398,8 @@
 void lv_set_visible(struct logical_volume *lv);
 void lv_set_hidden(struct logical_volume *lv);
 
-/* Set full_scan to 1 to re-read every (filtered) device label */
-struct dm_list *get_vgnames(struct cmd_context *cmd, int full_scan,
-			     int include_internal);
-struct dm_list *get_vgids(struct cmd_context *cmd, int full_scan,
-			   int include_internal);
+struct dm_list *get_vgnames(struct cmd_context *cmd, int include_internal);
+struct dm_list *get_vgids(struct cmd_context *cmd, int include_internal);
 int scan_vgs_for_pvs(struct cmd_context *cmd);
 
 int pv_write(struct cmd_context *cmd, struct physical_volume *pv,
--- LVM2/lib/metadata/metadata.c	2010/03/16 15:30:49	1.320
+++ LVM2/lib/metadata/metadata.c	2010/03/16 16:57:04	1.321
@@ -2967,7 +2967,8 @@
 	 *       allowed to do a full scan here any more. */
 
 	// The slow way - full scan required to cope with vgrename
-	if (!(vgnames = get_vgnames(cmd, 2, 0))) {
+	lvmcache_label_scan(cmd, 2);
+	if (!(vgnames = get_vgnames(cmd, 0))) {
 		log_error("vg_read_by_vgid: get_vgnames failed");
 		goto out;
 	}
@@ -3103,16 +3104,14 @@
 }
 
 /* May return empty list */
-struct dm_list *get_vgnames(struct cmd_context *cmd, int full_scan,
-			     int include_internal)
+struct dm_list *get_vgnames(struct cmd_context *cmd, int include_internal)
 {
-	return lvmcache_get_vgnames(cmd, full_scan, include_internal);
+	return lvmcache_get_vgnames(cmd, include_internal);
 }
 
-struct dm_list *get_vgids(struct cmd_context *cmd, int full_scan,
-			   int include_internal)
+struct dm_list *get_vgids(struct cmd_context *cmd, int include_internal)
 {
-	return lvmcache_get_vgids(cmd, full_scan, include_internal);
+	return lvmcache_get_vgids(cmd, include_internal);
 }
 
 static int _get_pvs(struct cmd_context *cmd, struct dm_list **pvslist)
@@ -3138,7 +3137,7 @@
 	}
 
 	/* Get list of VGs */
-	if (!(vgids = get_vgids(cmd, 0, 1))) {
+	if (!(vgids = get_vgids(cmd, 1))) {
 		log_error("get_pvs: get_vgids failed");
 		return 0;
 	}
--- LVM2/liblvm/lvm_vg.c	2010/02/24 18:16:18	1.37
+++ LVM2/liblvm/lvm_vg.c	2010/03/16 16:57:04	1.38
@@ -351,12 +351,12 @@
 
 struct dm_list *lvm_list_vg_names(lvm_t libh)
 {
-	return get_vgnames((struct cmd_context *)libh, 0, 0);
+	return get_vgnames((struct cmd_context *)libh, 0);
 }
 
 struct dm_list *lvm_list_vg_uuids(lvm_t libh)
 {
-	return get_vgids((struct cmd_context *)libh, 0, 0);
+	return get_vgids((struct cmd_context *)libh, 0);
 }
 
 /*
--- LVM2/tools/toollib.c	2010/03/16 14:37:39	1.186
+++ LVM2/tools/toollib.c	2010/03/16 16:57:05	1.187
@@ -275,7 +275,7 @@
 
 	if (!argc || !dm_list_empty(&tags)) {
 		log_verbose("Finding all logical volumes");
-		if (!(vgnames = get_vgnames(cmd, 0, 0)) || dm_list_empty(vgnames)) {
+		if (!(vgnames = get_vgnames(cmd, 0)) || dm_list_empty(vgnames)) {
 			log_error("No volume groups found");
 			return ret_max;
 		}
@@ -518,7 +518,7 @@
 
 	if (!argc || !dm_list_empty(&tags)) {
 		log_verbose("Finding all volume groups");
-		if (!(vgids = get_vgids(cmd, 0, 0)) || dm_list_empty(vgids)) {
+		if (!(vgids = get_vgids(cmd, 0)) || dm_list_empty(vgids)) {
 			log_error("No volume groups found");
 			return ret_max;
 		}
@@ -723,7 +723,7 @@
 			if (sigint_caught())
 				goto out;
 		}
-		if (!dm_list_empty(&tags) && (vgnames = get_vgnames(cmd, 0, 1)) &&
+		if (!dm_list_empty(&tags) && (vgnames = get_vgnames(cmd, 1)) &&
 			   !dm_list_empty(vgnames)) {
 			dm_list_iterate_items(sll, vgnames) {
 				vg = vg_read(cmd, sll->str, NULL, flags);
--- LVM2/tools/vgrename.c	2010/02/24 20:01:41	1.70
+++ LVM2/tools/vgrename.c	2010/03/16 16:57:05	1.71
@@ -87,7 +87,7 @@
 	log_verbose("Checking for existing volume group \"%s\"", vg_name_old);
 
 	/* Avoid duplicates */
-	if (!(vgids = get_vgids(cmd, 0, 0)) || dm_list_empty(vgids)) {
+	if (!(vgids = get_vgids(cmd, 0)) || dm_list_empty(vgids)) {
 		log_error("No complete volume groups found");
 		return 0;
 	}


