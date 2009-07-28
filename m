From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 28 Jul 2009 15:55:50 -0000
Subject: LVM2/daemons/clogd cluster.c cluster.h functio ...
Message-ID: <20090728155550.28586.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2009-07-28 15:55:50

Modified files:
	daemons/clogd  : cluster.c cluster.h functions.c functions.h 

Log message:
	Making adjustments to go along with the changes to the kernel.
	A patch to the kernel, adding the 'luid' field to dm_ulog_request,
	will allow us to properly identify log instances.  We will now
	be able to definitively identify which logs are to be removed/
	suspended/resumed.  This replaces the old faulty behavior of
	assuming the logs were the same if they had the same UUID and
	incrementing/decrementing a reference count.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/cluster.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/cluster.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/functions.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/functions.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/daemons/clogd/cluster.c	2009/07/21 15:34:53	1.5
+++ LVM2/daemons/clogd/cluster.c	2009/07/28 15:55:50	1.6
@@ -101,6 +101,7 @@
 	uint32_t lowest_id;
 	cpg_handle_t handle;
 	struct cpg_name name;
+	uint64_t luid;
 
 	/* Are we the first, or have we received checkpoint? */
 	int state;
@@ -147,6 +148,12 @@
 		return -ENOENT;
 	}
 
+	/*
+	 * Once the request heads for the cluster, the luid looses
+	 * all its meaning.
+	 */
+	rq->u_rq.luid = 0;
+
 	iov.iov_base = rq;
 	iov.iov_len = sizeof(struct clog_request) + rq->u_rq.data_size;
 
@@ -357,7 +364,8 @@
 	new->requester = cp_requester;
 	strncpy(new->uuid, entry->name.value, entry->name.length);
 
