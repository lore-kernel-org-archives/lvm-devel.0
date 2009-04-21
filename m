From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 21 Apr 2009 19:16:23 -0000
Subject: LVM2/daemons/clogd clogd.c cluster.c functions ...
Message-ID: <20090421191623.29839.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2009-04-21 19:16:22

Modified files:
	daemons/clogd  : clogd.c cluster.c functions.c functions.h 

Log message:
	- Updating cluster log with latest code changes/bug fixes before
	altering to new kernel structures.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/clogd.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/cluster.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/functions.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/functions.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/daemons/clogd/clogd.c	2009/01/08 17:12:33	1.1
+++ LVM2/daemons/clogd/clogd.c	2009/04/21 19:16:22	1.2
@@ -31,7 +31,6 @@
 static void daemonize(void);
 static void init_all(void);
 static void cleanup_all(void);
-static void set_priority(void);
 
 int main(int argc, char *argv[])
 {
@@ -42,8 +41,6 @@
 	/* Parent can now exit, we're ready to handle requests */
 	kill(getppid(), SIGTERM);
 
-	/* set_priority(); -- let's try to do w/o this */
-
 	LOG_PRINT("Starting clogd:");
 	LOG_PRINT(" Built: "__DATE__" "__TIME__"\n");
 	LOG_DBG(" Compiled with debugging.");
@@ -266,18 +263,3 @@
 	cleanup_local();
 	cleanup_cluster();
 }
-
-static void set_priority(void)
-{
-        struct sched_param sched_param;
-        int res;
-
-        res = sched_get_priority_max(SCHED_RR);
-        if (res != -1) {
-                sched_param.sched_priority = res;
-                res = sched_setscheduler(0, SCHED_RR, &sched_param);
-	}
-
-	if (res == -1)
-		LOG_ERROR("Unable to set SCHED_RR priority.");
-}
--- LVM2/daemons/clogd/cluster.c	2009/01/08 17:12:33	1.1
+++ LVM2/daemons/clogd/cluster.c	2009/04/21 19:16:22	1.2
@@ -68,9 +68,14 @@
 static SaCkptCallbacksT callbacks = { 0, 0 };
 static SaVersionT version = { 'B', 1, 1 };
 
-#define DEBUGGING_HISTORY 50
+#define DEBUGGING_HISTORY 100
 static char debugging[DEBUGGING_HISTORY][128];
 static int idx = 0;
+#define LOG_SPRINT(f, arg...) do {\
+		idx++; \
+		idx = idx % DEBUGGING_HISTORY; \
+		sprintf(debugging[idx], f, ## arg); \
+	} while (0)
 
 static int log_resp_rec = 0;
 
@@ -213,9 +218,18 @@
 	 * a cluster action to co-ordinate reading
 	 * the disk and checkpointing
 	 */
-	if ((t->request_type != DM_CLOG_RESUME) ||
-	    (t->originator == my_cluster_id))
-		r = do_request(t, server);
+	if (t->request_type == DM_CLOG_RESUME) {
+		if (t->originator == my_cluster_id) {
+			r = do_request(t, server);
+
+			r = kernel_send(t);
+			if (r < 0)
+				LOG_ERROR("Failed to send resume response to kernel");
+		}
+		return r;
+	}
+
+	r = do_request(t, server);
 
 	if (server &&
 	    (t->request_type != DM_CLOG_CLEAR_REGION) &&
@@ -337,7 +351,7 @@
 	strncpy(new->uuid, entry->name.value, entry->name.length);
 
 	new->bitmap_size = push_state(entry->name.value, "clean_bits",
-				      &new->clean_bits);
+				      &new->clean_bits, cp_requester);
 	if (new->bitmap_size <= 0) {
 		LOG_ERROR("Failed to store clean_bits to checkpoint for node %u",
 			  new->requester);
@@ -346,7 +360,7 @@
 	}
 
 	new->bitmap_size = push_state(entry->name.value,
-				      "sync_bits", &new->sync_bits);
+				      "sync_bits", &new->sync_bits, cp_requester);
 	if (new->bitmap_size <= 0) {
 		LOG_ERROR("Failed to store sync_bits to checkpoint for node %u",
 			  new->requester);
@@ -355,7 +369,7 @@
 		return NULL;
 	}
 
