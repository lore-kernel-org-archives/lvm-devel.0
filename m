From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon, 24 Aug 2015 19:04:16 +0000 (UTC)
Subject: master - libdm: add precise timestamps support to libdm-stats
Message-ID: <20150824190416.A330C60993@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f4262026b671ac2604ec8143c6fe328e9ab159aa
Commit:        f4262026b671ac2604ec8143c6fe328e9ab159aa
Parent:        82a27a85b54b68277e79de2fa9b4fadb01330497
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Aug 20 11:55:06 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Aug 24 20:03:21 2015 +0100

libdm: add precise timestamps support to libdm-stats

Add support for the kernel precise_timestamps feature. This allows
regions to be created using counters with nanosecond precision.

A new dm_stats method, dm_stats_set_precise_timestamps() causes all
future regions created with this handle to attempt to enable precise
counters.
---
 WHATS_NEW_DM                        |    2 +
 libdm/.exported_symbols.DM_1_02_106 |    2 +
 libdm/libdevmapper.h                |   11 +++
 libdm/libdm-stats.c                 |  155 +++++++++++++++++++++++++++++------
 tools/dmsetup.c                     |    1 +
 5 files changed, 144 insertions(+), 27 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 363f7bf..e083231 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,7 @@
 Version 1.02.106 -
 ===================================
+  Add precise argument to dm_stats_create_region().
+  Add support to libdm-stats for precise_timestamps
 
 Version 1.02.105 - 17th August 2015
 ===================================
diff --git a/libdm/.exported_symbols.DM_1_02_106 b/libdm/.exported_symbols.DM_1_02_106
index 0ce8924..b664cc6 100644
--- a/libdm/.exported_symbols.DM_1_02_106
+++ b/libdm/.exported_symbols.DM_1_02_106
@@ -1 +1,3 @@
 dm_message_supports_precise_timestamps
+dm_stats_create_region
+dm_stats_driver_supports_precise
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 2be2ce3..71b8ce4 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -473,6 +473,13 @@ int dm_stats_bind_uuid(struct dm_stats *dms, const char *uuid);
  */
 int dm_message_supports_precise_timestamps(void);
 
+/*
+ * Precise timetamps support.
+ * 
+ * Test for the presence of precise_timestamps support.
+ */
+int dm_stats_driver_supports_precise(void);
+
 #define DM_STATS_ALL_PROGRAMS ""
 /*
  * Parse the response from a @stats_list message. dm_stats_list will
@@ -535,6 +542,9 @@ int dm_stats_populate(struct dm_stats *dms, const char *program_id,
  *
  *   dm_stats_create_region(dms, 1024, 1 << 11, -2, p, a);
  *
+ * If precise is non-zero attempt to create a region with nanosecond
+ * precision counters using the kernel precise_timestamps feature.
+ *
  * program_id is an optional string argument that identifies the
  * program creating the region. If program_id is NULL or the empty
  * string the default program_id stored in the handle will be used.
@@ -548,6 +558,7 @@ int dm_stats_populate(struct dm_stats *dms, const char *program_id,
  */
 int dm_stats_create_region(struct dm_stats *dms, uint64_t *region_id,
 			   uint64_t start, uint64_t len, int64_t step,
+			   int precise,
 			   const char *program_id, const char *aux_data);
 
 /*
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 4b4135a..b85300f 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -19,6 +19,8 @@
 #define NSEC_PER_MSEC   1000000L
 #define NSEC_PER_SEC    1000000000L
 
+#define PRECISE_ARG "precise_timestamps"
+
 /*
  * See Documentation/device-mapper/statistics.txt for full descriptions
  * of the device-mapper statistics counter fields.
@@ -61,7 +63,8 @@ struct dm_stats {
 	uint64_t nr_regions; /* total number of present regions */
 	uint64_t max_region; /* size of the regions table */
 	uint64_t interval_ns;  /* sampling interval in nanoseconds */
-	uint64_t timescale; /* sample value multiplier */
+	uint64_t timescale; /* default sample value multiplier */
+	int precise; /* use precise_timestamps when creating regions */
 	struct dm_stats_region *regions;
 	/* statistics cursor */
 	uint64_t cur_region;
@@ -109,8 +112,9 @@ struct dm_stats *dm_stats_create(const char *program_id)
 	dms->name = NULL;
 	dms->uuid = NULL;
 
