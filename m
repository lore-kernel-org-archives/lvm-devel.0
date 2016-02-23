From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Feb 2016 11:26:04 +0000 (UTC)
Subject: master - gcc: cleanup some sign warnings
Message-ID: <20160223112604.8CEA460D10@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dbc71dc05ef100a3907e6b47764b8eff71f1c7f3
Commit:        dbc71dc05ef100a3907e6b47764b8eff71f1c7f3
Parent:        293aabe4cd43a80fa94d7adb009fb8ab6c9d3641
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 23 12:18:48 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 12:25:25 2016 +0100

gcc: cleanup some sign warnings

When comparing unsigned with int, the comparision is made
as 'unsigned' type, so make it rather explicit which type
is being compared.
---
 daemons/cmirrord/cluster.c       |    2 +-
 daemons/lvmlockd/lvmlockd-core.c |    2 +-
 lib/activate/dev_manager.c       |    4 ++--
 lib/log/log.c                    |    2 +-
 lib/metadata/lv_manip.c          |    8 ++++----
 lib/metadata/metadata.c          |    6 +++---
 lib/metadata/raid_manip.c        |    2 +-
 lib/metadata/thin_manip.c        |    4 ++--
 lib/raid/raid.c                  |    2 +-
 libdm/mm/pool-fast.c             |    6 +++---
 tools/lvchange.c                 |    2 +-
 tools/lvconvert.c                |    2 +-
 12 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/daemons/cmirrord/cluster.c b/daemons/cmirrord/cluster.c
index 3b8fef3..e196eb2 100644
--- a/daemons/cmirrord/cluster.c
+++ b/daemons/cmirrord/cluster.c
@@ -1440,7 +1440,7 @@ static void cpg_leave_callback(struct clog_cpg *match,
 			free(rq);
 		}
 	}