-	r = push_state(entry->name.value, "recovering_region", &new->recovering_region);
+	r = push_state(entry->name.value, "recovering_region", &new->recovering_region, cp_requester);
 	if (r <= 0) {
 		LOG_ERROR("Failed to store recovering_region to checkpoint for node %u",
 			  new->requester);
@@ -541,6 +555,7 @@
 	tfr->request_type = DM_CLOG_CHECKPOINT_READY;
 	tfr->originator = cp->requester;  /* FIXME: hack to overload meaning of originator */
 	strncpy(tfr->uuid, cp->uuid, CPG_MAX_NAME_LENGTH);
+	tfr->seq = my_cluster_id;
 
 	r = cluster_send(tfr);
 	if (r)
@@ -704,15 +719,11 @@
 	return rtn;
 }
 
-static void do_checkpoints(struct clog_cpg *entry)
+static void do_checkpoints(struct clog_cpg *entry, int leaving)
 {
 	struct checkpoint_data *cp;
 
 	for (cp = entry->checkpoint_list; cp;) {
-		LOG_COND(log_checkpoint,
-			 "[%s] Checkpoint data available for node %u",
-			 SHORT_UUID(entry->name.value), cp->requester);
-
 		/*
 		 * FIXME: Check return code.  Could send failure
 		 * notice in tfr in export_checkpoint function
@@ -720,18 +731,34 @@
 		 */
 		switch (export_checkpoint(cp)) {
 		case -EEXIST:
+			LOG_SPRINT("[%s] Checkpoint for %u already handled%s",
+				   SHORT_UUID(entry->name.value), cp->requester,
+				   (leaving) ? "(L)": "");
 			LOG_COND(log_checkpoint,
-				 "[%s] Checkpoint for %u already handled",
-				 SHORT_UUID(entry->name.value), cp->requester);
+				 "[%s] Checkpoint for %u already handled%s",
+				 SHORT_UUID(entry->name.value), cp->requester,
+				 (leaving) ? "(L)": "");
+			entry->checkpoint_list = cp->next;
+			free_checkpoint(cp);
+			cp = entry->checkpoint_list;
+			break;
 		case 0:
+			LOG_SPRINT("[%s] Checkpoint data available for node %u%s",
+				   SHORT_UUID(entry->name.value), cp->requester,
+				   (leaving) ? "(L)": "");
+			LOG_COND(log_checkpoint,
+				 "[%s] Checkpoint data available for node %u%s",
+				 SHORT_UUID(entry->name.value), cp->requester,
+				 (leaving) ? "(L)": "");
 			entry->checkpoint_list = cp->next;
 			free_checkpoint(cp);
 			cp = entry->checkpoint_list;
 			break;
 		default:
 			/* FIXME: Skipping will cause list corruption */
-			LOG_ERROR("[%s] Failed to export checkpoint for %u",
-				  SHORT_UUID(entry->name.value), cp->requester);
+			LOG_ERROR("[%s] Failed to export checkpoint for %u%s",
+				  SHORT_UUID(entry->name.value), cp->requester,
+				  (leaving) ? "(L)": "");
 		}
 	}
 }
