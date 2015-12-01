From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  1 Dec 2015 12:04:51 +0000 (UTC)
Subject: master - cleanup: use dm_get_status_mirror
Message-ID: <20151201120451.6A41E60CF9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=86e7894ecceede2e4977cb9d8f39f5fa53e6f5ea
Commit:        86e7894ecceede2e4977cb9d8f39f5fa53e6f5ea
Parent:        6336ef98d41b8c5b1435de08855aa66c8fd527c2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 30 21:17:25 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 1 13:03:16 2015 +0100

cleanup: use dm_get_status_mirror

Use libdm function to parse mirror status report.
---
 WHATS_NEW                                         |    1 +
 WHATS_NEW_DM                                      |    1 +
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c |  121 ++++++---------
 lib/activate/dev_manager.c                        |  108 +++-----------
 lib/mirror/mirrored.c                             |  167 +++++++--------------
 5 files changed, 118 insertions(+), 280 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index dcd2b22..d9222bc 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.137 -
 =====================================
+  Use dm_get_status_mirror() instead of individual parsers.
   Add mem pool arg for check_transient_status() target function.
   Avoid misleading error with -m is omitted with lvconvert to raid types.
 
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 689fe43..3357cec 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.113 - 
 =====================================
+  Mirror plugin in dmeventd uses dm_get_status_mirror().
   Add dm_get_status_mirror() for parsing mirror status line.
 
 Version 1.02.112 - 28th November 2015
