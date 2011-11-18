From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 18 Nov 2011 19:31:11 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/a ...
Message-ID: <20111118193111.19359.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-18 19:31:10

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c fs.c 
	lib/commands   : toolcontext.c 
	lib/format_text: format-text.c 
	lib/metadata   : metadata.c 

Log message:
	Replace dynamic buffer allocations for PATH_MAX
	
	Use static buffer instead of stack allocated buffer.
	This reduces stack size usage of lvm tool and the
	change is very simple.
	
	Since the whole library is not thread safe - it should not
	add any new problems - and if there will be some conversion
	it's easy to convert this to use some preallocated buffer.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2190&r2=1.2191
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.223&r2=1.224
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.140&r2=1.141
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.185&r2=1.186
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.473&r2=1.474

--- LVM2/WHATS_NEW	2011/11/18 19:28:00	1.2190
+++ LVM2/WHATS_NEW	2011/11/18 19:31:09	1.2191
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Reduce stack allocation of some PATH_MAX sized char buffers.
   Unlock memory before writing metadata.
   Add query before removing snapshots when inactive snapshot origin is removed.
   Allow changing availability state of snapshots.
--- LVM2/lib/activate/activate.c	2011/11/11 16:41:37	1.223
+++ LVM2/lib/activate/activate.c	2011/11/18 19:31:09	1.224
@@ -38,7 +38,7 @@
 
 int lvm1_present(struct cmd_context *cmd)
 {
-	char path[PATH_MAX];
+	static char path[PATH_MAX];
 
 	if (dm_snprintf(path, sizeof(path), "%s/lvm/global", cmd->proc_dir)
 	    < 0) {
@@ -294,7 +294,7 @@
 	const struct dm_config_node *cn;
 	const struct dm_config_value *cv;
 	const char *str;
-	char path[PATH_MAX];
+	static char path[PATH_MAX];
 
 	if (!(cn = find_config_tree_node(cmd, "activation/volume_list"))) {
 		log_verbose("activation/volume_list configuration setting "
--- LVM2/lib/activate/fs.c	2011/10/14 13:23:48	1.63
+++ LVM2/lib/activate/fs.c	2011/11/18 19:31:09	1.64
@@ -36,7 +36,7 @@
 
 static int _mk_dir(const char *dev_dir, const char *vg_name)
 {
-	char vg_path[PATH_MAX];
+	static char vg_path[PATH_MAX];
 	mode_t old_umask;
 
 	if (dm_snprintf(vg_path, sizeof(vg_path), "%s%s",
@@ -67,7 +67,7 @@
 
 static int _rm_dir(const char *dev_dir, const char *vg_name)
 {
-	char vg_path[PATH_MAX];
+	static char vg_path[PATH_MAX];
 
 	if (dm_snprintf(vg_path, sizeof(vg_path), "%s%s",
 			 dev_dir, vg_name) == -1) {
@@ -87,7 +87,7 @@
 static void _rm_blks(const char *dir)
 {
 	const char *name;
-	char path[PATH_MAX];
+	static char path[PATH_MAX];
 	struct dirent *dirent;
 	struct stat buf;
 	DIR *d;
@@ -124,8 +124,8 @@
 static int _mk_link(const char *dev_dir, const char *vg_name,
 		    const char *lv_name, const char *dev, int check_udev)
 {
-	char lv_path[PATH_MAX], link_path[PATH_MAX], lvm1_group_path[PATH_MAX];
-	char vg_path[PATH_MAX];
+	static char lv_path[PATH_MAX], link_path[PATH_MAX], lvm1_group_path[PATH_MAX];
+	static char vg_path[PATH_MAX];
 	struct stat buf, buf_lp;
 
 	if (dm_snprintf(vg_path, sizeof(vg_path), "%s%s",
@@ -226,7 +226,7 @@
 		    const char *lv_name, int check_udev)
 {
 	struct stat buf;
-	char lv_path[PATH_MAX];
+	static char lv_path[PATH_MAX];
 
 	if (dm_snprintf(lv_path, sizeof(lv_path), "%s%s/%s",
 			 dev_dir, vg_name, lv_name) == -1) {
--- LVM2/lib/commands/toolcontext.c	2011/11/11 15:11:11	1.140
+++ LVM2/lib/commands/toolcontext.c	2011/11/18 19:31:09	1.141
@@ -477,7 +477,7 @@
 
 static int _load_config_file(struct cmd_context *cmd, const char *tag)
 {
-	char config_file[PATH_MAX] = "";
+	static char config_file[PATH_MAX] = "";
 	const char *filler = "";
 	struct stat info;
 	struct config_tree_list *cfl;
@@ -786,10 +786,10 @@
 
 static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache)
 {
+	static char cache_file[PATH_MAX];
 	const char *dev_cache = NULL, *cache_dir, *cache_file_prefix;
 	struct dev_filter *f3, *f4;
 	struct stat st;
-	char cache_file[PATH_MAX];
 
 	cmd->dump_filter = 0;
 
@@ -1138,8 +1138,8 @@
 
 static int _init_backup(struct cmd_context *cmd)
 {
+	static char default_dir[PATH_MAX];
 	uint32_t days, min;
-	char default_dir[PATH_MAX];
 	const char *dir;
 
 	if (!cmd->system_dir[0]) {
--- LVM2/lib/format_text/format-text.c	2011/08/30 14:55:17	1.185
+++ LVM2/lib/format_text/format-text.c	2011/11/18 19:31:10	1.186
@@ -1791,6 +1791,7 @@
 static int _create_vg_text_instance(struct format_instance *fid,
                                     const struct format_instance_ctx *fic)
 {
+	static char path[PATH_MAX];
 	uint32_t type = fic->type;
 	struct text_fid_context *fidtc;
 	struct metadata_area *mda;
@@ -1798,7 +1799,6 @@
 	struct dir_list *dl;
 	struct raw_list *rl;
 	struct dm_list *dir_list, *raw_list;
-	char path[PATH_MAX];
 	struct text_context tc;
 	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_info *info;
--- LVM2/lib/metadata/metadata.c	2011/11/18 19:28:01	1.473
+++ LVM2/lib/metadata/metadata.c	2011/11/18 19:31:10	1.474
@@ -452,12 +452,12 @@
 
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
@@ -4201,7 +4201,7 @@
 int fid_add_mda(struct format_instance *fid, struct metadata_area *mda,
 		 const char *key, size_t key_len, const unsigned sub_key)
 {
-	char full_key[PATH_MAX];
+	static char full_key[PATH_MAX];
 	dm_list_add(mda_is_ignored(mda) ? &fid->metadata_areas_ignored :
 					  &fid->metadata_areas_in_use, &mda->list);
 
@@ -4212,7 +4212,7 @@
 	/* Add metadata area to index. */
 	if (fid->type & FMT_INSTANCE_VG) {
 		if (!_convert_key_to_string(key, key_len, sub_key,
-					    full_key, PATH_MAX))
+					    full_key, sizeof(full_key)))
 		return_0;
 
 		dm_hash_insert(fid->metadata_areas_index.hash,
@@ -4246,13 +4246,13 @@
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
@@ -4266,8 +4266,8 @@
 int fid_remove_mda(struct format_instance *fid, struct metadata_area *mda,
 		   const char *key, size_t key_len, const unsigned sub_key)
 {
+	static char full_key[PATH_MAX];
 	struct metadata_area *mda_indexed = NULL;
-	char full_key[PATH_MAX];
 
 	/* At least one of mda or key must be specified. */
 	if (!mda && !key)
@@ -4287,7 +4287,7 @@
 
 		if (fid->type & FMT_INSTANCE_VG) {
 			if (!_convert_key_to_string(key, key_len, sub_key,
-					    full_key, PATH_MAX))
+					    full_key, sizeof(full_key)))
 				return_0;
 
 			dm_hash_remove(fid->metadata_areas_index.hash, full_key);