@@ -763,8 +790,6 @@
 		}
 
 		switch (tfr->request_type) {
-		case DM_CLOG_RESUME:
-			/* We are only concerned about this request locally */
 		case DM_CLOG_SET_REGION_SYNC:
 			/*
 			 * Some requests simply do not need to be resent.
@@ -776,11 +801,10 @@
 				 "[%s] Skipping resend of %s/#%u...",
 				 SHORT_UUID(entry->name.value),
 				 _RQ_TYPE(tfr->request_type), tfr->seq);
-			idx++;
-			idx = idx % DEBUGGING_HISTORY;
-			sprintf(debugging[idx], "###  No resend: [%s] %s/%u ###",
-				SHORT_UUID(entry->name.value), _RQ_TYPE(tfr->request_type),
-				tfr->seq);
+			LOG_SPRINT("###  No resend: [%s] %s/%u ###",
+				   SHORT_UUID(entry->name.value),
+				   _RQ_TYPE(tfr->request_type), tfr->seq);
+
 			tfr->data_size = 0;
 			kernel_send(tfr);
 				
@@ -796,11 +820,9 @@
 				 SHORT_UUID(entry->name.value),
 				 _RQ_TYPE(tfr->request_type),
 				 tfr->seq, entry->lowest_id);
-			idx++;
-			idx = idx % DEBUGGING_HISTORY;
-			sprintf(debugging[idx], "***  Resending: [%s] %s/%u ***",
-				SHORT_UUID(entry->name.value), _RQ_TYPE(tfr->request_type),
-				tfr->seq);
+			LOG_SPRINT("***  Resending: [%s] %s/%u ***",
+				   SHORT_UUID(entry->name.value),
+				   _RQ_TYPE(tfr->request_type),	tfr->seq);
 			r = cluster_send(tfr);
 			if (r < 0)
 				LOG_ERROR("Failed resend");
@@ -825,7 +847,7 @@
 			free(entry);
 			continue;
 		}
-		do_checkpoints(entry);
+		do_checkpoints(entry, 0);
 
 		resend_requests(entry);
 	}
@@ -858,6 +880,8 @@
 				free(tfr);
 				continue;
 			}
+			LOG_SPRINT("[%s] Checkpoint prepared for %u",
+				 SHORT_UUID(entry->name.value), tfr->originator);
 			LOG_COND(log_checkpoint, "[%s] Checkpoint prepared for %u",
 				 SHORT_UUID(entry->name.value), tfr->originator);
 			new->next = entry->checkpoint_list;
@@ -878,6 +902,7 @@
 		}
 		free(tfr);
 	}
+
 	return 0;
 }
 
@@ -901,6 +926,7 @@
 
 	if ((nodeid == my_cluster_id) &&
 	    !(tfr->request_type & DM_CLOG_RESPONSE) &&
+	    (tfr->request_type != DM_CLOG_RESUME) &&
 	    (tfr->request_type != DM_CLOG_CLEAR_REGION) &&
 	    (tfr->request_type != DM_CLOG_CHECKPOINT_READY)) {
 		tmp_tfr = malloc(DM_CLOG_TFR_SIZE);
@@ -915,6 +941,7 @@
 			return;
 		}
 		memcpy(tmp_tfr, tfr, sizeof(*tfr) + tfr->data_size);
+		INIT_LIST_HEAD((struct list_head *)&tmp_tfr->private);
 		list_add_tail((struct list_head *)&tmp_tfr->private, &match->working_list);
 	}
 
@@ -952,6 +979,7 @@
 				LOG_COND(log_resend_requests, "[%s] %u is leaving, delay = %d",
 					 SHORT_UUID(tfr->uuid), nodeid, match->delay);
 			}
+			tfr->originator = nodeid; /* don't really need this, but nice for debug */
 			goto out;
 		}
 	}
@@ -969,45 +997,33 @@
 	if (tfr->request_type == DM_CLOG_CHECKPOINT_READY) {
 		if (my_cluster_id == tfr->originator) {
 			/* Redundant checkpoints ignored if match->valid */
+			LOG_SPRINT("[%s] CHECKPOINT_READY notification from %u",
+				   SHORT_UUID(tfr->uuid), nodeid);
 			if (import_checkpoint(match, (match->state != INVALID))) {
+				LOG_SPRINT("[%s] Failed to import checkpoint from %u",
+					   SHORT_UUID(tfr->uuid), nodeid);
 				LOG_ERROR("[%s] Failed to import checkpoint from %u",
 					  SHORT_UUID(tfr->uuid), nodeid);
+				kill(getpid(), SIGUSR1);
 				/* Could we retry? */
 				goto out;
 			} else if (match->state == INVALID) {
+				LOG_SPRINT("[%s] Checkpoint data received from %u.  Log is now valid",
+					   SHORT_UUID(match->name.value), nodeid);
 				LOG_COND(log_checkpoint,
 					 "[%s] Checkpoint data received from %u.  Log is now valid",
 					 SHORT_UUID(match->name.value), nodeid);
 				match->state = VALID;
 
 				flush_startup_list(match);
+			} else {
+				LOG_SPRINT("[%s] Redundant checkpoint from %u ignored.",
+					   SHORT_UUID(tfr->uuid), nodeid);
 			}
 		}
 		goto out;
 	}
 
