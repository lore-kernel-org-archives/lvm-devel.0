From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 21 Jul 2009 15:32:19 -0000
Subject: LVM2/daemons/clogd Makefile cluster.c function ...
Message-ID: <20090721153219.18130.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2009-07-21 15:32:16

Modified files:
	daemons/clogd  : Makefile cluster.c functions.c local.c 

Log message:
	Rebasing the cluster log daemon code from the most current
	sources in the 'cluster' tree.  There have been a number of
	bug fixes and I don't want to loose them.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/Makefile.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/cluster.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/functions.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/local.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/daemons/clogd/Makefile	2009/01/08 17:12:33	1.1
+++ LVM2/daemons/clogd/Makefile	2009/07/21 15:32:13	1.2
@@ -12,7 +12,7 @@
 
 SOURCES = clogd.c cluster.c functions.c link_mon.c local.c logging.c
 
-TARGET = $(shell if [ ! -e /usr/include/linux/dm-clog-tfr.h ]; then \
+TARGET = $(shell if [ ! -e /usr/include/linux/dm-log-userspace.h ]; then \
 		echo 'no_clogd_kernel_headers'; \
 	elif [ ! -e /usr/include/linux/ext2_fs.h ]; then \
 		echo 'no_e2fsprogs_devel'; \
--- LVM2/daemons/clogd/cluster.c	2009/04/22 12:46:25	1.3
+++ LVM2/daemons/clogd/cluster.c	2009/07/21 15:32:13	1.4
@@ -69,12 +69,12 @@
 static SaVersionT version = { 'B', 1, 1 };
 
 #define DEBUGGING_HISTORY 100
-static char debugging[DEBUGGING_HISTORY][128];
-static int idx = 0;
-#define LOG_SPRINT(f, arg...) do {\
-		idx++; \
-		idx = idx % DEBUGGING_HISTORY; \
-		sprintf(debugging[idx], f, ## arg); \
+//static char debugging[DEBUGGING_HISTORY][128];
+//static int idx = 0;
+#define LOG_SPRINT(cc, f, arg...) do {		\
+		cc->idx++; \
+		cc->idx = cc->idx % DEBUGGING_HISTORY; \
+		sprintf(cc->debugging[cc->idx], f, ## arg); \
 	} while (0)
 
 static int log_resp_rec = 0;
@@ -114,6 +114,8 @@
 	int checkpoints_needed;
 	uint32_t checkpoint_requesters[MAX_CHECKPOINT_REQUESTERS];
 	struct checkpoint_data *checkpoint_list;
+	int idx;
+	char debugging[DEBUGGING_HISTORY][128];
 };
 
 /* FIXME: Need lock for this */
@@ -731,7 +733,7 @@
 		 */
 		switch (export_checkpoint(cp)) {
 		case -EEXIST:
-			LOG_SPRINT("[%s] Checkpoint for %u already handled%s",
+			LOG_SPRINT(entry, "[%s] Checkpoint for %u already handled%s",
 				   SHORT_UUID(entry->name.value), cp->requester,
 				   (leaving) ? "(L)": "");
 			LOG_COND(log_checkpoint,
@@ -743,7 +745,7 @@
 			cp = entry->checkpoint_list;
 			break;
 		case 0:
-			LOG_SPRINT("[%s] Checkpoint data available for node %u%s",
+			LOG_SPRINT(entry, "[%s] Checkpoint data available for node %u%s",
 				   SHORT_UUID(entry->name.value), cp->requester,
 				   (leaving) ? "(L)": "");
 			LOG_COND(log_checkpoint,
@@ -801,7 +803,7 @@
 				 "[%s] Skipping resend of %s/#%u...",
 				 SHORT_UUID(entry->name.value),
 				 _RQ_TYPE(tfr->request_type), tfr->seq);
-			LOG_SPRINT("###  No resend: [%s] %s/%u ###",
+			LOG_SPRINT(entry, "###  No resend: [%s] %s/%u ###",
 				   SHORT_UUID(entry->name.value),
 				   _RQ_TYPE(tfr->request_type), tfr->seq);
 
@@ -820,7 +822,7 @@
 				 SHORT_UUID(entry->name.value),
 				 _RQ_TYPE(tfr->request_type),
 				 tfr->seq, entry->lowest_id);
-			LOG_SPRINT("***  Resending: [%s] %s/%u ***",
+			LOG_SPRINT(entry, "***  Resending: [%s] %s/%u ***",
 				   SHORT_UUID(entry->name.value),
 				   _RQ_TYPE(tfr->request_type),	tfr->seq);
 			r = cluster_send(tfr);
@@ -880,7 +882,7 @@
 				free(tfr);
 				continue;
 			}
-			LOG_SPRINT("[%s] Checkpoint prepared for %u",
+			LOG_SPRINT(entry, "[%s] Checkpoint prepared for %u",
 				 SHORT_UUID(entry->name.value), tfr->originator);
 			LOG_COND(log_checkpoint, "[%s] Checkpoint prepared for %u",
 				 SHORT_UUID(entry->name.value), tfr->originator);
@@ -997,10 +999,11 @@
 	if (tfr->request_type == DM_CLOG_CHECKPOINT_READY) {
 		if (my_cluster_id == tfr->originator) {
 			/* Redundant checkpoints ignored if match->valid */
-			LOG_SPRINT("[%s] CHECKPOINT_READY notification from %u",
+			LOG_SPRINT(match, "[%s] CHECKPOINT_READY notification from %u",
 				   SHORT_UUID(tfr->uuid), nodeid);
 			if (import_checkpoint(match, (match->state != INVALID))) {
-				LOG_SPRINT("[%s] Failed to import checkpoint from %u",
+				LOG_SPRINT(match,
+					   "[%s] Failed to import checkpoint from %u",
 					   SHORT_UUID(tfr->uuid), nodeid);
 				LOG_ERROR("[%s] Failed to import checkpoint from %u",
 					  SHORT_UUID(tfr->uuid), nodeid);
@@ -1008,7 +1011,8 @@
 				/* Could we retry? */
 				goto out;
 			} else if (match->state == INVALID) {
-				LOG_SPRINT("[%s] Checkpoint data received from %u.  Log is now valid",
+				LOG_SPRINT(match,
+					   "[%s] Checkpoint data received from %u.  Log is now valid",
 					   SHORT_UUID(match->name.value), nodeid);
 				LOG_COND(log_checkpoint,
 					 "[%s] Checkpoint data received from %u.  Log is now valid",
@@ -1017,7 +1021,8 @@
 
 				flush_startup_list(match);
 			} else {
-				LOG_SPRINT("[%s] Redundant checkpoint from %u ignored.",
+				LOG_SPRINT(match,
+					   "[%s] Redundant checkpoint from %u ignored.",
 					   SHORT_UUID(tfr->uuid), nodeid);
 			}
 		}
@@ -1078,7 +1083,7 @@
 				  SHORT_UUID(tfr->uuid), match->checkpoint_requesters[i]);
 			break;
 		}
-		LOG_SPRINT("[%s] Checkpoint prepared for %u* (%s)",
+		LOG_SPRINT(match, "[%s] Checkpoint prepared for %u* (%s)",
 			   SHORT_UUID(tfr->uuid), match->checkpoint_requesters[i],
 			   (log_get_state(tfr) != LOG_RESUMED)? "LOG_RESUMED": "LOG_SUSPENDED");
 		LOG_COND(log_checkpoint, "[%s] Checkpoint prepared for %u*",
@@ -1106,21 +1111,22 @@
 
                LOG_ERROR("HISTORY::");
                for (i = 0; i < DEBUGGING_HISTORY; i++) {
-                       idx++;
-                       idx = idx % DEBUGGING_HISTORY;
-                       if (debugging[idx][0] == '\0')
+                       match->idx++;
+                       match->idx = match->idx % DEBUGGING_HISTORY;
+                       if (match->debugging[match->idx][0] == '\0')
                                continue;
-                       LOG_ERROR("%d:%d) %s", i, idx, debugging[idx]);
+                       LOG_ERROR("%d:%d) %s", i, match->idx,
+				 match->debugging[match->idx]);
                }
        } else if (!(tfr->request_type & DM_CLOG_RESPONSE) ||
                   (tfr->originator == my_cluster_id)) {
 		if (!response)
-			LOG_SPRINT("SEQ#=%u, UUID=%s, TYPE=%s, ORIG=%u, RESP=%s",
+			LOG_SPRINT(match, "SEQ#=%u, UUID=%s, TYPE=%s, ORIG=%u, RESP=%s",
 				   tfr->seq, SHORT_UUID(tfr->uuid),
 				   _RQ_TYPE(tfr->request_type),
 				   tfr->originator, (response) ? "YES" : "NO");
 		else
-			LOG_SPRINT("SEQ#=%u, UUID=%s, TYPE=%s, ORIG=%u, RESP=%s, RSPR=%u",
+			LOG_SPRINT(match, "SEQ#=%u, UUID=%s, TYPE=%s, ORIG=%u, RESP=%s, RSPR=%u",
 				   tfr->seq, SHORT_UUID(tfr->uuid),
 				   _RQ_TYPE(tfr->request_type),
 				   tfr->originator, (response) ? "YES" : "NO",
@@ -1203,7 +1209,7 @@
 		LOG_COND(log_membership_change, "[%s]  Server unchanged at %u (%u joined)",
 			 SHORT_UUID(match->name.value),
 			 lowest, joined->nodeid);
-	LOG_SPRINT("+++  UUID=%s  %u join  +++",
+	LOG_SPRINT(match, "+++  UUID=%s  %u join  +++",
 		   SHORT_UUID(match->name.value), joined->nodeid);
 }
 
@@ -1218,7 +1224,7 @@
 	struct clog_tfr *tfr;
 	struct checkpoint_data *p_cp, *c_cp;
 
-	LOG_SPRINT("---  UUID=%s  %u left  ---",
+	LOG_SPRINT(match, "---  UUID=%s  %u left  ---",
 		   SHORT_UUID(match->name.value), left->nodeid);
 
 	/* Am I leaving? */
@@ -1574,8 +1580,8 @@
 	int i;
 	SaAisErrorT rv;
 
-	for (i = 0; i < DEBUGGING_HISTORY; i++)
-		debugging[i][0] = '\0';
+//	for (i = 0; i < DEBUGGING_HISTORY; i++)
+//		debugging[i][0] = '\0';
 
 	INIT_LIST_HEAD(&clog_cpg_list);
 	rv = saCkptInitialize(&ckpt_handle, &callbacks, &version);
@@ -1634,14 +1640,15 @@
 			t = (struct clog_tfr *)p;
 			LOG_ERROR("  %s/%u", _RQ_TYPE(t->request_type), t->seq);
 		}
-	}
 
-	LOG_ERROR("Command History:");
-	for (i = 0; i < DEBUGGING_HISTORY; i++) {
-		idx++;
-		idx = idx % DEBUGGING_HISTORY;
-		if (debugging[idx][0] == '\0')
-			continue;
-		LOG_ERROR("%d:%d) %s", i, idx, debugging[idx]);
+		LOG_ERROR("Command History:");
+		for (i = 0; i < DEBUGGING_HISTORY; i++) {
+			entry->idx++;
+			entry->idx = entry->idx % DEBUGGING_HISTORY;
+			if (entry->debugging[entry->idx][0] == '\0')
+				continue;
+			LOG_ERROR("%d:%d) %s", i, entry->idx,
+				  entry->debugging[entry->idx]);
+		}
 	}
 }
--- LVM2/daemons/clogd/functions.c	2009/04/21 19:16:22	1.2
+++ LVM2/daemons/clogd/functions.c	2009/07/21 15:32:13	1.3
@@ -31,12 +31,12 @@
 #define LOG_OFFSET 2
 
 #define RESYNC_HISTORY 50
-static char resync_history[RESYNC_HISTORY][128];
-static int idx = 0;
-#define LOG_SPRINT(f, arg...) do {\
-		idx++; \
-		idx = idx % RESYNC_HISTORY; \
-		sprintf(resync_history[idx], f, ## arg); \
+//static char resync_history[RESYNC_HISTORY][128];
+//static int idx = 0;
+#define LOG_SPRINT(_lc, f, arg...) do {		\
+		lc->idx++; \
+		lc->idx = lc->idx % RESYNC_HISTORY; \
+		sprintf(lc->resync_history[lc->idx], f, ## arg); \
 	} while (0)
 
 struct log_header {
@@ -86,6 +86,8 @@
 	uint64_t disk_nr_regions;
 	size_t disk_size;       /* size of disk_buffer in bytes */
 	void *disk_buffer;      /* aligned memory for O_DIRECT */
+	int idx;
+	char resync_history[RESYNC_HISTORY][128];
 };
 
 struct mark_entry {
@@ -545,8 +547,9 @@
 
 	if (strlen(tfr->data) != tfr->data_size) {
 		LOG_ERROR("Received constructor request with bad data");
-		LOG_ERROR("strlen(tfr->data)[%d] != tfr->data_size[%d]",
-			  (int)strlen(tfr->data), tfr->data_size);
+		LOG_ERROR("strlen(tfr->data)[%d] != tfr->data_size[%llu]",
+			  (int)strlen(tfr->data),
+			  (unsigned long long)tfr->data_size);
 		LOG_ERROR("tfr->data = '%s' [%d]",
 			  tfr->data, (int)strlen(tfr->data));
 		return -EINVAL;
@@ -814,7 +817,7 @@
 
 	lc->sync_count = count_bits32(lc->sync_bits, lc->bitset_uint32_count);
 
-	LOG_SPRINT("[%s] Initial sync_count = %llu",
+	LOG_SPRINT(lc, "[%s] Initial sync_count = %llu",
 		   SHORT_UUID(lc->uuid), (unsigned long long)lc->sync_count);
 	lc->sync_search = 0;
 	lc->state = LOG_RESUMED;
@@ -1164,7 +1167,11 @@
  */
 static int clog_get_resync_work(struct clog_tfr *tfr)
 {
-	struct {int i; uint64_t r; } *pkg = (void *)tfr->data;
+	struct {
+		int32_t i;
+		uint32_t arch_padding;
+		uint64_t r;
+	} *pkg = (void *)tfr->data;
 	struct log_c *lc = get_log(tfr->uuid);
 
 	if (!lc)
@@ -1178,7 +1185,7 @@
 		 * FIXME: handle intermittent errors during recovery
 		 * by resetting sync_search... but not to many times.
 		 */
-		LOG_SPRINT("GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+		LOG_SPRINT(lc, "GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
 			   "Recovery finished",
 			   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator);
 		return 0;
@@ -1186,7 +1193,7 @@
 
 	if (lc->recovering_region != (uint64_t)-1) {
 		if (lc->recoverer == tfr->originator) {
-			LOG_SPRINT("GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+			LOG_SPRINT(lc, "GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
 				   "Re-requesting work (%llu)",
 				   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator,
 				   (unsigned long long)lc->recovering_region);
@@ -1194,7 +1201,7 @@
 			pkg->i = 1;
 			LOG_COND(log_resend_requests, "***** RE-REQUEST *****");
 		} else {
-			LOG_SPRINT("GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+			LOG_SPRINT(lc, "GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
 				   "Someone already recovering (%llu)",
 				   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator,
 				   (unsigned long long)lc->recovering_region);
@@ -1213,7 +1220,7 @@
 		free(del);
 
 		if (!log_test_bit(lc->sync_bits, pkg->r)) {
-			LOG_SPRINT("GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+			LOG_SPRINT(lc, "GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
 				   "Assigning priority resync work (%llu)",
 				   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator,
 				   (unsigned long long)pkg->r);
@@ -1229,7 +1236,7 @@
 				    lc->sync_search);
 
 	if (pkg->r >= lc->region_count) {
-		LOG_SPRINT("GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+		LOG_SPRINT(lc, "GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
 			   "Resync work complete.",
 			   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator);
 		return 0;
@@ -1237,7 +1244,7 @@
 
 	lc->sync_search = pkg->r + 1;
 
-	LOG_SPRINT("GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+	LOG_SPRINT(lc, "GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
 		   "Assigning resync work (%llu)",
 		   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator,
 		   (unsigned long long)pkg->r);
@@ -1254,7 +1261,11 @@
  */
 static int clog_set_region_sync(struct clog_tfr *tfr)
 {
-	struct { uint64_t region; int in_sync; } *pkg = (void *)tfr->data;
+	struct {
+		uint64_t region;
+		uint32_t arch_padding;
+		int32_t in_sync;
+	} *pkg = (void *)tfr->data;
 	struct log_c *lc = get_log(tfr->uuid);
 
 	if (!lc)
@@ -1264,7 +1275,7 @@
 
 	if (pkg->in_sync) {
 		if (log_test_bit(lc->sync_bits, pkg->region)) {
-			LOG_SPRINT("SET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+			LOG_SPRINT(lc, "SET - SEQ#=%u, UUID=%s, nodeid = %u:: "
 				   "Region already set (%llu)",
 				   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator,
 				   (unsigned long long)pkg->region);
@@ -1273,7 +1284,7 @@
 			lc->sync_count++;
 
 			/* The rest of this section is all for debugging */
-			LOG_SPRINT("SET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+			LOG_SPRINT(lc, "SET - SEQ#=%u, UUID=%s, nodeid = %u:: "
 				   "Setting region (%llu)",
 				   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator,
 				   (unsigned long long)pkg->region);
@@ -1291,7 +1302,7 @@
 
 			if (!log_test_bit(lc->sync_bits,
 					  (pkg->region) ? pkg->region - 1 : 0)) {
-				LOG_SPRINT("*** Previous bit not set ***");
+				LOG_SPRINT(lc, "*** Previous bit not set ***");
 				lc->skip_bit_warning = (pkg->region) ?
 					pkg->region - 1 : 0;
 			}
@@ -1299,7 +1310,7 @@
 	} else if (log_test_bit(lc->sync_bits, pkg->region)) {
 		lc->sync_count--;
 		log_clear_bit(lc, lc->sync_bits, pkg->region);
-		LOG_SPRINT("SET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+		LOG_SPRINT(lc, "SET - SEQ#=%u, UUID=%s, nodeid = %u:: "
 			   "Unsetting region (%llu)",
 			   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator,
 			   (unsigned long long)pkg->region);
@@ -1308,7 +1319,7 @@
 	if (lc->sync_count != count_bits32(lc->sync_bits, lc->bitset_uint32_count)) {
 		unsigned long long reset = count_bits32(lc->sync_bits, lc->bitset_uint32_count);
 
-		LOG_SPRINT("SET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+		LOG_SPRINT(lc, "SET - SEQ#=%u, UUID=%s, nodeid = %u:: "
 			   "sync_count(%llu) != bitmap count(%llu)",
 			   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator,
 			   (unsigned long long)lc->sync_count, reset);
@@ -1319,7 +1330,7 @@
 	}
 
 	if (lc->sync_count > lc->region_count)
-		LOG_SPRINT("SET - SEQ#=%u, UUID=%s, nodeid = %u:: "
+		LOG_SPRINT(lc, "SET - SEQ#=%u, UUID=%s, nodeid = %u:: "
 			   "(lc->sync_count > lc->region_count) - this is bad",
 			   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator);
 
@@ -1355,7 +1366,7 @@
 	if (lc->sync_count != count_bits32(lc->sync_bits, lc->bitset_uint32_count)) {
 		unsigned long long reset = count_bits32(lc->sync_bits, lc->bitset_uint32_count);
 
-		LOG_SPRINT("get_sync_count - SEQ#=%u, UUID=%s, nodeid = %u:: "
+		LOG_SPRINT(lc, "get_sync_count - SEQ#=%u, UUID=%s, nodeid = %u:: "
 			   "sync_count(%llu) != bitmap count(%llu)",
 			   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator,
 			   (unsigned long long)lc->sync_count, reset);
@@ -1485,7 +1496,11 @@
 static int clog_is_remote_recovering(struct clog_tfr *tfr)
 {
 	uint64_t region = *((uint64_t *)(tfr->data));
-	struct { int is_recovering; uint64_t in_sync_hint; } *pkg = (void *)tfr->data;
+	struct {
+		int32_t is_recovering;
+		uint32_t arch_padding;
+		uint64_t in_sync_hint;
+	} *pkg = (void *)tfr->data;
 	struct log_c *lc = get_log(tfr->uuid);
 
 	if (!lc)
@@ -1505,9 +1520,9 @@
 		/*
 		 * Remember, 'lc->sync_search' is 1 plus the region
 		 * currently being recovered.  So, we must take off 1
-		 * to account for that.
+		 * to account for that; but only if 'sync_search > 1'.
 		 */
-		pkg->in_sync_hint = (lc->sync_search - 1);
+		pkg->in_sync_hint = lc->sync_search ? (lc->sync_search - 1) : 0;
 		LOG_DBG("[%s] Region is %s: %llu",
 			SHORT_UUID(lc->uuid),
 			(region == lc->recovering_region) ?
@@ -1688,7 +1703,7 @@
 		sprintf(*buf, "%llu %u", (unsigned long long)lc->recovering_region,
 			lc->recoverer);
 
-		LOG_SPRINT("CKPT SEND - SEQ#=X, UUID=%s, nodeid = %u:: "
+		LOG_SPRINT(lc, "CKPT SEND - SEQ#=X, UUID=%s, nodeid = %u:: "
 			   "recovering_region=%llu, recoverer=%u, sync_count=%llu",
 			   SHORT_UUID(lc->uuid), debug_who,
 			   (unsigned long long)lc->recovering_region,
@@ -1738,7 +1753,7 @@
 	if (!strncmp(which, "recovering_region", 17)) {
 		sscanf(buf, "%llu %u", (unsigned long long *)&lc->recovering_region,
 		       &lc->recoverer);
-		LOG_SPRINT("CKPT INIT - SEQ#=X, UUID=%s, nodeid = X:: "
+		LOG_SPRINT(lc, "CKPT INIT - SEQ#=X, UUID=%s, nodeid = X:: "
 			   "recovering_region=%llu, recoverer=%u",
 			   SHORT_UUID(lc->uuid),
 			   (unsigned long long)lc->recovering_region, lc->recoverer);
@@ -1808,14 +1823,10 @@
 	LOG_ERROR("");
 	LOG_ERROR("LOG COMPONENT DEBUGGING::");
 	LOG_ERROR("Official log list:");
-	__list_for_each(l, &log_list) {
+	LOG_ERROR("Pending log list:");
+	__list_for_each(l, &log_pending_list) {
 		lc = list_entry(l, struct log_c, list);
 		LOG_ERROR("%s", lc->uuid);
-		LOG_ERROR("  recoverer        : %u", lc->recoverer);
-		LOG_ERROR("  recovering_region: %llu",
-			  (unsigned long long)lc->recovering_region);
-		LOG_ERROR("  recovery_halted  : %s", (lc->recovery_halted) ?
-			  "YES" : "NO");
 		LOG_ERROR("sync_bits:");
 		print_bits((char *)lc->sync_bits,
 			   lc->bitset_uint32_count * sizeof(*lc->sync_bits), 1);
@@ -1824,19 +1835,21 @@
 			   lc->bitset_uint32_count * sizeof(*lc->clean_bits), 1);
 	}
 
-	LOG_ERROR("Pending log list:");
-	__list_for_each(l, &log_pending_list) {
+	__list_for_each(l, &log_list) {
 		lc = list_entry(l, struct log_c, list);
 		LOG_ERROR("%s", lc->uuid);
+		LOG_ERROR("  recoverer        : %u", lc->recoverer);
+		LOG_ERROR("  recovering_region: %llu",
+			  (unsigned long long)lc->recovering_region);
+		LOG_ERROR("  recovery_halted  : %s", (lc->recovery_halted) ?
+			  "YES" : "NO");
 		LOG_ERROR("sync_bits:");
 		print_bits((char *)lc->sync_bits,
 			   lc->bitset_uint32_count * sizeof(*lc->sync_bits), 1);
 		LOG_ERROR("clean_bits:");
 		print_bits((char *)lc->clean_bits,
 			   lc->bitset_uint32_count * sizeof(*lc->clean_bits), 1);
-	}
 
-	__list_for_each(l, &log_list) {
 		lc = list_entry(l, struct log_c, list);
 		LOG_ERROR("Validating %s::", SHORT_UUID(lc->uuid));
 		r = find_next_zero_bit(lc->sync_bits, lc->region_count, 0);
@@ -1851,14 +1864,15 @@
 			LOG_ERROR("ADJUSTING SYNC_COUNT");
 			lc->sync_count = lc->region_count;
 		}
-	}
 
-	LOG_ERROR("Resync request history:");
-	for (i = 0; i < RESYNC_HISTORY; i++) {
-		idx++;
-		idx = idx % RESYNC_HISTORY;
-		if (resync_history[idx][0] == '\0')
-			continue;
-		LOG_ERROR("%d:%d) %s", i, idx, resync_history[idx]);
+		LOG_ERROR("Resync request history:");
+		for (i = 0; i < RESYNC_HISTORY; i++) {
+			lc->idx++;
+			lc->idx = lc->idx % RESYNC_HISTORY;
+			if (lc->resync_history[lc->idx][0] == '\0')
+				continue;
+			LOG_ERROR("%d:%d) %s", i, lc->idx,
+				  lc->resync_history[lc->idx]);
+		}
 	}
 }
--- LVM2/daemons/clogd/local.c	2009/01/08 17:12:33	1.1
+++ LVM2/daemons/clogd/local.c	2009/07/21 15:32:13	1.2
@@ -263,6 +263,7 @@
 	case DM_CLOG_GET_REGION_SIZE:
 	default:
 		LOG_ERROR("Invalid log request received, ignoring.");
+
 		return 0;
 	}
 


