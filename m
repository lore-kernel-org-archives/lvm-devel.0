From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat,  5 Sep 2015 22:57:30 +0000 (UTC)
Subject: master - style: Standardise some error paths.
Message-ID: <20150905225730.BD9AE61255@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fb123084166634e8f3b8550520391df369e9db70
Commit:        fb123084166634e8f3b8550520391df369e9db70
Parent:        f5a3b05c7ac8474cd323558399d2886f8edb5731
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Sep 5 23:56:30 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Sep 5 23:56:30 2015 +0100

style: Standardise some error paths.

---
 daemons/cmirrord/functions.c   |    4 +-
 daemons/lvmetad/lvmetad-core.c |    2 +-
 lib/metadata/metadata.c        |    3 +-
 libdm/libdm-file.c             |    4 +-
 libdm/libdm-report.c           |    2 +-
 libdm/libdm-stats.c            |  197 +++++++++--------
 liblvm/lvm_pv.c                |    5 +-
 tools/dmsetup.c                |  475 ++++++++++++++++++++--------------------
 8 files changed, 355 insertions(+), 337 deletions(-)

diff --git a/daemons/cmirrord/functions.c b/daemons/cmirrord/functions.c
index 61b3e11..4f36cc6 100644
--- a/daemons/cmirrord/functions.c
+++ b/daemons/cmirrord/functions.c
@@ -1445,7 +1445,7 @@ static int disk_status_info(struct log_c *lc, struct dm_ulog_request *rq)
 	char *data = (char *)rq->data;
 	struct stat statbuf;
 
-	if(fstat(lc->disk_fd, &statbuf)) {
+	if (fstat(lc->disk_fd, &statbuf)) {
 		rq->error = -errno;
 		return -errno;
 	}
@@ -1508,7 +1508,7 @@ static int disk_status_table(struct log_c *lc, struct dm_ulog_request *rq)
 	char *data = (char *)rq->data;
 	struct stat statbuf;
 
-	if(fstat(lc->disk_fd, &statbuf)) {
+	if (fstat(lc->disk_fd, &statbuf)) {
 		rq->error = -errno;
 		return -errno;
 	}
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 19e8723..89aaaf8 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -578,7 +578,7 @@ static void mark_outdated_pv(lvmetad_state *s, const char *vgid, const char *pvi
 		    !(cft_vgid = make_text_node(outdated_pvs, "vgid", dm_pool_strdup(outdated_pvs->mem, vgid),
 						outdated_pvs->root, NULL)))
 			abort();
-		if(!dm_hash_insert(s->vgid_to_outdated_pvs, cft_vgid->v->v.str, outdated_pvs))
+		if (!dm_hash_insert(s->vgid_to_outdated_pvs, cft_vgid->v->v.str, outdated_pvs))
 			abort();
 		DEBUGLOG(s, "created outdated_pvs list for VG %s", vgid);
 	}
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 8757331..b45f850 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -319,10 +319,11 @@ static struct pv_list *_copy_pvl(struct dm_pool *pvmem, struct pv_list *pvl_from
 	if (!(pvl_to->pv = dm_pool_alloc(pvmem, sizeof(*pvl_to->pv))))
 		goto_bad;
 
-	if(!_copy_pv(pvmem, pvl_to->pv, pvl_from->pv))
+	if (!_copy_pv(pvmem, pvl_to->pv, pvl_from->pv))
 		goto_bad;
 
 	return pvl_to;
+
 bad:
 	dm_pool_free(pvmem, pvl_to);
 	return NULL;
diff --git a/libdm/libdm-file.c b/libdm/libdm-file.c
index 52f9d45..e4beddd 100644
--- a/libdm/libdm-file.c
+++ b/libdm/libdm-file.c
@@ -119,8 +119,8 @@ int dm_create_lockfile(const char *lockfile)
 	char buffer[50];
 	int retries = 0;
 
-	if((fd = open(lockfile, O_CREAT | O_WRONLY,
-		      (S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH))) < 0) {
+	if ((fd = open(lockfile, O_CREAT | O_WRONLY,
+		       (S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH))) < 0) {
 		log_error("Cannot open lockfile [%s], error was [%s]",
 			  lockfile, strerror(errno));
 		return 0;
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 6416f18..10ab7df 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -4195,7 +4195,7 @@ static void _destroy_rows(struct dm_report *rh)
 	 * pool allocation this will also free all subsequently allocated
 	 * rows from the report and any associated string data.
 	 */
-	if(rh->first_row)
+	if (rh->first_row)
 		dm_pool_free(rh->mem, rh->first_row);
 	rh->first_row = NULL;
 	dm_list_init(&rh->rows);
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 736aae5..93c7760 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -105,7 +105,7 @@ static char *_program_id_from_proc(void)
 
 	if (!fgets(buf, sizeof(buf), comm)) {
 		log_error("Could not read from %s", PROC_SELF_COMM);
-		if(fclose(comm))
+		if (fclose(comm))
 			stack;
 		return NULL;
 	}
@@ -145,7 +145,7 @@ struct dm_stats *dm_stats_create(const char *program_id)
 
 	/* FIXME: better hint. */
 	if (!(dms->mem = dm_pool_create("stats_pool", 4096)))
-		goto_out;
+		goto_bad;
 
 	if (!(dms->hist_mem = dm_pool_create("histogram_pool", hist_hint)))
 		return_0;
@@ -169,7 +169,8 @@ struct dm_stats *dm_stats_create(const char *program_id)
 	dms->regions = NULL;
 
 	return dms;
-out:
+
+bad:
 	dm_free(dms);
 	return NULL;
 }
@@ -354,7 +355,7 @@ static char *_build_histogram_arg(struct dm_histogram *bounds, int *precise)
 		hist_len += 1 + (size_t) lround(log10(value));
 	}
 
-	if(!(hist_arg = dm_zalloc(hist_len))) {
+	if (!(hist_arg = dm_zalloc(hist_len))) {
 		log_error("Could not allocate memory for histogram argument.");
 		return 0;
 	}
@@ -373,14 +374,16 @@ static char *_build_histogram_arg(struct dm_histogram *bounds, int *precise)
 		value = entry->upper / scale;
 		if ((l = dm_snprintf(arg, hist_len - len, FMTu64"%s", value,
 				     (last) ? "" : ",")) < 0)
-			goto out;
+			goto_bad;
 		len += (size_t) l;
 		arg += (size_t) l;
 	}
 	return hist_arg;
-out:
+
+bad:
 	log_error("Could not build histogram arguments.");
 	dm_free(hist_arg);
+
 	return NULL;
 }
 
@@ -392,16 +395,17 @@ static struct dm_task *_stats_send_message(struct dm_stats *dms, char *msg)
 		return_0;
 
 	if (!_set_stats_device(dms, dmt))
-		goto_out;
+		goto_bad;
 
 	if (!dm_task_set_message(dmt, msg))
-		goto_out;
+		goto_bad;
 
 	if (!dm_task_run(dmt))
-		goto_out;
+		goto_bad;
 
 	return dmt;
-out:
+
+bad:
 	dm_task_destroy(dmt);
 	return NULL;
 }