-	/*
-	 * If the log is now valid, we can queue the checkpoints
-	 */
-	for (i = match->checkpoints_needed; i; ) {
-		struct checkpoint_data *new;
-
-		i--;
-		new = prepare_checkpoint(match, match->checkpoint_requesters[i]);
-		if (!new) {
-			/* FIXME: Need better error handling */
-			LOG_ERROR("[%s] Failed to prepare checkpoint for %u!!!",
-				  SHORT_UUID(tfr->uuid), match->checkpoint_requesters[i]);
-			break;
-		}
-		LOG_COND(log_checkpoint, "[%s] Checkpoint prepared for %u*",
-			 SHORT_UUID(tfr->uuid), match->checkpoint_requesters[i]);
-		match->checkpoints_needed--;
-
-		new->next = match->checkpoint_list;
-		match->checkpoint_list = new;
-	}		
-
 	if (tfr->request_type & DM_CLOG_RESPONSE) {
 		response = 1;
 		r = handle_cluster_response(match, tfr);
@@ -1033,6 +1049,7 @@
 
 			memcpy(tmp_tfr, tfr, sizeof(*tfr) + tfr->data_size);
 			tmp_tfr->error = match->lowest_id;
+			INIT_LIST_HEAD((struct list_head *)&tmp_tfr->private);
 			list_add_tail((struct list_head *)&tmp_tfr->private,
 				      &match->startup_list);
 			goto out;
@@ -1041,6 +1058,37 @@
 		r = handle_cluster_request(match, tfr, i_am_server);
 	}
 
+	/*
+	 * If the log is now valid, we can queue the checkpoints
+	 */
+	for (i = match->checkpoints_needed; i; ) {
+		struct checkpoint_data *new;
+
+		if (log_get_state(tfr) != LOG_RESUMED) {
+			LOG_DBG("[%s] Withholding checkpoints until log is valid (%s from %u)",
+				SHORT_UUID(tfr->uuid), _RQ_TYPE(tfr->request_type), nodeid);
+			break;
+		}
+
+		i--;
+		new = prepare_checkpoint(match, match->checkpoint_requesters[i]);
+		if (!new) {
+			/* FIXME: Need better error handling */
+			LOG_ERROR("[%s] Failed to prepare checkpoint for %u!!!",
+				  SHORT_UUID(tfr->uuid), match->checkpoint_requesters[i]);
+			break;
+		}
+		LOG_SPRINT("[%s] Checkpoint prepared for %u* (%s)",
+			   SHORT_UUID(tfr->uuid), match->checkpoint_requesters[i],
+			   (log_get_state(tfr) != LOG_RESUMED)? "LOG_RESUMED": "LOG_SUSPENDED");
+		LOG_COND(log_checkpoint, "[%s] Checkpoint prepared for %u*",
+			 SHORT_UUID(tfr->uuid), match->checkpoint_requesters[i]);
+		match->checkpoints_needed--;
+
+		new->next = match->checkpoint_list;
+		match->checkpoint_list = new;
+	}		
+
 out:
 	/* nothing happens after this point.  It is just for debugging */
 	if (r) {
@@ -1066,17 +1114,17 @@
                }
        } else if (!(tfr->request_type & DM_CLOG_RESPONSE) ||
                   (tfr->originator == my_cluster_id)) {
-               int len;
-               idx++;
-               idx = idx % DEBUGGING_HISTORY;
-               len = sprintf(debugging[idx],
-                             "SEQ#=%u, UUID=%s, TYPE=%s, ORIG=%u, RESP=%s",
-                             tfr->seq,
-                             SHORT_UUID(tfr->uuid),
-                             _RQ_TYPE(tfr->request_type),
-                             tfr->originator, (response) ? "YES" : "NO");
-               if (response)
-                       sprintf(debugging[idx] + len, ", RSPR=%u", nodeid);
+		if (!response)
+			LOG_SPRINT("SEQ#=%u, UUID=%s, TYPE=%s, ORIG=%u, RESP=%s",
+				   tfr->seq, SHORT_UUID(tfr->uuid),
+				   _RQ_TYPE(tfr->request_type),
+				   tfr->originator, (response) ? "YES" : "NO");
+		else
+			LOG_SPRINT("SEQ#=%u, UUID=%s, TYPE=%s, ORIG=%u, RESP=%s, RSPR=%u",
+				   tfr->seq, SHORT_UUID(tfr->uuid),
+				   _RQ_TYPE(tfr->request_type),
+				   tfr->originator, (response) ? "YES" : "NO",
+				   nodeid);
 	}
 }
 