diff --git a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
index e20b249..68fe728 100644
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -31,8 +31,9 @@ struct dso_state {
 
 DM_EVENT_LOG_FN("mirr")
 
-static int _process_status_code(const char status_code, const char *dev_name,
-				const char *dev_type, int r)
+static void _process_status_code(dm_status_mirror_health_t health,
+				 uint32_t major, uint32_t minor,
+				 const char *dev_type, int *r)
 {
 	/*
 	 *    A => Alive - No failures
@@ -42,90 +43,60 @@ static int _process_status_code(const char status_code, const char *dev_name,
 	 *    R => Read - A read failure occurred, mirror data unaffected
 	 *    U => Unclassified failure (bug)
 	 */ 
-	if (status_code == 'F') {
-		log_error("%s device %s flush failed.", dev_type, dev_name);
-		r = ME_FAILURE;
-	} else if (status_code == 'S')
-		log_error("%s device %s sync failed.", dev_type, dev_name);
-	else if (status_code == 'R')
-		log_error("%s device %s read failed.", dev_type, dev_name);
-	else if (status_code != 'A') {
-		log_error("%s device %s has failed (%c).",
-			  dev_type, dev_name, status_code);
-		r = ME_FAILURE;
+	switch (health) {
+	case DM_STATUS_MIRROR_ALIVE:
+		return;
+	case DM_STATUS_MIRROR_FLUSH_FAILED:
+		log_error("%s device %u:%u flush failed.",
+			  dev_type, major, minor);
+		*r = ME_FAILURE;
+		break;
+	case DM_STATUS_MIRROR_SYNC_FAILED:
+		log_error("%s device %u:%u sync failed.",
+			  dev_type, major, minor);
+		break;
+	case DM_STATUS_MIRROR_READ_FAILED:
+		log_error("%s device %u:%u read failed.",
+			  dev_type, major, minor);
+		break;
+	default:
+		log_error("%s device %u:%u has failed (%c).",
+			  dev_type, major, minor, (char)health);
+		*r = ME_FAILURE;
+		break;
 	}
-
-	return r;
 }
 
-static int _get_mirror_event(char *params)
+static int _get_mirror_event(struct dso_state *state, char *params)
 {
-	int i, r = ME_INSYNC;
-	char **args = NULL;
-	char *dev_status_str;
-	char *log_status_str;
-	char *sync_str;
-	char *p = NULL;
-	int log_argc, num_devs;
+	int r = ME_INSYNC;
+	unsigned i;
+	struct dm_status_mirror *ms;
 
-	/*
-	 * dm core parms:	     0 409600 mirror
-	 * Mirror core parms:	     2 253:4 253:5 400/400
-	 * New-style failure params: 1 AA
-	 * New-style log params:     3 cluster 253:3 A
-	 *			 or  3 disk 253:3 A
-	 *			 or  1 core
-	 */
-
-	/* number of devices */
-	if (!dm_split_words(params, 1, 0, &p))
-		goto out_parse;
-
-	if (!(num_devs = atoi(p)) ||
-	    (num_devs > DEFAULT_MIRROR_MAX_IMAGES) || (num_devs < 0))
-		goto out_parse;
-	p += strlen(p) + 1;
-
-	/* devices names + "400/400" + "1 AA" + 1 or 3 log parms + NULL */
-	args = dm_malloc((num_devs + 7) * sizeof(char *));
-	if (!args || dm_split_words(p, num_devs + 7, 0, args) < num_devs + 5)
-		goto out_parse;
-
-	/* FIXME: Code differs from lib/mirror/mirrored.c */
-	dev_status_str = args[2 + num_devs];
-	log_argc = atoi(args[3 + num_devs]);
-	log_status_str = args[3 + num_devs + log_argc];
-	sync_str = args[num_devs];
+	if (dm_get_status_mirror(state->mem, params, &ms))
+		goto_out;
 
 	/* Check for bad mirror devices */
-	for (i = 0; i < num_devs; i++)
-		r = _process_status_code(dev_status_str[i], args[i],
-			i ? "Secondary mirror" : "Primary mirror", r);
+	for (i = 0; i < ms->dev_count; ++i)
+		_process_status_code(ms->devs[i].health,
+				     ms->devs[i].major, ms->devs[i].minor,
+				     i ? "Secondary mirror" : "Primary mirror", &r);
 
 	/* Check for bad disk log device */
-	if (log_argc > 1)
-		r = _process_status_code(log_status_str[0],
-					 args[2 + num_devs + log_argc],
-					 "Log", r);
-
-	if (r == ME_FAILURE)
-		goto out;
-
-	p = strstr(sync_str, "/");
-	if (p) {
-		p[0] = '\0';
-		if (strcmp(sync_str, p+1))
-			r = ME_IGNORE;
-		p[0] = '/';
-	} else
-		goto out_parse;
+	for (i = 0; i < ms->log_count; ++i)
+		_process_status_code(ms->logs[i].health,
+				     ms->logs[i].major, ms->logs[i].minor,
+				     "Log", &r);
+
+	/* Ignore if not in-sync */
+	if ((r == ME_INSYNC) && (ms->insync_regions != ms->total_regions))
+		r = ME_IGNORE;
+
+	dm_pool_free(state->mem, ms);
 
-out:
-	dm_free(args);
 	return r;
 
-out_parse:
-	dm_free(args);
+out:
 	log_error("Unable to parse mirror status string.");
 
 	return ME_IGNORE;
@@ -172,7 +143,7 @@ void process_event(struct dm_task *dmt,
 			continue;
 		}
 
-		switch(_get_mirror_event(params)) {
+		switch(_get_mirror_event(state, params)) {
 		case ME_INSYNC:
 			/* FIXME: all we really know is that this
 			   _part_ of the device is in sync
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 4eff5cb..4d0b4d8 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -247,79 +247,6 @@ static int _info_run(info_type_t type, const char *name, const char *dlid,
 }
 
 /*
- * _parse_mirror_status
- * @mirror_status_string
- * @image_health:  return for allocated copy of image health characters
- * @log_device: return for 'dev_t' of log device
- * @log_health: NULL if corelog, otherwise dm_malloc'ed log health char which
- *              the caller must free
- *
- * This function takes the mirror status string, breaks it up and returns
- * its components.  For now, we only return the health characters.  This
- * is an internal function.  If there are more things we want to return
- * later, we can do that then.
- *
- * Returns: 1 on success, 0 on failure
- */
-static int _parse_mirror_status(char *mirror_status_str,
-				char **images_health,
-				dev_t *log_dev, char **log_health)
-{
-	int major, minor;
-	char *p = NULL;
-	char **args, **log_args;
-	unsigned num_devs, log_argc;
-
-	*images_health = NULL;
-	*log_health = NULL;
-	*log_dev = 0;
-
-	if (!dm_split_words(mirror_status_str, 1, 0, &p) ||
-	    !(num_devs = (unsigned) atoi(p)))
-		/* On errors, we must assume the mirror is to be avoided */
-		return_0;
-
-	p += strlen(p) + 1;
-	args = alloca((num_devs + 5) * sizeof(char *));
-
-	if ((unsigned)dm_split_words(p, num_devs + 4, 0, args) < num_devs + 4)
-		return_0;
-
-	log_argc = (unsigned) atoi(args[3 + num_devs]);
-	log_args = alloca(log_argc * sizeof(char *));
-
-	if ((unsigned)dm_split_words(args[3 + num_devs] + strlen(args[3 + num_devs]) + 1,
-				     log_argc, 0, log_args) < log_argc)
-		return_0;
-
-	if (!strcmp(log_args[0], "disk")) {
-		if (!(*log_health = dm_strdup(log_args[2]))) {
-			log_error("Allocation of log string failed.");
-			return 0;
-		}
-		if (sscanf(log_args[1], "%d:%d", &major, &minor) != 2) {
-			log_error("Failed to parse log's device number from %s.", log_args[1]);
-			goto out;
-		}
-		*log_dev = MKDEV((dev_t)major, minor);
-	}
-
-	if (!(*images_health = dm_strdup(args[2 + num_devs]))) {
-		log_error("Allocation of images string failed.");
-		goto out;
-	}
-
-	return 1;
-
-out:
-	dm_free(*log_health);
-	*log_health = NULL;
-	*log_dev = 0;
-
-	return 0;
-}
-
-/*
  * ignore_blocked_mirror_devices
  * @dev
  * @start
@@ -349,44 +276,45 @@ static int _ignore_blocked_mirror_devices(struct device *dev,
 					  uint64_t start, uint64_t length,
 					  char *mirror_status_str)
 {
+	struct dm_pool *mem;
+	struct dm_status_mirror *sm;
 	unsigned i, check_for_blocking = 0;
-	dev_t log_dev;
-	char *images_health, *log_health;
 	uint64_t s,l;
 	char *p, *params, *target_type = NULL;
 	void *next = NULL;
 	struct dm_task *dmt = NULL;
 	int r = 0;
+	struct device *tmp_dev;
+	char buf[16];
 
-	if (!_parse_mirror_status(mirror_status_str,
-				  &images_health, &log_dev, &log_health))
+	if (!(mem = dm_pool_create("blocked_mirrors", 128)))
 		return_0;
 
-	for (i = 0; images_health[i]; i++)
-		if (images_health[i] != 'A') {
+	if (!dm_get_status_mirror(mem, mirror_status_str, &sm))
+		goto_out;
+
+	for (i = 0; i < sm->dev_count; ++i)
+		if (sm->devs[i].health != DM_STATUS_MIRROR_ALIVE) {
 			log_debug_activation("%s: Mirror image %d marked as failed",
 					     dev_name(dev), i);
 			check_for_blocking = 1;
 		}
 
-	if (!check_for_blocking && log_dev) {
-		if (log_health[0] != 'A') {
+	if (!check_for_blocking && sm->log_count) {
+		if (sm->logs[0].health != DM_STATUS_MIRROR_ALIVE) {
 			log_debug_activation("%s: Mirror log device marked as failed",
 					     dev_name(dev));
 			check_for_blocking = 1;
 		} else {
-			struct device *tmp_dev;
-			char buf[16];
 
-			if (dm_snprintf(buf, sizeof(buf), "%d:%d",
-					(int)MAJOR(log_dev),
-					(int)MINOR(log_dev)) < 0)
+			if (dm_snprintf(buf, sizeof(buf), "%u:%u",
+					sm->logs[0].major, sm->logs[0].minor) < 0)
 				goto_out;
 
 			if (!(tmp_dev = dev_create_file(buf, NULL, NULL, 0)))
 				goto_out;
 
-			tmp_dev->dev = log_dev;
+			tmp_dev->dev = MKDEV((dev_t)sm->logs[0].major, sm->logs[0].minor);
 			if (device_is_usable(tmp_dev, (struct dev_usable_check_params)
 					     { .check_empty = 1,
 					       .check_blocked = 1,
@@ -440,8 +368,8 @@ static int _ignore_blocked_mirror_devices(struct device *dev,
 out:
 	if (dmt)
 		dm_task_destroy(dmt);
-	dm_free(log_health);
-	dm_free(images_health);
+
+	dm_pool_destroy(mem);
 
 	return r;
 }
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index b810c70..371718d 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -168,161 +168,94 @@ static int _mirrored_target_percent(void **target_state,
 				    uint64_t *total_numerator,
 				    uint64_t *total_denominator)
 {
-	uint64_t numerator, denominator;
-	unsigned mirror_count, m;
-	int used;
-	char *pos = params;
+	struct dm_status_mirror *sm;
 
 	if (!*target_state)
 		*target_state = _mirrored_init_target(mem, cmd);
 
-	/* Status line: <#mirrors> (maj:min)+ <synced>/<total_regions> */
-	log_debug_activation("Mirror status: %s", params);
-
-	if (sscanf(pos, "%u %n", &mirror_count, &used) != 1) {
-		log_error("Failure parsing mirror status mirror count: %s",
-			  params);
-		return 0;
-	}
-	pos += used;
-
-	for (m = 0; m < mirror_count; m++) {
-		if (sscanf(pos, "%*x:%*x %n", &used) != 0) {
-			log_error("Failure parsing mirror status devices: %s",
-				  params);
-			return 0;
-		}
-		pos += used;
-	}
-
-	if (sscanf(pos, FMTu64 "/" FMTu64 "%n", &numerator, &denominator,
-		   &used) != 2) {
-		log_error("Failure parsing mirror status fraction: %s", params);
-		return 0;
-	}
-	pos += used;
+	if (!dm_get_status_mirror(mem, params, &sm))
+		return_0;
 
-	*total_numerator += numerator;
-	*total_denominator += denominator;
+	*total_numerator += sm->insync_regions;
+	*total_denominator += sm->total_regions;
 
 	if (seg)
-		seg->extents_copied = seg->area_len * numerator / denominator;
+		seg->extents_copied = seg->area_len * sm->insync_regions / sm->total_regions;
+
+	*percent = dm_make_percent(sm->insync_regions, sm->total_regions);
 
-        *percent = dm_make_percent(numerator, denominator);
+	dm_pool_free(mem, sm);
 
 	return 1;
 }
 
 static int _mirrored_transient_status(struct dm_pool *mem, struct lv_segment *seg, char *params)
 {
-	unsigned i, j;
+	struct dm_status_mirror *sm;
+	struct logical_volume *log;
 	struct logical_volume *lv = seg->lv;
+	int failed = 0, r = 0;
+	unsigned i, j;
 	struct lvinfo info;
-	char *p = NULL;
-	char **args, **log_args;
-	struct logical_volume **images;
-	struct logical_volume *log;
-	unsigned num_devs, log_argc;
-	int failed = 0;
-	char *status;
 
 	log_very_verbose("Mirrored transient status: \"%s\"", params);
 
-	/* number of devices */
-	if (!dm_split_words(params, 1, 0, &p))
-		return_0;
-
-	if (!(num_devs = (unsigned) atoi(p)))
-		return_0;
-
-	p += strlen(p) + 1;
-
-	if (num_devs > DEFAULT_MIRROR_MAX_IMAGES) {
-		log_error("Unexpectedly many (%d) mirror images in %s.",
-			  num_devs, lv->name);
-		return 0;
-	}
-
-	args = alloca((num_devs + 5) * sizeof(char *));
-	images = alloca(num_devs * sizeof(struct logical_volume *));
-
-	/* FIXME: dm_split_words()  should return unsigned */
-	if ((unsigned)dm_split_words(p, num_devs + 4, 0, args) < num_devs + 4)
-		return_0;
-
-	log_argc = (unsigned) atoi(args[3 + num_devs]);
-
-	if (log_argc > 16) {
-		log_error("Unexpectedly many (%d) log arguments in %s.",
-			  log_argc, lv->name);
-		return 0;
-	}
-
-	log_args = alloca(log_argc * sizeof(char *));
-
-	if ((unsigned)dm_split_words(args[3 + num_devs] + strlen(args[3 + num_devs]) + 1,
-				     log_argc, 0, log_args) < log_argc)
+	if (!dm_get_status_mirror(mem, params, &sm))
 		return_0;
 
-	if (num_devs != seg->area_count) {
+	if (sm->dev_count != seg->area_count) {
 		log_error("Active mirror has a wrong number of mirror images!");
-		log_error("Metadata says %d, kernel says %d.", seg->area_count, num_devs);
-		return 0;
+		log_error("Metadata says %u, kernel says %u.",
+			  seg->area_count, sm->dev_count);
+		goto out;
 	}
 
-	if (!strcmp(log_args[0], "disk")) {
-		char buf[32];
+	if (!strcmp(sm->log_type, "disk")) {
 		log = first_seg(lv)->log_lv;
 		if (!lv_info(lv->vg->cmd, log, 0, &info, 0, 0)) {
 			log_error("Check for existence of mirror log %s failed.",
-				  log->name);
-			return 0;
+				  display_lvname(log));
+			goto out;
 		}
 		log_debug_activation("Found mirror log at %d:%d", info.major, info.minor);
-		sprintf(buf, "%d:%d", info.major, info.minor);
-		if (strcmp(buf, log_args[1])) {
-			log_error("Mirror log mismatch. Metadata says %s, kernel says %s.",
-				  buf, log_args[1]);
-			return 0;
+		if (info.major != (int)sm->logs[0].major ||
+		    info.minor != (int)sm->logs[0].minor) {
+			log_error("Mirror log mismatch. Metadata says %d:%d, kernel says %u:%u.",
+				  info.major, info.minor,
+				  sm->logs[0].major, sm->logs[0].minor);
+			goto out;
 		}
-		log_very_verbose("Status of log (%s): %s", buf, log_args[2]);
-		if (log_args[2][0] != 'A') {
+		log_very_verbose("Status of log (%d:%d): %c.",
+				 info.major, info.minor,
+				 sm->logs[0].health);
+		if (sm->logs[0].health != DM_STATUS_MIRROR_ALIVE) {
 			log->status |= PARTIAL_LV;
 			++failed;
 		}
 	}
 
-	for (i = 0; i < num_devs; ++i)
-		images[i] = NULL;
-
 	for (i = 0; i < seg->area_count; ++i) {
-		char buf[32];
 		if (!lv_info(lv->vg->cmd, seg_lv(seg, i), 0, &info, 0, 0)) {
 			log_error("Check for existence of mirror image %s failed.",
 				  seg_lv(seg, i)->name);
-			return 0;
+			goto out;
 		}
 		log_debug_activation("Found mirror image at %d:%d", info.major, info.minor);
-		sprintf(buf, "%d:%d", info.major, info.minor);
-		for (j = 0; j < num_devs; ++j) {
-			if (!strcmp(buf, args[j])) {
-			    log_debug_activation("Match: metadata image %d matches kernel image %d", i, j);
-			    images[j] = seg_lv(seg, i);
+		for (j = 0; j < sm->dev_count; ++j)
+			if (info.major == (int)sm->devs[j].major &&
+			    info.minor == (int)sm->devs[j].minor) {
+				log_very_verbose("Status of image %d: %c.",
+						 i, sm->devs[j].health);
+				if (sm->devs[j].health != DM_STATUS_MIRROR_ALIVE) {
+					seg_lv(seg, i)->status |= PARTIAL_LV;
+					++failed;
+				}
+				break;
 			}
-		}
-	}
-
-	status = args[2 + num_devs];
-
-	for (i = 0; i < num_devs; ++i) {
-		if (!images[i]) {
-			log_error("Failed to find image %d (%s).", i, args[i]);
-			return 0;
-		}
-		log_very_verbose("Status of image %d: %c", i, status[i]);
-		if (status[i] != 'A') {
-			images[i]->status |= PARTIAL_LV;
-			++failed;
+		if (j == sm->dev_count) {
+			log_error("Failed to find image %d (%d:%d).",
+				  i, info.major, info.minor);
+			goto out;
 		}
 	}
 
@@ -330,7 +263,11 @@ static int _mirrored_transient_status(struct dm_pool *mem, struct lv_segment *se
 	if (failed)
 		vg_mark_partial_lvs(lv->vg, 0);
 
-	return 1;
+	r = 1;
+out:
+	dm_pool_free(mem, sm);
+
+	return r;
 }
 
 static int _add_log(struct dm_pool *mem, struct lv_segment *seg,