@@ -425,7 +429,7 @@ static int _stats_parse_histogram_spec(struct dm_stats *dms,
 
 	/* Advance past "histogram:". */
 	histogram = strchr(histogram, ':');
-	if(!histogram) {
+	if (!histogram) {
 		log_error("Could not parse histogram description.");
 		return 0;
 	}
@@ -444,21 +448,23 @@ static int _stats_parse_histogram_spec(struct dm_stats *dms,
 	hist.region = region;
 	hist.dms = dms;
 
-	if(!dm_pool_grow_object(mem, &hist, sizeof(hist)))
-		goto_out;
+	if (!dm_pool_grow_object(mem, &hist, sizeof(hist)))
+		goto_bad;
 
 	c = histogram;
 	do {
-		for(v = _valid_chars; *v; v++)
+		for (v = _valid_chars; *v; v++)
 			if (*c == *v)
 				break;
-		if(!*v)
+		if (!*v) {
+			stack;
 			goto badchar;
+		}
 
 		if (*c == ',') {
 			log_error("Invalid histogram description: %s",
 				  histogram);
-			goto out;
+			goto bad;
 		} else {
 			const char *val_start = c;
 			char *endptr = NULL;
@@ -467,15 +473,17 @@ static int _stats_parse_histogram_spec(struct dm_stats *dms,
 			this_val = strtoull(val_start, &endptr, 10);
 			if (!endptr) {
 				log_error("Could not parse histogram boundary.");
-				goto out;
+				goto bad;
 			}
 
 			c = endptr; /* Advance to units, comma, or end. */
 
 			if (*c == ',')
 				c++;
-			else if (*c || (*c == ' ')) /* Expected ',' or NULL. */
+			else if (*c || (*c == ' ')) { /* Expected ',' or NULL. */
+				stack;
 				goto badchar;
+			}
 
 			if (*c == ',')
 				c++;
@@ -484,7 +492,7 @@ static int _stats_parse_histogram_spec(struct dm_stats *dms,
 			cur.count = 0;
 
 			if (!dm_pool_grow_object(mem, &cur, sizeof(cur)))
-				goto_out;
+				goto_bad;
 
 			nr_bins++;
 		}
@@ -493,7 +501,7 @@ static int _stats_parse_histogram_spec(struct dm_stats *dms,
 	/* final upper bound. */
 	cur.upper = UINT64_MAX;
 	if (!dm_pool_grow_object(mem, &cur, sizeof(cur)))
-		goto_out;
+		goto_bad;
 
 	region->bounds = dm_pool_end_object(mem);
 
@@ -507,7 +515,7 @@ static int _stats_parse_histogram_spec(struct dm_stats *dms,
 
 badchar:
 	log_error("Invalid character in histogram: '%c' (0x%x)", *c, *c);
-out:
+bad:
 	dm_pool_abandon_object(mem);
 	return 0;
 }
@@ -614,12 +622,12 @@ static int _stats_parse_list(struct dm_stats *dms, const char *resp)
 		return_0;
 
 	if (!dm_pool_begin_object(mem, 1024))
-		goto_out;
+		goto_bad;
 
 	while(fgets(line, sizeof(line), list_rows)) {
 
 		if (!_stats_parse_list_region(dms, &cur, line))
-			goto_out;
+			goto_bad;
 
 		/* handle holes in the list of region_ids */
 		if (cur.region_id > max_region) {
@@ -628,12 +636,12 @@ static int _stats_parse_list(struct dm_stats *dms, const char *resp)
 			fill.region_id = DM_STATS_REGION_NOT_PRESENT;
 			do {
 				if (!dm_pool_grow_object(mem, &fill, sizeof(fill)))
-					goto_out;
+					goto_bad;
 			} while (max_region++ < (cur.region_id - 1));
 		}
 
 		if (!dm_pool_grow_object(mem, &cur, sizeof(cur)))
-			goto_out;
+			goto_bad;
 
 		max_region++;
 		nr_regions++;
@@ -647,10 +655,12 @@ static int _stats_parse_list(struct dm_stats *dms, const char *resp)
 		stack;
 
 	return 1;
-out:
-	if(fclose(list_rows))
+
+bad:
+	if (fclose(list_rows))
 		stack;
 	dm_pool_abandon_object(mem);
+
 	return 0;
 }
 
@@ -675,17 +685,17 @@ int dm_stats_list(struct dm_stats *dms, const char *program_id)
 	}
 
 	if (!(dmt = _stats_send_message(dms, msg)))
-		return 0;
+		return_0;
 
 	if (!_stats_parse_list(dms, dm_task_get_message_response(dmt))) {
 		log_error("Could not parse @stats_list response.");
-		goto out;
+		goto bad;
 	}
 
 	dm_task_destroy(dmt);
 	return 1;
 
-out:
+bad:
 	dm_task_destroy(dmt);
 	return 0;
 }
@@ -715,15 +725,17 @@ static int _stats_parse_histogram(struct dm_pool *mem, char *hist_str,
 
 	do {
 		memset(&cur, 0, sizeof(cur));
-		for(v = _valid_chars; *v; v++)
+		for (v = _valid_chars; *v; v++)
 			if (*c == *v)
 				break;
-		if(!*v)
+		if (!*v) {
+			stack;
 			goto badchar;
+		}
 
 		if (*c == ',') {
 			log_error("Invalid histogram: %s", hist_str);
-			goto out;
+			return 0;
 		} else {
 			const char *val_start = c;
 			char *endptr = NULL;
@@ -732,15 +744,17 @@ static int _stats_parse_histogram(struct dm_pool *mem, char *hist_str,
 			this_val = strtoull(val_start, &endptr, 10);
 			if (!endptr) {
 				log_error("Could not parse histogram value.");
-				goto out;
+				return 0;
 			}
 			c = endptr; /* Advance to colon, or end. */
 
 			if (*c == ':')
 				c++;
-			else if (*c & (*c != '\n'))
+			else if (*c & (*c != '\n')) {
 				/* Expected ':', '\n', or NULL. */
+				stack;
 				goto badchar;
+			}
 
 			if (*c == ':')
 				c++;
@@ -764,7 +778,6 @@ static int _stats_parse_histogram(struct dm_pool *mem, char *hist_str,
 
 badchar:
 	log_error("Invalid character in histogram data: '%c' (0x%x)", *c, *c);
-out:
 	return 0;
 }
 
@@ -788,7 +801,7 @@ static int _stats_parse_region(struct dm_stats *dms, const char *resp,
 	region->start = UINT64_MAX;
 
 	if (!dm_pool_begin_object(mem, 512))
-		goto_out;
+		goto_bad;
 
 	/*
 	 * dm_task_get_message_response() returns a 'const char *' but
@@ -796,7 +809,7 @@ static int _stats_parse_region(struct dm_stats *dms, const char *resp,
 	 */
 	stats_rows = fmemopen((char *)resp, strlen(resp), "r");
 	if (!stats_rows)
-		goto_out;
+		goto_bad;
 
 	/*
 	 * Output format for each step-sized area of a region:
@@ -844,7 +857,7 @@ static int _stats_parse_region(struct dm_stats *dms, const char *resp,
 			   &cur.total_read_nsecs, &cur.total_write_nsecs);
 		if (r != 15) {
 			log_error("Could not parse @stats_print row.");
-			goto out;
+			goto bad;
 		}
 
 		/* scale time values up if needed */
@@ -862,7 +875,7 @@ static int _stats_parse_region(struct dm_stats *dms, const char *resp,
 			char *hist_str = strchr(row, ':');
 			if (!hist_str) {
 				log_error("Could not parse histogram value.");
-				goto out;
+				goto bad;
 			}
 			/* Find space preceding histogram. */
 			while (hist_str && *(hist_str - 1) != ' ')
@@ -874,15 +887,15 @@ static int _stats_parse_region(struct dm_stats *dms, const char *resp,
 			 */
 			if (!_stats_parse_histogram(dms->hist_mem, hist_str,
 						    &hist, region))
-				goto out;
+				goto_bad;
 			hist->dms = dms;
 			hist->region = region;
 		}
 
 		cur.histogram = hist;
 
-		if(!dm_pool_grow_object(mem, &cur, sizeof(cur)))
-			goto_out;
+		if (!dm_pool_grow_object(mem, &cur, sizeof(cur)))
+			goto_bad;
 
 		if (region->start == UINT64_MAX) {
 			region->start = start;
@@ -899,12 +912,12 @@ static int _stats_parse_region(struct dm_stats *dms, const char *resp,
 
 	return 1;
 
-out:
-
+bad:
 	if (stats_rows)
-		if(fclose(stats_rows))
+		if (fclose(stats_rows))
 			stack;
 	dm_pool_abandon_object(mem);
+
 	return 0;
 }
 
@@ -1017,7 +1030,7 @@ int dm_stats_get_region_nr_histogram_bins(const struct dm_stats *dms,
 		     ? dms->cur_region : region_id ;
 
 	if (!dms->regions[region_id].bounds)
-		return 0;
+		return_0;
 
 	return dms->regions[region_id].bounds->nr_bins;
 }
@@ -1083,7 +1096,7 @@ static int _stats_create_region(struct dm_stats *dms, uint64_t *region_id,
 	}
 
 	if (!(dmt = _stats_send_message(dms, msg)))
-		goto out;
+		goto_out;
 
 	resp = dm_task_get_message_response(dmt);
 	if (!resp) {
@@ -1101,9 +1114,10 @@ static int _stats_create_region(struct dm_stats *dms, uint64_t *region_id,
 	r = 1;
 
 out:
-	if(dmt)
+	if (dmt)
 		dm_task_destroy(dmt);
 	dm_free((void *) opt_args);
+
 	return r;
 }
 
@@ -1116,9 +1130,8 @@ int dm_stats_create_region(struct dm_stats *dms, uint64_t *region_id,
 	int r = 0;
 
 	/* Nanosecond counters and histograms both need precise_timestamps. */
-	if ((precise || bounds)
-	    && !_stats_check_precise_timestamps(dms))
-		return 0;
+	if ((precise || bounds) && !_stats_check_precise_timestamps(dms))
+		return_0;
 
 	if (bounds) {
 		/* _build_histogram_arg enables precise if vals < 1ms. */
@@ -1129,6 +1142,7 @@ int dm_stats_create_region(struct dm_stats *dms, uint64_t *region_id,
 	r = _stats_create_region(dms, region_id, start, len, step,
 				 precise, hist_arg, program_id, aux_data);
 	dm_free(hist_arg);
+
 out:
 	return r;
 }
@@ -1143,17 +1157,15 @@ int dm_stats_delete_region(struct dm_stats *dms, uint64_t region_id)
 
 	if (!dm_snprintf(msg, sizeof(msg), "@stats_delete " FMTu64, region_id)) {
 		log_error("Could not prepare @stats_delete message.");
-		goto out;
+		return 0;
 	}
 
 	dmt = _stats_send_message(dms, msg);
 	if (!dmt)
-		goto_out;
+		return_0;
 	dm_task_destroy(dmt);
-	return 1;
 
-out:
-	return 0;
+	return 1;
 }
 
 int dm_stats_clear_region(struct dm_stats *dms, uint64_t region_id)
@@ -1166,17 +1178,17 @@ int dm_stats_clear_region(struct dm_stats *dms, uint64_t region_id)
 
 	if (!dm_snprintf(msg, sizeof(msg), "@stats_clear " FMTu64, region_id)) {
 		log_error("Could not prepare @stats_clear message.");
-		goto out;
+		return 0;
 	}
 
 	dmt = _stats_send_message(dms, msg);
+
 	if (!dmt)
-		goto_out;
+		return_0;
+
 	dm_task_destroy(dmt);
-	return 1;
 
-out:
-	return 0;
+	return 1;
 }
 
 static struct dm_task *_stats_print_region(struct dm_stats *dms,
@@ -1194,22 +1206,19 @@ static struct dm_task *_stats_print_region(struct dm_stats *dms,
 		if (!dm_snprintf(lines, sizeof(lines),
 				 lines_fmt, start_line, num_lines)) {
 			log_error(err_fmt, "row specification");
-			goto out;
+			return NULL;
 		}
 
 	if (!dm_snprintf(msg, sizeof(msg), msg_fmt, (clear) ? clear_str : "",
 			 region_id, (start_line || num_lines) ? lines : "")) {
 		log_error(err_fmt, "message");
-		goto out;
+		return NULL;
 	}
 
 	if (!(dmt = _stats_send_message(dms, msg)))
-		goto out;
+		return_NULL;
 
 	return dmt;
-
-out:
-	return NULL;
 }
 
 char *dm_stats_print_region(struct dm_stats *dms, uint64_t region_id,
@@ -1226,7 +1235,7 @@ char *dm_stats_print_region(struct dm_stats *dms, uint64_t region_id,
 				  start_line, num_lines, clear);
 
 	if (!dmt)
-		return 0;
+		return_0;
 
 	resp = dm_pool_strdup(dms->mem, dm_task_get_message_response(dmt));
 	dm_task_destroy(dmt);
@@ -1245,7 +1254,7 @@ void dm_stats_buffer_destroy(struct dm_stats *dms, char *buffer)
 uint64_t dm_stats_get_nr_regions(const struct dm_stats *dms)
 {
 	if (!dms || !dms->regions)
-		return 0;
+		return_0;
 	return dms->nr_regions;
 }
 
@@ -1255,10 +1264,10 @@ uint64_t dm_stats_get_nr_regions(const struct dm_stats *dms)
 int dm_stats_region_present(const struct dm_stats *dms, uint64_t region_id)
 {
 	if (!dms->regions)
-		return 0;
+		return_0;
 
 	if (region_id > dms->max_region)
-		return 0;
+		return_0;
 
 	return _stats_region_present(&dms->regions[region_id]);
 }
@@ -1293,12 +1302,12 @@ int dm_stats_populate(struct dm_stats *dms, const char *program_id,
 
 	if (all_regions && !dm_stats_list(dms, program_id)) {
 		log_error("Could not parse @stats_list response.");
-		goto out;
+		goto bad;
 	}
 
 	/* successful list but no regions registered */
 	if (!dms->nr_regions)
-		return 0;
+		return_0;
 
 	dm_stats_walk_start(dms);
 	do {
@@ -1310,12 +1319,12 @@ int dm_stats_populate(struct dm_stats *dms, const char *program_id,
 
 		/* obtain all lines and clear counter values */
 		if (!(dmt = _stats_print_region(dms, region_id, 0, 0, 1)))
-			goto_out;
+			goto_bad;
 
 		resp = dm_task_get_message_response(dmt);
 		if (!_dm_stats_populate_region(dms, region_id, resp)) {
 			dm_task_destroy(dmt);
-			goto_out;
+			goto_bad;
 		}
 
 		dm_task_destroy(dmt);
@@ -1325,7 +1334,7 @@ int dm_stats_populate(struct dm_stats *dms, const char *program_id,
 
 	return 1;
 
-out:
+bad:
 	_stats_regions_destroy(dms);
 	dms->regions = NULL;
 	return 0;
@@ -1620,10 +1629,10 @@ int dm_stats_get_service_time(const struct dm_stats *dms, double *svctm,
 	double tput;
 
 	if (!dm_stats_get_throughput(dms, &tput, region_id, area_id))
-		return 0;
+		return_0;
 
 	if (!dm_stats_get_utilization(dms, &util, region_id, area_id))
-		return 0;
+		return_0;
 
 	/* avoid NAN with zero counter values */
 	if ( (uint64_t) tput == 0 || (uint64_t) util == 0) {
@@ -1973,23 +1982,26 @@ struct dm_histogram *dm_histogram_bounds_from_string(const char *bounds_str)
 	c = bounds_str;
 
 	if (!(dmh = _alloc_dm_histogram(nr_entries)))
-		return 0;
+		return_0;
 
 	dmh->nr_bins = nr_entries;
 
 	cur = dmh->bins;
 
 	do {
-		for(v = _valid_chars; *v; v++)
+		for (v = _valid_chars; *v; v++)
 			if (*c == *v)
 				break;
-		if(!*v)
+
+		if (!*v) {
+			stack;
 			goto badchar;
+		}
 
 		if (*c == ',') {
 			log_error("Empty histogram bin not allowed: %s",
 				  bounds_str);
-			goto out;
+			goto bad;
 		} else {
 			const char *val_start = c;
 			char *endptr = NULL;
@@ -1998,7 +2010,7 @@ struct dm_histogram *dm_histogram_bounds_from_string(const char *bounds_str)
 			this_val = strtoull(val_start, &endptr, 10);
 			if (!endptr) {
 				log_error("Could not parse histogram bound.");
-				goto out;
+				goto bad;
 			}
 			c = endptr; /* Advance to units, comma, or end. */
 
@@ -2012,13 +2024,17 @@ struct dm_histogram *dm_histogram_bounds_from_string(const char *bounds_str)
 					mult = NSEC_PER_USEC;
 				else if (*c == 'n')
 					mult = 1;
-				else
+				else {
+					stack;
 					goto badchar;
+				}
 				c += 2; /* Advance over 'ms', 'us', or 'ns'. */
 			} else if (*c == ',')
 				c++;
-			else if (*c) /* Expected ',' or NULL. */
+			else if (*c) { /* Expected ',' or NULL. */
+				stack;
 				goto badchar;
+			}
 
 			if (*c == ',')
 				c++;
@@ -2035,7 +2051,7 @@ struct dm_histogram *dm_histogram_bounds_from_string(const char *bounds_str)
 
 badchar:
 	log_error("Invalid character in histogram: %c", *c);
-out:
+bad:
 	dm_free(dmh);
 	return NULL;
 }
@@ -2121,7 +2137,7 @@ static int _make_bounds_string(char *buf, size_t size, uint64_t lower,
 	int bounds = flags & DM_HISTOGRAM_BOUNDS_MASK;
 
 	if (!bounds)
-		return 0;
+		return_0;
 
 	*buf = '\0';
 
@@ -2258,14 +2274,15 @@ const char *dm_histogram_to_string(const struct dm_histogram *dmh, int bin,
 					  sep);
 
 		if (len < 0)
-			goto_out;
+			goto_bad;
 
 		width = minwidth; /* re-set histogram column width. */
 		dm_pool_grow_object(mem, buf, (size_t) len);
 	}
 	dm_pool_grow_object(mem, "\0", 1);
 	return (const char *) dm_pool_end_object(mem);
-out:
+
+bad:
 	dm_pool_abandon_object(mem);
 	return NULL;
 }
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index 24b2732..5933e0a 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -155,9 +155,8 @@ static struct dm_list *_lvm_list_pvs(lvm_t libh)
 	} else {
 		dm_list_init(&rc->pvslist);
 		dm_list_init(&rc->vgslist);
-		if( !get_pvs_perserve_vg(cmd, &rc->pvslist, &rc->vgslist) ) {
-			return NULL;
-		}
+		if (!get_pvs_perserve_vg(cmd, &rc->pvslist, &rc->vgslist))
+			return_NULL;
 
 		/*
 		 * If we have no PVs we still need to have access to cmd
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 8983e18..61ad5a9 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -327,7 +327,7 @@ static int _parse_line(struct dm_task *dmt, char *buffer, const char *file,
 		*comment = '\0';
 
 	if (!dm_task_add_target(dmt, start, size, ttype, ptr))
-		return 0;
+		return_0;
 
 	return 1;
 }
@@ -364,11 +364,11 @@ static int _parse_file(struct dm_task *dmt, const char *file)
 	while (getline(&buffer, &buffer_size, fp) > 0)
 #endif
 		if (!_parse_line(dmt, buffer, file ? : "on stdin", ++line))
-			goto out;
+			goto_out;
 
 	r = 1;
 
-      out:
+out:
 	memset(buffer, 0, buffer_size);
 #ifndef HAVE_GETLINE
 	dm_free(buffer);
@@ -421,33 +421,33 @@ static struct dm_task *_get_deps_task(int major, int minor)
 	struct dm_info info;
 
 	if (!(dmt = dm_task_create(DM_DEVICE_DEPS)))
-		return NULL;
+		return_NULL;
 
 	if (!dm_task_set_major(dmt, major) ||
 	    !dm_task_set_minor(dmt, minor))
-		goto err;
+		goto_bad;
 
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
-		goto err;
+		goto_bad;
 
 	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
-		goto err;
+		goto_bad;
 
 	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
-		goto err;
+		goto_bad;
 
 	if (!_task_run(dmt))
-		goto err;
+		goto_bad;
 
 	if (!dm_task_get_info(dmt, &info))
-		goto err;
+		goto_bad;
 
 	if (!info.exists)
-		goto err;
+		goto_bad;
 
 	return dmt;
 
-      err:
+bad:
 	dm_task_destroy(dmt);
 	return NULL;
 }
@@ -581,7 +581,7 @@ static int _do_timerfd_wait(void)
 	ssize_t bytes;
 
 	if (_timer_fd < 0)
-		return 0;
+		return_0;
 
 	/* read on timerfd returns a uint64_t in host byte order. */
 	bytes = read(_timer_fd, &expired, sizeof(expired));
@@ -646,9 +646,9 @@ static int _do_usleep_wait(void)
 	 */
 	if (!_last_sleep && !_now) {
 		if (!(_last_sleep = dm_timestamp_alloc()))
-			goto_out;
+			return_0;
 		if (!(_now = dm_timestamp_alloc()))
-			goto_out;
+			return_0;
 		dm_timestamp_get(_now);
 		this_interval = _interval;
 		log_error("Using "FMTu64" as first interval.", this_interval);
@@ -673,17 +673,15 @@ static int _do_usleep_wait(void)
 			log_error("Report interval interrupted by signal.");
 		if (errno == EINVAL)
 			log_error("Report interval too short.");
-		goto out;
+		return_0;
 	}
 
-	if(_count == 2) {
+	if (_count == 2) {
 		dm_timestamp_destroy(_last_sleep);
 		dm_timestamp_destroy(_now);
 	}
 
 	return 1;
-out:
-	return 0;
 }
 
 static int _start_timer(void)
@@ -838,7 +836,7 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 		dm_stats_bind_devno(obj.stats, info->major, info->minor);
 
 		if (!dm_stats_populate(obj.stats, _program_id, DM_STATS_REGIONS_ALL))
-			goto out;
+			goto_out;
 
 		/* Update timestamps and handle end-of-interval accounting. */
 		_update_interval_times();
@@ -856,11 +854,11 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 		dm_stats_bind_devno(obj.stats, info->major, info->minor);
 
 		if (!dm_stats_list(obj.stats, _program_id))
-			goto out;
+			goto_out;
 
 		/* No regions to report */
 		if (!dm_stats_get_nr_regions(obj.stats))
-			goto out;
+			goto_out;
 	}
 
 	/*
@@ -879,7 +877,7 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 	} dm_stats_walk_while(obj.stats);
 	r = 1;
 
-      out:
+out:
 	if (obj.deps_task)
 		dm_task_destroy(obj.deps_task);
 	if (obj.split_name)
@@ -938,7 +936,7 @@ static int _display_info(struct dm_task *dmt)
 	struct dm_info info;
 
 	if (!dm_task_get_info(dmt, &info))
-		return 0;
+		return_0;
 
 	if (!_switches[COLS_ARG])
 		_display_info_long(dmt, &info);
@@ -953,14 +951,14 @@ static int _set_task_device(struct dm_task *dmt, const char *name, int optional)
 {
 	if (name) {
 		if (!dm_task_set_name(dmt, name))
-			return 0;
+			return_0;
 	} else if (_switches[UUID_ARG]) {
 		if (!dm_task_set_uuid(dmt, _uuid))
-			return 0;
+			return_0;
 	} else if (_switches[MAJOR_ARG] && _switches[MINOR_ARG]) {
 		if (!dm_task_set_major(dmt, _int_args[MAJOR_ARG]) ||
 		    !dm_task_set_minor(dmt, _int_args[MINOR_ARG]))
-			return 0;
+			return_0;
 	} else if (!optional) {
 		fprintf(stderr, "No device specified.\n");
 		return 0;
@@ -972,15 +970,15 @@ static int _set_task_device(struct dm_task *dmt, const char *name, int optional)
 static int _set_task_add_node(struct dm_task *dmt)
 {
 	if (!dm_task_set_add_node(dmt, DEFAULT_DM_ADD_NODE))
-		return 0;
+		return_0;
 
 	if (_switches[ADD_NODE_ON_RESUME_ARG] &&
 	    !dm_task_set_add_node(dmt, DM_ADD_NODE_ON_RESUME))
-		return 0;
+		return_0;
 
 	if (_switches[ADD_NODE_ON_CREATE_ARG] &&
 	    !dm_task_set_add_node(dmt, DM_ADD_NODE_ON_CREATE))
-		return 0;
+		return_0;
 
 	return 1;
 }
@@ -1014,35 +1012,35 @@ static int _load(CMD_ARGS)
 		file = argv[0];
 
 	if (!(dmt = dm_task_create(DM_DEVICE_RELOAD)))
-		return 0;
+		return_0;
 
 	if (!_set_task_device(dmt, name, 0))
-		goto out;
+		goto_out;
 
 	if (!_switches[NOTABLE_ARG] && !_parse_file(dmt, file))
-		goto out;
+		goto_out;
 
 	if (_switches[READ_ONLY] && !dm_task_set_ro(dmt))
-		goto out;
+		goto_out;
 
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
-		goto out;
+		goto_out;
 
 	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
-		goto out;
+		goto_out;
 
 	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
-		goto out;
+		goto_out;
 
 	if (!_task_run(dmt))
-		goto out;
+		goto_out;
 
 	r = 1;
 
 	if (_switches[VERBOSE_ARG])
 		r = _display_info(dmt);
 
-      out:
+out:
 	dm_task_destroy(dmt);
 
 	return r;
@@ -1060,45 +1058,45 @@ static int _create(CMD_ARGS)
 		file = argv[1];
 
 	if (!(dmt = dm_task_create(DM_DEVICE_CREATE)))
-		return 0;
+		return_0;
 
 	if (!dm_task_set_name(dmt, argv[0]))
-		goto out;
+		goto_out;
 
 	if (_switches[UUID_ARG] && !dm_task_set_uuid(dmt, _uuid))
-		goto out;
+		goto_out;
 
 	if (!_switches[NOTABLE_ARG] && !_parse_file(dmt, file))
-		goto out;
+		goto_out;
 
 	if (_switches[READ_ONLY] && !dm_task_set_ro(dmt))
-		goto out;
+		goto_out;
 
 	if (_switches[MAJOR_ARG] && !dm_task_set_major(dmt, _int_args[MAJOR_ARG]))
-		goto out;
+		goto_out;
 
 	if (_switches[MINOR_ARG] && !dm_task_set_minor(dmt, _int_args[MINOR_ARG]))
-		goto out;
+		goto_out;
 
 	if (_switches[UID_ARG] && !dm_task_set_uid(dmt, _int_args[UID_ARG]))
-		goto out;
+		goto_out;
 
 	if (_switches[GID_ARG] && !dm_task_set_gid(dmt, _int_args[GID_ARG]))
-		goto out;
+		goto_out;
 
 	if (_switches[MODE_ARG] && !dm_task_set_mode(dmt, _int_args[MODE_ARG]))
-		goto out;
+		goto_out;
 
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
-		goto out;
+		goto_out;
 
 	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
-		goto out;
+		goto_out;
 
 	if (_switches[READAHEAD_ARG] &&
 	    !dm_task_set_read_ahead(dmt, _int_args[READAHEAD_ARG],
 				    _read_ahead_flags))
-		goto out;
+		goto_out;
 
 	if (_switches[NOTABLE_ARG])
 		dm_udev_set_sync_support(0);
@@ -1108,10 +1106,10 @@ static int _create(CMD_ARGS)
 			      DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG;
 
 	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
-		goto out;
+		goto_out;
 
 	if (!_set_task_add_node(dmt))
-		goto out;
+		goto_out;
 
 	if (_udev_cookie)
 		cookie = _udev_cookie;
@@ -1121,11 +1119,11 @@ static int _create(CMD_ARGS)
 
 	if (!dm_task_set_cookie(dmt, &cookie, udev_flags) ||
 	    !_task_run(dmt))
-		goto out;
+		goto_out;
 
 	r = 1;
 
-      out:
+out:
 	if (!_udev_cookie)
 		(void) dm_udev_wait(cookie);
 
@@ -1144,26 +1142,26 @@ static int _do_rename(const char *name, const char *new_name, const char *new_uu
 	uint16_t udev_flags = 0;
 
 	if (!(dmt = dm_task_create(DM_DEVICE_RENAME)))
-		return 0;
+		return_0;
 
 	/* FIXME Kernel doesn't support uuid or device number here yet */
 	if (!_set_task_device(dmt, name, 0))
-		goto out;
+		goto_out;
 
 	if (new_uuid) {
 		if (!dm_task_set_newuuid(dmt, new_uuid))
-			goto out;
+			goto_out;
 	} else if (!new_name || !dm_task_set_newname(dmt, new_name))
-		goto out;
+		goto_out;
 
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
-		goto out;
+		goto_out;
 
 	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
-		goto out;
+		goto_out;
 
 	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
-		goto out;
+		goto_out;
 
 	if (_switches[NOUDEVRULES_ARG])
 		udev_flags |= DM_UDEV_DISABLE_DM_RULES_FLAG |
@@ -1177,11 +1175,11 @@ static int _do_rename(const char *name, const char *new_name, const char *new_uu
 
 	if (!dm_task_set_cookie(dmt, &cookie, udev_flags) ||
 	    !_task_run(dmt))
-		goto out;
+		goto_out;
 
 	r = 1;
 
-      out:
+out:
 	if (!_udev_cookie)
 		(void) dm_udev_wait(cookie);
 
@@ -1210,14 +1208,14 @@ static int _message(CMD_ARGS)
 	char *endptr;
 
 	if (!(dmt = dm_task_create(DM_DEVICE_TARGET_MSG)))
-		return 0;
+		return_0;
 
 	if (_switches[UUID_ARG] || _switches[MAJOR_ARG]) {
 		if (!_set_task_device(dmt, NULL, 0))
-			goto out;
+			goto_out;
 	} else {
 		if (!_set_task_device(dmt, argv[0], 0))
-			goto out;
+			goto_out;
 		argc--;
 		argv++;
 	}
@@ -1228,7 +1226,7 @@ static int _message(CMD_ARGS)
 		goto out;
 	}
 	if (!dm_task_set_sector(dmt, sector))
-		goto out;
+		goto_out;
 
 	argc--;
 	argv++;
@@ -1255,19 +1253,19 @@ static int _message(CMD_ARGS)
 	dm_free(str);
 
 	if (!i)
-		goto out;
+		goto_out;
 
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
-		goto out;
+		goto_out;
 
 	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
-		goto out;
+		goto_out;
 
 	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
-		goto out;
+		goto_out;
 
 	if (!_task_run(dmt))
-		goto out;
+		goto_out;
 
 	if ((response = dm_task_get_message_response(dmt))) {
 		if (!*response || response[strlen(response) - 1] == '\n')
@@ -1278,7 +1276,7 @@ static int _message(CMD_ARGS)
 
 	r = 1;
 
-      out:
+out:
 	dm_task_destroy(dmt);
 
 	return r;
@@ -1290,37 +1288,37 @@ static int _setgeometry(CMD_ARGS)
 	struct dm_task *dmt;
 
 	if (!(dmt = dm_task_create(DM_DEVICE_SET_GEOMETRY)))
-		return 0;
+		return_0;
 
 	if (_switches[UUID_ARG] || _switches[MAJOR_ARG]) {
 		if (!_set_task_device(dmt, NULL, 0))
-			goto out;
+			goto_out;
 	} else {
 		if (!_set_task_device(dmt, argv[0], 0))
-			goto out;
+			goto_out;
 		argc--;
 		argv++;
 	}
 
 	if (!dm_task_set_geometry(dmt, argv[0], argv[1], argv[2], argv[3]))
-		goto out;
+		goto_out;
 
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
-		goto out;
+		goto_out;
 
 	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
-		goto out;
+		goto_out;
 
 	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
-		goto out;
+		goto_out;
 
 	/* run the task */
 	if (!_task_run(dmt))
-		goto out;
+		goto_out;
 
 	r = 1;
 
-      out:
+out:
 	dm_task_destroy(dmt);
 
 	return r;
@@ -1373,7 +1371,7 @@ static int _udevflags(CMD_ARGS)
 					       0};
 
 	if (!(cookie = _get_cookie_value(argv[0])))
-		return 0;
+		return_0;
 
 	flags = cookie >> DM_UDEV_FLAGS_SHIFT;
 
@@ -1405,7 +1403,7 @@ static int _udevcomplete(CMD_ARGS)
 	uint32_t cookie;
 
 	if (!(cookie = _get_cookie_value(argv[0])))
-		return 0;
+		return_0;
 
 	/*
 	 * Strip flags from the cookie and use cookie magic instead.
@@ -1519,7 +1517,7 @@ static int _udevcreatecookie(CMD_ARGS)
 	uint32_t cookie;
 
 	if (!dm_udev_create_cookie(&cookie))
-		return 0;
+		return_0;
 
 	if (cookie)
 		printf("0x%08" PRIX32 "\n", cookie);
@@ -1530,7 +1528,7 @@ static int _udevcreatecookie(CMD_ARGS)
 static int _udevreleasecookie(CMD_ARGS)
 {
 	if (argv[0] && !(_udev_cookie = _get_cookie_value(argv[0])))
-		return 0;
+		return_0;
 
 	if (!_udev_cookie) {
 		log_error("No udev transaction cookie given.");
@@ -1686,7 +1684,7 @@ static int _version(CMD_ARGS)
 		printf("Library version:   %s\n", version);
 
 	if (!dm_driver_version(version, sizeof(version)))
-		return 0;
+		return_0;
 
 	printf("Driver version:    %s\n", version);
 
@@ -1710,37 +1708,37 @@ static int _simple(int task, const char *name, uint32_t event_nr, int display)
 	struct dm_task *dmt;
 
 	if (!(dmt = dm_task_create(task)))
-		return 0;
+		return_0;
 
 	if (!_set_task_device(dmt, name, 0))
-		goto out;
+		goto_out;
 
 	if (event_nr && !dm_task_set_event_nr(dmt, event_nr))
-		goto out;
+		goto_out;
 
 	if (_switches[NOFLUSH_ARG] && !dm_task_no_flush(dmt))
-		goto out;
+		goto_out;
 
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
-		goto out;
+		goto_out;
 
 	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
-		goto out;
+		goto_out;
 
 	if (_switches[NOLOCKFS_ARG] && !dm_task_skip_lockfs(dmt))
-		goto out;
+		goto_out;
 
 	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
-		goto out;
+		goto_out;
 
 	/* FIXME: needs to coperate with udev */
 	if (!_set_task_add_node(dmt))
-		goto out;
+		goto_out;
 
 	if (_switches[READAHEAD_ARG] &&
 	    !dm_task_set_read_ahead(dmt, _int_args[READAHEAD_ARG],
 				    _read_ahead_flags))
-		goto out;
+		goto_out;
 
 	if (_switches[NOUDEVRULES_ARG])
 		udev_flags |= DM_UDEV_DISABLE_DM_RULES_FLAG |
@@ -1753,7 +1751,7 @@ static int _simple(int task, const char *name, uint32_t event_nr, int display)
 		udev_flags |= DM_UDEV_DISABLE_LIBRARY_FALLBACK;
 
 	if (udev_wait_flag && !dm_task_set_cookie(dmt, &cookie, udev_flags))
-		goto out;
+		goto_out;
 
 	if (_switches[RETRY_ARG] && task == DM_DEVICE_REMOVE)
 		dm_task_retry_remove(dmt);
@@ -1763,7 +1761,7 @@ static int _simple(int task, const char *name, uint32_t event_nr, int display)
 
 	r = _task_run(dmt);
 
-      out:
+out:
 	if (!_udev_cookie && udev_wait_flag)
 		(void) dm_udev_wait(cookie);
 
@@ -1817,19 +1815,19 @@ static int _process_all(const struct command *cmd, const char *subcommand, int a
 	struct dm_task *dmt;
 
 	if (!(dmt = dm_task_create(DM_DEVICE_LIST)))
-		return 0;
+		return_0;
 
 	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
-		goto out;
+		goto_out;
 
 	if (!_task_run(dmt)) {
 		r = 0;
-		goto out;
+		goto_out;
 	}
 
 	if (!(names = dm_task_get_names(dmt))) {
 		r = 0;
-		goto out;
+		goto_out;
 	}
 
 	if (!names->dev) {
@@ -1845,7 +1843,7 @@ static int _process_all(const struct command *cmd, const char *subcommand, int a
 		next = names->next;
 	} while (next);
 
-      out:
+out:
 	dm_task_destroy(dmt);
 	return r;
 }
@@ -1859,25 +1857,25 @@ static uint64_t _get_device_size(const char *name)
 	void *next = NULL;
 
 	if (!(dmt = dm_task_create(DM_DEVICE_TABLE)))
-		return 0;
+		return_0;
 
 	if (!_set_task_device(dmt, name, 0))
-		goto out;
+		goto_out;
 
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
-		goto out;
+		goto_out;
 
 	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
-		goto out;
+		goto_out;
 
 	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
-		goto out;
+		goto_out;
 
 	if (!_task_run(dmt))
-		goto out;
+		goto_out;
 
 	if (!dm_task_get_info(dmt, &info) || !info.exists)
-		goto out;
+		goto_out;
 
 	do {
 		next = dm_get_next_target(dmt, next, &start, &length,
@@ -1885,7 +1883,7 @@ static uint64_t _get_device_size(const char *name)
 		size += length;
 	} while (next);
 
-      out:
+out:
 	dm_task_destroy(dmt);
 	return size;
 }
@@ -1902,37 +1900,37 @@ static int _error_device(CMD_ARGS)
 	size = _get_device_size(name);
 
 	if (!(dmt = dm_task_create(DM_DEVICE_RELOAD)))
-		return 0;
+		return_0;
 
 	if (!_set_task_device(dmt, name, 0))
-		goto error;
+		goto_bad;
 
 	if (!dm_task_add_target(dmt, UINT64_C(0), size, "error", ""))
-		goto error;
+		goto_bad;
 
 	if (_switches[READ_ONLY] && !dm_task_set_ro(dmt))
-		goto error;
+		goto_bad;
 
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
-		goto error;
+		goto_bad;
 
 	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
-		goto error;
+		goto_bad;
 
 	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
-		goto error;
+		goto_bad;
 
 	if (!_task_run(dmt))
-		goto error;
+		goto_bad;
 
 	if (!_simple(DM_DEVICE_RESUME, name, 0, 0)) {
 		_simple(DM_DEVICE_CLEAR, name, 0, 0);
-		goto error;
+		goto_bad;
 	}
 
 	r = 1;
 
-error:
+bad:
 	dm_task_destroy(dmt);
 	return r;
 }
@@ -2013,14 +2011,14 @@ static int _exec_command(const char *name)
 	pid_t pid;
 
 	if (argc < 0)
-		return 0;
+		return_0;
 
 	if (!dm_mknodes(name))
-		return 0;
+		return_0;
 
 	n = snprintf(path, sizeof(path), "%s/%s", dm_dir(), name);
 	if (n < 0 || n > (int) sizeof(path) - 1)
-		return 0;
+		return_0;
 
 	if (!argc) {
 		c = _command_to_exec;
@@ -2038,7 +2036,7 @@ static int _exec_command(const char *name)
 
 		if (!argc) {
 			argc = -1;
-			return 0;
+			return_0;
 		}
 
 		if (argc == ARGS_MAX) {
@@ -2093,28 +2091,28 @@ static int _status(CMD_ARGS)
 		ls_only = 1;
 
 	if (!(dmt = dm_task_create(cmdno)))
-		return 0;
+		return_0;
 
 	if (!_set_task_device(dmt, name, 0))
-		goto out;
+		goto_out;
 
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
-		goto out;
+		goto_out;
 
 	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
-		goto out;
+		goto_out;
 
 	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
-		goto out;
+		goto_out;
 
 	if (_switches[NOFLUSH_ARG] && !dm_task_no_flush(dmt))
-		goto out;
+		goto_out;
 
 	if (!_task_run(dmt))
-		goto out;
+		goto_out;
 
 	if (!dm_task_get_info(dmt, &info) || !info.exists)
-		goto out;
+		goto_out;
 
 	if (!name)
 		name = dm_task_get_name(dmt);
@@ -2163,11 +2161,11 @@ static int _status(CMD_ARGS)
 		printf("\n");
 
 	if (matched && _switches[EXEC_ARG] && _command_to_exec && !_exec_command(name))
-		goto out;
+		goto_out;
 
 	r = 1;
 
-      out:
+out:
 	dm_task_destroy(dmt);
 	return r;
 }
@@ -2181,13 +2179,13 @@ static int _targets(CMD_ARGS)
 	struct dm_versions *last_target;
 
 	if (!(dmt = dm_task_create(DM_DEVICE_LIST_VERSIONS)))
-		return 0;
+		return_0;
 
 	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
-		goto out;
+		goto_out;
 
 	if (!_task_run(dmt))
-		goto out;
+		goto_out;
 
 	target = dm_task_get_versions(dmt);
 
@@ -2203,7 +2201,7 @@ static int _targets(CMD_ARGS)
 
 	r = 1;
 
-      out:
+out:
 	dm_task_destroy(dmt);
 	return r;
 }
@@ -2224,26 +2222,26 @@ static int _info(CMD_ARGS)
 	}
 
 	if (!(dmt = dm_task_create(DM_DEVICE_INFO)))
-		return 0;
+		return_0;
 
 	if (!_set_task_device(dmt, name, 0))
-		goto out;
+		goto_out;
 
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
-		goto out;
+		goto_out;
 
 	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
-		goto out;
+		goto_out;
 
 	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
-		goto out;
+		goto_out;
 
 	if (!_task_run(dmt))
-		goto out;
+		goto_out;
 
 	r = _display_info(dmt);
 
-      out:
+out:
 	dm_task_destroy(dmt);
 	return r;
 }
@@ -2268,28 +2266,28 @@ static int _deps(CMD_ARGS)
 	}
 
 	if (!(dmt = dm_task_create(DM_DEVICE_DEPS)))
-		return 0;
+		return_0;
 
 	if (!_set_task_device(dmt, name, 0))
-		goto out;
+		goto_out;
 
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
-		goto out;
+		goto_out;
 
 	if (_switches[INACTIVE_ARG] && !dm_task_query_inactive_table(dmt))
-		goto out;
+		goto_out;
 
 	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
-		goto out;
+		goto_out;
 
 	if (!_task_run(dmt))
-		goto out;
+		goto_out;
 
 	if (!dm_task_get_info(dmt, &info))
-		goto out;
+		goto_out;
 
 	if (!(deps = dm_task_get_deps(dmt)))
-		goto out;
+		goto_out;
 
 	if (!info.exists) {
 		printf("Device does not exist.\n");
@@ -2322,7 +2320,7 @@ static int _deps(CMD_ARGS)
 
 	r = 1;
 
-      out:
+out:
 	dm_task_destroy(dmt);
 	return r;
 }
@@ -2670,7 +2668,7 @@ static int _add_dep(CMD_ARGS)
 {
 	if (names &&
 	    !dm_tree_add_dev(_dtree, (unsigned) MAJOR(names->dev), (unsigned) MINOR(names->dev)))
-		return 0;
+		return_0;
 
 	return 1;
 }
@@ -2684,10 +2682,10 @@ static int _build_whole_deptree(const struct command *cmd)
 		return 1;
 
 	if (!(_dtree = dm_tree_create()))
-		return 0;
+		return_0;
 
 	if (!_process_all(cmd, NULL, 0, NULL, 0, _add_dep))
-		return 0;
+		return_0;
 
 	return 1;
 }
@@ -2695,7 +2693,7 @@ static int _build_whole_deptree(const struct command *cmd)
 static int _display_tree(CMD_ARGS)
 {
 	if (!_build_whole_deptree(cmd))
-		return 0;
+		return_0;
 
 	_display_tree_walk_children(dm_tree_find_node(_dtree, 0, 0), 0);
 
@@ -2732,7 +2730,7 @@ static int _show_units(void)
 {
 	/* --nosuffix overrides --units */
 	if (_switches[NOSUFFIX_ARG])
-		return 0;
+		return_0;
 
 	return (_int_args[UNITS_ARG]) ? 1 : 0;
 }
@@ -2944,8 +2942,10 @@ static int _dm_info_devno_disp(struct dm_report *rh, struct dm_pool *mem,
 
 	if (private) {
 		if (!dm_device_get_name(info->major, info->minor,
-					1, buf, PATH_MAX))
+					1, buf, PATH_MAX)) {
+			stack;
 			goto out_abandon;
+		}
 	}
 	else {
 		if (dm_snprintf(buf, sizeof(buf), "%d:%d",
@@ -4375,7 +4375,7 @@ static int _report_init(const struct command *cmd, const char *subcommand)
 	if (!(_report = dm_report_init_with_selection(&_report_type, _report_types,
 				_report_fields, options, separator, flags, keys,
 				selection, NULL, NULL)))
-		goto out;
+		goto_out;
 
 	if ((_report_type & DR_TREE) && !_build_whole_deptree(cmd)) {
 		err("Internal device dependency tree creation failed.");
@@ -4431,19 +4431,19 @@ static int _mangle(CMD_ARGS)
 	}
 
 	if (!(dmt = dm_task_create(DM_DEVICE_STATUS)))
-		return 0;
+		return_0;
 
 	if (!(_set_task_device(dmt, name, 0)))
-		goto out;
+		goto_out;
 
 	if (!_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
-		goto out;
+		goto_out;
 
 	if (!_task_run(dmt))
-		goto out;
+		goto_out;
 
 	if (!dm_task_get_info(dmt, &info) || !info.exists)
-		goto out;
+		goto_out;
 
 	uuid = dm_task_get_uuid(dmt);
 
@@ -4465,15 +4465,15 @@ static int _mangle(CMD_ARGS)
 
 	if (target_format == DM_STRING_MANGLING_NONE) {
 		if (!(new_name = dm_task_get_name_unmangled(dmt)))
-			goto out;
+			goto_out;
 		if (!(new_uuid = dm_task_get_uuid_unmangled(dmt)))
-			goto out;
+			goto_out;
 	}
 	else {
 		if (!(new_name = dm_task_get_name_mangled(dmt)))
-			goto out;
+			goto_out;
 		if (!(new_uuid = dm_task_get_uuid_mangled(dmt)))
-			goto out;
+			goto_out;
 	}
 
 	/* We can't rename the UUID, the device must be reactivated manually. */
@@ -4508,13 +4508,13 @@ static int _stats(CMD_ARGS);
 static int _bind_stats_device(struct dm_stats *dms, const char *name)
 {
 	if (name && !dm_stats_bind_name(dms, name))
-		return 0;
+		return_0;
 	else if (_switches[UUID_ARG] && !dm_stats_bind_uuid(dms, _uuid))
-		return 0;
+		return_0;
 	else if (_switches[MAJOR_ARG] && _switches[MINOR_ARG]
 		 && !dm_stats_bind_devno(dms, _int_args[MAJOR_ARG],
 					 _int_args[MINOR_ARG]))
-		return 0;
+		return_0;
 
 	return 1;
 }
@@ -4524,10 +4524,10 @@ static int _stats_clear_regions(struct dm_stats *dms, uint64_t region_id)
 	int allregions = (region_id == DM_STATS_REGIONS_ALL);
 
 	if (!dm_stats_list(dms, NULL))
-		goto_out;
+		return_0;
 
 	if (!dm_stats_get_nr_regions(dms))
-		goto done;
+		return 1;
 
 	dm_stats_walk_do(dms) {
 		if (allregions)
@@ -4535,21 +4535,18 @@ static int _stats_clear_regions(struct dm_stats *dms, uint64_t region_id)
 
 		if (!dm_stats_region_present(dms, region_id)) {
 			log_error("No such region: %"PRIu64".", region_id);
-			goto out;
+			return 0;
 		}
 		if (!dm_stats_clear_region(dms, region_id)) {
 			log_error("Clearing statistics region %"PRIu64" failed.",
 				  region_id);
-			goto out;
+			return 0;
 		}
 		log_info("Cleared statistics region %"PRIu64".", region_id);
 		dm_stats_walk_next_region(dms);
 	} dm_stats_walk_while(dms);
-done:
-	return 1;
 
-out:
-	return 0;
+	return 1;
 }
 
 static int _stats_clear(CMD_ARGS)
@@ -4611,7 +4608,7 @@ static int _size_from_string(char *argptr, uint64_t *size, const char *name)
 	uint64_t factor;
 	char *endptr = NULL, unit_type;
 	if (!argptr)
-		return 0;
+		return_0;
 
 	*size = strtoull(argptr, &endptr, 10);
 	if (endptr == argptr) {
@@ -4674,30 +4671,30 @@ static int _do_stats_create_regions(struct dm_stats *dms,
 	void *next = NULL;
 
 	if (histogram && !(bounds = dm_histogram_bounds_from_string(histogram)))
-		return 0;
+		return_0;
 
 	if (!(dmt = dm_task_create(DM_DEVICE_TABLE))) {
 		dm_stats_destroy(dms);
-		return 0;
+		return_0;
 	}
 
 	if (!_set_task_device(dmt, name, 0))
-		goto out;
+		goto_out;
 
 	if (!dm_task_no_open_count(dmt))
-		goto out;
+		goto_out;
 
 	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
-		goto out;
+		goto_out;
 
 	if (!_task_run(dmt))
-		goto out;
+		goto_out;
 
 	if (!dm_task_get_info(dmt, &info) || !info.exists)
-		goto out;
+		goto_out;
 
 	if (!(devname = dm_task_get_name(dmt)))
-		goto out;
+		goto_out;
 
 	do {
 		uint64_t segment_start, segment_len;
@@ -4797,7 +4794,7 @@ static int _stats_create(CMD_ARGS)
 	if (_switches[AREA_SIZE_ARG])
 		if (!_size_from_string(_string_args[AREA_SIZE_ARG],
 				       &area_size, "areasize"))
-			return 0;
+			return_0;
 
 	areas = (areas) ? areas : 1;
 	/* bytes to sectors or -(areas): promote to signed before conversion */
@@ -4806,7 +4803,7 @@ static int _stats_create(CMD_ARGS)
 	if (_switches[START_ARG]) {
 		if (!_size_from_string(_string_args[START_ARG],
 				       &start, "start"))
-			return 0;
+			return_0;
 	}
 
 	/* bytes to sectors */
@@ -4815,7 +4812,7 @@ static int _stats_create(CMD_ARGS)
 	if (_switches[LENGTH_ARG]) {
 		if (!_size_from_string(_string_args[LENGTH_ARG],
 				       &len, "length"))
-			return 0;
+			return_0;
 	}
 
 	/* bytes to sectors */
@@ -4831,13 +4828,13 @@ static int _stats_create(CMD_ARGS)
 
 	dms = dm_stats_create(DM_STATS_PROGRAM_ID);
 	if (!_bind_stats_device(dms, name))
-		goto_out;
+		goto_bad;
 
 	if (_switches[PRECISE_ARG]) {
 		if (!dm_stats_driver_supports_precise()) {
 			log_error("Using --precise requires driver version "
 				  "4.32.0 or later.");
-			goto out;
+			goto bad;
 		}
 	}
 
@@ -4845,7 +4842,7 @@ static int _stats_create(CMD_ARGS)
 		if (!dm_stats_driver_supports_histogram()) {
 			log_error("Using --bounds requires driver version "
 				  "4.32.0 or later.");
-			goto out;
+			goto bad;
 		}
 	}
 
@@ -4857,7 +4854,7 @@ static int _stats_create(CMD_ARGS)
 					_switches[SEGMENTS_ARG],
 					program_id, aux_data);
 
-out:
+bad:
 	dm_stats_destroy(dms);
 	return 0;
 }
@@ -4869,6 +4866,7 @@ static int _stats_delete(CMD_ARGS)
 	char *name = NULL;
 	const char *program_id = DM_STATS_PROGRAM_ID;
 	int allregions = _switches[ALL_REGIONS_ARG];
+	int r = 0;
 
 	/* delete does not use a report */
 	if (_report) {
@@ -4908,9 +4906,11 @@ static int _stats_delete(CMD_ARGS)
 	if (allregions && !dm_stats_list(dms, program_id))
 		goto_out;
 
-	if (allregions && !dm_stats_get_nr_regions(dms))
+	if (allregions && !dm_stats_get_nr_regions(dms)) {
 		/* no regions present */
-		goto done;
+		r = 1;
+		goto out;
+	}
 
 	dm_stats_walk_do(dms) {
 		if (_switches[ALL_REGIONS_ARG])
@@ -4923,13 +4923,11 @@ static int _stats_delete(CMD_ARGS)
 		dm_stats_walk_next_region(dms);
 	} dm_stats_walk_while(dms);
 
-done:
-	dm_stats_destroy(dms);
-	return 1;
+	r = 1;
 
 out:
 	dm_stats_destroy(dms);
-	return 0;
+	return r;
 }
 
 static int _stats_print(CMD_ARGS)
@@ -4939,6 +4937,7 @@ static int _stats_print(CMD_ARGS)
 	uint64_t region_id;
 	unsigned clear = (unsigned) _switches[CLEAR_ARG];
 	int allregions = _switches[ALL_REGIONS_ARG];
+	int r = 0;
 
 	/* print does not use a report */
 	if (_report) {
@@ -4969,8 +4968,10 @@ static int _stats_print(CMD_ARGS)
 	if (!dm_stats_list(dms, NULL))
 		goto_out;
 
-	if (allregions && !dm_stats_get_nr_regions(dms))
-		goto done;
+	if (allregions && !dm_stats_get_nr_regions(dms)) {
+		r = 1;
+		goto out;
+	}
 
 	dm_stats_walk_do(dms) {
 		if (_switches[ALL_REGIONS_ARG])
@@ -4994,13 +4995,11 @@ static int _stats_print(CMD_ARGS)
 
 	} dm_stats_walk_while(dms);
 
-done:
-	dm_stats_destroy(dms);
-	return 1;
+	r = 1;
 
 out:
 	dm_stats_destroy(dms);
-	return 0;
+	return r;
 }
 
 static int _stats_report(CMD_ARGS)
@@ -5028,25 +5027,27 @@ static int _stats_report(CMD_ARGS)
 	}
 
 	if (!(dmt = dm_task_create(DM_DEVICE_INFO)))
-		return 0;
+		return_0;
 
 	if (!_set_task_device(dmt, name, 0))
-		goto out;
+		goto_out;
 
 	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
-		goto out;
+		goto_out;
 
 	if (!_task_run(dmt))
-		goto out;
+		goto_out;
 
 	r = _display_info(dmt);
 
-      out:
+out:
 	dm_task_destroy(dmt);
+
 	if (!r && _report) {
 		dm_report_free(_report);
 		_report = NULL;
 	}
+
 	return r;
 }
 
@@ -5321,7 +5322,7 @@ static int _stats(CMD_ARGS)
 	 */
 	if (!stats_cmd->fn(stats_cmd, subcommand, argc, argv, NULL,
 			   multiple_devices))
-		return 0;
+		return_0;
 
 	return 1;
 }
@@ -5418,35 +5419,35 @@ static char *parse_loop_device_name(const char *dev, const char *dev_dir)
 	char *device = NULL;
 
 	if (!(buf = dm_malloc(PATH_MAX)))
-		return NULL;
+		return_NULL;
 
 	if (dev[0] == '/') {
 		if (!(device = _get_abspath(dev)))
-			goto error;
+			goto_bad;
 
 		if (strncmp(device, dev_dir, strlen(dev_dir)))
-			goto error;
+			goto_bad;
 
 		/* If dev_dir does not end in a slash, ensure that the
 		   following byte in the device string is "/".  */
 		if (dev_dir[strlen(dev_dir) - 1] != '/' &&
 		    device[strlen(dev_dir)] != '/')
-			goto error;
+			goto_bad;
 
 		if (!dm_strncpy(buf, strrchr(device, '/') + 1, PATH_MAX))
-			goto error;
+			goto_bad;
 		dm_free(device);
 	} else {
 		/* check for device number */
 		if (strncmp(dev, "loop", sizeof("loop") - 1))
-			goto error;
+			goto_bad;
 
 		if (!dm_strncpy(buf, dev, PATH_MAX))
-			goto error;
+			goto_bad;
 	}
 
 	return buf;
-error:
+bad:
 	dm_free(device);
 	dm_free(buf);
 
@@ -5476,10 +5477,10 @@ static int _loop_table(char *table, size_t tlen, char *file,
 	}
 
 	if (fd < 0)
-		goto error;
+		goto_bad;
 
 	if (fstat(fd, &fbuf))
-		goto error;
+		goto_bad;
 
 	size = (fbuf.st_size - off);
 	sectors = size >> SECTOR_SHIFT;
@@ -5491,7 +5492,7 @@ static int _loop_table(char *table, size_t tlen, char *file,
 
 #ifdef HAVE_SYS_STATVFS_H
 	if (fstatvfs(fd, &fsbuf))
-		goto error;
+		goto_bad;
 
 	/* FIXME Fragment size currently unused */
 	blksize = fsbuf.f_frsize;
@@ -5502,18 +5503,18 @@ static int _loop_table(char *table, size_t tlen, char *file,
 
 	if (dm_snprintf(table, tlen, "%llu %llu loop %s %llu\n", 0ULL,
 			(long long unsigned)sectors, file, (long long unsigned)off) < 0)
-		return 0;
+		return_0;
 
 	if (_switches[VERBOSE_ARG] > 1)
 		fprintf(stderr, "Table: %s\n", table);
 
 	return 1;
 
-error:
+bad:
 	if (fd > -1 && close(fd))
 		log_sys_error("close", file);
 
-	return 0;
+	return_0;
 }
 
 static int _process_losetup_switches(const char *base, int *argcp, char ***argvp,
@@ -5536,7 +5537,7 @@ static int _process_losetup_switches(const char *base, int *argcp, char ***argvp
 	while ((c = GETOPTLONG_FN(*argcp, *argvp, "ade:fo:v",
 				  long_options, NULL)) != -1 ) {
 		if (c == ':' || c == '?')
-			return 0;
+			return_0;
 		if (c == 'a')
 			show_all++;
 		if (c == 'd')
@@ -5836,7 +5837,7 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			_string_args[AUX_DATA_ARG] = optarg;
 		}
 		if (c == ':' || c == '?')
-			return 0;
+			return_0;
 		if (c == 'h' || ind == HELP_ARG)
 			_switches[HELP_ARG]++;
 		if (ind == BOUNDS_ARG) {
@@ -6201,7 +6202,7 @@ unknown:
 
 #ifdef UDEV_SYNC_SUPPORT
 	if (!_set_up_udev_support(dev_dir))
-		goto out;
+		goto_out;
 #endif
 
 	/*
@@ -6215,7 +6216,7 @@ unknown:
 		subcommand = (char *) "";
 
 	if (_switches[COLS_ARG] && !_report_init(cmd, subcommand))
-		goto out;
+		goto_out;
 
 	if (_switches[COUNT_ARG])
 		_count = ((uint32_t)_int_args[COUNT_ARG]) ? : UINT32_MAX;