@@ -1089,6 +1137,7 @@
 	int my_pid = getpid();
 	uint32_t lowest = match->lowest_id;
 	struct clog_tfr *tfr;
+	char dbuf[32];
 
 	/* Assign my_cluster_id */
 	if ((my_cluster_id == 0xDEAD) && (joined->pid == my_pid))
@@ -1104,8 +1153,12 @@
 	if (joined->nodeid == my_cluster_id)
 		goto out;
 
-	LOG_COND(log_checkpoint, "[%s] Joining node, %u needs checkpoint",
-		 SHORT_UUID(match->name.value), joined->nodeid);
+	memset(dbuf, 0, sizeof(dbuf));
+	for (i = 0; i < (member_list_entries-1); i++)
+		sprintf(dbuf+strlen(dbuf), "%u-", member_list[i].nodeid);
+	sprintf(dbuf+strlen(dbuf), "(%u)", joined->nodeid);
+	LOG_COND(log_checkpoint, "[%s] Joining node, %u needs checkpoint [%s]",
+		 SHORT_UUID(match->name.value), joined->nodeid, dbuf);
 
 	/*
 	 * FIXME: remove checkpoint_requesters/checkpoints_needed, and use
@@ -1127,6 +1180,7 @@
 	}
 	tfr->request_type = DM_CLOG_MEMBER_JOIN;
 	tfr->originator   = joined->nodeid;
+	INIT_LIST_HEAD((struct list_head *)&tfr->private);
 	list_add_tail((struct list_head *)&tfr->private, &match->startup_list);
 
 out:
@@ -1149,10 +1203,8 @@
 		LOG_COND(log_membership_change, "[%s]  Server unchanged at %u (%u joined)",
 			 SHORT_UUID(match->name.value),
 			 lowest, joined->nodeid);
-	idx++;
-	idx = idx % DEBUGGING_HISTORY;
-	sprintf(debugging[idx], "+++  UUID=%s  %u join  +++",
-		SHORT_UUID(match->name.value), joined->nodeid);
+	LOG_SPRINT("+++  UUID=%s  %u join  +++",
+		   SHORT_UUID(match->name.value), joined->nodeid);
 }
 
 static void cpg_leave_callback(struct clog_cpg *match,
@@ -1160,17 +1212,14 @@
 			       struct cpg_address *member_list,
 			       int member_list_entries)
 {
-	int i, fd;
+	int i, j, fd;
 	struct list_head *p, *n;
 	uint32_t lowest = match->lowest_id;
 	struct clog_tfr *tfr;
+	struct checkpoint_data *p_cp, *c_cp;
 
-	{
-               idx++;
-               idx = idx % DEBUGGING_HISTORY;
-               sprintf(debugging[idx], "---  UUID=%s  %u left  ---",
-		       SHORT_UUID(match->name.value), left->nodeid);
-	}
+	LOG_SPRINT("---  UUID=%s  %u left  ---",
+		   SHORT_UUID(match->name.value), left->nodeid);
 
 	/* Am I leaving? */
 	if (my_cluster_id == left->nodeid) {
@@ -1198,6 +1247,42 @@
 		match->state = INVALID;
 	}			
 
