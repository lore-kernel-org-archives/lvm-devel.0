From: David Teigland <teigland@sourceware.org>
Date: Wed,  5 May 2021 19:00:57 +0000 (GMT)
Subject: main - devices file: recommend removing filter
Message-ID: <20210505190057.CD8923857429@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=71933d3496dfb21e1e39744d69f0372e202c1a1c
Commit:        71933d3496dfb21e1e39744d69f0372e202c1a1c
Parent:        2419345b9d407d8b07327d7484f765ee92be5994
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 5 13:59:42 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 5 13:59:42 2021 -0500

devices file: recommend removing filter

When the devices file is enabled and the filter is set,
recommand that the user remove the filter from lvm.conf
since it's ignored.
---
 lib/commands/toolcontext.c |  4 ++--
 lib/filters/filter-regex.c | 21 +++++++++++++++++++--
 lib/filters/filter.h       |  2 +-
 3 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 75634caff..296618686 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1106,7 +1106,7 @@ static struct dev_filter *_init_filter_chain(struct cmd_context *cmd)
 
 	/* global regex filter. Optional. */
 	if ((cn = find_config_tree_node(cmd, devices_global_filter_CFG, NULL))) {
-		if (!(filters[nr_filt] = regex_filter_create(cn->v))) {
+		if (!(filters[nr_filt] = regex_filter_create(cn->v, 0, 1))) {
 			log_error("Failed to create global regex device filter");
 			goto bad;
 		}
@@ -1115,7 +1115,7 @@ static struct dev_filter *_init_filter_chain(struct cmd_context *cmd)
 
 	/* regex filter. Optional. */
 	if ((cn = find_config_tree_node(cmd, devices_filter_CFG, NULL))) {
-		if (!(filters[nr_filt] = regex_filter_create(cn->v))) {
+		if (!(filters[nr_filt] = regex_filter_create(cn->v, 1, 0))) {
 			log_error("Failed to create regex device filter");
 			goto bad;
 		}
diff --git a/lib/filters/filter-regex.c b/lib/filters/filter-regex.c
index c6916983b..05c5b3f2d 100644
--- a/lib/filters/filter-regex.c
+++ b/lib/filters/filter-regex.c
@@ -21,6 +21,10 @@ struct rfilter {
 	struct dm_pool *mem;
 	dm_bitset_t accept;
 	struct dm_regex *engine;
+	unsigned config_filter:1;
+	unsigned config_global_filter:1;
+	unsigned warned_filter:1;
+	unsigned warned_global_filter:1;
 };
 
 static int _extract_pattern(struct dm_pool *mem, const char *pat,
@@ -157,8 +161,18 @@ static int _accept_p(struct cmd_context *cmd, struct dev_filter *f, struct devic
 	if (cmd->enable_devices_list)
 		return 1;
 
-	if (cmd->enable_devices_file && !cmd->filter_regex_with_devices_file)
+	if (cmd->enable_devices_file && !cmd->filter_regex_with_devices_file) {
+		/* can't warn in create_filter because enable_devices_file is set later */
+		if (rf->config_filter && !rf->warned_filter) {
+			log_warn("Please remove the lvm.conf filter, it is ignored with the devices file.");
+			rf->warned_filter = 1;
+		}
+		if (rf->config_global_filter && !rf->warned_global_filter) {
+			log_warn("Please remove the lvm.conf global_filter, it is ignored with the devices file.");
+			rf->warned_global_filter = 1;
+		}
 		return 1;
+	}
 
 	dm_list_iterate_items(sl, &dev->aliases) {
 		m = dm_regex_match(rf->engine, sl->str);
@@ -199,7 +213,7 @@ static void _regex_destroy(struct dev_filter *f)
 	dm_pool_destroy(rf->mem);
 }
 
-struct dev_filter *regex_filter_create(const struct dm_config_value *patterns)
+struct dev_filter *regex_filter_create(const struct dm_config_value *patterns, int config_filter, int config_global_filter)
 {
 	struct dm_pool *mem = dm_pool_create("filter regex", 10 * 1024);
 	struct rfilter *rf;
@@ -213,6 +227,9 @@ struct dev_filter *regex_filter_create(const struct dm_config_value *patterns)
 
 	rf->mem = mem;
 
+	rf->config_filter = config_filter;
+	rf->config_global_filter = config_global_filter;
+
 	if (!_build_matcher(rf, patterns))
 		goto_bad;
 
diff --git a/lib/filters/filter.h b/lib/filters/filter.h
index 40fbdeabb..f9de65273 100644
--- a/lib/filters/filter.h
+++ b/lib/filters/filter.h
@@ -44,7 +44,7 @@ void internal_filter_clear(void);
  * r|.*|             - reject everything else
  */
 
-struct dev_filter *regex_filter_create(const struct dm_config_value *patterns);
+struct dev_filter *regex_filter_create(const struct dm_config_value *patterns, int config_filter, int config_global_filter);
 
 typedef enum {
 	FILTER_MODE_NO_LVMETAD,