-	new->bitmap_size = push_state(entry->name.value, "clean_bits",
+	new->bitmap_size = push_state(entry->name.value, entry->luid,
+				      "clean_bits",
 				      &new->clean_bits, cp_requester);
 	if (new->bitmap_size <= 0) {
 		LOG_ERROR("Failed to store clean_bits to checkpoint for node %u",
@@ -366,8 +374,9 @@
 		return NULL;
 	}
 
-	new->bitmap_size = push_state(entry->name.value,
-				      "sync_bits", &new->sync_bits, cp_requester);
+	new->bitmap_size = push_state(entry->name.value, entry->luid,
+				      "sync_bits",
+				      &new->sync_bits, cp_requester);
 	if (new->bitmap_size <= 0) {
 		LOG_ERROR("Failed to store sync_bits to checkpoint for node %u",
 			  new->requester);
@@ -376,7 +385,9 @@
 		return NULL;
 	}
 
-	r = push_state(entry->name.value, "recovering_region", &new->recovering_region, cp_requester);
+	r = push_state(entry->name.value, entry->luid,
+		       "recovering_region",
+		       &new->recovering_region, cp_requester);
 	if (r <= 0) {
 		LOG_ERROR("Failed to store recovering_region to checkpoint for node %u",
 			  new->requester);
@@ -703,7 +714,7 @@
 		}
 
 		if (iov.readSize) {
-			if (pull_state(entry->name.value,
+			if (pull_state(entry->name.value, entry->luid,
 				       (char *)desc.sectionId.id, bitmap,
 				       iov.readSize)) {
 				LOG_ERROR("Error loading state");
@@ -1235,7 +1246,7 @@
 		cpg_fd_get(match->handle, &fd);
 		links_unregister(fd);
 
-		cluster_postsuspend(match->name.value);
+		cluster_postsuspend(match->name.value, match->luid);
 
 		list_for_each_entry_safe(rq, n, &match->working_list, list) {
 			list_del_init(&rq->list);
@@ -1437,7 +1448,7 @@
 	return 1;
 }
 
-int create_cluster_cpg(char *str)
+int create_cluster_cpg(char *uuid, uint64_t luid)
 {
 	int r;
 	int size;
@@ -1445,8 +1456,8 @@
 	struct clog_cpg *tmp, *tmp2;
 
 	list_for_each_entry_safe(tmp, tmp2, &clog_cpg_list, list)
-		if (!strncmp(tmp->name.value, str, CPG_MAX_NAME_LENGTH)) {
-			LOG_ERROR("Log entry already exists: %s", str);
+		if (!strncmp(tmp->name.value, uuid, CPG_MAX_NAME_LENGTH)) {
+			LOG_ERROR("Log entry already exists: %s", uuid);
 			return -EEXIST;
 		}
 
@@ -1461,10 +1472,11 @@
 	INIT_LIST_HEAD(&new->startup_list);
 	INIT_LIST_HEAD(&new->working_list);
 
-	size = ((strlen(str) + 1) > CPG_MAX_NAME_LENGTH) ?
-		CPG_MAX_NAME_LENGTH : (strlen(str) + 1);
-	strncpy(new->name.value, str, size);
+	size = ((strlen(uuid) + 1) > CPG_MAX_NAME_LENGTH) ?
+		CPG_MAX_NAME_LENGTH : (strlen(uuid) + 1);
+	strncpy(new->name.value, uuid, size);
 	new->name.length = size;
+	new->luid = luid;
 
 	/*
 	 * Ensure there are no stale checkpoints around before we join
@@ -1560,12 +1572,12 @@
 	return 0;
 }
 
-int destroy_cluster_cpg(char *str)
+int destroy_cluster_cpg(char *uuid)
 {
 	struct clog_cpg *del, *tmp;
 
 	list_for_each_entry_safe(del, tmp, &clog_cpg_list, list)
-		if (!strncmp(del->name.value, str, CPG_MAX_NAME_LENGTH))
+		if (!strncmp(del->name.value, uuid, CPG_MAX_NAME_LENGTH))
 			_destroy_cluster_cpg(del);
 
 	return 0;
--- LVM2/daemons/clogd/cluster.h	2009/07/21 15:34:53	1.2
+++ LVM2/daemons/clogd/cluster.h	2009/07/28 15:55:50	1.3
@@ -38,8 +38,8 @@
 void cleanup_cluster(void);
 void cluster_debug(void);
 
-int create_cluster_cpg(char *str);
-int destroy_cluster_cpg(char *str);
+int create_cluster_cpg(char *uuid, uint64_t luid);
+int destroy_cluster_cpg(char *uuid);
 
 int cluster_send(struct clog_request *rq);
 
--- LVM2/daemons/clogd/functions.c	2009/07/21 15:34:53	1.4
+++ LVM2/daemons/clogd/functions.c	2009/07/28 15:55:50	1.5
@@ -49,7 +49,7 @@
 	struct list_head list;
 
 	char uuid[DM_UUID_LEN];
-	uint32_t ref_count;
+	uint64_t luid;
 
 	time_t delay; /* limits how fast a resume can happen after suspend */
 	int touched;
@@ -146,11 +146,10 @@
 
 /*
  * get_log
- * @rq
  *
  * Returns: log if found, NULL otherwise
  */
-static struct log_c *get_log(const char *uuid)
+static struct log_c *get_log(const char *uuid, uint64_t luid)
 {
 	struct list_head *l;
 	struct log_c *lc;
@@ -158,7 +157,8 @@
 	/* FIXME: Need prefetch to do this right */
 	__list_for_each(l, &log_list) {
 		lc = list_entry(l, struct log_c, list);
-		if (!strcmp(lc->uuid, uuid))
+		if (!strcmp(lc->uuid, uuid) &&
+		    (!luid || (luid == lc->luid)))
 			return lc;
 	}
 
@@ -167,14 +167,13 @@
 
 /*
  * get_pending_log
- * @rq
  *
  * Pending logs are logs that have been 'clog_ctr'ed, but
  * have not joined the CPG (via clog_resume).
  *
  * Returns: log if found, NULL otherwise
  */
-static struct log_c *get_pending_log(const char *uuid)
+static struct log_c *get_pending_log(const char *uuid, uint64_t luid)
 {
 	struct list_head *l;
 	struct log_c *lc;
@@ -182,7 +181,8 @@
 	/* FIXME: Need prefetch to do this right */
 	__list_for_each(l, &log_pending_list) {
 		lc = list_entry(l, struct log_c, list);
-		if (!strcmp(lc->uuid, uuid))
+		if (!strcmp(lc->uuid, uuid) &&
+		    (!luid || (luid == lc->luid)))
 			return lc;
 	}
 
@@ -358,7 +358,8 @@
 	return r ? -errno : 0;
 }
 
-static int _clog_ctr(char *uuid, int argc, char **argv, uint64_t device_size)
+static int _clog_ctr(char *uuid, uint64_t luid,
+		     int argc, char **argv, uint64_t device_size)
 {
 	int i;
 	int r = 0;
@@ -447,16 +448,15 @@
 	lc->skip_bit_warning = region_count;
 	lc->disk_fd = -1;
 	lc->log_dev_failed = 0;
-	lc->ref_count = 1;
 	strncpy(lc->uuid, uuid, DM_UUID_LEN);
+	lc->luid = luid;
 
-	if ((dup = get_log(lc->uuid)) ||
-	    (dup = get_pending_log(lc->uuid))) {
-		LOG_DBG("[%s] Inc reference count on cluster log",
-			SHORT_UUID(lc->uuid));
+	if ((dup = get_log(lc->uuid, lc->luid)) ||
+	    (dup = get_pending_log(lc->uuid, lc->luid))) {
+		LOG_ERROR("[%s/%llu] Log already exists, unable to create.",
+			  SHORT_UUID(lc->uuid), lc->luid);
 		free(lc);
-		dup->ref_count++;
-		return 0;
+		return -EINVAL;
 	}
 
 	INIT_LIST_HEAD(&lc->mark_list);
@@ -590,7 +590,7 @@
 	}
 
 	argc--;  /* We pass in the device_size separate */
-	r = _clog_ctr(rq->uuid, argc - 1, argv + 1, device_size);
+	r = _clog_ctr(rq->uuid, rq->luid, argc - 1, argv + 1, device_size);
 
 	/* We join the CPG when we resume */
 
@@ -617,32 +617,21 @@
  */
 static int clog_dtr(struct dm_ulog_request *rq)
 {
-	struct log_c *lc = get_log(rq->uuid);
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
 
 	if (lc) {
 		/*
 		 * The log should not be on the official list.  There
 		 * should have been a suspend first.
 		 */
-		lc->ref_count--;
-		if (!lc->ref_count) {
-			LOG_ERROR("[%s] DTR before SUS: leaving CPG",
-				  SHORT_UUID(rq->uuid));
-			destroy_cluster_cpg(rq->uuid);
-		}
-	} else if ((lc = get_pending_log(rq->uuid))) {
-		lc->ref_count--;
-	} else {
+		LOG_ERROR("[%s] DTR before SUS: leaving CPG",
+			  SHORT_UUID(rq->uuid));
+		destroy_cluster_cpg(rq->uuid);
+	} else if (!(lc = get_pending_log(rq->uuid, rq->luid))) {
 		LOG_ERROR("clog_dtr called on log that is not official or pending");
 		return -EINVAL;
 	}
 
-	if (lc->ref_count) {
-		LOG_DBG("[%s] Dec reference count on cluster log",
-			SHORT_UUID(lc->uuid));
-		return 0;
-	}
-
 	LOG_DBG("[%s] Cluster log removed", SHORT_UUID(lc->uuid));
 
 	list_del_init(&lc->list);
@@ -664,7 +653,7 @@
  */
 static int clog_presuspend(struct dm_ulog_request *rq)
 {
-	struct log_c *lc = get_log(rq->uuid);
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
 
 	if (!lc)
 		return -EINVAL;
@@ -684,7 +673,7 @@
  */
 static int clog_postsuspend(struct dm_ulog_request *rq)
 {
-	struct log_c *lc = get_log(rq->uuid);
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
 
 	if (!lc)
 		return -EINVAL;
@@ -705,9 +694,9 @@
  * @rq
  *
  */
-int cluster_postsuspend(char *uuid)
+int cluster_postsuspend(char *uuid, uint64_t luid)
 {
-	struct log_c *lc = get_log(uuid);
+	struct log_c *lc = get_log(uuid, luid);
 
 	if (!lc)
 		return -EINVAL;
@@ -732,7 +721,7 @@
 {
 	uint32_t i;
 	int commit_log = 0;
-	struct log_c *lc = get_log(rq->uuid);
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
 	size_t size = lc->bitset_uint32_count * sizeof(uint32_t);
 
 	if (!lc)
@@ -770,7 +759,8 @@
 		lc->resume_override = 1000;
 		goto out;
 	default:
-		LOG_ERROR("Error:: multiple loading of bits (%d)", lc->resume_override);
+		LOG_ERROR("Error:: multiple loading of bits (%d)",
+			  lc->resume_override);
 		return -EINVAL;
 	}
 
@@ -791,8 +781,8 @@
 				SHORT_UUID(lc->uuid));
 		break;		
 	case -EINVAL:
-		LOG_PRINT("[%s] (Re)initializing mirror log - resync issued.",
-			  SHORT_UUID(lc->uuid));
+		LOG_DBG("[%s] (Re)initializing mirror log - resync issued.",
+			SHORT_UUID(lc->uuid));
 		lc->disk_nr_regions = 0;
 		break;
 	default:
@@ -858,11 +848,11 @@
 {
 	int r;
 	time_t t;
-	struct log_c *lc = get_log(rq->uuid);
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
 
 	if (!lc) {
 		/* Is the log in the pending list? */
-		lc = get_pending_log(rq->uuid);
+		lc = get_pending_log(rq->uuid, rq->luid);
 		if (!lc) {
 			LOG_ERROR("clog_resume called on log that is not official or pending");
 			return -EINVAL;
@@ -897,7 +887,7 @@
 			sleep(3 - t);
 
 		/* Join the CPG */
-		r = create_cluster_cpg(rq->uuid);
+		r = create_cluster_cpg(rq->uuid, rq->luid);
 		if (r) {
 			LOG_ERROR("clog_resume:  Failed to create cluster CPG");
 			return r;
@@ -924,9 +914,9 @@
 static int clog_get_region_size(struct dm_ulog_request *rq)
 {
 	uint64_t *rtn = (uint64_t *)rq->data;
-	struct log_c *lc = get_log(rq->uuid);
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
 
-	if (!lc && !(lc = get_pending_log(rq->uuid)))
+	if (!lc && !(lc = get_pending_log(rq->uuid, rq->luid)))
 		return -EINVAL;
 
 	*rtn = lc->region_size;
@@ -945,7 +935,7 @@
 {
 	int64_t *rtn = (int64_t *)rq->data;
 	uint64_t region = *((uint64_t *)(rq->data));
-	struct log_c *lc = get_log(rq->uuid);
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
 
 	if (!lc)
 		return -EINVAL;
@@ -970,7 +960,7 @@
 {
 	int64_t *rtn = (int64_t *)rq->data;
 	uint64_t region = *((uint64_t *)(rq->data));
-	struct log_c *lc = get_log(rq->uuid);
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
 
 	if (!lc)
 		return -EINVAL;
@@ -999,7 +989,7 @@
 static int clog_flush(struct dm_ulog_request *rq, int server)
 {
 	int r = 0;
-	struct log_c *lc = get_log(rq->uuid);
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
 	
 	if (!lc)
 		return -EINVAL;
@@ -1087,7 +1077,7 @@
 	int r;
 	int count;
 	uint64_t *region;
-	struct log_c *lc = get_log(rq->uuid);
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
 
 	if (!lc)
 		return -EINVAL;
@@ -1154,7 +1144,7 @@
 	int r;
 	int count;
 	uint64_t *region;
-	struct log_c *lc = get_log(rq->uuid);
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
 
 	if (!lc)
 		return -EINVAL;
@@ -1189,7 +1179,7 @@
 		int64_t i;
 		uint64_t r;
 	} *pkg = (void *)rq->data;
-	struct log_c *lc = get_log(rq->uuid);
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
 
 	if (!lc)
 		return -EINVAL;
@@ -1282,7 +1272,7 @@
 		uint64_t region;
 		int64_t in_sync;
 	} *pkg = (void *)rq->data;
-	struct log_c *lc = get_log(rq->uuid);
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
 
 	if (!lc)
 		return -EINVAL;
@@ -1361,7 +1351,7 @@
 static int clog_get_sync_count(struct dm_ulog_request *rq, uint32_t originator)
 {
 	uint64_t *sync_count = (uint64_t *)rq->data;
-	struct log_c *lc = get_log(rq->uuid);
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
 
 	/*
 	 * FIXME: Mirror requires us to be able to ask for
@@ -1370,7 +1360,7 @@
 	 * the stored value may not be accurate.
 	 */
 	if (!lc)
-		lc = get_pending_log(rq->uuid);
+		lc = get_pending_log(rq->uuid, rq->luid);
 
 	if (!lc)
 		return -EINVAL;
@@ -1429,10 +1419,10 @@
 static int clog_status_info(struct dm_ulog_request *rq)
 {
 	int r;
-	struct log_c *lc = get_log(rq->uuid);
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
 
 	if (!lc)
-		lc = get_pending_log(rq->uuid);
+		lc = get_pending_log(rq->uuid, rq->luid);
 
 	if (!lc)
 		return -EINVAL;
@@ -1484,10 +1474,10 @@
 static int clog_status_table(struct dm_ulog_request *rq)
 {
 	int r;
-	struct log_c *lc = get_log(rq->uuid);
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
 
 	if (!lc)
-		lc = get_pending_log(rq->uuid);
+		lc = get_pending_log(rq->uuid, rq->luid);
 
 	if (!lc)
 		return -EINVAL;
@@ -1512,7 +1502,7 @@
 		int64_t is_recovering;
 		uint64_t in_sync_hint;
 	} *pkg = (void *)rq->data;
-	struct log_c *lc = get_log(rq->uuid);
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
 
 	if (!lc)
 		return -EINVAL;
@@ -1693,7 +1683,8 @@
 }
 
 /* int store_bits(const char *uuid, const char *which, char **buf)*/
-int push_state(const char *uuid, const char *which, char **buf, uint32_t debug_who)
+int push_state(const char *uuid, uint64_t luid,
+	       const char *which, char **buf, uint32_t debug_who)
 {
 	int bitset_size;
 	struct log_c *lc;
@@ -1701,7 +1692,7 @@
 	if (*buf)
 		LOG_ERROR("store_bits: *buf != NULL");
 
-	lc = get_log(uuid);
+	lc = get_log(uuid, luid);
 	if (!lc) {
 		LOG_ERROR("store_bits: No log found for %s", uuid);
 		return -EINVAL;
@@ -1747,7 +1738,8 @@
 }
 
 /*int load_bits(const char *uuid, const char *which, char *buf, int size)*/
-int pull_state(const char *uuid, const char *which, char *buf, int size)
+int pull_state(const char *uuid, uint64_t luid,
+	       const char *which, char *buf, int size)
 {
 	int bitset_size;
 	struct log_c *lc;
@@ -1755,7 +1747,7 @@
 	if (!buf)
 		LOG_ERROR("pull_state: buf == NULL");
 
-	lc = get_log(uuid);
+	lc = get_log(uuid, luid);
 	if (!lc) {
 		LOG_ERROR("pull_state: No log found for %s", uuid);
 		return -EINVAL;
@@ -1799,7 +1791,7 @@
 {
 	struct log_c *lc;
 
-	lc = get_log(rq->uuid);
+	lc = get_log(rq->uuid, rq->luid);
 	if (!lc)
 		return -EINVAL;
 
--- LVM2/daemons/clogd/functions.h	2009/07/21 15:34:53	1.3
+++ LVM2/daemons/clogd/functions.h	2009/07/28 15:55:50	1.4
@@ -8,12 +8,13 @@
 #define LOG_SUSPENDED 2
 
 int local_resume(struct dm_ulog_request *rq);
-int cluster_postsuspend(char *);
+int cluster_postsuspend(char *, uint64_t);
 
 int do_request(struct clog_request *rq, int server);
-int push_state(const char *uuid, const char *which,
-	       char **buf, uint32_t debug_who);
-int pull_state(const char *uuid, const char *which, char *buf, int size);
+int push_state(const char *uuid, uint64_t luid,
+	       const char *which, char **buf, uint32_t debug_who);
+int pull_state(const char *uuid, uint64_t luid,
+	       const char *which, char *buf, int size);
 
 int log_get_state(struct dm_ulog_request *rq);
 int log_status(void);


