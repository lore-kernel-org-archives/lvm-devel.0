From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Sep 2021 10:36:16 +0000 (GMT)
Subject: main - cov: add some initializers
Message-ID: <20210913103616.07C863858002@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=63930f576a29d701894586c6ef1f90bf63f321d1
Commit:        63930f576a29d701894586c6ef1f90bf63f321d1
Parent:        f5f1cdfa70ad2ec907fba8b9f5d0c1a251571c80
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 10 22:32:44 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 13 12:34:41 2021 +0200

cov: add some initializers

---
 daemons/cmirrord/cluster.c          | 2 +-
 daemons/cmirrord/functions.c        | 2 +-
 daemons/lvmlockd/lvmlockd-sanlock.c | 2 +-
 daemons/lvmpolld/lvmpolld-core.c    | 2 +-
 device_mapper/libdm-report.c        | 8 ++++----
 lib/device/dev-cache.c              | 2 +-
 lib/format_text/archive.c           | 2 +-
 lib/label/label.c                   | 2 +-
 lib/metadata/mirror.c               | 2 ++
 libdm/libdm-report.c                | 8 ++++----
 libdm/libdm-stats.c                 | 4 ++--
 tools/toollib.c                     | 2 +-
 12 files changed, 20 insertions(+), 18 deletions(-)