-	/* all regions currently use msec precision */
+	/* by default all regions use msec precision */
 	dms->timescale = NSEC_PER_MSEC;
+	dms->precise = 0;
 
 	dms->nr_regions = DM_STATS_REGION_NOT_PRESENT;
 	dms->max_region = DM_STATS_REGION_NOT_PRESENT;
@@ -225,6 +229,19 @@ int dm_stats_bind_uuid(struct dm_stats *dms, const char *uuid)
 	return 1;
 }
 
+static int _stats_check_precise_timestamps(const struct dm_stats *dms)
+{
+	/* Already checked? */
+	if (dms && dms->precise)
+		return 1;
+	return dm_message_supports_precise_timestamps();
+}
+
+int dm_stats_driver_supports_precise(void)
+{
+	return _stats_check_precise_timestamps(NULL);
+}
+
 static struct dm_task *_stats_send_message(struct dm_stats *dms, char *msg)
 {
 	struct dm_task *dmt;
@@ -249,24 +266,55 @@ out:
 
 static int _stats_parse_list_region(struct dm_stats_region *region, char *line)
 {
-	/* FIXME: the kernel imposes no length limit here */
-	char program_id[256], aux_data[256];
+	char *p = NULL, string_data[4096]; /* FIXME: add dm_sscanf with %ms? */
+	const char *program_id, *aux_data, *stats_args;
+	const char *empty_string = "";
 	int r;
 
-	/* line format:
-	 * <region_id>: <start_sector>+<length> <step> <program_id> <aux_data>
+	memset(string_data, 0, sizeof(string_data));
+
+	/*
+	 * Parse fixed fields, line format:
+	 *
+	 * <region_id>: <start_sector>+<length> <step> <string data>
+	 *
+	 * Maximum string data size is 4096 - 1 bytes.
 	 */
-	r = sscanf(line, FMTu64 ": " FMTu64 "+" FMTu64 " " FMTu64 "%255s %255s",
-		   &region->region_id, &region->start, &region->len, &region->step,
-		   program_id, aux_data);
+	r = sscanf(line, FMTu64 ": " FMTu64 "+" FMTu64 " " FMTu64 " %4095c",
+		   &region->region_id, &region->start, &region->len,
+		   &region->step, string_data);
 
-	if (r != 6)
+	if (r != 5)
 		return_0;
 
-	if (!strcmp(program_id, "-"))
-		program_id[0] = '\0';
-	if (!strcmp(aux_data, "-"))
-		aux_data[0] = '\0';
+	/* program_id is guaranteed to be first. */
+	program_id = string_data;
+
+	/*
+	 * FIXME: support embedded '\ ' in string data:
+	 *   s/strchr/_find_unescaped_space()/
+	 */
+	if ((p = strchr(string_data, ' '))) {
+		/* terminate program_id string. */
+		*p = '\0';
+		if (!strcmp(program_id, "-"))
+			program_id = empty_string;
+		aux_data = p + 1;
+		if ((p = strchr(aux_data, ' '))) {
+			/* terminate aux_data string. */
+			*p = '\0';
+			if (!strcmp(aux_data, "-"))
+				aux_data = empty_string;
+			stats_args = p + 1;
+		} else
+			stats_args = empty_string;
+	} else
+		aux_data = stats_args = empty_string;
+
+	if (strstr(stats_args, PRECISE_ARG))
+		region->timescale = 1;
+	else
+		region->timescale = NSEC_PER_MSEC;
 
 	if (!(region->program_id = dm_strdup(program_id)))
 		return_0;
@@ -621,14 +669,17 @@ uint64_t dm_stats_get_nr_areas(const struct dm_stats *dms)
 	return nr_areas;
 }
 
-int dm_stats_create_region(struct dm_stats *dms, uint64_t *region_id,
-			   uint64_t start, uint64_t len, int64_t step,
-			   const char *program_id, const char *aux_data)
+static int _stats_create_region(struct dm_stats *dms, uint64_t *region_id,
+				uint64_t start, uint64_t len, int64_t step,
+				int precise,
+				const char *program_id,	const char *aux_data)
 {
 	struct dm_task *dmt = NULL;
 	char msg[1024], range[64];
 	const char *err_fmt = "Could not prepare @stats_create %s.";
-	const char *resp;
+	const char *precise_str = PRECISE_ARG;
+	const char *resp, *opt_args = NULL;
+	int nr_opt = 0, r = 0; /* number of optional args. */
 
 	if (!_stats_bound(dms))
 		return_0;
@@ -640,16 +691,35 @@ int dm_stats_create_region(struct dm_stats *dms, uint64_t *region_id,
 		if (!dm_snprintf(range, sizeof(range), FMTu64 "+" FMTu64,
 				 start, len)) {
 			log_error(err_fmt, "range");
-			goto out;
+			return 0;
 		}
 	}
 
-	if (!dm_snprintf(msg, sizeof(msg), "@stats_create %s %s" FMTu64 " %s %s",
-			 (start || len) ? range : "-",
+	if (precise < 0)
+		precise = dms->precise;
+
+	if (precise)
+		nr_opt++;
+	else
+		precise_str = "";
+
+	if (nr_opt) {
+		if ((dm_asprintf((char **)&opt_args, "%d %s", nr_opt,
+				 precise_str)) < 0) {
+			log_error(err_fmt, PRECISE_ARG " option.");
+			return 0;
+		}
+	} else
+		opt_args = dm_strdup("");
+
+	if (!dm_snprintf(msg, sizeof(msg), "@stats_create %s %s" FMTu64
+			 " %s %s %s", (start || len) ? range : "-",
 			 (step < 0) ? "/" : "",
-			 (uint64_t)llabs(step), program_id, aux_data)) {
+			 (uint64_t)llabs(step),
+			 opt_args, program_id, aux_data)) {
 		log_error(err_fmt, "message");
-		goto out;
+		dm_free((void *) opt_args);
+		return 0;
 	}
 
 	if (!(dmt = _stats_send_message(dms, msg)))
@@ -668,14 +738,45 @@ int dm_stats_create_region(struct dm_stats *dms, uint64_t *region_id,
 			goto_out;
 	}
 
-	dm_task_destroy(dmt);
+	r = 1;
 
-	return 1;
 out:
 	if(dmt)
 		dm_task_destroy(dmt);
-	return 0;
+	dm_free((void *) opt_args);
+	return r;
+}
+
+int dm_stats_create_region(struct dm_stats *dms, uint64_t *region_id,
+			   uint64_t start, uint64_t len, int64_t step,
+			   int precise,
+			   const char *program_id,
+			   const char *aux_data)
+{
+	/* Nanosecond counters need precise_timestamps. */
+	if (precise && !_stats_check_precise_timestamps(dms))
+		return 0;
+
+	return _stats_create_region(dms, region_id, start, len, step,
+				    precise,
+				    program_id, aux_data);
+}
+
+/* Backward compatible dm_stats_create_region() */
+#if defined(__GNUC__)
+int dm_stats_create_region_v1_02_104(struct dm_stats *dms, uint64_t *region_id,
+				     uint64_t start, uint64_t len, int64_t step,
+				     const char *program_id, const char *aux_data);
+int dm_stats_create_region_v1_02_104(struct dm_stats *dms, uint64_t *region_id,
+				     uint64_t start, uint64_t len, int64_t step,
+				     const char *program_id, const char *aux_data)
+{
+	return _stats_create_region(dms, region_id, start, len, step,
+				    dms->precise,
+				    program_id, aux_data);
 }
+DM_EXPORT_SYMBOL(dm_stats_create_region, 1_02_104);
+#endif
 
 int dm_stats_delete_region(struct dm_stats *dms, uint64_t region_id)
 {
@@ -815,7 +916,7 @@ static int _dm_stats_populate_region(struct dm_stats *dms, uint64_t region_id,
 	if (!_stats_bound(dms))
 		return_0;
 
-	if (!_stats_parse_region(dms->mem, resp, region, dms->timescale)) {
+	if (!_stats_parse_region(dms->mem, resp, region, region->timescale)) {
 		log_error("Could not parse @stats_print message response.");
 		return 0;
 	}
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 45d4173..b8376dd 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4520,6 +4520,7 @@ static int _do_stats_create_regions(struct dm_stats *dms,
 			this_len = (segments) ? segment_len : this_len;
 			if (!dm_stats_create_region(dms, &region_id,
 						    this_start, this_len, step,
+						    -1,
 						    program_id, aux_data)) {
 				log_error("%s: Could not create statistics region.",
 					  devname);


