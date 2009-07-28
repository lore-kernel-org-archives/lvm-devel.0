From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 28 Jul 2009 21:14:14 -0000
Subject: LVM2/daemons/clogd Makefile cluster.c cluster. ...
Message-ID: <20090728211414.3824.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2009-07-28 21:14:13

Modified files:
	daemons/clogd  : Makefile cluster.c cluster.h functions.c 
	                 logging.h 
Removed files:
	daemons/clogd  : list.h 

Log message:
	Remove old custom list macros and replace with libdevmapper list
	macros.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/Makefile.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/cluster.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/cluster.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/functions.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/logging.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/list.h.diff?cvsroot=lvm2&r1=1.1&r2=NONE

--- LVM2/daemons/clogd/Makefile	2009/07/21 15:32:13	1.2
+++ LVM2/daemons/clogd/Makefile	2009/07/28 21:14:12	1.3
@@ -41,11 +41,11 @@
 CFLAGS += -g
 
 LDFLAGS += $(shell if [ -e /usr/lib64/openais ]; then \
-		echo '-L/usr/lib64/openais -L/usr/lib64'; \
+		echo '-L/usr/lib64/openais -L/usr/lib64 -L/lib64'; \
 	else \
-		echo '-L/usr/lib/openais -L/usr/lib'; \
+		echo '-L/usr/lib/openais -L/usr/lib -L/lib'; \
 	fi)
-LDFLAGS += -lcpg -lSaCkpt -lext2fs
+LDFLAGS += -lcpg -lSaCkpt -lext2fs -ldevmapper
 
 all: ${TARGET}
 
--- LVM2/daemons/clogd/cluster.c	2009/07/28 15:55:50	1.6
+++ LVM2/daemons/clogd/cluster.c	2009/07/28 21:14:12	1.7
@@ -15,7 +15,7 @@
 #include <openais/saCkpt.h>
 
 #include "linux/dm-log-userspace.h"
-#include "list.h"
+#include <libdevmapper.h>
 #include "functions.h"
 #include "local.h"
 #include "common.h"
@@ -96,7 +96,7 @@
 
 #define MAX_CHECKPOINT_REQUESTERS 10
 struct clog_cpg {
-	struct list_head list;
+	struct dm_list list;
 
 	uint32_t lowest_id;
 	cpg_handle_t handle;
@@ -109,8 +109,8 @@
 	int free_me;
 	int delay;
 	int resend_requests;
-	struct list_head startup_list;
-	struct list_head working_list;
+	struct dm_list startup_list;
+	struct dm_list working_list;
 
 	int checkpoints_needed;
 	uint32_t checkpoint_requesters[MAX_CHECKPOINT_REQUESTERS];
@@ -119,8 +119,7 @@
 	char debugging[DEBUGGING_HISTORY][128];
 };
 
