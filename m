From: David Teigland <teigland@sourceware.org>
Date: Fri,  9 Dec 2022 14:51:43 +0000 (GMT)
Subject: main - writecache: support settings metadata_only and pause_writeback
Message-ID: <20221209145143.0E7E2383814D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fa7fe5cbbe927d13a8b93aba24640ce5d8c11896
Commit:        fa7fe5cbbe927d13a8b93aba24640ce5d8c11896
Parent:        9ce55a43d0165da9827e7b8e75bf25583a571e89
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Dec 8 16:42:04 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Dec 8 16:53:36 2022 -0600

writecache: support settings metadata_only and pause_writeback

Two new settings for tuning dm-writecache.
---
 device_mapper/all.h             |  6 +++++-
 device_mapper/libdm-deptree.c   | 12 ++++++++++++
 lib/metadata/writecache_manip.c |  8 ++++++++
 lib/writecache/writecache.c     | 20 ++++++++++++++++++++
 man/lvmcache.7_main             | 15 +++++++++++++++
 tools/lvchange.c                | 10 ++++++++++
 tools/toollib.c                 | 14 ++++++++++++++
 7 files changed, 84 insertions(+), 1 deletion(-)

diff --git a/device_mapper/all.h b/device_mapper/all.h
index b70a8f29c..1e19add68 100644
--- a/device_mapper/all.h
+++ b/device_mapper/all.h
@@ -982,7 +982,9 @@ struct writecache_settings {
 	uint32_t fua;
 	uint32_t nofua;
 	uint32_t cleaner;
-	uint32_t max_age;
+	uint32_t max_age;         /* in milliseconds */
+	uint32_t metadata_only;
+	uint32_t pause_writeback; /* in milliseconds */
 
 	/*
 	 * Allow an unrecognized key and its val to be passed to the kernel for
@@ -1004,6 +1006,8 @@ struct writecache_settings {
 	unsigned nofua_set:1;
 	unsigned cleaner_set:1;
 	unsigned max_age_set:1;
+	unsigned metadata_only_set:1;
+	unsigned pause_writeback_set:1;
 };
 
 int dm_tree_node_add_writecache_target(struct dm_tree_node *node,
diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index 39af7b1d4..c6cc8de56 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -2679,6 +2679,10 @@ static int _writecache_emit_segment_line(struct dm_task *dmt,
 		count += 1;
 	if (seg->writecache_settings.max_age_set)
 		count += 2;
+	if (seg->writecache_settings.metadata_only_set)
+		count += 1;
+	if (seg->writecache_settings.pause_writeback_set)
+		count += 2;
 	if (seg->writecache_settings.new_key)
 		count += 2;
 
@@ -2730,6 +2734,14 @@ static int _writecache_emit_segment_line(struct dm_task *dmt,
 		EMIT_PARAMS(pos, " max_age %u", seg->writecache_settings.max_age);
 	}
 
+	if (seg->writecache_settings.metadata_only_set) {
+		EMIT_PARAMS(pos, " metadata_only");
+	}
+
+	if (seg->writecache_settings.pause_writeback_set) {
+		EMIT_PARAMS(pos, " pause_writeback %u", seg->writecache_settings.pause_writeback);
+	}
+
 	if (seg->writecache_settings.new_key) {
 		EMIT_PARAMS(pos, " %s %s",
 			seg->writecache_settings.new_key,
diff --git a/lib/metadata/writecache_manip.c b/lib/metadata/writecache_manip.c
index 8150d0781..21b7940fb 100644
--- a/lib/metadata/writecache_manip.c
+++ b/lib/metadata/writecache_manip.c
@@ -518,6 +518,14 @@ int writecache_settings_to_str_list(struct writecache_settings *settings, struct
 		if (!_writecache_setting_str_list_add("max_age", (uint64_t)settings->max_age, NULL, result, mem))
 			errors++;
 
+	if (settings->metadata_only_set)
+		if (!_writecache_setting_str_list_add("metadata_only", (uint64_t)settings->metadata_only, NULL, result, mem))
+			errors++;
+
+	if (settings->pause_writeback_set)
+		if (!_writecache_setting_str_list_add("pause_writeback", (uint64_t)settings->pause_writeback, NULL, result, mem))
+			errors++;
+
 	if (settings->new_key && settings->new_val)
 		if (!_writecache_setting_str_list_add(settings->new_key, 0, settings->new_val, result, mem))
 			errors++;
diff --git a/lib/writecache/writecache.c b/lib/writecache/writecache.c
index aa2113271..8ccaca2d0 100644
--- a/lib/writecache/writecache.c
+++ b/lib/writecache/writecache.c
@@ -135,6 +135,18 @@ static int _writecache_text_import(struct lv_segment *seg,
 		seg->writecache_settings.max_age_set = 1;
 	}
 
+	if (dm_config_has_node(sn, "metadata_only")) {
+		if (!dm_config_get_uint32(sn, "metadata_only", &seg->writecache_settings.metadata_only))
+			return SEG_LOG_ERROR("Unknown writecache_setting in");
+		seg->writecache_settings.metadata_only_set = 1;
+	}
+
+	if (dm_config_has_node(sn, "pause_writeback")) {
+		if (!dm_config_get_uint32(sn, "pause_writeback", &seg->writecache_settings.pause_writeback))
+			return SEG_LOG_ERROR("Unknown writecache_setting in");
+		seg->writecache_settings.pause_writeback_set = 1;
+	}
+
 	if (dm_config_has_node(sn, "writecache_setting_key")) {
 		const char *key;
 		const char *val;
@@ -207,6 +219,14 @@ static int _writecache_text_export(const struct lv_segment *seg,
 	        outf(f, "max_age = %u", seg->writecache_settings.max_age);
 	}
 
+	if (seg->writecache_settings.metadata_only_set) {
+	        outf(f, "metadata_only = %u", seg->writecache_settings.metadata_only);
+	}
+
+	if (seg->writecache_settings.pause_writeback_set) {
+	        outf(f, "pause_writeback = %u", seg->writecache_settings.pause_writeback);
+	}
+
 	if (seg->writecache_settings.new_key && seg->writecache_settings.new_val) {
 	        outf(f, "writecache_setting_key = \"%s\"",
 	                seg->writecache_settings.new_key);
diff --git a/man/lvmcache.7_main b/man/lvmcache.7_main
index d46c50d04..fdb375083 100644
--- a/man/lvmcache.7_main
+++ b/man/lvmcache.7_main
@@ -340,6 +340,21 @@ perform.  If not done beforehand, the splitcache command enables the
 cleaner mode and waits for flushing to complete before detaching the
 writecache.  Adding cleaner=0 to the splitcache command will skip the
 cleaner mode, and any required flushing is performed in device suspend.
+.
+.TP
+max_age = <milliseconds>
+Specifies the maximum age of a block in milliseconds. If a block is stored in
+the cache for too long, it will be written to the underlying device and cleaned up.
+.
+.TP
+metadata_only = 0|1
+Only metadata is promoted to the cache. This option improves performance for
+heavier REQ_META workloads.
+.
+.TP
+pause_writeback = <milliseconds>
+Pause writeback if there was some write I/O redirected to the origin volume in
+the last number of milliseconds.
 
 .SS dm-writecache using metadata profiles
 .
diff --git a/tools/lvchange.c b/tools/lvchange.c
index dfbefa000..db63eb9ea 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -665,6 +665,16 @@ static int _lvchange_writecache(struct cmd_context *cmd,
 		seg->writecache_settings.max_age = settings.max_age;
 		set_count++;
 	}
+	if (settings.metadata_only_set) {
+		seg->writecache_settings.metadata_only_set = settings.metadata_only_set;
+		seg->writecache_settings.metadata_only = settings.metadata_only;
+		set_count++;
+	}
+	if (settings.pause_writeback_set) {
+		seg->writecache_settings.pause_writeback_set = settings.pause_writeback_set;
+		seg->writecache_settings.pause_writeback = settings.pause_writeback;
+		set_count++;
+	}
 	if (settings.new_key && settings.new_val) {
 		seg->writecache_settings.new_key = settings.new_key;
 		seg->writecache_settings.new_val = settings.new_val;
diff --git a/tools/toollib.c b/tools/toollib.c
index ae6f311ba..d52c9e342 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1473,6 +1473,20 @@ static int _get_one_writecache_setting(struct cmd_context *cmd, struct writecach
 		return 1;
 	}
 
+	if (!strncmp(key, "metadata_only", strlen("metadata_only"))) {
+		if (sscanf(val, "%u", &settings->metadata_only) != 1)
+			goto_bad;
+		settings->metadata_only_set = 1;
+		return 1;
+	}
+
+	if (!strncmp(key, "pause_writeback", strlen("pause_writeback"))) {
+		if (sscanf(val, "%u", &settings->pause_writeback) != 1)
+			goto_bad;
+		settings->pause_writeback_set = 1;
+		return 1;
+	}
+
 	if (settings->new_key) {
 		log_error("Setting %s is not recognized. Only one unrecognized setting is allowed.", key);
 		return 0;