-	for (i = 0, j = 0; i < match->checkpoints_needed; i++, j++) {
+	for (i = 0, j = 0; (int) i < match->checkpoints_needed; i++, j++) {
 		match->checkpoint_requesters[j] = match->checkpoint_requesters[i];
 		if (match->checkpoint_requesters[i] == left->nodeid) {
 			LOG_ERROR("[%s] Removing pending ckpt from needed list (%u is leaving)",
diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index c273d25..9283568 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -317,7 +317,7 @@ static void log_save_line(int len, char *line,
 	unsigned int w = *wrap;
 	int i;
 
-	if (len < LOG_DUMP_SIZE - p) {
+	if (len < (int) (LOG_DUMP_SIZE - p)) {
 		memcpy(log_buf + p, line, len);
 		p += len;
 
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index fbb0688..a1c9a23 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1847,14 +1847,14 @@ static int _pool_callback(struct dm_tree_node *node,
 				log_sys_error("close", argv[args]);
 			return 0;
 		}
-		for (ret = 0; ret < DM_ARRAY_SIZE(buf); ++ret)
+		for (ret = 0; ret < (int) DM_ARRAY_SIZE(buf); ++ret)
 			if (buf[ret])
 				break;
 
 		if (close(fd))
 			log_sys_error("close", argv[args]);
 
-		if (ret == DM_ARRAY_SIZE(buf)) {
+		if (ret == (int) DM_ARRAY_SIZE(buf)) {
 			log_debug("%s skipped, detect empty disk header on %s.",
 				  argv[0], argv[args]);
 			return 1;
diff --git a/lib/log/log.c b/lib/log/log.c
index 30c9c59..d939b9d 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -452,7 +452,7 @@ void print_log(int level, const char *file, int line, int dm_errno_or_class,
 			goto done;
 
 		bufused += n;
-		if (n >= sizeof(buf))
+		if (n >= (int) sizeof(buf))
 			bufused = sizeof(buf) - 1;
 	      done:
 		buf[bufused] = '\n';
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d99d347..64eb6b7 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6201,7 +6201,7 @@ int remove_layer_from_lv(struct logical_volume *lv,
 	struct lv_segment *parent_seg;
 	struct segment_type *segtype;
 	struct lv_names lv_names;
-	int r;
+	unsigned r;
 
 	log_very_verbose("Removing layer %s for %s", layer_lv->name, lv->name);
 
@@ -6277,7 +6277,7 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 	struct segment_type *segtype;
 	struct lv_segment *mapseg;
 	struct lv_names lv_names;
-	unsigned exclusive = 0;
+	unsigned exclusive = 0, i;
 
 	/* create an empty layer LV */
 	if (dm_snprintf(name, sizeof(name), "%s%s", lv_where->name, layer_suffix) < 0) {
@@ -6370,8 +6370,8 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 	 *   currently supported only for thin data layer
 	 *   FIXME: without strcmp it breaks mirrors....
 	 */
-	for (r = 0; r < DM_ARRAY_SIZE(_suffixes); ++r)
-		if (strcmp(layer_suffix, _suffixes[r]) == 0) {
+	for (i = 0; i < DM_ARRAY_SIZE(_suffixes); ++i)
+		if (strcmp(layer_suffix, _suffixes[i]) == 0) {
 			lv_names.old = lv_where->name;
 			lv_names.new = layer_lv->name;
 			if (!for_each_sub_lv(layer_lv, _rename_cb, (void *) &lv_names))
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 8478abb..a41c227 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2572,7 +2572,7 @@ static int _lv_validate_references_single(struct logical_volume *lv, void *data)
  */
 static int _validate_lock_args_chars(const char *lock_args)
 {
-	int i;
+	unsigned i;
 	char c;
 	int found_colon = 0;
 	int r = 1;
@@ -2581,13 +2581,13 @@ static int _validate_lock_args_chars(const char *lock_args)
 		c = lock_args[i];
 
 		if (!isalnum(c) && c != '.' && c != '_' && c != '-' && c != '+' && c != ':') {
-			log_error(INTERNAL_ERROR "Invalid character at index %d of lock_args \"%s\"",
+			log_error(INTERNAL_ERROR "Invalid character at index %u of lock_args \"%s\"",
 				  i, lock_args);
 			r = 0;
 		}
 
 		if (c == ':' && found_colon) {
-			log_error(INTERNAL_ERROR "Invalid colon at index %d of lock_args \"%s\"",
+			log_error(INTERNAL_ERROR "Invalid colon at index %u of lock_args \"%s\"",
 				  i, lock_args);
 			r = 0;
 		}
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 0fec123..e6684fc 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -864,7 +864,7 @@ static int _raid_extract_images(struct logical_volume *lv, uint32_t new_count,
 	log_verbose("Extracting %u %s from %s/%s", extract,
 		    (extract > 1) ? "images" : "image",
 		    lv->vg->name, lv->name);
-	if (dm_list_size(target_pvs) < extract) {
+	if ((int) dm_list_size(target_pvs) < extract) {
 		log_error("Unable to remove %d images:  Only %d device%s given.",
 			  extract, dm_list_size(target_pvs),
 			  (dm_list_size(target_pvs) == 1) ? "" : "s");
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index de3c7e8..aa5f388 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -320,9 +320,9 @@ int pool_check_overprovisioning(const struct logical_volume *lv)
 		 * for growing - threshold is 100% or percent is 0% */
 		sz = poolsum;
 	else
-		sz = ~0; /* No warning */
+		sz = UINT64_C(~0); /* No warning */
 
-	if (sz != ~0) {
+	if (sz != UINT64_C(~0)) {
 		log_warn("WARNING: Sum of all thin volume sizes (%s) exceeds the "
 			 "size of thin pool%s%s%s (%s)!",
 			 display_size(cmd, thinsum),
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 56eae1c..36f455d 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -121,7 +121,7 @@ static int _raid_text_import(struct lv_segment *seg,
 		{ "min_recovery_rate",	&seg->min_recovery_rate },
 		{ "max_recovery_rate",	&seg->max_recovery_rate },
 	}, *aip = raid_attr_import;
-	int i;
+	unsigned i;
 
 	for (i = 0; i < DM_ARRAY_SIZE(raid_attr_import); i++, aip++) {
 		if (dm_config_has_node(sn, aip->name)) {
diff --git a/libdm/mm/pool-fast.c b/libdm/mm/pool-fast.c
index e7fedfc..65ca856 100644
--- a/libdm/mm/pool-fast.c
+++ b/libdm/mm/pool-fast.c
@@ -100,7 +100,7 @@ void *dm_pool_alloc_aligned(struct dm_pool *p, size_t s, unsigned alignment)
 		_align_chunk(c, alignment);
 
 	/* have we got room ? */
-	if (!c || (c->begin > c->end) || (c->end - c->begin < s)) {
+	if (!c || (c->begin > c->end) || ((c->end - c->begin) < (int) s)) {
 		/* allocate new chunk */
 		size_t needed = s + alignment + sizeof(struct chunk);
 		c = _new_chunk(p, (needed > p->chunk_size) ?
@@ -177,7 +177,7 @@ int dm_pool_begin_object(struct dm_pool *p, size_t hint)
 	if (c)
 		_align_chunk(c, align);
 
-	if (!c || (c->begin > c->end) || (c->end - c->begin < hint)) {
+	if (!c || (c->begin > c->end) || ((c->end - c->begin) < (int) hint)) {
 		/* allocate a new chunk */
 		c = _new_chunk(p,
 			       hint > (p->chunk_size - sizeof(struct chunk)) ?
@@ -200,7 +200,7 @@ int dm_pool_grow_object(struct dm_pool *p, const void *extra, size_t delta)
 	if (!delta)
 		delta = strlen(extra);
 
-	if (c->end - (c->begin + p->object_len) < delta) {
+	if ((c->end - (c->begin + p->object_len)) < (int) delta) {
 		/* move into a new chunk */
 		if (p->object_len + delta > (p->chunk_size / 2))
 			nc = _new_chunk(p, (p->object_len + delta) * 2);
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 91c8728..316a786 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -789,7 +789,7 @@ static int _lvchange_writemostly(struct logical_volume *lv)
 				return 0;
 			}
 
-			for (s = 0; s < raid_seg->area_count; s++) {
+			for (s = 0; s < (int) raid_seg->area_count; s++) {
 				/*
 				 * We don't bother checking the metadata area,
 				 * since writemostly only affects the data areas.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 4e6d91b..e7394c0 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -90,7 +90,7 @@ struct convert_poll_id_list {
 
 static int _lvconvert_validate_names(struct lvconvert_params *lp)
 {
-	int i, j;
+	unsigned i, j;
 	const char *names[] = {
 		(lp->lv_name == lp->pool_data_name) ? NULL : lp->lv_name, "converted",
 		lp->pool_data_name, "pool",