+	/* Remove any pending checkpoints for the leaving node. */
+	for (p_cp = NULL, c_cp = match->checkpoint_list;
+	     c_cp && (c_cp->requester != left->nodeid);
+	     p_cp = c_cp, c_cp = c_cp->next);
+	if (c_cp) {
+		if (p_cp)
+			p_cp->next = c_cp->next;
+		else
+			match->checkpoint_list = c_cp->next;
+
+		LOG_COND(log_checkpoint,
+			 "[%s] Removing pending checkpoint (%u is leaving)",
+			 SHORT_UUID(match->name.value), left->nodeid);
+		free_checkpoint(c_cp);
+	}
+	list_for_each_safe(p, n, &match->startup_list) {
+		tfr = (struct clog_tfr *)p;
+		if ((tfr->request_type == DM_CLOG_MEMBER_JOIN) &&
+		    (tfr->originator == left->nodeid)) {
+			LOG_COND(log_checkpoint,
+				 "[%s] Removing pending ckpt from startup list (%u is leaving)",
+				 SHORT_UUID(match->name.value), left->nodeid);
+			list_del_init(p);
+			free(tfr);
+		}
+	}
+	for (i = 0, j = 0; i < match->checkpoints_needed; i++, j++) {
+		match->checkpoint_requesters[j] = match->checkpoint_requesters[i];
+		if (match->checkpoint_requesters[i] == left->nodeid) {
+			LOG_ERROR("[%s] Removing pending ckpt from needed list (%u is leaving)",
+				  SHORT_UUID(match->name.value), left->nodeid);
+			j--;
+		}
+	}
+	match->checkpoints_needed = j;			
+
 	if (left->nodeid < my_cluster_id) {
 		match->delay = (match->delay > 0) ? match->delay - 1 : 0;
 		if (!match->delay && list_empty(&match->working_list))
@@ -1379,9 +1464,7 @@
 	new->name.length = size;
 
 	/*
-	 * Look for checkpoints before joining to see if
-	 * someone wrote a checkpoint after I left a previous
-	 * session.
+	 * Ensure there are no stale checkpoints around before we join
 	 */
 	if (remove_checkpoint(new) == 1)
 		LOG_COND(log_checkpoint,
@@ -1437,6 +1520,7 @@
 static int _destroy_cluster_cpg(struct clog_cpg *del)
 {
 	int r;
+	int state;
 	
 	LOG_COND(log_resend_requests, "[%s] I am leaving.2.....",
 		 SHORT_UUID(del->name.value));
@@ -1445,13 +1529,27 @@
 	 * We must send any left over checkpoints before
 	 * leaving.  If we don't, an incoming node could
 	 * be stuck with no checkpoint and stall.
+	do_checkpoints(del); --- THIS COULD BE CAUSING OUR PROBLEMS:
+
+	- Incoming node deletes old checkpoints before joining
+	- A stale checkpoint is issued here by leaving node
+	- (leaving node leaves)
+	- Incoming node joins cluster and finds stale checkpoint.
+	- (leaving node leaves - option 2)
 	 */
-	do_checkpoints(del);
+	do_checkpoints(del, 1);
+
+	state = del->state;
 
 	del->cpg_state = INVALID;
 	del->state = LEAVING;
 
-	if (!list_empty(&del->startup_list))
+	/*
+	 * If the state is VALID, we might be processing the
+	 * startup list.  If so, we certainly don't want to
+	 * clear the startup_list here by calling abort_startup
+	 */
+	if (!list_empty(&del->startup_list) && (state != VALID))
 		abort_startup(del);
 
 	r = cpg_leave(del->handle, &del->name);
@@ -1473,13 +1571,11 @@
 
 int init_cluster(void)
 {
+	int i;
 	SaAisErrorT rv;
 
-	{
-		int i;
-		for (i = 0; i < DEBUGGING_HISTORY; i++)
-			debugging[i][0] = '\0';
-	}
+	for (i = 0; i < DEBUGGING_HISTORY; i++)
+		debugging[i][0] = '\0';
 
 	INIT_LIST_HEAD(&clog_cpg_list);
 	rv = saCkptInitialize(&ckpt_handle, &callbacks, &version);
--- LVM2/daemons/clogd/functions.c	2009/01/08 17:12:33	1.1
+++ LVM2/daemons/clogd/functions.c	2009/04/21 19:16:22	1.2
@@ -11,6 +11,7 @@
 #include <linux/kdev_t.h>
 #define __USE_GNU /* for O_DIRECT */
 #include <fcntl.h>
+#include <time.h>
 #include "linux/dm-clog-tfr.h"
 #include "list.h"
 #include "functions.h"
@@ -50,6 +51,7 @@
 	char uuid[DM_UUID_LEN];
 	uint32_t ref_count;
 
+	time_t delay; /* limits how fast a resume can happen after suspend */
 	int touched;
 	uint32_t region_size;
 	uint32_t region_count;
@@ -60,6 +62,7 @@
 	uint32_t *sync_bits;
 	uint32_t recoverer;
 	uint64_t recovering_region; /* -1 means not recovering */
+	uint64_t skip_bit_warning; /* used to warn if region skipped */
 	int sync_search;
 
 	int resume_override;
@@ -429,6 +432,7 @@
 	lc->block_on_error = block_on_error;
 	lc->sync_search = 0;
 	lc->recovering_region = (uint64_t)-1;
+	lc->skip_bit_warning = region_count;
 	lc->disk_fd = -1;
 	lc->log_dev_failed = 0;
 	lc->ref_count = 1;
@@ -645,7 +649,6 @@
 	if (lc->touched)
 		LOG_DBG("WARNING: log still marked as 'touched' during suspend");
 
-	lc->state = LOG_SUSPENDED;
 	lc->recovery_halted = 1;
 
 	return 0;
@@ -666,8 +669,10 @@
 	LOG_DBG("[%s] clog_postsuspend: leaving CPG", SHORT_UUID(lc->uuid));
 	destroy_cluster_cpg(tfr->uuid);
 
+	lc->state = LOG_SUSPENDED;
 	lc->recovering_region = (uint64_t)-1;
 	lc->recoverer = (uint32_t)-1;
+	lc->delay = time(NULL);
 
 	return 0;
 }
@@ -714,6 +719,9 @@
 	case 1000:
 		LOG_ERROR("[%s] Additional resume issued before suspend",
 			  SHORT_UUID(tfr->uuid));
+#ifdef DEBUG
+		kill(getpid(), SIGUSR1);
+#endif
 		return 0;
 	case 0:
 		lc->resume_override = 1000;
@@ -806,8 +814,8 @@
 
 	lc->sync_count = count_bits32(lc->sync_bits, lc->bitset_uint32_count);
 
-	LOG_DBG("[%s] Initial sync_count = %llu",
-		SHORT_UUID(lc->uuid), (unsigned long long)lc->sync_count);
+	LOG_SPRINT("[%s] Initial sync_count = %llu",
+		   SHORT_UUID(lc->uuid), (unsigned long long)lc->sync_count);
 	lc->sync_search = 0;
 	lc->state = LOG_RESUMED;
 	lc->recovery_halted = 0;
@@ -826,6 +834,7 @@
 int local_resume(struct clog_tfr *tfr)
 {
 	int r;
+	time_t t;
 	struct log_c *lc = get_log(tfr->uuid);
 
 	if (!lc) {
@@ -836,6 +845,34 @@
 			return -EINVAL;
 		}
 
+		t = time(NULL);
+		t -= lc->delay;
+		/*
+		 * This should be considered a temporary fix.  It addresses
+		 * a problem that exists when nodes suspend/resume in rapid
+		 * succession.  While the problem is very rare, it has been
+		 * seen to happen in real-world-like testing.
+		 *
+		 * The problem:
+		 * - Node A joins cluster
+		 * - Node B joins cluster
+		 * - Node A prepares checkpoint
+		 * - Node A gets ready to write checkpoint
+		 * - Node B leaves
+		 * - Node B joins
+		 * - Node A finishes write of checkpoint
+		 * - Node B receives checkpoint meant for previous session
+		 * -- Node B can now be non-coherent
+		 *
+		 * This timer will solve the problem for now, but could be
+		 * replaced by a generation number sent with the resume
+		 * command from the kernel.  The generation number would
+		 * be included in the name of the checkpoint to prevent
+		 * reading stale data.
+		 */
+		if ((t < 3) && (t >= 0))
+			sleep(3 - t);
+
 		/* Join the CPG */
 		r = create_cluster_cpg(tfr->uuid);
 		if (r) {
@@ -1155,6 +1192,7 @@
 				   (unsigned long long)lc->recovering_region);
 			pkg->r = lc->recovering_region;
 			pkg->i = 1;
+			LOG_COND(log_resend_requests, "***** RE-REQUEST *****");
 		} else {
 			LOG_SPRINT("GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
 				   "Someone already recovering (%llu)",
@@ -1233,10 +1271,30 @@
 		} else {
 			log_set_bit(lc, lc->sync_bits, pkg->region);
 			lc->sync_count++;
+
+			/* The rest of this section is all for debugging */
 			LOG_SPRINT("SET - SEQ#=%u, UUID=%s, nodeid = %u:: "
 				   "Setting region (%llu)",
 				   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator,
 				   (unsigned long long)pkg->region);
+			if (pkg->region == lc->skip_bit_warning)
+				lc->skip_bit_warning = lc->region_count;
+
+			if (pkg->region > (lc->skip_bit_warning + 5)) {
+				LOG_ERROR("*** Region #%llu skipped during recovery ***",
+					  (unsigned long long)lc->skip_bit_warning);
+				lc->skip_bit_warning = lc->region_count;
+#ifdef DEBUG
+				kill(getpid(), SIGUSR1);
+#endif
+			}
+
+			if (!log_test_bit(lc->sync_bits,
+					  (pkg->region) ? pkg->region - 1 : 0)) {
+				LOG_SPRINT("*** Previous bit not set ***");
+				lc->skip_bit_warning = (pkg->region) ?
+					pkg->region - 1 : 0;
+			}
 		}
 	} else if (log_test_bit(lc->sync_bits, pkg->region)) {
 		lc->sync_count--;
@@ -1254,6 +1312,9 @@
 			   "sync_count(%llu) != bitmap count(%llu)",
 			   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator,
 			   (unsigned long long)lc->sync_count, reset);
+#ifdef DEBUG
+		kill(getpid(), SIGUSR1);
+#endif
 		lc->sync_count = reset;
 	}
 
@@ -1291,6 +1352,19 @@
 
 	tfr->data_size = sizeof(*sync_count);
 
+	if (lc->sync_count != count_bits32(lc->sync_bits, lc->bitset_uint32_count)) {
+		unsigned long long reset = count_bits32(lc->sync_bits, lc->bitset_uint32_count);
+
+		LOG_SPRINT("get_sync_count - SEQ#=%u, UUID=%s, nodeid = %u:: "
+			   "sync_count(%llu) != bitmap count(%llu)",
+			   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator,
+			   (unsigned long long)lc->sync_count, reset);
+#ifdef DEBUG
+		kill(getpid(), SIGUSR1);
+#endif
+		lc->sync_count = reset;
+	}
+
 	return 0;
 }
 
@@ -1593,7 +1667,7 @@
 }
 
 /* int store_bits(const char *uuid, const char *which, char **buf)*/
