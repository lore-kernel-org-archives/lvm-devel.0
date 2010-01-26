From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 26 Jan 2010 15:14:59 +0100
Subject: [PATCH] Add possibility to exclude internal VG names and uuids in lists returned from liblvm (and lvmcache)
Message-ID: <4B5EF8E3.5040401@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is related to liblvm and its lvm_list_vg_names() and lvm_list_vg_uuids() functions
where we should not expose internal VG names/uuids (the ones with "#" prefix )through the
interface. Otherwise, we could end up with library users opening internal VGs which will
initiate locking mechanism that won't be cleaned up properly.

"#orphans_{lvm1, lvm2, pool}" names are treated in a special way, they are truncated first
to "orphans" and this is used as a part of the lock name then (e.g. while calling lvm_vg_open()).
When library user calls lvm_vg_close(), the original name "orphans_{lvm1, lvm2, pool}"
is used directly and therefore no unlock occurs.

This simple patch adds possibility to exclude those internal VG names and ids in the
lists provided by lvmcache: lvmcache_get_vgids() and lvmcache_get_vgnames().

(The actual problem we can observe now occurs while using udisks-lvm-pv-export that is
called from udisks udev rule. This reserves the lock and prevents, for example, vgcreate
to succeed...)

Peter


diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index cce4013..35ee05b 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -623,7 +623,8 @@ struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 	return vg;
 }
 
-struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd, int full_scan)
+struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd, int full_scan,
+				    int include_internal)
 {
 	struct dm_list *vgids;
 	struct lvmcache_vginfo *vginfo;
@@ -636,6 +637,9 @@ struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd, int full_scan)
 	}
 
 	dm_list_iterate_items(vginfo, &_vginfos) {
+		if (!include_internal && is_orphan_vg(vginfo->vgname))
+			continue;
+
 		if (!str_list_add(cmd->mem, vgids,
 				  dm_pool_strdup(cmd->mem, vginfo->vgid))) {
 			log_error("strlist allocation failed");
@@ -646,7 +650,8 @@ struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd, int full_scan)
 	return vgids;
 }
 
-struct dm_list *lvmcache_get_vgnames(struct cmd_context *cmd, int full_scan)
+struct dm_list *lvmcache_get_vgnames(struct cmd_context *cmd, int full_scan,
+				      int include_internal)
 {
 	struct dm_list *vgnames;
 	struct lvmcache_vginfo *vginfo;
@@ -659,6 +664,9 @@ struct dm_list *lvmcache_get_vgnames(struct cmd_context *cmd, int full_scan)
 	}
 
 	dm_list_iterate_items(vginfo, &_vginfos) {
+		if (!include_internal && is_orphan_vg(vginfo->vgname))
+			continue;
+
 		if (!str_list_add(cmd->mem, vgnames,
 				  dm_pool_strdup(cmd->mem, vginfo->vgname))) {
 			log_errno(ENOMEM, "strlist allocation failed");
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index e2d749e..2c14b6c 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -98,12 +98,16 @@ int vgs_locked(void);
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
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 8342dc0..f8329d5 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -398,8 +398,10 @@ void lv_set_visible(struct logical_volume *lv);
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
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 449f49c..28c7c47 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2911,14 +2911,14 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
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
@@ -3047,14 +3047,16 @@ bad:
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
@@ -3080,7 +3082,7 @@ static int _get_pvs(struct cmd_context *cmd, struct dm_list **pvslist)
 	}
 
 	/* Get list of VGs */
-	if (!(vgids = get_vgids(cmd, 0))) {
+	if (!(vgids = get_vgids(cmd, 0, 1))) {
 		log_error("get_pvs: get_vgids failed");
 		return 0;
 	}
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index 4addc1c..9a5c239 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -315,19 +315,14 @@ char *lvm_vg_get_name(const vg_t vg)
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
diff --git a/tools/toollib.c b/tools/toollib.c
index 6c1a422..e4040f8 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -275,7 +275,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 
 	if (!argc || !dm_list_empty(&tags)) {
 		log_verbose("Finding all logical volumes");
-		if (!(vgnames = get_vgnames(cmd, 0)) || dm_list_empty(vgnames)) {
+		if (!(vgnames = get_vgnames(cmd, 0, 0)) || dm_list_empty(vgnames)) {
 			log_error("No volume groups found");
 			return ret_max;
 		}
@@ -284,8 +284,6 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 	vg = NULL;
 	dm_list_iterate_items(strl, vgnames) {
 		vgname = strl->str;
-		if (is_orphan_vg(vgname))
-			continue;	/* FIXME Unnecessary? */
 		vg = vg_read(cmd, vgname, NULL, flags);
 
 		if (vg_read_error(vg)) {
@@ -520,14 +518,13 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 
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
@@ -726,7 +723,7 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 			if (sigint_caught())
 				goto out;
 		}
-		if (!dm_list_empty(&tags) && (vgnames = get_vgnames(cmd, 0)) &&
+		if (!dm_list_empty(&tags) && (vgnames = get_vgnames(cmd, 0, 1)) &&
 			   !dm_list_empty(vgnames)) {
 			dm_list_iterate_items(sll, vgnames) {
 				vg = vg_read(cmd, sll->str, NULL, flags);
diff --git a/tools/vgrename.c b/tools/vgrename.c
index f1c4779..faf20bc 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -87,15 +87,14 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
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


