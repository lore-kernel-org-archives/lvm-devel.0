From: Milan Broz <mbroz@redhat.com>
Date: Mon, 15 Mar 2010 19:37:43 +0100
Subject: [PATCH 2/2] [RFC] Remove full_scan paramaters from get_vgids and get_vgnames.
In-Reply-To: <1268678263-18037-1-git-send-email-mbroz@redhat.com>
References: <1268678263-18037-1-git-send-email-mbroz@redhat.com>
Message-ID: <1268678263-18037-2-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

There is only one place where it is used, replace
for now with lvmcache_label_scan(cmd, 2).

(The intention is to keep full rescan handling internal
to lvmcache, so code give only hints whre is rescan really needed,
see previous patch)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/cache/lvmcache.c             |    8 ++++----
 lib/cache/lvmcache.h             |   10 ++++------
 lib/metadata/metadata-exported.h |    5 ++---
 lib/metadata/metadata.c          |   13 +++++++------
 liblvm/lvm_vg.c                  |    4 ++--
 tools/toollib.c                  |    6 +++---
 tools/vgrename.c                 |    2 +-
 7 files changed, 23 insertions(+), 25 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 29fd1df..c80ba6e 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -635,13 +635,13 @@ struct volume_group *lvmcache_get_vg(const char *vgid, unsigned precommitted)
 	return vg;
 }
 
-struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd, int full_scan,
+struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd,
 				    int include_internal)
 {
 	struct dm_list *vgids;
 	struct lvmcache_vginfo *vginfo;
 
-	lvmcache_label_scan(cmd, full_scan);
+	lvmcache_label_scan(cmd, 0);
 
 	if (!(vgids = str_list_create(cmd->mem))) {
 		log_error("vgids list allocation failed");
@@ -662,13 +662,13 @@ struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd, int full_scan,
 	return vgids;
 }
 
-struct dm_list *lvmcache_get_vgnames(struct cmd_context *cmd, int full_scan,
+struct dm_list *lvmcache_get_vgnames(struct cmd_context *cmd,
 				      int include_internal)
 {
 	struct dm_list *vgnames;
 	struct lvmcache_vginfo *vginfo;
 
-	lvmcache_label_scan(cmd, full_scan);
+	lvmcache_label_scan(cmd, 0);
 
 	if (!(vgnames = str_list_create(cmd->mem))) {
 		log_errno(ENOMEM, "vgnames list allocation failed");
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index d37bff2..e604bad 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -101,15 +101,13 @@ int vgs_locked(void);
 int vgname_is_locked(const char *vgname);
 
 /* Returns list of struct str_lists containing pool-allocated copy of vgnames */
-/* Set full_scan to 1 to reread every filtered device label. If include_internal
- * is not set, return only proper vg names. */
-struct dm_list *lvmcache_get_vgnames(struct cmd_context *cmd, int full_scan,
+/* If include_internal is not set, return only proper vg names. */
+struct dm_list *lvmcache_get_vgnames(struct cmd_context *cmd,
 				      int include_internal);
 
 /* Returns list of struct str_lists containing pool-allocated copy of vgids */
-/* Set full_scan to 1 to reread every filtered device label. If include_internal
- * is not set, return only proper vg ids. */
-struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd, int full_scan,
+/* If include_internal is not set, return only proper vg ids. */
+struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd,
 				    int include_internal);
 
 /* Returns list of struct str_lists containing pool-allocated copy of pvids */
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 9540285..13aeb41 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -398,10 +398,9 @@ int unlink_lv_from_vg(struct logical_volume *lv);
 void lv_set_visible(struct logical_volume *lv);
 void lv_set_hidden(struct logical_volume *lv);
 
-/* Set full_scan to 1 to re-read every (filtered) device label */
-struct dm_list *get_vgnames(struct cmd_context *cmd, int full_scan,
+struct dm_list *get_vgnames(struct cmd_context *cmd,
 			     int include_internal);
-struct dm_list *get_vgids(struct cmd_context *cmd, int full_scan,
+struct dm_list *get_vgids(struct cmd_context *cmd,
 			   int include_internal);
 int scan_vgs_for_pvs(struct cmd_context *cmd);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index f079554..713f7e2 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2963,7 +2963,8 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 	 *       allowed to do a full scan here any more. */
 
 	// The slow way - full scan required to cope with vgrename
-	if (!(vgnames = get_vgnames(cmd, 2, 0))) {
+	lvmcache_label_scan(cmd, 2);
+	if (!(vgnames = get_vgnames(cmd, 0))) {
 		log_error("vg_read_by_vgid: get_vgnames failed");
 		goto out;
 	}
@@ -3099,16 +3100,16 @@ bad:
 }
 
 /* May return empty list */
-struct dm_list *get_vgnames(struct cmd_context *cmd, int full_scan,
+struct dm_list *get_vgnames(struct cmd_context *cmd,
 			     int include_internal)
 {
-	return lvmcache_get_vgnames(cmd, full_scan, include_internal);
+	return lvmcache_get_vgnames(cmd, include_internal);
 }
 
-struct dm_list *get_vgids(struct cmd_context *cmd, int full_scan,
+struct dm_list *get_vgids(struct cmd_context *cmd,
 			   int include_internal)
 {
-	return lvmcache_get_vgids(cmd, full_scan, include_internal);
+	return lvmcache_get_vgids(cmd, include_internal);
 }
 
 static int _get_pvs(struct cmd_context *cmd, struct dm_list **pvslist)
@@ -3134,7 +3135,7 @@ static int _get_pvs(struct cmd_context *cmd, struct dm_list **pvslist)
 	}
 
 	/* Get list of VGs */
-	if (!(vgids = get_vgids(cmd, 0, 1))) {
+	if (!(vgids = get_vgids(cmd, 1))) {
 		log_error("get_pvs: get_vgids failed");
 		return 0;
 	}
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index ec829e8..334e906 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -351,12 +351,12 @@ char *lvm_vg_get_name(const vg_t vg)
 
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
diff --git a/tools/toollib.c b/tools/toollib.c
index e4040f8..8d16013 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -275,7 +275,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 
 	if (!argc || !dm_list_empty(&tags)) {
 		log_verbose("Finding all logical volumes");
-		if (!(vgnames = get_vgnames(cmd, 0, 0)) || dm_list_empty(vgnames)) {
+		if (!(vgnames = get_vgnames(cmd, 0)) || dm_list_empty(vgnames)) {
 			log_error("No volume groups found");
 			return ret_max;
 		}
@@ -518,7 +518,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 
 	if (!argc || !dm_list_empty(&tags)) {
 		log_verbose("Finding all volume groups");
-		if (!(vgids = get_vgids(cmd, 0, 0)) || dm_list_empty(vgids)) {
+		if (!(vgids = get_vgids(cmd, 0)) || dm_list_empty(vgids)) {
 			log_error("No volume groups found");
 			return ret_max;
 		}
@@ -723,7 +723,7 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 			if (sigint_caught())
 				goto out;
 		}
-		if (!dm_list_empty(&tags) && (vgnames = get_vgnames(cmd, 0, 1)) &&
+		if (!dm_list_empty(&tags) && (vgnames = get_vgnames(cmd, 1)) &&
 			   !dm_list_empty(vgnames)) {
 			dm_list_iterate_items(sll, vgnames) {
 				vg = vg_read(cmd, sll->str, NULL, flags);
diff --git a/tools/vgrename.c b/tools/vgrename.c
index a63a626..799dcb2 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -87,7 +87,7 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 	log_verbose("Checking for existing volume group \"%s\"", vg_name_old);
 
 	/* Avoid duplicates */
-	if (!(vgids = get_vgids(cmd, 0, 0)) || dm_list_empty(vgids)) {
+	if (!(vgids = get_vgids(cmd, 0)) || dm_list_empty(vgids)) {
 		log_error("No complete volume groups found");
 		return 0;
 	}
-- 
1.7.0