-int push_state(const char *uuid, const char *which, char **buf)
+int push_state(const char *uuid, const char *which, char **buf, uint32_t debug_who)
 {
 	int bitset_size;
 	struct log_c *lc;
@@ -1614,10 +1688,12 @@
 		sprintf(*buf, "%llu %u", (unsigned long long)lc->recovering_region,
 			lc->recoverer);
 
-		LOG_SPRINT("CKPT SEND - SEQ#=X, UUID=%s, nodeid = X:: "
-			   "recovering_region=%llu, recoverer=%u",
-			   SHORT_UUID(lc->uuid),
-			   (unsigned long long)lc->recovering_region, lc->recoverer);
+		LOG_SPRINT("CKPT SEND - SEQ#=X, UUID=%s, nodeid = %u:: "
+			   "recovering_region=%llu, recoverer=%u, sync_count=%llu",
+			   SHORT_UUID(lc->uuid), debug_who,
+			   (unsigned long long)lc->recovering_region,
+			   lc->recoverer,
+			   (unsigned long long)count_bits32(lc->sync_bits, lc->bitset_uint32_count));
 		return 64;
 	}
 
--- LVM2/daemons/clogd/functions.h	2009/01/08 17:12:33	1.1
+++ LVM2/daemons/clogd/functions.h	2009/04/21 19:16:22	1.2
@@ -10,7 +10,7 @@
 int cluster_postsuspend(char *);
 
 int do_request(struct clog_tfr *tfr, int server);
-int push_state(const char *uuid, const char *which, char **buf);
+int push_state(const char *uuid, const char *which, char **buf, uint32_t debug_who);
 int pull_state(const char *uuid, const char *which, char *buf, int size);
 
 int log_get_state(struct clog_tfr *tfr);