-/* FIXME: Need lock for this */
-static struct list_head clog_cpg_list;
+static struct dm_list clog_cpg_list;
 
 /*
  * cluster_send
@@ -136,7 +135,7 @@
 	struct iovec iov;
 	struct clog_cpg *entry, *tmp;
 
-	list_for_each_entry_safe(entry, tmp, &clog_cpg_list, list)
+	dm_list_iterate_items(entry, &clog_cpg_list)
 		if (!strncmp(entry->name.value, rq->u_rq.uuid,
 			     CPG_MAX_NAME_LENGTH)) {
 			found = 1;
@@ -196,16 +195,16 @@
 }
 
 static struct clog_request *get_matching_rq(struct clog_request *rq,
-					    struct list_head *l)
+					    struct dm_list *l)
 {
 	struct clog_request *match, *n;
 
-	list_for_each_entry_safe(match, n, l, list) {
+	dm_list_iterate_items_safe(match, n, l)
 		if (match->u_rq.seq == rq->u_rq.seq) {
-			list_del_init(&match->list);
+			dm_list_del(&match->list);
 			return match;
 		}
-	}
+
 	return NULL;
 }
 
@@ -284,15 +283,14 @@
 			  rq->u_rq.seq);
 
 		LOG_ERROR("Current local list:");
-		if (list_empty(&entry->working_list))
+		if (dm_list_empty(&entry->working_list))
 			LOG_ERROR("   [none]");
 
-		list_for_each_entry_safe(orig_rq, n, &entry->working_list, list) {
+		dm_list_iterate_items(orig_rq, &entry->working_list)
 			LOG_ERROR("   [%s]  %s:%u",
 				  SHORT_UUID(orig_rq->u_rq.uuid),
 				  _RQ_TYPE(orig_rq->u_rq.request_type),
 				  orig_rq->u_rq.seq);
-		}
 
 		return -EINVAL;
 	}
@@ -321,10 +319,9 @@
 {
 	struct clog_cpg *match, *tmp;
 
-	list_for_each_entry_safe(match, tmp, &clog_cpg_list, list) {
+	dm_list_iterate_items(match, &clog_cpg_list)
 		if (match->handle == handle)
 			return match;
-	}
 
 	return NULL;
 }
@@ -569,7 +566,7 @@
 	}
 	memset(rq, 0, sizeof(*rq));
 
-	INIT_LIST_HEAD(&rq->list);
+	dm_list_init(&rq->list);
 	rq->u_rq.request_type = DM_ULOG_CHECKPOINT_READY;
 	rq->originator = cp->requester;  /* FIXME: hack to overload meaning of originator */
 	strncpy(rq->u_rq.uuid, cp->uuid, CPG_MAX_NAME_LENGTH);
@@ -794,8 +791,8 @@
 
 	entry->resend_requests = 0;
 
