From: David Teigland <teigland@sourceware.org>
Date: Wed, 10 Jun 2020 17:31:42 +0000 (GMT)
Subject: master - writecache: add settings cleaner and max_age
Message-ID: <20200610173142.B749C3858D35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a7b2fc8f5791747ff3326997a07743eeebbd3ef7
Commit:        a7b2fc8f5791747ff3326997a07743eeebbd3ef7
Parent:        d15c466f9557004fa003b8986b82deca25cc5aaf
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 31 14:14:50 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 10 12:15:50 2020 -0500

writecache: add settings cleaner and max_age

available in dm-writecache 1.2
---
 device_mapper/all.h             |  4 ++++
 device_mapper/libdm-deptree.c   | 12 ++++++++++
 lib/metadata/writecache_manip.c |  8 +++++++
 lib/report/report.c             |  2 +-
 lib/writecache/writecache.c     | 49 +++++++++++++++++++++++++++++++++++++++++
 tools/lvchange.c                | 10 +++++++++
 tools/toollib.c                 | 14 ++++++++++++
 7 files changed, 98 insertions(+), 1 deletion(-)

diff --git a/device_mapper/all.h b/device_mapper/all.h
index f00b6a5dc..c3c6219e3 100644
--- a/device_mapper/all.h
+++ b/device_mapper/all.h
@@ -951,6 +951,8 @@ struct writecache_settings {
 	uint64_t autocommit_time; /* in milliseconds */
 	uint32_t fua;
 	uint32_t nofua;
+	uint32_t cleaner;
+	uint32_t max_age;
 
 	/*
 	 * Allow an unrecognized key and its val to be passed to the kernel for
@@ -970,6 +972,8 @@ struct writecache_settings {
 	unsigned autocommit_time_set:1;
 	unsigned fua_set:1;
 	unsigned nofua_set:1;
+	unsigned cleaner_set:1;
+	unsigned max_age_set:1;
 };
 
 int dm_tree_node_add_writecache_target(struct dm_tree_node *node,
diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index 9ba24cbbf..2722a2c3b 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -2670,6 +2670,10 @@ static int _writecache_emit_segment_line(struct dm_task *dmt,
 		count += 1;
 	if (seg->writecache_settings.nofua_set)
 		count += 1;
+	if (seg->writecache_settings.cleaner_set && seg->writecache_settings.cleaner)
+		count += 1;
+	if (seg->writecache_settings.max_age_set)
+		count += 2;
 	if (seg->writecache_settings.new_key)
 		count += 2;
 
@@ -2713,6 +2717,14 @@ static int _writecache_emit_segment_line(struct dm_task *dmt,
 		EMIT_PARAMS(pos, " nofua");
 	}
 
+	if (seg->writecache_settings.cleaner_set && seg->writecache_settings.cleaner) {
+		EMIT_PARAMS(pos, " cleaner");
+	}
+
+	if (seg->writecache_settings.max_age_set) {
+		EMIT_PARAMS(pos, " max_age %u", seg->writecache_settings.max_age);
+	}
+
 	if (seg->writecache_settings.new_key) {
 		EMIT_PARAMS(pos, " %s %s",
 			seg->writecache_settings.new_key,
diff --git a/lib/metadata/writecache_manip.c b/lib/metadata/writecache_manip.c
index e24bcb76b..7ad8c75e7 100644
--- a/lib/metadata/writecache_manip.c
+++ b/lib/metadata/writecache_manip.c
@@ -454,6 +454,14 @@ int writecache_settings_to_str_list(struct writecache_settings *settings, struct
 		if (!_writecache_setting_str_list_add("nofua", (uint64_t)settings->nofua, NULL, result, mem))
 			errors++;
 
+	if (settings->cleaner_set && settings->cleaner)
+		if (!_writecache_setting_str_list_add("cleaner", (uint64_t)settings->cleaner, NULL, result, mem))
+			errors++;
+
+	if (settings->max_age_set)
+		if (!_writecache_setting_str_list_add("max_age", (uint64_t)settings->max_age, NULL, result, mem))
+			errors++;
+
 	if (settings->new_key && settings->new_val)
 		if (!_writecache_setting_str_list_add(settings->new_key, 0, settings->new_val, result, mem))
 			errors++;
diff --git a/lib/report/report.c b/lib/report/report.c
index 268bed61b..74ec74cf7 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1434,7 +1434,7 @@ static int _cache_settings_disp(struct dm_report *rh, struct dm_pool *mem,
 		if (!(result = str_list_create(mem)))
 			return_0;
 
-		if (!writecache_settings_to_str_list(&seg->writecache_settings, result, mem))
+		if (!writecache_settings_to_str_list((struct writecache_settings *)&seg->writecache_settings, result, mem))
 			return_0;
 
 		return _field_set_string_list(rh, field, result, private, 0, NULL);
diff --git a/lib/writecache/writecache.c b/lib/writecache/writecache.c
index 130922a54..c7aea286d 100644
--- a/lib/writecache/writecache.c
+++ b/lib/writecache/writecache.c
@@ -26,6 +26,9 @@
 #include "lib/metadata/lv_alloc.h"
 #include "lib/config/defaults.h"
 
+static int _writecache_cleaner_supported;
+static int _writecache_max_age_supported;
+
 #define SEG_LOG_ERROR(t, p...) \
         log_error(t " segment %s of logical volume %s.", ## p,	\
                   dm_config_parent_name(sn), seg->lv->name), 0;
@@ -120,6 +123,18 @@ static int _writecache_text_import(struct lv_segment *seg,
 		seg->writecache_settings.nofua_set = 1;
 	}
 
+	if (dm_config_has_node(sn, "cleaner")) {
+		if (!dm_config_get_uint32(sn, "cleaner", &seg->writecache_settings.cleaner))
+			return SEG_LOG_ERROR("Unknown writecache_setting in");
+		seg->writecache_settings.cleaner_set = 1;
+	}
+
+	if (dm_config_has_node(sn, "max_age")) {
+		if (!dm_config_get_uint32(sn, "max_age", &seg->writecache_settings.max_age))
+			return SEG_LOG_ERROR("Unknown writecache_setting in");
+		seg->writecache_settings.max_age_set = 1;
+	}
+
 	if (dm_config_has_node(sn, "writecache_setting_key")) {
 		const char *key;
 		const char *val;
@@ -184,6 +199,14 @@ static int _writecache_text_export(const struct lv_segment *seg,
 	        outf(f, "nofua = %u", seg->writecache_settings.nofua);
 	}
 
+	if (seg->writecache_settings.cleaner_set && seg->writecache_settings.cleaner) {
+	        outf(f, "cleaner = %u", seg->writecache_settings.cleaner);
+	}
+
+	if (seg->writecache_settings.max_age_set) {
+	        outf(f, "max_age = %u", seg->writecache_settings.max_age);
+	}
+
 	if (seg->writecache_settings.new_key && seg->writecache_settings.new_val) {
 	        outf(f, "writecache_setting_key = \"%s\"",
 	                seg->writecache_settings.new_key);
@@ -208,6 +231,7 @@ static int _target_present(struct cmd_context *cmd,
 {
 	static int _writecache_checked = 0;
 	static int _writecache_present = 0;
+	uint32_t maj, min, patchlevel;
 
 	if (!activation())
 		return 0;
@@ -215,6 +239,19 @@ static int _target_present(struct cmd_context *cmd,
 	if (!_writecache_checked) {
 		_writecache_checked = 1;
 		_writecache_present =  target_present(cmd, TARGET_NAME_WRITECACHE, 1);
+
+		if (!target_version(TARGET_NAME_WRITECACHE, &maj, &min, &patchlevel))
+			return_0;
+
+		if (maj < 1) {
+			log_error("writecache target version older than minimum 1.0.0");
+			return 0;
+		}
+
+		if (min >= 2) {
+			_writecache_cleaner_supported = 1;
+			_writecache_max_age_supported = 1;
+		}
 	}
 
 	return _writecache_present;
@@ -257,6 +294,18 @@ static int _writecache_add_target_line(struct dev_manager *dm,
 		return 0;
 	}
 
+	if (!_writecache_cleaner_supported && seg->writecache_settings.cleaner_set && seg->writecache_settings.cleaner) {
+		log_warn("WARNING: ignoring writecache setting \"cleaner\" which is not supported by kernel for LV %s.", seg->lv->name);
+		seg->writecache_settings.cleaner = 0;
+		seg->writecache_settings.cleaner_set = 0;
+	}
+
+	if (!_writecache_max_age_supported && seg->writecache_settings.max_age_set) {
+		log_warn("WARNING: ignoring writecache setting \"max_age\" which is not supported by kernel for LV %s.", seg->lv->name);
+		seg->writecache_settings.max_age = 0;
+		seg->writecache_settings.max_age_set = 0;
+	}
+
 	if ((pmem = lv_on_pmem(seg->writecache)) < 0)
 		return_0;
 
diff --git a/tools/lvchange.c b/tools/lvchange.c
index ba24e8239..c0adadf8d 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -658,6 +658,16 @@ static int _lvchange_writecache(struct cmd_context *cmd,
 		seg->writecache_settings.nofua = settings.nofua;
 		set_count++;
 	}
+	if (settings.cleaner_set) {
+		seg->writecache_settings.cleaner_set = settings.cleaner_set;
+		seg->writecache_settings.cleaner = settings.cleaner;
+		set_count++;
+	}
+	if (settings.max_age_set) {
+		seg->writecache_settings.max_age_set = settings.max_age_set;
+		seg->writecache_settings.max_age = settings.max_age;
+		set_count++;
+	}
 
 	if (!set_count) {
 		/*
diff --git a/tools/toollib.c b/tools/toollib.c
index 94e6e6c44..eb0de5501 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1262,6 +1262,20 @@ static int _get_one_writecache_setting(struct cmd_context *cmd, struct writecach
 		return 1;
 	}
 
+	if (!strncmp(key, "cleaner", strlen("cleaner"))) {
+		if (sscanf(val, "%u", &settings->cleaner) != 1)
+			goto_bad;
+		settings->cleaner_set = 1;
+		return 1;
+	}
+
+	if (!strncmp(key, "max_age", strlen("max_age"))) {
+		if (sscanf(val, "%u", &settings->max_age) != 1)
+			goto_bad;
+		settings->max_age_set = 1;
+		return 1;
+	}
+
 	if (settings->new_key) {
 		log_error("Setting %s is not recognized. Only one unrecognized setting is allowed.", key);
 		return 0;


