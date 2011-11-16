From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 16 Nov 2011 14:22:54 +0100
Subject: [PATCH 07/12] Replace dynamic buffer allocations for PATH_MAX
In-Reply-To: <cover.1321449480.git.zkabelac@redhat.com>
References: <cover.1321449480.git.zkabelac@redhat.com>
Message-ID: <2227cbf65a362a5a4b8740768d808d49bc0e14a1.1321449480.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use static buffer instead of stack allocated buffer.
This reduces stack size usage of lvm tool and the
change is very simple.

Since the whole library is not thread safe - it should not
add any extra problems - and if there will be some convertion
it's easy to convert this to use some preallocated buffer.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/activate.c       |    4 ++--
 lib/activate/fs.c             |   12 ++++++------
 lib/commands/toolcontext.c    |    6 +++---
 lib/format_text/format-text.c |    2 +-
 lib/metadata/metadata.c       |   16 ++++++++--------
 5 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 0541c55..c0e8bea 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -38,7 +38,7 @@
 
 int lvm1_present(struct cmd_context *cmd)
 {
-	char path[PATH_MAX];
+	static char path[PATH_MAX];
 
 	if (dm_snprintf(path, sizeof(path), "%s/lvm/global", cmd->proc_dir)
 	    < 0) {
@@ -294,7 +294,7 @@ static int _passes_activation_filter(struct cmd_context *cmd,
 	const struct dm_config_node *cn;
 	const struct dm_config_value *cv;
 	const char *str;
-	char path[PATH_MAX];
+	static char path[PATH_MAX];
 
 	if (!(cn = find_config_tree_node(cmd, "activation/volume_list"))) {
 		log_verbose("activation/volume_list configuration setting "
diff --git a/lib/activate/fs.c b/lib/activate/fs.c
index f9eb280..2edd81e 100644
--- a/lib/activate/fs.c
+++ b/lib/activate/fs.c
@@ -36,7 +36,7 @@ static int _fs_create = 0;
 
 static int _mk_dir(const char *dev_dir, const char *vg_name)
 {
-	char vg_path[PATH_MAX];
+	static char vg_path[PATH_MAX];
 	mode_t old_umask;
 
 	if (dm_snprintf(vg_path, sizeof(vg_path), "%s%s",
@@ -67,7 +67,7 @@ static int _mk_dir(const char *dev_dir, const char *vg_name)
 
 static int _rm_dir(const char *dev_dir, const char *vg_name)
 {
-	char vg_path[PATH_MAX];
+	static char vg_path[PATH_MAX];
 
 	if (dm_snprintf(vg_path, sizeof(vg_path), "%s%s",
 			 dev_dir, vg_name) == -1) {
@@ -87,7 +87,7 @@ static int _rm_dir(const char *dev_dir, const char *vg_name)
 static void _rm_blks(const char *dir)
 {
 	const char *name;
-	char path[PATH_MAX];
+	static char path[PATH_MAX];
 	struct dirent *dirent;
 	struct stat buf;
 	DIR *d;
@@ -124,8 +124,8 @@ static void _rm_blks(const char *dir)
 static int _mk_link(const char *dev_dir, const char *vg_name,
 		    const char *lv_name, const char *dev, int check_udev)
 {
-	char lv_path[PATH_MAX], link_path[PATH_MAX], lvm1_group_path[PATH_MAX];
-	char vg_path[PATH_MAX];
+	static char lv_path[PATH_MAX], link_path[PATH_MAX], lvm1_group_path[PATH_MAX];
+	static char vg_path[PATH_MAX];
 	struct stat buf, buf_lp;
 
 	if (dm_snprintf(vg_path, sizeof(vg_path), "%s%s",
@@ -226,7 +226,7 @@ static int _rm_link(const char *dev_dir, const char *vg_name,
 		    const char *lv_name, int check_udev)
 {
 	struct stat buf;
-	char lv_path[PATH_MAX];
+	static char lv_path[PATH_MAX];
 
 	if (dm_snprintf(lv_path, sizeof(lv_path), "%s%s/%s",
 			 dev_dir, vg_name, lv_name) == -1) {
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index ec6e400..8b6ad3b 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -477,7 +477,7 @@ static int _init_tags(struct cmd_context *cmd, struct dm_config_tree *cft)
 
 static int _load_config_file(struct cmd_context *cmd, const char *tag)
 {
-	char config_file[PATH_MAX] = "";
+	static char config_file[PATH_MAX] = "";
 	const char *filler = "";
 	struct stat info;
 	struct config_tree_list *cfl;
@@ -786,10 +786,10 @@ err:
 
 static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache)
 {
+	static char cache_file[PATH_MAX];
 	const char *dev_cache = NULL, *cache_dir, *cache_file_prefix;
 	struct dev_filter *f3, *f4;
 	struct stat st;
-	char cache_file[PATH_MAX];
 
 	cmd->dump_filter = 0;
 
@@ -1138,8 +1138,8 @@ static int _init_hostname(struct cmd_context *cmd)
 
 static int _init_backup(struct cmd_context *cmd)
 {
+	static char default_dir[PATH_MAX];
 	uint32_t days, min;
-	char default_dir[PATH_MAX];
 	const char *dir;
 
 	if (!cmd->system_dir[0]) {
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 5e1db36..df3c870 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1791,6 +1791,7 @@ static void *_create_text_context(struct dm_pool *mem, struct text_context *tc)
 static int _create_vg_text_instance(struct format_instance *fid,
                                     const struct format_instance_ctx *fic)
 {
+	static char path[PATH_MAX];
 	uint32_t type = fic->type;
 	struct text_fid_context *fidtc;
 	struct metadata_area *mda;
@@ -1798,7 +1799,6 @@ static int _create_vg_text_instance(struct format_instance *fid,
 	struct dir_list *dl;
 	struct raw_list *rl;
 	struct dm_list *dir_list, *raw_list;
-	char path[PATH_MAX];
 	struct text_context tc;
 	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_info *info;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index f9742e7..500732d 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -452,12 +452,12 @@ int move_pvs_used_by_lv(struct volume_group *vg_from,
 
 static int validate_new_vg_name(struct cmd_context *cmd, const char *vg_name)
 {
-	char vg_path[PATH_MAX];
+	static char vg_path[PATH_MAX];
 
 	if (!validate_name(vg_name))
 		return_0;
 
-	snprintf(vg_path, PATH_MAX, "%s%s", cmd->dev_dir, vg_name);
+	snprintf(vg_path, sizeof(vg_path), "%s%s", cmd->dev_dir, vg_name);
 	if (path_exists(vg_path)) {
 		log_error("%s: already exists in filesystem", vg_path);
 		return 0;
@@ -4197,7 +4197,7 @@ static int _convert_key_to_string(const char *key, size_t key_len,
 int fid_add_mda(struct format_instance *fid, struct metadata_area *mda,
 		 const char *key, size_t key_len, const unsigned sub_key)
 {
-	char full_key[PATH_MAX];
+	static char full_key[PATH_MAX];
 	dm_list_add(mda_is_ignored(mda) ? &fid->metadata_areas_ignored :
 					  &fid->metadata_areas_in_use, &mda->list);
 
@@ -4208,7 +4208,7 @@ int fid_add_mda(struct format_instance *fid, struct metadata_area *mda,
 	/* Add metadata area to index. */
 	if (fid->type & FMT_INSTANCE_VG) {
 		if (!_convert_key_to_string(key, key_len, sub_key,
-					    full_key, PATH_MAX))
+					    full_key, sizeof(full_key)))
 		return_0;
 
 		dm_hash_insert(fid->metadata_areas_index.hash,
@@ -4242,13 +4242,13 @@ struct metadata_area *fid_get_mda_indexed(struct format_instance *fid,
 					  const char *key, size_t key_len,
 					  const unsigned sub_key)
 {
-	char full_key[PATH_MAX];
+	static char full_key[PATH_MAX];
 	struct metadata_area *mda = NULL;
 
 
 	if (fid->type & FMT_INSTANCE_VG) {
 		if (!_convert_key_to_string(key, key_len, sub_key,
-					    full_key, PATH_MAX))
+					    full_key, sizeof(full_key)))
 			return_NULL;
 		mda = (struct metadata_area *) dm_hash_lookup(fid->metadata_areas_index.hash,
 							      full_key);
@@ -4262,8 +4262,8 @@ struct metadata_area *fid_get_mda_indexed(struct format_instance *fid,
 int fid_remove_mda(struct format_instance *fid, struct metadata_area *mda,
 		   const char *key, size_t key_len, const unsigned sub_key)
 {
+	static char full_key[PATH_MAX];
 	struct metadata_area *mda_indexed = NULL;
-	char full_key[PATH_MAX];
 
 	/* At least one of mda or key must be specified. */
 	if (!mda && !key)
@@ -4283,7 +4283,7 @@ int fid_remove_mda(struct format_instance *fid, struct metadata_area *mda,
 
 		if (fid->type & FMT_INSTANCE_VG) {
 			if (!_convert_key_to_string(key, key_len, sub_key,
-					    full_key, PATH_MAX))
+					    full_key, sizeof(full_key)))
 				return_0;
 
 			dm_hash_remove(fid->metadata_areas_index.hash, full_key);
-- 
1.7.7.3