-	list_for_each_entry_safe(rq, n, &entry->working_list, list) {
-		list_del_init(&rq->list);
+	dm_list_iterate_items_safe(rq, n, &entry->working_list) {
+		dm_list_del(&rq->list);
 
 		if (strcmp(entry->name.value, rq->u_rq.uuid)) {
 			LOG_ERROR("[%s]  Stray request from another log (%s)",
@@ -857,7 +854,7 @@
 	int r = SA_AIS_OK;
 	struct clog_cpg *entry, *tmp;
 
-	list_for_each_entry_safe(entry, tmp, &clog_cpg_list, list) {
+	dm_list_iterate_items(entry, &clog_cpg_list) {
 		r = cpg_dispatch(entry->handle, CPG_DISPATCH_ALL);
 		if (r != SA_AIS_OK)
 			LOG_ERROR("cpg_dispatch failed: %s", str_ais_error(r));
@@ -881,8 +878,8 @@
 	struct clog_request *rq, *n;
 	struct checkpoint_data *new;
 
-	list_for_each_entry_safe(rq, n, &entry->startup_list, list) {
-		list_del_init(&rq->list);
+	dm_list_iterate_items_safe(rq, n, &entry->startup_list) {
+		dm_list_del(&rq->list);
 
 		if (rq->u_rq.request_type == DM_ULOG_MEMBER_JOIN) {
 			new = prepare_checkpoint(entry, rq->originator);
@@ -959,8 +956,8 @@
 			return;
 		}
 		memcpy(tmp_rq, rq, sizeof(*rq) + rq->u_rq.data_size);
-		INIT_LIST_HEAD(&tmp_rq->list);
-		list_add_tail(&tmp_rq->list, &match->working_list);
+		dm_list_init(&tmp_rq->list);
+		dm_list_add( &match->working_list, &tmp_rq->list);
 	}
 
 	if (rq->u_rq.request_type == DM_ULOG_POSTSUSPEND) {
@@ -979,15 +976,14 @@
 					match->resend_requests = 1;
 					LOG_COND(log_resend_requests, "[%s] %u is leaving, resend required%s",
 						 SHORT_UUID(rq->u_rq.uuid), nodeid,
-						 (list_empty(&match->working_list)) ? " -- working_list empty": "");
-			
-					list_for_each_entry_safe(tmp_rq, n, &match->working_list, list) {
+						 (dm_list_empty(&match->working_list)) ? " -- working_list empty": "");
+
+					dm_list_iterate_items(tmp_rq, &match->working_list)
 						LOG_COND(log_resend_requests,
 							 "[%s]                %s/%u",
 							 SHORT_UUID(tmp_rq->u_rq.uuid),
 							 _RQ_TYPE(tmp_rq->u_rq.request_type),
 							 tmp_rq->u_rq.seq);
-					}
 				}
 
 				match->delay++;
@@ -1067,8 +1063,8 @@
 
 			memcpy(tmp_rq, rq, sizeof(*rq) + rq->u_rq.data_size);
 			tmp_rq->pit_server = match->lowest_id;
-			INIT_LIST_HEAD(&tmp_rq->list);
-			list_add_tail(&tmp_rq->list, &match->startup_list);
+			dm_list_init(&tmp_rq->list);
+			dm_list_add(&match->startup_list, &tmp_rq->list);
 			goto out;
 		}
 
@@ -1182,7 +1178,7 @@
 	 * FIXME: remove checkpoint_requesters/checkpoints_needed, and use
 	 * the startup_list interface exclusively
 	 */
-	if (list_empty(&match->startup_list) && (match->state == VALID) &&
+	if (dm_list_empty(&match->startup_list) && (match->state == VALID) &&
 	    (match->checkpoints_needed < MAX_CHECKPOINT_REQUESTERS)) {
 		match->checkpoint_requesters[match->checkpoints_needed++] = joined->nodeid;
 		goto out;
@@ -1198,8 +1194,8 @@
 	}
 	rq->u_rq.request_type = DM_ULOG_MEMBER_JOIN;
 	rq->originator = joined->nodeid;
-	INIT_LIST_HEAD(&rq->list);
-	list_add_tail(&rq->list, &match->startup_list);
+	dm_list_init(&rq->list);
+	dm_list_add(&match->startup_list, &rq->list);
 
 out:
 	/* Find the lowest_id, i.e. the server */
@@ -1241,15 +1237,15 @@
 	/* Am I leaving? */
 	if (my_cluster_id == left->nodeid) {
 		LOG_DBG("Finalizing leave...");
-		list_del_init(&match->list);
+		dm_list_del(&match->list);
 
 		cpg_fd_get(match->handle, &fd);
 		links_unregister(fd);
 
 		cluster_postsuspend(match->name.value, match->luid);
 
-		list_for_each_entry_safe(rq, n, &match->working_list, list) {
-			list_del_init(&rq->list);
+		dm_list_iterate_items_safe(rq, n, &match->working_list) {
+			dm_list_del(&rq->list);
 
 			if (rq->u_rq.request_type == DM_ULOG_POSTSUSPEND)
 				kernel_send(&rq->u_rq);
@@ -1278,13 +1274,13 @@
 			 SHORT_UUID(match->name.value), left->nodeid);
 		free_checkpoint(c_cp);
 	}
-	list_for_each_entry_safe(rq, n, &match->startup_list, list) {
+	dm_list_iterate_items_safe(rq, n, &match->startup_list) {
 		if ((rq->u_rq.request_type == DM_ULOG_MEMBER_JOIN) &&
 		    (rq->originator == left->nodeid)) {
 			LOG_COND(log_checkpoint,
 				 "[%s] Removing pending ckpt from startup list (%u is leaving)",
 				 SHORT_UUID(match->name.value), left->nodeid);
-			list_del_init(&rq->list);
+			dm_list_del(&rq->list);
 			free(rq);
 		}
 	}
@@ -1300,11 +1296,11 @@
 
 	if (left->nodeid < my_cluster_id) {
 		match->delay = (match->delay > 0) ? match->delay - 1 : 0;
-		if (!match->delay && list_empty(&match->working_list))
+		if (!match->delay && dm_list_empty(&match->working_list))
 			match->resend_requests = 0;
 		LOG_COND(log_resend_requests, "[%s] %u has left, delay = %d%s",
 			 SHORT_UUID(match->name.value), left->nodeid,
-			 match->delay, (list_empty(&match->working_list)) ?
+			 match->delay, (dm_list_empty(&match->working_list)) ?
 			 " -- working_list empty": "");
 	}
 
@@ -1344,10 +1340,9 @@
 		 */
 
 		i = 1; /* We do not have a DM_ULOG_MEMBER_JOIN entry of our own */
-		list_for_each_entry_safe(rq, n, &match->startup_list, list) {
+		dm_list_iterate_items(rq, &match->startup_list)
 			if (rq->u_rq.request_type == DM_ULOG_MEMBER_JOIN)
 				i++;
-		}
 
 		if (i == member_list_entries) {
 			/* 
@@ -1371,7 +1366,7 @@
 	struct clog_cpg *match, *tmp;
 	int found = 0;
 
-	list_for_each_entry_safe(match, tmp, &clog_cpg_list, list)
+	dm_list_iterate_items(match, &clog_cpg_list)
 		if (match->handle == handle) {
 			found = 1;
 			break;
@@ -1455,7 +1450,7 @@
 	struct clog_cpg *new = NULL;
 	struct clog_cpg *tmp, *tmp2;
 
-	list_for_each_entry_safe(tmp, tmp2, &clog_cpg_list, list)
+	dm_list_iterate_items(tmp, &clog_cpg_list)
 		if (!strncmp(tmp->name.value, uuid, CPG_MAX_NAME_LENGTH)) {
 			LOG_ERROR("Log entry already exists: %s", uuid);
 			return -EEXIST;
@@ -1467,10 +1462,10 @@
 		return -ENOMEM;
 	}
 	memset(new, 0, sizeof(*new));
-	INIT_LIST_HEAD(&new->list);
+	dm_list_init(&new->list);
 	new->lowest_id = 0xDEAD;
-	INIT_LIST_HEAD(&new->startup_list);
-	INIT_LIST_HEAD(&new->working_list);
+	dm_list_init(&new->startup_list);
+	dm_list_init(&new->working_list);
 
 	size = ((strlen(uuid) + 1) > CPG_MAX_NAME_LENGTH) ?
 		CPG_MAX_NAME_LENGTH : (strlen(uuid) + 1);
@@ -1501,7 +1496,7 @@
 	}
 
 	new->cpg_state = VALID;
-	list_add(&new->list, &clog_cpg_list);
+	dm_list_add(&clog_cpg_list, &new->list);
 	LOG_DBG("New   handle: %llu", (unsigned long long)new->handle);
 	LOG_DBG("New   name: %s", new->name.value);
 
@@ -1519,8 +1514,8 @@
 	LOG_DBG("[%s]  CPG teardown before checkpoint received",
 		SHORT_UUID(del->name.value));
 
-	list_for_each_entry_safe(rq, n, &del->startup_list, list) {
-		list_del_init(&rq->list);
+	dm_list_iterate_items_safe(rq, n, &del->startup_list) {
+		dm_list_del(&rq->list);
 
 		LOG_DBG("[%s]  Ignoring request from %u: %s",
 			SHORT_UUID(del->name.value), rq->originator,
@@ -1563,7 +1558,7 @@
 	 * startup list.  If so, we certainly don't want to
 	 * clear the startup_list here by calling abort_startup
 	 */
-	if (!list_empty(&del->startup_list) && (state != VALID))
+	if (!dm_list_empty(&del->startup_list) && (state != VALID))
 		abort_startup(del);
 
 	r = cpg_leave(del->handle, &del->name);
@@ -1576,7 +1571,7 @@
 {
 	struct clog_cpg *del, *tmp;
 
-	list_for_each_entry_safe(del, tmp, &clog_cpg_list, list)
+	dm_list_iterate_items_safe(del, tmp, &clog_cpg_list)
 		if (!strncmp(del->name.value, uuid, CPG_MAX_NAME_LENGTH))
 			_destroy_cluster_cpg(del);
 
@@ -1587,7 +1582,7 @@
 {
 	SaAisErrorT rv;
 
-	INIT_LIST_HEAD(&clog_cpg_list);
+	dm_list_init(&clog_cpg_list);
 	rv = saCkptInitialize(&ckpt_handle, &callbacks, &version);
 
 	if (rv != SA_AIS_OK)
@@ -1614,7 +1609,7 @@
 
 	LOG_ERROR("");
 	LOG_ERROR("CLUSTER COMPONENT DEBUGGING::");
-	list_for_each_entry_safe(entry, tmp, &clog_cpg_list, list) {
+	dm_list_iterate_items(entry, &clog_cpg_list) {
 		LOG_ERROR("%s::", SHORT_UUID(entry->name.value));
 		LOG_ERROR("  lowest_id         : %u", entry->lowest_id);
 		LOG_ERROR("  state             : %s", (entry->state == INVALID) ?
@@ -1633,16 +1628,14 @@
 				break;
 		LOG_ERROR("  CKPTs waiting     : %d", i);
 		LOG_ERROR("  Working list:");
-		list_for_each_entry_safe(rq, n, &entry->working_list, list) {
+		dm_list_iterate_items(rq, &entry->working_list)
 			LOG_ERROR("  %s/%u", _RQ_TYPE(rq->u_rq.request_type),
 				  rq->u_rq.seq);
-		}
 
 		LOG_ERROR("  Startup list:");
-		list_for_each_entry_safe(rq, n, &entry->startup_list, list) {
+		dm_list_iterate_items(rq, &entry->startup_list)
 			LOG_ERROR("  %s/%u", _RQ_TYPE(rq->u_rq.request_type),
 				  rq->u_rq.seq);
-		}
 
 		LOG_ERROR("Command History:");
 		for (i = 0; i < DEBUGGING_HISTORY; i++) {
--- LVM2/daemons/clogd/cluster.h	2009/07/28 15:55:50	1.3
+++ LVM2/daemons/clogd/cluster.h	2009/07/28 21:14:12	1.4
@@ -1,7 +1,7 @@
 #ifndef __CLUSTER_LOG_CLUSTER_DOT_H__
 #define __CLUSTER_LOG_CLUSTER_DOT_H__
 
-#include "list.h"
+#include <libdevmapper.h>
 #include <linux/dm-log-userspace.h>
 
 /*
@@ -12,7 +12,7 @@
  * available.
  */
 struct clog_request {
-	struct list_head list;
+	struct dm_list list;
 
 	/*
 	 * 'originator' is the machine from which the requests
--- LVM2/daemons/clogd/functions.c	2009/07/28 15:55:50	1.5
+++ LVM2/daemons/clogd/functions.c	2009/07/28 21:14:12	1.6
@@ -13,7 +13,6 @@
 #include <fcntl.h>
 #include <time.h>
 #include "linux/dm-log-userspace.h"
-#include "list.h"
 #include "functions.h"
 #include "common.h"
 #include "cluster.h"
@@ -46,7 +45,7 @@
 };
 
 struct log_c {
-	struct list_head list;
+	struct dm_list list;
 
 	char uuid[DM_UUID_LEN];
 	uint64_t luid;
@@ -76,7 +75,7 @@
 
 	uint32_t state;         /* current operational state of the log */
 
-	struct list_head mark_list;
+	struct dm_list mark_list;
 
 	uint32_t recovery_halted;
 	struct recovery_request *recovery_request_list;
@@ -91,7 +90,7 @@
 };
 
 struct mark_entry {
-	struct list_head list;
+	struct dm_list list;
 	uint32_t nodeid;
 	uint64_t region;
 };
@@ -101,9 +100,8 @@
 	struct recovery_request *next;
 };
 
-static struct list_head log_list = LIST_HEAD_INIT(log_list);
-static struct list_head log_pending_list = LIST_HEAD_INIT(log_pending_list);
-
+static DM_LIST_INIT(log_list);
+static DM_LIST_INIT(log_pending_list);
 
 static int log_test_bit(uint32_t *bs, unsigned bit)
 {
@@ -151,16 +149,12 @@
  */
 static struct log_c *get_log(const char *uuid, uint64_t luid)
 {
-	struct list_head *l;
 	struct log_c *lc;
 
-	/* FIXME: Need prefetch to do this right */
-	__list_for_each(l, &log_list) {
-		lc = list_entry(l, struct log_c, list);
+	dm_list_iterate_items(lc, &log_list)
 		if (!strcmp(lc->uuid, uuid) &&
 		    (!luid || (luid == lc->luid)))
 			return lc;
-	}
 
 	return NULL;
 }
@@ -175,16 +169,12 @@
  */
 static struct log_c *get_pending_log(const char *uuid, uint64_t luid)
 {
-	struct list_head *l;
 	struct log_c *lc;
 
-	/* FIXME: Need prefetch to do this right */
-	__list_for_each(l, &log_pending_list) {
-		lc = list_entry(l, struct log_c, list);
+	dm_list_iterate_items(lc, &log_pending_list)
 		if (!strcmp(lc->uuid, uuid) &&
 		    (!luid || (luid == lc->luid)))
 			return lc;
-	}
 
 	return NULL;
 }
@@ -459,7 +449,7 @@
 		return -EINVAL;
 	}
 
-	INIT_LIST_HEAD(&lc->mark_list);
+	dm_list_init(&lc->mark_list);
 
 	lc->bitset_uint32_count = region_count / 
 		(sizeof(*lc->clean_bits) << BYTE_SHIFT);
@@ -513,7 +503,7 @@
 		LOG_DBG("Disk log ready");
 	}
 
-	list_add(&lc->list, &log_pending_list);
+	dm_list_add(&log_pending_list, &lc->list);
 
 	return 0;
 fail:
@@ -634,7 +624,7 @@
 
 	LOG_DBG("[%s] Cluster log removed", SHORT_UUID(lc->uuid));
 
-	list_del_init(&lc->list);
+	dm_list_del(&lc->list);
 	if (lc->disk_fd != -1)
 		close(lc->disk_fd);
 	if (lc->disk_buffer)
@@ -705,8 +695,8 @@
 	lc->resume_override = 0;
 
 	/* move log to pending list */
-	list_del_init(&lc->list);
-	list_add(&lc->list, &log_pending_list);
+	dm_list_del(&lc->list);
+	dm_list_add(&log_pending_list, &lc->list);
 
 	return 0;
 }
@@ -894,8 +884,8 @@
 		}
 
 		/* move log to official list */
-		list_del_init(&lc->list);
-		list_add(&lc->list, &log_list);
+		dm_list_del(&lc->list);
+		dm_list_add(&log_list, &lc->list);
 	}
 
 	return 0;
@@ -1030,17 +1020,13 @@
 {
 	int found = 0;
 	struct mark_entry *m;
-	struct list_head *p, *n;
 
-	list_for_each_safe(p, n, &lc->mark_list) {
-		/* FIXME: Use proper macros */
-		m = (struct mark_entry *)p;
+	dm_list_iterate_items(m, &lc->mark_list)
 		if (m->region == region) {
 			found = 1;
 			if (m->nodeid == who)
 				return 0;
 		}
-	}
 
 	if (!found)
 		log_clear_bit(lc, lc->clean_bits, region);
@@ -1058,7 +1044,7 @@
 
 	m->nodeid = who;
 	m->region = region;
-	list_add_tail(&m->list, &lc->mark_list);
+	dm_list_add(&lc->mark_list, &m->list);
 
 	return 0;
 }
@@ -1104,20 +1090,16 @@
 static int clear_region(struct log_c *lc, uint64_t region, uint32_t who)
 {
 	int other_matches = 0;
-	struct mark_entry *m;
-	struct list_head *p, *n;
+	struct mark_entry *m, *n;
 
-	list_for_each_safe(p, n, &lc->mark_list) {
-		/* FIXME: Use proper macros */
-		m = (struct mark_entry *)p;
+	dm_list_iterate_items_safe(m, n, &lc->mark_list)
 		if (m->region == region) {
 			if (m->nodeid == who) {
-				list_del_init(&m->list);
+				dm_list_del(&m->list);
 				free(m);
 			} else
 				other_matches = 1;
 		}
-	}			
 
 	/*
 	 * Clear region if:
@@ -1805,12 +1787,7 @@
  */
 int log_status(void)
 {
-	struct list_head *l;
-
-	__list_for_each(l, &log_list)
-		return 1;
-
-	__list_for_each(l, &log_pending_list)
+	if (!dm_list_empty(&log_list) || !dm_list_empty(&log_pending_list))
 		return 1;
 
 	return 0;
@@ -1818,7 +1795,6 @@
 
 void log_debug(void)
 {
-	struct list_head *l;
 	struct log_c *lc;
 	uint64_t r;
 	int i;
@@ -1827,8 +1803,7 @@
 	LOG_ERROR("LOG COMPONENT DEBUGGING::");
 	LOG_ERROR("Official log list:");
 	LOG_ERROR("Pending log list:");
-	__list_for_each(l, &log_pending_list) {
-		lc = list_entry(l, struct log_c, list);
+	dm_list_iterate_items(lc, &log_pending_list) {
 		LOG_ERROR("%s", lc->uuid);
 		LOG_ERROR("sync_bits:");
 		print_bits((char *)lc->sync_bits,
@@ -1838,8 +1813,7 @@
 			   lc->bitset_uint32_count * sizeof(*lc->clean_bits), 1);
 	}
 
-	__list_for_each(l, &log_list) {
-		lc = list_entry(l, struct log_c, list);
+	dm_list_iterate_items(lc, &log_list) {
 		LOG_ERROR("%s", lc->uuid);
 		LOG_ERROR("  recoverer        : %u", lc->recoverer);
 		LOG_ERROR("  recovering_region: %llu",
@@ -1853,7 +1827,6 @@
 		print_bits((char *)lc->clean_bits,
 			   lc->bitset_uint32_count * sizeof(*lc->clean_bits), 1);
 
-		lc = list_entry(l, struct log_c, list);
 		LOG_ERROR("Validating %s::", SHORT_UUID(lc->uuid));
 		r = find_next_zero_bit(lc->sync_bits, lc->region_count, 0);
 		LOG_ERROR("  lc->region_count = %llu",
--- LVM2/daemons/clogd/logging.h	2009/07/21 15:34:53	1.2
+++ LVM2/daemons/clogd/logging.h	2009/07/28 21:14:12	1.3
@@ -4,30 +4,6 @@
 #include <stdio.h>
 #include <syslog.h>
 
-#if (BITS_PER_LONG == 64)
-#define PRIu64 "lu"
-#define PRId64 "ld"
-#define PRIo64 "lo"
-#define PRIx64 "lx"
-#define PRIX64 "lX"
-#define SCNu64 "lu"
-#define SCNd64 "ld"
-#define SCNo64 "lo"
-#define SCNx64 "lx"
-#define SCNX64 "lX"
-#else
-#define PRIu64 "Lu"
-#define PRId64 "Ld"
-#define PRIo64 "Lo"
-#define PRIx64 "Lx"
-#define PRIX64 "LX"
-#define SCNu64 "Lu"
-#define SCNd64 "Ld"
-#define SCNo64 "Lo"
-#define SCNx64 "Lx"
-#define SCNX64 "LX"
-#endif
-
 /* SHORT_UUID - print last 8 chars of a string */
 #define SHORT_UUID(x) (strlen(x) > 8) ? ((x) + (strlen(x) - 8)) : (x)
 