diff --git a/daemons/cmirrord/cluster.c b/daemons/cmirrord/cluster.c
index 23308e7a9..5de43c534 100644
--- a/daemons/cmirrord/cluster.c
+++ b/daemons/cmirrord/cluster.c
@@ -1383,7 +1383,7 @@ static void cpg_leave_callback(struct clog_cpg *match,
 			       size_t member_list_entries)
 {
 	unsigned i;
-	int j, fd;
+	int j, fd = -1;
 	uint32_t lowest = match->lowest_id;
 	struct clog_request *rq, *n;
 	struct checkpoint_data *p_cp, *c_cp;
diff --git a/daemons/cmirrord/functions.c b/daemons/cmirrord/functions.c
index 23a17015a..6c8c386a7 100644
--- a/daemons/cmirrord/functions.c
+++ b/daemons/cmirrord/functions.c
@@ -378,7 +378,7 @@ static int _clog_ctr(char *uuid, uint64_t luid,
 	uint32_t block_on_error = 0;
 
 	int disk_log;
-	char disk_path[PATH_MAX];
+	char disk_path[PATH_MAX] = { 0 };
 	int unlink_path = 0;
 	long page_size;
 	int pages;
diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index 13567cf95..e595eeffd 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -1660,7 +1660,7 @@ int lm_lock_sanlock(struct lockspace *ls, struct resource *r, int ld_mode,
 	struct sanlk_options opt;
 	uint64_t lock_lv_offset;
 	uint32_t flags = 0;
-	struct val_blk vb;
+	struct val_blk vb = { 0 };
 	int added = 0;
 	int rv;
 
diff --git a/daemons/lvmpolld/lvmpolld-core.c b/daemons/lvmpolld/lvmpolld-core.c
index ab8284145..47c9376b4 100644
--- a/daemons/lvmpolld/lvmpolld-core.c
+++ b/daemons/lvmpolld/lvmpolld-core.c
@@ -372,7 +372,7 @@ static void debug_print(struct lvmpolld_state *ls, const char * const* ptr)
 
 static void *fork_and_poll(void *args)
 {
-	int outfd, errfd, state;
+	int outfd, errfd, state = 0;
 	struct lvmpolld_thread_data *data;
 	pid_t r;
 
diff --git a/device_mapper/libdm-report.c b/device_mapper/libdm-report.c
index c6e7a2a03..13a8e46b1 100644
--- a/device_mapper/libdm-report.c
+++ b/device_mapper/libdm-report.c
@@ -2332,7 +2332,7 @@ static const char *_reserved_name(struct dm_report *rh,
 				  uint32_t field_num, const char *s, size_t len)
 {
 	dm_report_reserved_handler handler;
-	const char *canonical_name;
+	const char *canonical_name = NULL;
 	const char **name;
 	char *tmp_s;
 	char c;
@@ -3910,7 +3910,7 @@ static struct selection_node *_parse_ex(struct dm_report *rh,
 	static const char _pe_expected_msg[] = "Syntax error: right parenthesis expected at \'%s\'";
 	struct selection_node *sn = NULL;
 	uint32_t t;
-	const char *tmp;
+	const char *tmp = NULL;
 
 	t = _tok_op_log(s, next, SEL_MODIFIER_NOT | SEL_PRECEDENCE_PS);
 	if (t == SEL_MODIFIER_NOT) {
@@ -3956,7 +3956,7 @@ static struct selection_node *_parse_and_ex(struct dm_report *rh,
 					    struct selection_node *and_sn)
 {
 	struct selection_node *n;
-	const char *tmp;
+	const char *tmp = NULL;
 
 	n = _parse_ex(rh, s, next);
 	if (!n)
@@ -3988,7 +3988,7 @@ static struct selection_node *_parse_or_ex(struct dm_report *rh,
 					   struct selection_node *or_sn)
 {
 	struct selection_node *n;
-	const char *tmp;
+	const char *tmp = NULL;
 
 	n = _parse_and_ex(rh, s, next, NULL);
 	if (!n)
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index d9227dfd5..3918afba0 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -836,7 +836,7 @@ static void _collapse_slashes(char *str)
 static int _insert_dir(const char *dir)
 {
 	int n, dirent_count, r = 1;
-	struct dirent **dirent;
+	struct dirent **dirent = NULL;
 	char path[PATH_MAX];
 	size_t len;
 
diff --git a/lib/format_text/archive.c b/lib/format_text/archive.c
index e8c552a85..1528cb173 100644
--- a/lib/format_text/archive.c
+++ b/lib/format_text/archive.c
@@ -126,7 +126,7 @@ static struct dm_list *_scan_archive(struct dm_pool *mem,
 	int i, count;
 	uint32_t ix;
 	char vgname_found[64], *path;
-	struct dirent **dirent;
+	struct dirent **dirent = NULL;
 	struct archive_file *af;
 	struct dm_list *results;
 
diff --git a/lib/label/label.c b/lib/label/label.c
index aeee35259..4c243a43d 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -893,7 +893,7 @@ static int _setup_bcache(void)
 static void _prepare_open_file_limit(struct cmd_context *cmd, unsigned int num_devs)
 {
 #ifdef HAVE_PRLIMIT
-	struct rlimit old, new;
+	struct rlimit old = { 0 }, new;
 	unsigned int want = num_devs + BASE_FD_COUNT;
 	int rv;
 
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index c1934b5b7..050341a03 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -456,6 +456,7 @@ static int _merge_mirror_images(struct logical_volume *lv,
 		return 1;
 
 	img_lvs = alloca(sizeof(*img_lvs) * addition);
+	memset(img_lvs, 0, sizeof(*img_lvs) * addition);
 
 	dm_list_iterate_items(lvl, mimages)
 		img_lvs[i++] = lvl->lv;
@@ -1531,6 +1532,7 @@ static int _form_mirror(struct cmd_context *cmd, struct alloc_handle *ah,
 	 * create mirror image LVs
 	 */
 	img_lvs = alloca(sizeof(*img_lvs) * mirrors);
+	memset(img_lvs, 0, sizeof(*img_lvs) * mirrors);
 
 	if (!_create_mimage_lvs(ah, mirrors, stripes, stripe_size, lv, img_lvs, log))
 		return_0;
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 2efcc07c9..f3bf628a5 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -2331,7 +2331,7 @@ static const char *_reserved_name(struct dm_report *rh,
 				  uint32_t field_num, const char *s, size_t len)
 {
 	dm_report_reserved_handler handler;
-	const char *canonical_name;
+	const char *canonical_name = NULL;
 	const char **name;
 	char *tmp_s;
 	char c;
@@ -3909,7 +3909,7 @@ static struct selection_node *_parse_ex(struct dm_report *rh,
 	static const char _pe_expected_msg[] = "Syntax error: right parenthesis expected at \'%s\'";
 	struct selection_node *sn = NULL;
 	uint32_t t;
-	const char *tmp;
+	const char *tmp = NULL;
 
 	t = _tok_op_log(s, next, SEL_MODIFIER_NOT | SEL_PRECEDENCE_PS);
 	if (t == SEL_MODIFIER_NOT) {
@@ -3955,7 +3955,7 @@ static struct selection_node *_parse_and_ex(struct dm_report *rh,
 					    struct selection_node *and_sn)
 {
 	struct selection_node *n;
-	const char *tmp;
+	const char *tmp = NULL;
 
 	n = _parse_ex(rh, s, next);
 	if (!n)
@@ -3987,7 +3987,7 @@ static struct selection_node *_parse_or_ex(struct dm_report *rh,
 					   struct selection_node *or_sn)
 {
 	struct selection_node *n;
-	const char *tmp;
+	const char *tmp = NULL;
 
 	n = _parse_and_ex(rh, s, next, NULL);
 	if (!n)
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 120ad4d68..6cfa23384 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4519,7 +4519,7 @@ static int _stats_unmap_regions(struct dm_stats *dms, uint64_t group_id,
 	struct dm_stats_region *region = NULL;
 	struct dm_stats_group *group = NULL;
 	uint64_t nr_kept, nr_old;
-	struct _extent ext;
+	struct _extent ext = { 0 };
 	int64_t i;
 
 	group = &dms->groups[group_id];
@@ -4607,7 +4607,7 @@ static uint64_t *_stats_map_file_regions(struct dm_stats *dms, int fd,
 	struct dm_pool *extent_mem = NULL;
 	struct _extent *old_ext;
 	char *hist_arg = NULL;
-	struct statfs fsbuf;
+	struct statfs fsbuf = { 0 };
 	int64_t nr_kept = 0;
 	struct stat buf;
 	int update;
diff --git a/tools/toollib.c b/tools/toollib.c
index 3bb04f92c..562cad06a 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -123,7 +123,7 @@ const char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
 	size_t devdir_len = strlen(cmd->dev_dir);
 	const char *dmdir = dm_dir() + devdir_len;
 	size_t dmdir_len = strlen(dmdir), vglv_sz;
-	char *vgname, *lvname, *layer, *vglv;
+	char *vgname = NULL, *lvname, *layer, *vglv;
 
 	/* FIXME Do this properly */
 	if (*vg_name == '/')


