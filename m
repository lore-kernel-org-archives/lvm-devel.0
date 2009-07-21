From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 21 Jul 2009 15:34:54 -0000
Subject: LVM2/daemons/clogd clogd.c cluster.c cluster.h ...
Message-ID: <20090721153454.25527.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2009-07-21 15:34:53

Modified files:
	daemons/clogd  : clogd.c cluster.c cluster.h common.h 
	                 functions.c functions.h local.c local.h 
	                 logging.c logging.h 

Log message:
	After rebasing the cluster logging code, adjustments need to be
	made to compensate for the changes in the kernel-side component
	that recently went upstream.  (Things like: renamed structures,
	removal of structure fields, and changes to arguments passed
	between userspace and kernel.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/clogd.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/cluster.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/cluster.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/common.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/functions.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/functions.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/local.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/local.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/logging.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clogd/logging.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/daemons/clogd/clogd.c	2009/04/21 19:16:22	1.2
+++ LVM2/daemons/clogd/clogd.c	2009/07/21 15:34:53	1.3
@@ -13,7 +13,7 @@
 #include <linux/types.h>
 #include <sys/socket.h>
 #include <linux/netlink.h>
-#include <linux/dm-clog-tfr.h>
+#include <linux/dm-log-userspace.h>
 #include <linux/dm-ioctl.h>
 
 #include "functions.h"
@@ -190,13 +190,13 @@
 			LOG_ERROR("Failed to create lockfile");
 			LOG_ERROR("Process already running?");
 			break;
-		case EXIT_KERNEL_TFR_SOCKET:
+		case EXIT_KERNEL_SOCKET:
 			LOG_ERROR("Unable to create netlink socket");
 			break;
-		case EXIT_KERNEL_TFR_BIND:
+		case EXIT_KERNEL_BIND:
 			LOG_ERROR("Unable to bind to netlink socket");
 			break;
-		case EXIT_KERNEL_TFR_SETSOCKOPT:
+		case EXIT_KERNEL_SETSOCKOPT:
 			LOG_ERROR("Unable to setsockopt on netlink socket");
 			break;
 		case EXIT_CLUSTER_CKPT_INIT:
--- LVM2/daemons/clogd/cluster.c	2009/07/21 15:32:13	1.4
+++ LVM2/daemons/clogd/cluster.c	2009/07/21 15:34:53	1.5
@@ -14,7 +14,7 @@
 #include <openais/cpg.h>
 #include <openais/saCkpt.h>
 
-#include "linux/dm-clog-tfr.h"
+#include "linux/dm-log-userspace.h"
 #include "list.h"
 #include "functions.h"
 #include "local.h"
@@ -24,44 +24,44 @@
 #include "cluster.h"
 
 /* Open AIS error codes */
-#define str_ais_error(x) \
-	((x) == SA_AIS_OK) ? "SA_AIS_OK" : \
-	((x) == SA_AIS_ERR_LIBRARY) ? "SA_AIS_ERR_LIBRARY" : \
-	((x) == SA_AIS_ERR_VERSION) ? "SA_AIS_ERR_VERSION" : \
-	((x) == SA_AIS_ERR_INIT) ? "SA_AIS_ERR_INIT" : \
-	((x) == SA_AIS_ERR_TIMEOUT) ? "SA_AIS_ERR_TIMEOUT" : \
-	((x) == SA_AIS_ERR_TRY_AGAIN) ? "SA_AIS_ERR_TRY_AGAIN" : \
+#define str_ais_error(x)						\
+	((x) == SA_AIS_OK) ? "SA_AIS_OK" :				\
+	((x) == SA_AIS_ERR_LIBRARY) ? "SA_AIS_ERR_LIBRARY" :		\
+	((x) == SA_AIS_ERR_VERSION) ? "SA_AIS_ERR_VERSION" :		\
+	((x) == SA_AIS_ERR_INIT) ? "SA_AIS_ERR_INIT" :			\
+	((x) == SA_AIS_ERR_TIMEOUT) ? "SA_AIS_ERR_TIMEOUT" :		\
+	((x) == SA_AIS_ERR_TRY_AGAIN) ? "SA_AIS_ERR_TRY_AGAIN" :	\
 	((x) == SA_AIS_ERR_INVALID_PARAM) ? "SA_AIS_ERR_INVALID_PARAM" : \
-	((x) == SA_AIS_ERR_NO_MEMORY) ? "SA_AIS_ERR_NO_MEMORY" : \
-	((x) == SA_AIS_ERR_BAD_HANDLE) ? "SA_AIS_ERR_BAD_HANDLE" : \
-	((x) == SA_AIS_ERR_BUSY) ? "SA_AIS_ERR_BUSY" : \
-	((x) == SA_AIS_ERR_ACCESS) ? "SA_AIS_ERR_ACCESS" : \
-	((x) == SA_AIS_ERR_NOT_EXIST) ? "SA_AIS_ERR_NOT_EXIST" : \
+	((x) == SA_AIS_ERR_NO_MEMORY) ? "SA_AIS_ERR_NO_MEMORY" :	\
+	((x) == SA_AIS_ERR_BAD_HANDLE) ? "SA_AIS_ERR_BAD_HANDLE" :	\
+	((x) == SA_AIS_ERR_BUSY) ? "SA_AIS_ERR_BUSY" :			\
+	((x) == SA_AIS_ERR_ACCESS) ? "SA_AIS_ERR_ACCESS" :		\
+	((x) == SA_AIS_ERR_NOT_EXIST) ? "SA_AIS_ERR_NOT_EXIST" :	\
 	((x) == SA_AIS_ERR_NAME_TOO_LONG) ? "SA_AIS_ERR_NAME_TOO_LONG" : \
-	((x) == SA_AIS_ERR_EXIST) ? "SA_AIS_ERR_EXIST" : \
-	((x) == SA_AIS_ERR_NO_SPACE) ? "SA_AIS_ERR_NO_SPACE" : \
-	((x) == SA_AIS_ERR_INTERRUPT) ? "SA_AIS_ERR_INTERRUPT" : \
+	((x) == SA_AIS_ERR_EXIST) ? "SA_AIS_ERR_EXIST" :		\
+	((x) == SA_AIS_ERR_NO_SPACE) ? "SA_AIS_ERR_NO_SPACE" :		\
+	((x) == SA_AIS_ERR_INTERRUPT) ? "SA_AIS_ERR_INTERRUPT" :	\
 	((x) == SA_AIS_ERR_NAME_NOT_FOUND) ? "SA_AIS_ERR_NAME_NOT_FOUND" : \
-	((x) == SA_AIS_ERR_NO_RESOURCES) ? "SA_AIS_ERR_NO_RESOURCES" : \
+	((x) == SA_AIS_ERR_NO_RESOURCES) ? "SA_AIS_ERR_NO_RESOURCES" :	\
 	((x) == SA_AIS_ERR_NOT_SUPPORTED) ? "SA_AIS_ERR_NOT_SUPPORTED" : \
 	((x) == SA_AIS_ERR_BAD_OPERATION) ? "SA_AIS_ERR_BAD_OPERATION" : \
 	((x) == SA_AIS_ERR_FAILED_OPERATION) ? "SA_AIS_ERR_FAILED_OPERATION" : \
 	((x) == SA_AIS_ERR_MESSAGE_ERROR) ? "SA_AIS_ERR_MESSAGE_ERROR" : \
-	((x) == SA_AIS_ERR_QUEUE_FULL) ? "SA_AIS_ERR_QUEUE_FULL" : \
+	((x) == SA_AIS_ERR_QUEUE_FULL) ? "SA_AIS_ERR_QUEUE_FULL" :	\
 	((x) == SA_AIS_ERR_QUEUE_NOT_AVAILABLE) ? "SA_AIS_ERR_QUEUE_NOT_AVAILABLE" : \
-	((x) == SA_AIS_ERR_BAD_FLAGS) ? "SA_AIS_ERR_BAD_FLAGS" : \
-	((x) == SA_AIS_ERR_TOO_BIG) ? "SA_AIS_ERR_TOO_BIG" : \
-	((x) == SA_AIS_ERR_NO_SECTIONS) ? "SA_AIS_ERR_NO_SECTIONS" : \
+	((x) == SA_AIS_ERR_BAD_FLAGS) ? "SA_AIS_ERR_BAD_FLAGS" :	\
+	((x) == SA_AIS_ERR_TOO_BIG) ? "SA_AIS_ERR_TOO_BIG" :		\
+	((x) == SA_AIS_ERR_NO_SECTIONS) ? "SA_AIS_ERR_NO_SECTIONS" :	\
 	"ais_error_unknown"
 
-#define DM_CLOG_RESPONSE 0x1000 /* in last byte of 32-bit value */
-#define DM_CLOG_CHECKPOINT_READY 21
-#define DM_CLOG_MEMBER_JOIN      22
-
-#define _RQ_TYPE(x) \
-	((x) == DM_CLOG_CHECKPOINT_READY) ? "DM_CLOG_CHECKPOINT_READY": \
-	((x) == DM_CLOG_MEMBER_JOIN) ? "DM_CLOG_MEMBER_JOIN": \
-	RQ_TYPE((x) & ~DM_CLOG_RESPONSE)
+#define DM_ULOG_RESPONSE 0x1000 /* in last byte of 32-bit value */
+#define DM_ULOG_CHECKPOINT_READY 21
+#define DM_ULOG_MEMBER_JOIN      22
+
+#define _RQ_TYPE(x)							\
+	((x) == DM_ULOG_CHECKPOINT_READY) ? "DM_ULOG_CHECKPOINT_READY": \
+	((x) == DM_ULOG_MEMBER_JOIN) ? "DM_ULOG_MEMBER_JOIN":		\
+	RQ_TYPE((x) & ~DM_ULOG_RESPONSE)
 
 static uint32_t my_cluster_id = 0xDEAD;
 static SaCkptHandleT ckpt_handle = 0;
@@ -71,10 +71,10 @@
 #define DEBUGGING_HISTORY 100
 //static char debugging[DEBUGGING_HISTORY][128];
 //static int idx = 0;
-#define LOG_SPRINT(cc, f, arg...) do {		\
-		cc->idx++; \
-		cc->idx = cc->idx % DEBUGGING_HISTORY; \
-		sprintf(cc->debugging[cc->idx], f, ## arg); \
+#define LOG_SPRINT(cc, f, arg...) do {				\
+		cc->idx++;					\
+		cc->idx = cc->idx % DEBUGGING_HISTORY;		\
+		sprintf(cc->debugging[cc->idx], f, ## arg);	\
 	} while (0)
 
 static int log_resp_rec = 0;
@@ -123,11 +123,11 @@
 
 /*
  * cluster_send
- * @tfr
+ * @rq
  *
  * Returns: 0 on success, -Exxx on error
  */
-int cluster_send(struct clog_tfr *tfr)
+int cluster_send(struct clog_request *rq)
 {
 	int r;
 	int count=0;
@@ -136,18 +136,19 @@
 	struct clog_cpg *entry, *tmp;
 
 	list_for_each_entry_safe(entry, tmp, &clog_cpg_list, list)
-		if (!strncmp(entry->name.value, tfr->uuid, CPG_MAX_NAME_LENGTH)) {
+		if (!strncmp(entry->name.value, rq->u_rq.uuid,
+			     CPG_MAX_NAME_LENGTH)) {
 			found = 1;
 			break;
 		}
 
 	if (!found) {
-		tfr->error = -ENOENT;
+		rq->u_rq.error = -ENOENT;
 		return -ENOENT;
 	}
 
-	iov.iov_base = tfr;
-	iov.iov_len = sizeof(struct clog_tfr) + tfr->data_size;
+	iov.iov_base = rq;
+	iov.iov_len = sizeof(struct clog_request) + rq->u_rq.data_size;
 
 	if (entry->cpg_state != VALID)
 		return -EINVAL;
@@ -159,17 +160,21 @@
 		count++;
 		if (count < 10)
 			LOG_PRINT("[%s]  Retry #%d of cpg_mcast_joined: %s",
-				  SHORT_UUID(tfr->uuid), count, str_ais_error(r));
+				  SHORT_UUID(rq->u_rq.uuid), count,
+				  str_ais_error(r));
 		else if ((count < 100) && !(count % 10))
 			LOG_ERROR("[%s]  Retry #%d of cpg_mcast_joined: %s",
-				  SHORT_UUID(tfr->uuid), count, str_ais_error(r));
+				  SHORT_UUID(rq->u_rq.uuid), count,
+				  str_ais_error(r));
 		else if ((count < 1000) && !(count % 100))
 			LOG_ERROR("[%s]  Retry #%d of cpg_mcast_joined: %s",
-				  SHORT_UUID(tfr->uuid), count, str_ais_error(r));
+				  SHORT_UUID(rq->u_rq.uuid), count,
+				  str_ais_error(r));
 		else if ((count < 10000) && !(count % 1000))
 			LOG_ERROR("[%s]  Retry #%d of cpg_mcast_joined: %s - "
 				  "OpenAIS not handling the load?",
-				  SHORT_UUID(tfr->uuid), count, str_ais_error(r));
+				  SHORT_UUID(rq->u_rq.uuid), count,
+				  str_ais_error(r));
 		usleep(1000);
 	} while (1);
 
@@ -179,39 +184,38 @@
 	/* error codes found in openais/cpg.h */
 	LOG_ERROR("cpg_mcast_joined error: %s", str_ais_error(r));
 
-	tfr->error = -EBADE;
+	rq->u_rq.error = -EBADE;
 	return -EBADE;
 }
 
-static struct clog_tfr *get_matching_tfr(struct clog_tfr *t, struct list_head *l)
+static struct clog_request *get_matching_rq(struct clog_request *rq,
+					    struct list_head *l)
 {
-	struct clog_tfr *match;
-	struct list_head *p, *n;
+	struct clog_request *match, *n;
 
-	list_for_each_safe(p, n, l) {
-		match = (struct clog_tfr *)p;
-		if (match->seq == t->seq) {
-			list_del_init(p);
+	list_for_each_entry_safe(match, n, l, list) {
+		if (match->u_rq.seq == rq->u_rq.seq) {
+			list_del_init(&match->list);
 			return match;
 		}
 	}
 	return NULL;
 }
 
-static char tfr_buffer[DM_CLOG_TFR_SIZE];
+static char rq_buffer[DM_ULOG_REQUEST_SIZE];
 static int handle_cluster_request(struct clog_cpg *entry,
-				  struct clog_tfr *tfr, int server)
+				  struct clog_request *rq, int server)
 {
 	int r = 0;
-	struct clog_tfr *t = (struct clog_tfr *)tfr_buffer;
+	struct clog_request *tmp = (struct clog_request *)rq_buffer;
 
 	/*
-	 * We need a separate clog_tfr struct, one that can carry
+	 * We need a separate dm_ulog_request struct, one that can carry
 	 * a return payload.  Otherwise, the memory address after
-	 * tfr will be altered - leading to problems
+	 * rq will be altered - leading to problems
 	 */
-	memset(t, 0, DM_CLOG_TFR_SIZE);
-	memcpy(t, tfr, sizeof(struct clog_tfr) + tfr->data_size);
+	memset(rq_buffer, 0, sizeof(rq_buffer));
+	memcpy(tmp, rq, sizeof(struct clog_request) + rq->u_rq.data_size);
 
 	/*
 	 * With resumes, we only handle our own.
@@ -220,28 +224,28 @@
 	 * a cluster action to co-ordinate reading
 	 * the disk and checkpointing
 	 */
-	if (t->request_type == DM_CLOG_RESUME) {
-		if (t->originator == my_cluster_id) {
-			r = do_request(t, server);
+	if (tmp->u_rq.request_type == DM_ULOG_RESUME) {
+		if (tmp->originator == my_cluster_id) {
+			r = do_request(tmp, server);
 
-			r = kernel_send(t);
+			r = kernel_send(&tmp->u_rq);
 			if (r < 0)
 				LOG_ERROR("Failed to send resume response to kernel");
 		}
 		return r;
 	}
 
-	r = do_request(t, server);
+	r = do_request(tmp, server);
 
 	if (server &&
-	    (t->request_type != DM_CLOG_CLEAR_REGION) &&
-	    (t->request_type != DM_CLOG_POSTSUSPEND)) {
-		t->request_type |= DM_CLOG_RESPONSE;
+	    (tmp->u_rq.request_type != DM_ULOG_CLEAR_REGION) &&
+	    (tmp->u_rq.request_type != DM_ULOG_POSTSUSPEND)) {
+		tmp->u_rq.request_type |= DM_ULOG_RESPONSE;
 
 		/*
-		 * Errors from previous functions are in the tfr struct.
+		 * Errors from previous functions are in the rq struct.
 		 */
-		r = cluster_send(t);
+		r = cluster_send(tmp);
 		if (r < 0)
 			LOG_ERROR("cluster_send failed: %s", strerror(-r));
 	}
@@ -249,38 +253,38 @@
 	return r;
 }
 
-static int handle_cluster_response(struct clog_cpg *entry, struct clog_tfr *tfr)
+static int handle_cluster_response(struct clog_cpg *entry,
+				   struct clog_request *rq)
 {
 	int r = 0;
-	struct clog_tfr *orig_tfr;
+	struct clog_request *orig_rq, *n;
 
 	/*
 	 * If I didn't send it, then I don't care about the response
 	 */
-	if (tfr->originator != my_cluster_id)
+	if (rq->originator != my_cluster_id)
 		return 0;
 
-	tfr->request_type &= ~DM_CLOG_RESPONSE;
-	orig_tfr = get_matching_tfr(tfr, &entry->working_list);
-
-	if (!orig_tfr) {
-		struct list_head *p, *n;
-		struct clog_tfr *t;
+	rq->u_rq.request_type &= ~DM_ULOG_RESPONSE;
+	orig_rq = get_matching_rq(rq, &entry->working_list);
 
+	if (!orig_rq) {
 		/* Unable to find match for response */
 
 		LOG_ERROR("[%s] No match for cluster response: %s:%u",
-			  SHORT_UUID(tfr->uuid),
-			  _RQ_TYPE(tfr->request_type), tfr->seq);
+			  SHORT_UUID(rq->u_rq.uuid),
+			  _RQ_TYPE(rq->u_rq.request_type),
+			  rq->u_rq.seq);
 
 		LOG_ERROR("Current local list:");
 		if (list_empty(&entry->working_list))
 			LOG_ERROR("   [none]");
 
-		list_for_each_safe(p, n, &entry->working_list) {
-			t = (struct clog_tfr *)p;
-			LOG_ERROR("   [%s]  %s:%u", SHORT_UUID(t->uuid),
-				  _RQ_TYPE(t->request_type), t->seq);
+		list_for_each_entry_safe(orig_rq, n, &entry->working_list, list) {
+			LOG_ERROR("   [%s]  %s:%u",
+				  SHORT_UUID(orig_rq->u_rq.uuid),
+				  _RQ_TYPE(orig_rq->u_rq.request_type),
+				  orig_rq->u_rq.seq);
 		}
 
 		return -EINVAL;
@@ -289,19 +293,20 @@
 	if (log_resp_rec > 0) {
 		LOG_COND(log_resend_requests,
 			 "[%s] Response received to %s/#%u",
-			 SHORT_UUID(tfr->uuid), _RQ_TYPE(tfr->request_type),
-			 tfr->seq);
+			 SHORT_UUID(rq->u_rq.uuid),
+			 _RQ_TYPE(rq->u_rq.request_type),
+			 rq->u_rq.seq);
 		log_resp_rec--;
 	}
 
 	/* FIXME: Ensure memcpy cannot explode */
-	memcpy(orig_tfr, tfr, sizeof(*tfr) + tfr->data_size);
+	memcpy(orig_rq, rq, sizeof(*rq) + rq->u_rq.data_size);
 
-	r = kernel_send(orig_tfr);
+	r = kernel_send(&orig_rq->u_rq);
 	if (r)
 		LOG_ERROR("Failed to send response to kernel");
 
-	free(orig_tfr);
+	free(orig_rq);
 	return r;
 }
 
@@ -409,7 +414,7 @@
 	SaCkptCheckpointOpenFlagsT flags;
 	SaNameT name;
 	SaAisErrorT rv;
-	struct clog_tfr *tfr;
+	struct clog_request *rq;
 	int len, r = 0;
 	char buf[32];
 
@@ -546,25 +551,25 @@
 	LOG_DBG("export_checkpoint: closing checkpoint");
 	saCkptCheckpointClose(h);
 
-	tfr = malloc(DM_CLOG_TFR_SIZE);
-	if (!tfr) {
+	rq = malloc(DM_ULOG_REQUEST_SIZE);
+	if (!rq) {
 		LOG_ERROR("export_checkpoint: Unable to allocate transfer structs");
 		return -ENOMEM;
 	}
-	memset(tfr, 0, sizeof(*tfr));
+	memset(rq, 0, sizeof(*rq));
 
-	INIT_LIST_HEAD((struct list_head *)&tfr->private);
-	tfr->request_type = DM_CLOG_CHECKPOINT_READY;
-	tfr->originator = cp->requester;  /* FIXME: hack to overload meaning of originator */
-	strncpy(tfr->uuid, cp->uuid, CPG_MAX_NAME_LENGTH);
-	tfr->seq = my_cluster_id;
+	INIT_LIST_HEAD(&rq->list);
+	rq->u_rq.request_type = DM_ULOG_CHECKPOINT_READY;
+	rq->originator = cp->requester;  /* FIXME: hack to overload meaning of originator */
+	strncpy(rq->u_rq.uuid, cp->uuid, CPG_MAX_NAME_LENGTH);
+	rq->u_rq.seq = my_cluster_id;
 
-	r = cluster_send(tfr);
+	r = cluster_send(rq);
 	if (r)
 		LOG_ERROR("Failed to send checkpoint ready notice: %s",
 			  strerror(-r));
 
-	free(tfr);
+	free(rq);
 	return 0;
 }
 
@@ -728,8 +733,8 @@
 	for (cp = entry->checkpoint_list; cp;) {
 		/*
 		 * FIXME: Check return code.  Could send failure
-		 * notice in tfr in export_checkpoint function
-		 * by setting tfr->error
+		 * notice in rq in export_checkpoint function
+		 * by setting rq->error
 		 */
 		switch (export_checkpoint(cp)) {
 		case -EEXIST:
@@ -768,8 +773,7 @@
 static int resend_requests(struct clog_cpg *entry)
 {
 	int r = 0;
-	struct list_head *p, *n;
-	struct clog_tfr *tfr;
+	struct clog_request *rq, *n;
 
 	if (!entry->resend_requests || entry->delay)
 		return 0;
@@ -779,20 +783,19 @@
 
 	entry->resend_requests = 0;
 
-	list_for_each_safe(p, n, &entry->working_list) {
-		list_del_init(p);
-		tfr = (struct clog_tfr *)p;
+	list_for_each_entry_safe(rq, n, &entry->working_list, list) {
+		list_del_init(&rq->list);
 
-		if (strcmp(entry->name.value, tfr->uuid)) {
+		if (strcmp(entry->name.value, rq->u_rq.uuid)) {
 			LOG_ERROR("[%s]  Stray request from another log (%s)",
 				  SHORT_UUID(entry->name.value),
-				  SHORT_UUID(tfr->uuid));
-			free(tfr);
+				  SHORT_UUID(rq->u_rq.uuid));
+			free(rq);
 			continue;
 		}
 
-		switch (tfr->request_type) {
-		case DM_CLOG_SET_REGION_SYNC:
+		switch (rq->u_rq.request_type) {
+		case DM_ULOG_SET_REGION_SYNC:
 			/*
 			 * Some requests simply do not need to be resent.
 			 * If it is a request that just changes log state,
@@ -802,13 +805,15 @@
 			LOG_COND(log_resend_requests,
 				 "[%s] Skipping resend of %s/#%u...",
 				 SHORT_UUID(entry->name.value),
-				 _RQ_TYPE(tfr->request_type), tfr->seq);
+				 _RQ_TYPE(rq->u_rq.request_type),
+				 rq->u_rq.seq);
 			LOG_SPRINT(entry, "###  No resend: [%s] %s/%u ###",
 				   SHORT_UUID(entry->name.value),
-				   _RQ_TYPE(tfr->request_type), tfr->seq);
+				   _RQ_TYPE(rq->u_rq.request_type),
+				   rq->u_rq.seq);
 
-			tfr->data_size = 0;
-			kernel_send(tfr);
+			rq->u_rq.data_size = 0;
+			kernel_send(&rq->u_rq);
 				
 			break;
 			
@@ -820,16 +825,17 @@
 			LOG_COND(log_resend_requests,
 				 "[%s] Resending %s(#%u) due to new server(%u)",
 				 SHORT_UUID(entry->name.value),
-				 _RQ_TYPE(tfr->request_type),
-				 tfr->seq, entry->lowest_id);
+				 _RQ_TYPE(rq->u_rq.request_type),
+				 rq->u_rq.seq, entry->lowest_id);
 			LOG_SPRINT(entry, "***  Resending: [%s] %s/%u ***",
 				   SHORT_UUID(entry->name.value),
-				   _RQ_TYPE(tfr->request_type),	tfr->seq);
-			r = cluster_send(tfr);
+				   _RQ_TYPE(rq->u_rq.request_type),
+				   rq->u_rq.seq);
+			r = cluster_send(rq);
 			if (r < 0)
 				LOG_ERROR("Failed resend");
 		}
-		free(tfr);
+		free(rq);
 	}
 
 	return r;
@@ -861,15 +867,14 @@
 {
 	int r = 0;
 	int i_was_server;
-	struct list_head *p, *n;
-	struct clog_tfr *tfr = NULL;
+	struct clog_request *rq, *n;
 	struct checkpoint_data *new;
 
-	list_for_each_safe(p, n, &entry->startup_list) {
-		list_del_init(p);
-		tfr = (struct clog_tfr *)p;
-		if (tfr->request_type == DM_CLOG_MEMBER_JOIN) {
-			new = prepare_checkpoint(entry, tfr->originator);
+	list_for_each_entry_safe(rq, n, &entry->startup_list, list) {
+		list_del_init(&rq->list);
+
+		if (rq->u_rq.request_type == DM_ULOG_MEMBER_JOIN) {
+			new = prepare_checkpoint(entry, rq->originator);
 			if (!new) {
 				/*
 				 * FIXME: Need better error handling.  Other nodes
@@ -878,22 +883,22 @@
 				 * but continue.
 				 */
 				LOG_ERROR("Failed to prepare checkpoint for %u!!!",
-					  tfr->originator);
-				free(tfr);
+					  rq->originator);
+				free(rq);
 				continue;
 			}
 			LOG_SPRINT(entry, "[%s] Checkpoint prepared for %u",
-				 SHORT_UUID(entry->name.value), tfr->originator);
+				   SHORT_UUID(entry->name.value), rq->originator);
 			LOG_COND(log_checkpoint, "[%s] Checkpoint prepared for %u",
-				 SHORT_UUID(entry->name.value), tfr->originator);
+				 SHORT_UUID(entry->name.value), rq->originator);
 			new->next = entry->checkpoint_list;
 			entry->checkpoint_list = new;
 		} else {
 			LOG_DBG("[%s] Processing delayed request: %s",
-				SHORT_UUID(tfr->uuid), _RQ_TYPE(tfr->request_type));
-			i_was_server = (tfr->error == my_cluster_id) ? 1 : 0;
-			tfr->error = 0;
-			r = handle_cluster_request(entry, tfr, i_was_server);
+				SHORT_UUID(rq->u_rq.uuid),
+				_RQ_TYPE(rq->u_rq.request_type));
+			i_was_server = (rq->pit_server == my_cluster_id) ? 1 : 0;
+			r = handle_cluster_request(entry, rq, i_was_server);
 
 			if (r)
 				/*
@@ -902,7 +907,7 @@
 				 */
 				LOG_ERROR("Error while processing delayed CPG message");
 		}
-		free(tfr);
+		free(rq);
 	}
 
 	return 0;
@@ -916,8 +921,8 @@
 	int r = 0;
 	int i_am_server;
 	int response = 0;
-	struct clog_tfr *tfr = msg;
-	struct clog_tfr *tmp_tfr = NULL;
+	struct clog_request *rq = msg;
+	struct clog_request *tmp_rq, *n;
 	struct clog_cpg *match;
 
 	match = find_clog_cpg(handle);
@@ -927,27 +932,27 @@
 	}
 
 	if ((nodeid == my_cluster_id) &&
-	    !(tfr->request_type & DM_CLOG_RESPONSE) &&
-	    (tfr->request_type != DM_CLOG_RESUME) &&
-	    (tfr->request_type != DM_CLOG_CLEAR_REGION) &&
-	    (tfr->request_type != DM_CLOG_CHECKPOINT_READY)) {
-		tmp_tfr = malloc(DM_CLOG_TFR_SIZE);
-		if (!tmp_tfr) {
+	    !(rq->u_rq.request_type & DM_ULOG_RESPONSE) &&
+	    (rq->u_rq.request_type != DM_ULOG_RESUME) &&
+	    (rq->u_rq.request_type != DM_ULOG_CLEAR_REGION) &&
+	    (rq->u_rq.request_type != DM_ULOG_CHECKPOINT_READY)) {
+		tmp_rq = malloc(DM_ULOG_REQUEST_SIZE);
+		if (!tmp_rq) {
 			/*
 			 * FIXME: It may be possible to continue... but we
 			 * would not be able to resend any messages that might
 			 * be necessary during membership changes
 			 */
 			LOG_ERROR("[%s] Unable to record request: -ENOMEM",
-				  SHORT_UUID(tfr->uuid));
+				  SHORT_UUID(rq->u_rq.uuid));
 			return;
 		}
-		memcpy(tmp_tfr, tfr, sizeof(*tfr) + tfr->data_size);
-		INIT_LIST_HEAD((struct list_head *)&tmp_tfr->private);
-		list_add_tail((struct list_head *)&tmp_tfr->private, &match->working_list);
+		memcpy(tmp_rq, rq, sizeof(*rq) + rq->u_rq.data_size);
+		INIT_LIST_HEAD(&tmp_rq->list);
+		list_add_tail(&tmp_rq->list, &match->working_list);
 	}
 
-	if (tfr->request_type == DM_CLOG_POSTSUSPEND) {
+	if (rq->u_rq.request_type == DM_ULOG_POSTSUSPEND) {
 		/*
 		 * If the server (lowest_id) indicates it is leaving,
 		 * then we must resend any outstanding requests.  However,
@@ -956,32 +961,29 @@
 		 */
 		if (nodeid == my_cluster_id) {
 			LOG_COND(log_resend_requests, "[%s] I am leaving.1.....",
-				 SHORT_UUID(tfr->uuid));
+				 SHORT_UUID(rq->u_rq.uuid));
 		} else {
 			if (nodeid < my_cluster_id) {
 				if (nodeid == match->lowest_id) {
-					struct list_head *p, *n;
-					
 					match->resend_requests = 1;
 					LOG_COND(log_resend_requests, "[%s] %u is leaving, resend required%s",
-						 SHORT_UUID(tfr->uuid), nodeid,
+						 SHORT_UUID(rq->u_rq.uuid), nodeid,
 						 (list_empty(&match->working_list)) ? " -- working_list empty": "");
 			
-					list_for_each_safe(p, n, &match->working_list) {
-						tmp_tfr = (struct clog_tfr *)p;
-					
+					list_for_each_entry_safe(tmp_rq, n, &match->working_list, list) {
 						LOG_COND(log_resend_requests,
 							 "[%s]                %s/%u",
-							 SHORT_UUID(tmp_tfr->uuid),
-							 _RQ_TYPE(tmp_tfr->request_type), tmp_tfr->seq);
+							 SHORT_UUID(tmp_rq->u_rq.uuid),
+							 _RQ_TYPE(tmp_rq->u_rq.request_type),
+							 tmp_rq->u_rq.seq);
 					}
 				}
 
 				match->delay++;
 				LOG_COND(log_resend_requests, "[%s] %u is leaving, delay = %d",
-					 SHORT_UUID(tfr->uuid), nodeid, match->delay);
+					 SHORT_UUID(rq->u_rq.uuid), nodeid, match->delay);
 			}
-			tfr->originator = nodeid; /* don't really need this, but nice for debug */
+			rq->originator = nodeid; /* don't really need this, but nice for debug */
 			goto out;
 		}
 	}
@@ -996,17 +998,17 @@
 
 	i_am_server = (my_cluster_id == match->lowest_id) ? 1 : 0;
 
-	if (tfr->request_type == DM_CLOG_CHECKPOINT_READY) {
-		if (my_cluster_id == tfr->originator) {
+	if (rq->u_rq.request_type == DM_ULOG_CHECKPOINT_READY) {
+		if (my_cluster_id == rq->originator) {
 			/* Redundant checkpoints ignored if match->valid */
 			LOG_SPRINT(match, "[%s] CHECKPOINT_READY notification from %u",
-				   SHORT_UUID(tfr->uuid), nodeid);
+				   SHORT_UUID(rq->u_rq.uuid), nodeid);
 			if (import_checkpoint(match, (match->state != INVALID))) {
 				LOG_SPRINT(match,
 					   "[%s] Failed to import checkpoint from %u",
-					   SHORT_UUID(tfr->uuid), nodeid);
+					   SHORT_UUID(rq->u_rq.uuid), nodeid);
 				LOG_ERROR("[%s] Failed to import checkpoint from %u",
-					  SHORT_UUID(tfr->uuid), nodeid);
+					  SHORT_UUID(rq->u_rq.uuid), nodeid);
 				kill(getpid(), SIGUSR1);
 				/* Could we retry? */
 				goto out;
@@ -1023,44 +1025,43 @@
 			} else {
 				LOG_SPRINT(match,
 					   "[%s] Redundant checkpoint from %u ignored.",
-					   SHORT_UUID(tfr->uuid), nodeid);
+					   SHORT_UUID(rq->u_rq.uuid), nodeid);
 			}
 		}
 		goto out;
 	}
 
-	if (tfr->request_type & DM_CLOG_RESPONSE) {
+	if (rq->u_rq.request_type & DM_ULOG_RESPONSE) {
 		response = 1;
-		r = handle_cluster_response(match, tfr);
+		r = handle_cluster_response(match, rq);
 	} else {
-		tfr->originator = nodeid;
+		rq->originator = nodeid;
 
 		if (match->state == LEAVING) {
 			LOG_ERROR("[%s]  Ignoring %s from %u.  Reason: I'm leaving",
-				  SHORT_UUID(tfr->uuid), _RQ_TYPE(tfr->request_type),
-				  tfr->originator);
+				  SHORT_UUID(rq->u_rq.uuid), _RQ_TYPE(rq->u_rq.request_type),
+				  rq->originator);
 			goto out;
 		}
 
 		if (match->state == INVALID) {
 			LOG_DBG("Log not valid yet, storing request");
-			tmp_tfr = malloc(DM_CLOG_TFR_SIZE);
-			if (!tmp_tfr) {
+			tmp_rq = malloc(DM_ULOG_REQUEST_SIZE);
+			if (!tmp_rq) {
 				LOG_ERROR("cpg_message_callback:  Unable to"
 					  " allocate transfer structs");
 				r = -ENOMEM; /* FIXME: Better error #? */
 				goto out;
 			}
 
-			memcpy(tmp_tfr, tfr, sizeof(*tfr) + tfr->data_size);
-			tmp_tfr->error = match->lowest_id;
-			INIT_LIST_HEAD((struct list_head *)&tmp_tfr->private);
-			list_add_tail((struct list_head *)&tmp_tfr->private,
-				      &match->startup_list);
+			memcpy(tmp_rq, rq, sizeof(*rq) + rq->u_rq.data_size);
+			tmp_rq->pit_server = match->lowest_id;
+			INIT_LIST_HEAD(&tmp_rq->list);
+			list_add_tail(&tmp_rq->list, &match->startup_list);
 			goto out;
 		}
 
-		r = handle_cluster_request(match, tfr, i_am_server);
+		r = handle_cluster_request(match, rq, i_am_server);
 	}
 
 	/*
@@ -1069,9 +1070,9 @@
 	for (i = match->checkpoints_needed; i; ) {
 		struct checkpoint_data *new;
 
-		if (log_get_state(tfr) != LOG_RESUMED) {
+		if (log_get_state(&rq->u_rq) != LOG_RESUMED) {
 			LOG_DBG("[%s] Withholding checkpoints until log is valid (%s from %u)",
-				SHORT_UUID(tfr->uuid), _RQ_TYPE(tfr->request_type), nodeid);
+				SHORT_UUID(rq->u_rq.uuid), _RQ_TYPE(rq->u_rq.request_type), nodeid);
 			break;
 		}
 
@@ -1080,14 +1081,14 @@
 		if (!new) {
 			/* FIXME: Need better error handling */
 			LOG_ERROR("[%s] Failed to prepare checkpoint for %u!!!",
-				  SHORT_UUID(tfr->uuid), match->checkpoint_requesters[i]);
+				  SHORT_UUID(rq->u_rq.uuid), match->checkpoint_requesters[i]);
 			break;
 		}
 		LOG_SPRINT(match, "[%s] Checkpoint prepared for %u* (%s)",
-			   SHORT_UUID(tfr->uuid), match->checkpoint_requesters[i],
-			   (log_get_state(tfr) != LOG_RESUMED)? "LOG_RESUMED": "LOG_SUSPENDED");
+			   SHORT_UUID(rq->u_rq.uuid), match->checkpoint_requesters[i],
+			   (log_get_state(&rq->u_rq) != LOG_RESUMED)? "LOG_RESUMED": "LOG_SUSPENDED");
 		LOG_COND(log_checkpoint, "[%s] Checkpoint prepared for %u*",
-			 SHORT_UUID(tfr->uuid), match->checkpoint_requesters[i]);
+			 SHORT_UUID(rq->u_rq.uuid), match->checkpoint_requesters[i]);
 		match->checkpoints_needed--;
 
 		new->next = match->checkpoint_list;
@@ -1098,38 +1099,38 @@
 	/* nothing happens after this point.  It is just for debugging */
 	if (r) {
 		LOG_ERROR("[%s] Error while processing CPG message, %s: %s",
-			  SHORT_UUID(tfr->uuid),
-			  _RQ_TYPE(tfr->request_type & ~DM_CLOG_RESPONSE),
+			  SHORT_UUID(rq->u_rq.uuid),
+			  _RQ_TYPE(rq->u_rq.request_type & ~DM_ULOG_RESPONSE),
 			  strerror(-r));
-		LOG_ERROR("[%s]    Response  : %s", SHORT_UUID(tfr->uuid),
+		LOG_ERROR("[%s]    Response  : %s", SHORT_UUID(rq->u_rq.uuid),
 			  (response) ? "YES" : "NO");
 		LOG_ERROR("[%s]    Originator: %u",
-			  SHORT_UUID(tfr->uuid), tfr->originator);
+			  SHORT_UUID(rq->u_rq.uuid), rq->originator);
 		if (response)
 			LOG_ERROR("[%s]    Responder : %u",
-				  SHORT_UUID(tfr->uuid), nodeid);
+				  SHORT_UUID(rq->u_rq.uuid), nodeid);
 
-               LOG_ERROR("HISTORY::");
-               for (i = 0; i < DEBUGGING_HISTORY; i++) {
-                       match->idx++;
-                       match->idx = match->idx % DEBUGGING_HISTORY;
-                       if (match->debugging[match->idx][0] == '\0')
-                               continue;
-                       LOG_ERROR("%d:%d) %s", i, match->idx,
-				 match->debugging[match->idx]);
-               }
-       } else if (!(tfr->request_type & DM_CLOG_RESPONSE) ||
-                  (tfr->originator == my_cluster_id)) {
+		LOG_ERROR("HISTORY::");
+		for (i = 0; i < DEBUGGING_HISTORY; i++) {
+			match->idx++;
+			match->idx = match->idx % DEBUGGING_HISTORY;
+			if (match->debugging[match->idx][0] == '\0')
+				continue;
+			LOG_ERROR("%d:%d) %s", i, match->idx,
+				  match->debugging[match->idx]);
+		}
+	} else if (!(rq->u_rq.request_type & DM_ULOG_RESPONSE) ||
+		   (rq->originator == my_cluster_id)) {
 		if (!response)
 			LOG_SPRINT(match, "SEQ#=%u, UUID=%s, TYPE=%s, ORIG=%u, RESP=%s",
-				   tfr->seq, SHORT_UUID(tfr->uuid),
-				   _RQ_TYPE(tfr->request_type),
-				   tfr->originator, (response) ? "YES" : "NO");
+				   rq->u_rq.seq, SHORT_UUID(rq->u_rq.uuid),
+				   _RQ_TYPE(rq->u_rq.request_type),
+				   rq->originator, (response) ? "YES" : "NO");
 		else
 			LOG_SPRINT(match, "SEQ#=%u, UUID=%s, TYPE=%s, ORIG=%u, RESP=%s, RSPR=%u",
-				   tfr->seq, SHORT_UUID(tfr->uuid),
-				   _RQ_TYPE(tfr->request_type),
-				   tfr->originator, (response) ? "YES" : "NO",
+				   rq->u_rq.seq, SHORT_UUID(rq->u_rq.uuid),
+				   _RQ_TYPE(rq->u_rq.request_type),
+				   rq->originator, (response) ? "YES" : "NO",
 				   nodeid);
 	}
 }
@@ -1142,7 +1143,7 @@
 	int i;
 	int my_pid = getpid();
 	uint32_t lowest = match->lowest_id;
-	struct clog_tfr *tfr;
+	struct clog_request *rq;
 	char dbuf[32];
 
 	/* Assign my_cluster_id */
@@ -1176,18 +1177,18 @@
 		goto out;
 	}
 
-	tfr = malloc(DM_CLOG_TFR_SIZE);
-	if (!tfr) {
+	rq = malloc(DM_ULOG_REQUEST_SIZE);
+	if (!rq) {
 		LOG_ERROR("cpg_config_callback: "
 			  "Unable to allocate transfer structs");
 		LOG_ERROR("cpg_config_callback: "
 			  "Unable to perform checkpoint");
 		goto out;
 	}
-	tfr->request_type = DM_CLOG_MEMBER_JOIN;
-	tfr->originator   = joined->nodeid;
-	INIT_LIST_HEAD((struct list_head *)&tfr->private);
-	list_add_tail((struct list_head *)&tfr->private, &match->startup_list);
+	rq->u_rq.request_type = DM_ULOG_MEMBER_JOIN;
+	rq->originator = joined->nodeid;
+	INIT_LIST_HEAD(&rq->list);
+	list_add_tail(&rq->list, &match->startup_list);
 
 out:
 	/* Find the lowest_id, i.e. the server */
@@ -1219,9 +1220,8 @@
 			       int member_list_entries)
 {
 	int i, j, fd;
-	struct list_head *p, *n;
 	uint32_t lowest = match->lowest_id;
-	struct clog_tfr *tfr;
+	struct clog_request *rq, *n;
 	struct checkpoint_data *p_cp, *c_cp;
 
 	LOG_SPRINT(match, "---  UUID=%s  %u left  ---",
@@ -1237,13 +1237,12 @@
 
 		cluster_postsuspend(match->name.value);
 
-		list_for_each_safe(p, n, &match->working_list) {
-			list_del_init(p);
-			tfr = (struct clog_tfr *)p;
-
-			if (tfr->request_type == DM_CLOG_POSTSUSPEND)
-				kernel_send(tfr);
-			free(tfr);
+		list_for_each_entry_safe(rq, n, &match->working_list, list) {
+			list_del_init(&rq->list);
+
+			if (rq->u_rq.request_type == DM_ULOG_POSTSUSPEND)
+				kernel_send(&rq->u_rq);
+			free(rq);
 		}
 
 		cpg_finalize(match->handle);
@@ -1268,15 +1267,14 @@
 			 SHORT_UUID(match->name.value), left->nodeid);
 		free_checkpoint(c_cp);
 	}
-	list_for_each_safe(p, n, &match->startup_list) {
-		tfr = (struct clog_tfr *)p;
-		if ((tfr->request_type == DM_CLOG_MEMBER_JOIN) &&
-		    (tfr->originator == left->nodeid)) {
+	list_for_each_entry_safe(rq, n, &match->startup_list, list) {
+		if ((rq->u_rq.request_type == DM_ULOG_MEMBER_JOIN) &&
+		    (rq->originator == left->nodeid)) {
 			LOG_COND(log_checkpoint,
 				 "[%s] Removing pending ckpt from startup list (%u is leaving)",
 				 SHORT_UUID(match->name.value), left->nodeid);
-			list_del_init(p);
-			free(tfr);
+			list_del_init(&rq->list);
+			free(rq);
 		}
 	}
 	for (i = 0, j = 0; i < match->checkpoints_needed; i++, j++) {
@@ -1334,10 +1332,9 @@
 		 * of the presence of out-going (and unable to respond) members.
 		 */
 
-		i = 1; /* We do not have a DM_CLOG_MEMBER_JOIN entry */
-		list_for_each_safe(p, n, &match->startup_list) {
-			tfr = (struct clog_tfr *)p;
-			if (tfr->request_type == DM_CLOG_MEMBER_JOIN)
+		i = 1; /* We do not have a DM_ULOG_MEMBER_JOIN entry of our own */
+		list_for_each_entry_safe(rq, n, &match->startup_list, list) {
+			if (rq->u_rq.request_type == DM_ULOG_MEMBER_JOIN)
 				i++;
 		}
 
@@ -1383,7 +1380,7 @@
 				  member_list, member_list_entries);
 	else
 		cpg_leave_callback(match, left_list,
-				  member_list, member_list_entries);
+				   member_list, member_list_entries);
 }
 
 cpg_callbacks_t cpg_callbacks = {
@@ -1505,19 +1502,18 @@
 
 static void abort_startup(struct clog_cpg *del)
 {
-	struct list_head *p, *n;
-	struct clog_tfr *tfr = NULL;
+	struct clog_request *rq, *n;
 
 	LOG_DBG("[%s]  CPG teardown before checkpoint received",
 		SHORT_UUID(del->name.value));
 
-	list_for_each_safe(p, n, &del->startup_list) {
-		list_del_init(p);
-		tfr = (struct clog_tfr *)p;
+	list_for_each_entry_safe(rq, n, &del->startup_list, list) {
+		list_del_init(&rq->list);
+
 		LOG_DBG("[%s]  Ignoring request from %u: %s",
-			SHORT_UUID(del->name.value), tfr->originator,
-			_RQ_TYPE(tfr->request_type));
-		free(tfr);
+			SHORT_UUID(del->name.value), rq->originator,
+			_RQ_TYPE(rq->u_rq.request_type));
+		free(rq);
 	}
 
 	remove_checkpoint(del);
@@ -1535,14 +1531,14 @@
 	 * We must send any left over checkpoints before
 	 * leaving.  If we don't, an incoming node could
 	 * be stuck with no checkpoint and stall.
-	do_checkpoints(del); --- THIS COULD BE CAUSING OUR PROBLEMS:
+	 do_checkpoints(del); --- THIS COULD BE CAUSING OUR PROBLEMS:
 
-	- Incoming node deletes old checkpoints before joining
-	- A stale checkpoint is issued here by leaving node
-	- (leaving node leaves)
-	- Incoming node joins cluster and finds stale checkpoint.
-	- (leaving node leaves - option 2)
-	 */
+	 - Incoming node deletes old checkpoints before joining
+	 - A stale checkpoint is issued here by leaving node
+	 - (leaving node leaves)
+	 - Incoming node joins cluster and finds stale checkpoint.
+	 - (leaving node leaves - option 2)
+	*/
 	do_checkpoints(del, 1);
 
 	state = del->state;
@@ -1577,12 +1573,8 @@
 
 int init_cluster(void)
 {
-	int i;
 	SaAisErrorT rv;
 
-//	for (i = 0; i < DEBUGGING_HISTORY; i++)
-//		debugging[i][0] = '\0';
-
 	INIT_LIST_HEAD(&clog_cpg_list);
 	rv = saCkptInitialize(&ckpt_handle, &callbacks, &version);
 
@@ -1605,8 +1597,7 @@
 {
 	struct checkpoint_data *cp;
 	struct clog_cpg *entry, *tmp;
-	struct list_head *p, *n;
-	struct clog_tfr *t;
+	struct clog_request *rq, *n;
 	int i;
 
 	LOG_ERROR("");
@@ -1630,15 +1621,15 @@
 				break;
 		LOG_ERROR("  CKPTs waiting     : %d", i);
 		LOG_ERROR("  Working list:");
-		list_for_each_safe(p, n, &entry->working_list) {
-			t = (struct clog_tfr *)p;
-			LOG_ERROR("  %s/%u", _RQ_TYPE(t->request_type), t->seq);
+		list_for_each_entry_safe(rq, n, &entry->working_list, list) {
+			LOG_ERROR("  %s/%u", _RQ_TYPE(rq->u_rq.request_type),
+				  rq->u_rq.seq);
 		}
 
 		LOG_ERROR("  Startup list:");
-		list_for_each_safe(p, n, &entry->startup_list) {
-			t = (struct clog_tfr *)p;
-			LOG_ERROR("  %s/%u", _RQ_TYPE(t->request_type), t->seq);
+		list_for_each_entry_safe(rq, n, &entry->startup_list, list) {
+			LOG_ERROR("  %s/%u", _RQ_TYPE(rq->u_rq.request_type),
+				  rq->u_rq.seq);
 		}
 
 		LOG_ERROR("Command History:");
--- LVM2/daemons/clogd/cluster.h	2009/01/08 17:12:33	1.1
+++ LVM2/daemons/clogd/cluster.h	2009/07/21 15:34:53	1.2
@@ -1,6 +1,39 @@
 #ifndef __CLUSTER_LOG_CLUSTER_DOT_H__
 #define __CLUSTER_LOG_CLUSTER_DOT_H__
 
+#include "list.h"
+#include <linux/dm-log-userspace.h>
+
+/*
+ * There is other information in addition to what can
+ * be found in the dm_ulog_request structure that we
+ * need for processing.  'clog_request' is the wrapping
+ * structure we use to make the additional fields
+ * available.
+ */
+struct clog_request {
+	struct list_head list;
+
+	/*
+	 * 'originator' is the machine from which the requests
+	 * was made.
+	 */
+	uint32_t originator;
+
+	/*
+	 * 'pit_server' is the "point-in-time" server for the
+	 * request.  (I.e.  The machine that was the server at
+	 * the time the request was issued - only important during
+	 * startup.
+	 */
+	uint32_t pit_server;
+
+	/*
+	 * The request from the kernel that is being processed
+	 */
+	struct dm_ulog_request u_rq;
+};
+
 int init_cluster(void);
 void cleanup_cluster(void);
 void cluster_debug(void);
@@ -8,6 +41,6 @@
 int create_cluster_cpg(char *str);
 int destroy_cluster_cpg(char *str);
 
-int cluster_send(struct clog_tfr *tfr);
+int cluster_send(struct clog_request *rq);
 
 #endif /* __CLUSTER_LOG_CLUSTER_DOT_H__ */
--- LVM2/daemons/clogd/common.h	2009/01/08 17:12:33	1.1
+++ LVM2/daemons/clogd/common.h	2009/07/21 15:34:53	1.2
@@ -8,33 +8,15 @@
 
 #define EXIT_LOCKFILE              2
 
-#define EXIT_KERNEL_TFR_SOCKET     3 /* Failed netlink socket create */
-#define EXIT_KERNEL_TFR_BIND       4
-#define EXIT_KERNEL_TFR_SETSOCKOPT 5
+#define EXIT_KERNEL_SOCKET         3 /* Failed netlink socket create */
+#define EXIT_KERNEL_BIND           4
+#define EXIT_KERNEL_SETSOCKOPT     5
 
 #define EXIT_CLUSTER_CKPT_INIT     6 /* Failed to init checkpoint */
 
 #define EXIT_QUEUE_NOMEM           7
 
-/* Located in dm-clog-tfr.h
-#define RQ_TYPE(x) \
-	((x) == DM_CLOG_CTR) ? "DM_CLOG_CTR" : \
-	((x) == DM_CLOG_DTR) ? "DM_CLOG_DTR" : \
-	((x) == DM_CLOG_PRESUSPEND) ? "DM_CLOG_PRESUSPEND" : \
-	((x) == DM_CLOG_POSTSUSPEND) ? "DM_CLOG_POSTSUSPEND" : \
-	((x) == DM_CLOG_RESUME) ? "DM_CLOG_RESUME" : \
-	((x) == DM_CLOG_GET_REGION_SIZE) ? "DM_CLOG_GET_REGION_SIZE" : \
-	((x) == DM_CLOG_IS_CLEAN) ? "DM_CLOG_IS_CLEAN" : \
-	((x) == DM_CLOG_IN_SYNC) ? "DM_CLOG_IN_SYNC" : \
-	((x) == DM_CLOG_FLUSH) ? "DM_CLOG_FLUSH" : \
-	((x) == DM_CLOG_MARK_REGION) ? "DM_CLOG_MARK_REGION" : \
-	((x) == DM_CLOG_CLEAR_REGION) ? "DM_CLOG_CLEAR_REGION" : \
-	((x) == DM_CLOG_GET_RESYNC_WORK) ? "DM_CLOG_GET_RESYNC_WORK" : \
-	((x) == DM_CLOG_SET_REGION_SYNC) ? "DM_CLOG_SET_REGION_SYNC" : \
-	((x) == DM_CLOG_GET_SYNC_COUNT) ? "DM_CLOG_GET_SYNC_COUNT" : \
-	((x) == DM_CLOG_STATUS_INFO) ? "DM_CLOG_STATUS_INFO" : \
-	((x) == DM_CLOG_STATUS_TABLE) ? "DM_CLOG_STATUS_TABLE" : \
-	NULL
-*/
+
+#define DM_ULOG_REQUEST_SIZE 1024
 
 #endif /* __CLUSTER_LOG_COMMON_DOT_H__ */
--- LVM2/daemons/clogd/functions.c	2009/07/21 15:32:13	1.3
+++ LVM2/daemons/clogd/functions.c	2009/07/21 15:34:53	1.4
@@ -12,7 +12,7 @@
 #define __USE_GNU /* for O_DIRECT */
 #include <fcntl.h>
 #include <time.h>
-#include "linux/dm-clog-tfr.h"
+#include "linux/dm-log-userspace.h"
 #include "list.h"
 #include "functions.h"
 #include "common.h"
@@ -33,10 +33,10 @@
 #define RESYNC_HISTORY 50
 //static char resync_history[RESYNC_HISTORY][128];
 //static int idx = 0;
-#define LOG_SPRINT(_lc, f, arg...) do {		\
-		lc->idx++; \
-		lc->idx = lc->idx % RESYNC_HISTORY; \
-		sprintf(lc->resync_history[lc->idx], f, ## arg); \
+#define LOG_SPRINT(_lc, f, arg...) do {					\
+		lc->idx++;						\
+		lc->idx = lc->idx % RESYNC_HISTORY;			\
+		sprintf(lc->resync_history[lc->idx], f, ## arg);	\
 	} while (0)
 
 struct log_header {
@@ -146,7 +146,7 @@
 
 /*
  * get_log
- * @tfr
+ * @rq
  *
  * Returns: log if found, NULL otherwise
  */
@@ -167,7 +167,7 @@
 
 /*
  * get_pending_log
- * @tfr
+ * @rq
  *
  * Pending logs are logs that have been 'clog_ctr'ed, but
  * have not joined the CPG (via clog_resume).
@@ -302,6 +302,16 @@
 	struct stat statbuf;
 	int major, minor;
 
+	if (!strstr(major_minor_str, ":")) {
+		r = stat(major_minor_str, &statbuf);
+		if (r)
+			return -errno;
+		if (!S_ISBLK(statbuf.st_mode))
+			return -EINVAL;
+		sprintf(path_rtn, "%s", major_minor_str);
+		return 0;
+	}
+
 	r = sscanf(major_minor_str, "%d:%d", &major, &minor);
 	if (r != 2)
 		return -EINVAL;
@@ -348,7 +358,7 @@
 	return r ? -errno : 0;
 }
 
-static int _clog_ctr(int argc, char **argv, uint64_t device_size)
+static int _clog_ctr(char *uuid, int argc, char **argv, uint64_t device_size)
 {
 	int i;
 	int r = 0;
@@ -371,7 +381,7 @@
 	if (!strtoll(argv[0], &p, 0) || *p) {
 		disk_log = 1;
 
-		if ((argc < 3) || (argc > 5)) {
+		if ((argc < 2) || (argc > 4)) {
 			LOG_ERROR("Too %s arguments to clustered_disk log type",
 				  (argc < 3) ? "few" : "many");
 			r = -EINVAL;
@@ -387,7 +397,7 @@
 	} else {
 		disk_log = 0;
 
-		if ((argc < 2) || (argc > 4)) {
+		if ((argc < 1) || (argc > 3)) {
 			LOG_ERROR("Too %s arguments to clustered_core log type",
 				  (argc < 2) ? "few" : "many");
 			r = -EINVAL;
@@ -438,12 +448,12 @@
 	lc->disk_fd = -1;
 	lc->log_dev_failed = 0;
 	lc->ref_count = 1;
-	strncpy(lc->uuid, argv[1 + disk_log], DM_UUID_LEN);
+	strncpy(lc->uuid, uuid, DM_UUID_LEN);
 
 	if ((dup = get_log(lc->uuid)) ||
 	    (dup = get_pending_log(lc->uuid))) {
 		LOG_DBG("[%s] Inc reference count on cluster log",
-			  SHORT_UUID(lc->uuid));
+			SHORT_UUID(lc->uuid));
 		free(lc);
 		dup->ref_count++;
 		return 0;
@@ -523,49 +533,56 @@
 
 /*
  * clog_ctr
- * @tfr
+ * @rq
  *
- * tfr->data should contain constructor string as follows:
- *	[disk] <regiion_size> <uuid> [[no]sync] <device_len>
+ * rq->data should contain constructor string as follows:
+ *	<log_type> [disk] <region_size> [[no]sync] <device_len>
  * The kernel is responsible for adding the <dev_len> argument
  * to the end; otherwise, we cannot compute the region_count.
  *
- * FIXME: Currently relies on caller to fill in tfr->error
+ * FIXME: Currently relies on caller to fill in rq->error
  */
-static int clog_dtr(struct clog_tfr *tfr);
-static int clog_ctr(struct clog_tfr *tfr)
+static int clog_dtr(struct dm_ulog_request *rq);
+static int clog_ctr(struct dm_ulog_request *rq)
 {
 	int argc, i, r = 0;
 	char *p, **argv = NULL;
 	uint64_t device_size;
 
 	/* Sanity checks */
-	if (!tfr->data_size) {
+	if (!rq->data_size) {
 		LOG_ERROR("Received constructor request with no data");
 		return -EINVAL;
 	}
 
-	if (strlen(tfr->data) != tfr->data_size) {
+	if (strlen(rq->data) > rq->data_size) {
 		LOG_ERROR("Received constructor request with bad data");
-		LOG_ERROR("strlen(tfr->data)[%d] != tfr->data_size[%llu]",
-			  (int)strlen(tfr->data),
-			  (unsigned long long)tfr->data_size);
-		LOG_ERROR("tfr->data = '%s' [%d]",
-			  tfr->data, (int)strlen(tfr->data));
+		LOG_ERROR("strlen(rq->data)[%d] != rq->data_size[%llu]",
+			  (int)strlen(rq->data),
+			  (unsigned long long)rq->data_size);
+		LOG_ERROR("rq->data = '%s' [%d]",
+			  rq->data, (int)strlen(rq->data));
 		return -EINVAL;
 	}
 
 	/* Split up args */
-	for (argc = 1, p = tfr->data; (p = strstr(p, " ")); p++, argc++)
+	for (argc = 1, p = rq->data; (p = strstr(p, " ")); p++, argc++)
 		*p = '\0';
 
 	argv = malloc(argc * sizeof(char *));
 	if (!argv)
 		return -ENOMEM;
 
-	for (i = 0, p = tfr->data; i < argc; i++, p = p + strlen(p) + 1)
+	for (i = 0, p = rq->data; i < argc; i++, p = p + strlen(p) + 1)
 		argv[i] = p;
 
+	if (strcmp(argv[0], "clustered_disk") &&
+	    strcmp(argv[0], "clustered_core")) {
+		LOG_ERROR("Unsupported userspace log type, \"%s\"", argv[0]);
+		free(argv);
+		return -EINVAL;
+	}
+
 	if (!(device_size = strtoll(argv[argc - 1], &p, 0)) || *p) {
 		LOG_ERROR("Invalid device size argument: %s", argv[argc - 1]);
 		free(argv);
@@ -573,31 +590,34 @@
 	}
 
 	argc--;  /* We pass in the device_size separate */
-	r = _clog_ctr(argc, argv, device_size);
+	r = _clog_ctr(rq->uuid, argc - 1, argv + 1, device_size);
 
 	/* We join the CPG when we resume */
 
 	/* No returning data */
-	tfr->data_size = 0;
+	rq->data_size = 0;
 
-	free(argv);
-	if (r)
-		LOG_ERROR("Failed to create cluster log (%s)", tfr->uuid);
+	if (r) {
+		LOG_ERROR("Failed to create cluster log (%s)", rq->uuid);
+		for (i = 0; i < argc; i++)
+			LOG_ERROR("argv[%d] = %s", i, argv[i]);
+	}
 	else
 		LOG_DBG("[%s] Cluster log created",
-			  SHORT_UUID(tfr->uuid));
+			SHORT_UUID(rq->uuid));
 
+	free(argv);
 	return r;
 }
 
 /*
  * clog_dtr
- * @tfr
+ * @rq
  *
  */
-static int clog_dtr(struct clog_tfr *tfr)
+static int clog_dtr(struct dm_ulog_request *rq)
 {
-	struct log_c *lc = get_log(tfr->uuid);
+	struct log_c *lc = get_log(rq->uuid);
 
 	if (lc) {
 		/*
@@ -607,10 +627,10 @@
 		lc->ref_count--;
 		if (!lc->ref_count) {
 			LOG_ERROR("[%s] DTR before SUS: leaving CPG",
-				  SHORT_UUID(tfr->uuid));
-			destroy_cluster_cpg(tfr->uuid);
+				  SHORT_UUID(rq->uuid));
+			destroy_cluster_cpg(rq->uuid);
 		}
-	} else if ((lc = get_pending_log(tfr->uuid))) {
+	} else if ((lc = get_pending_log(rq->uuid))) {
 		lc->ref_count--;
 	} else {
 		LOG_ERROR("clog_dtr called on log that is not official or pending");
@@ -619,7 +639,7 @@
 
 	if (lc->ref_count) {
 		LOG_DBG("[%s] Dec reference count on cluster log",
-			  SHORT_UUID(lc->uuid));
+			SHORT_UUID(lc->uuid));
 		return 0;
 	}
 
@@ -639,12 +659,12 @@
 
 /*
  * clog_presuspend
- * @tfr
+ * @rq
  *
  */
-static int clog_presuspend(struct clog_tfr *tfr)
+static int clog_presuspend(struct dm_ulog_request *rq)
 {
-	struct log_c *lc = get_log(tfr->uuid);
+	struct log_c *lc = get_log(rq->uuid);
 
 	if (!lc)
 		return -EINVAL;
@@ -659,18 +679,18 @@
 
 /*
  * clog_postsuspend
- * @tfr
+ * @rq
  *
  */
-static int clog_postsuspend(struct clog_tfr *tfr)
+static int clog_postsuspend(struct dm_ulog_request *rq)
 {
-	struct log_c *lc = get_log(tfr->uuid);
+	struct log_c *lc = get_log(rq->uuid);
 
 	if (!lc)
 		return -EINVAL;
 
 	LOG_DBG("[%s] clog_postsuspend: leaving CPG", SHORT_UUID(lc->uuid));
-	destroy_cluster_cpg(tfr->uuid);
+	destroy_cluster_cpg(rq->uuid);
 
 	lc->state = LOG_SUSPENDED;
 	lc->recovering_region = (uint64_t)-1;
@@ -682,7 +702,7 @@
 
 /*
  * cluster_postsuspend
- * @tfr
+ * @rq
  *
  */
 int cluster_postsuspend(char *uuid)
@@ -704,15 +724,15 @@
 
 /*
  * clog_resume
- * @tfr
+ * @rq
  *
  * Does the main work of resuming.
  */
-static int clog_resume(struct clog_tfr *tfr)
+static int clog_resume(struct dm_ulog_request *rq)
 {
 	uint32_t i;
 	int commit_log = 0;
-	struct log_c *lc = get_log(tfr->uuid);
+	struct log_c *lc = get_log(rq->uuid);
 	size_t size = lc->bitset_uint32_count * sizeof(uint32_t);
 
 	if (!lc)
@@ -721,7 +741,7 @@
 	switch (lc->resume_override) {
 	case 1000:
 		LOG_ERROR("[%s] Additional resume issued before suspend",
-			  SHORT_UUID(tfr->uuid));
+			  SHORT_UUID(rq->uuid));
 #ifdef DEBUG
 		kill(getpid(), SIGUSR1);
 #endif
@@ -756,12 +776,12 @@
 
 	if (lc->log_dev_failed) {
 		LOG_ERROR("Log device has failed, unable to read bits");
-		tfr->error = 0;  /* We can handle this so far */
+		rq->error = 0;  /* We can handle this so far */
 		lc->disk_nr_regions = 0;
 	} else
-		tfr->error = read_log(lc);
+		rq->error = read_log(lc);
 
-	switch (tfr->error) {
+	switch (rq->error) {
 	case 0:
 		if (lc->disk_nr_regions < lc->region_count)
 			LOG_DBG("[%s] Mirror has grown, updating log bits",
@@ -798,8 +818,8 @@
 	memcpy(lc->sync_bits, lc->clean_bits, size);
 
 	if (commit_log && (lc->disk_fd >= 0)) {
-		tfr->error = write_log(lc);
-		if (tfr->error)
+		rq->error = write_log(lc);
+		if (rq->error)
 			LOG_ERROR("Failed initial disk log write");
 		else
 			LOG_DBG("Disk log initialized");
@@ -823,26 +843,26 @@
 	lc->state = LOG_RESUMED;
 	lc->recovery_halted = 0;
 	
-	return tfr->error;
+	return rq->error;
 }
 
 /*
  * local_resume
- * @tfr
+ * @rq
  *
  * If the log is pending, we must first join the cpg and
  * put the log in the official list.
  *
  */
-int local_resume(struct clog_tfr *tfr)
+int local_resume(struct dm_ulog_request *rq)
 {
 	int r;
 	time_t t;
-	struct log_c *lc = get_log(tfr->uuid);
+	struct log_c *lc = get_log(rq->uuid);
 
 	if (!lc) {
 		/* Is the log in the pending list? */
-		lc = get_pending_log(tfr->uuid);
+		lc = get_pending_log(rq->uuid);
 		if (!lc) {
 			LOG_ERROR("clog_resume called on log that is not official or pending");
 			return -EINVAL;
@@ -877,7 +897,7 @@
 			sleep(3 - t);
 
 		/* Join the CPG */
-		r = create_cluster_cpg(tfr->uuid);
+		r = create_cluster_cpg(rq->uuid);
 		if (r) {
 			LOG_ERROR("clog_resume:  Failed to create cluster CPG");
 			return r;
@@ -893,7 +913,7 @@
 
 /*
  * clog_get_region_size
- * @tfr
+ * @rq
  *
  * Since this value doesn't change, the kernel
  * should not need to talk to server to get this
@@ -901,46 +921,44 @@
  *
  * Returns: 0 on success, -EXXX on failure
  */
-static int clog_get_region_size(struct clog_tfr *tfr)
+static int clog_get_region_size(struct dm_ulog_request *rq)
 {
-	uint64_t *rtn = (uint64_t *)tfr->data;
-	struct log_c *lc = get_log(tfr->uuid);
+	uint64_t *rtn = (uint64_t *)rq->data;
+	struct log_c *lc = get_log(rq->uuid);
 
-	LOG_PRINT("WARNING: kernel should not be calling clog_get_region_size");
-	if (!lc)
+	if (!lc && !(lc = get_pending_log(rq->uuid)))
 		return -EINVAL;
 
-	/* FIXME: region_size is 32-bit, while function requires 64-bit */
 	*rtn = lc->region_size;
-	tfr->data_size = sizeof(*rtn);
+	rq->data_size = sizeof(*rtn);
 
 	return 0;
 }
 
 /*
  * clog_is_clean
- * @tfr
+ * @rq
  *
  * Returns: 1 if clean, 0 otherwise
  */
-static int clog_is_clean(struct clog_tfr *tfr)
+static int clog_is_clean(struct dm_ulog_request *rq)
 {
-	int *rtn = (int *)tfr->data;
-	uint64_t region = *((uint64_t *)(tfr->data));
-	struct log_c *lc = get_log(tfr->uuid);
+	int64_t *rtn = (int64_t *)rq->data;
+	uint64_t region = *((uint64_t *)(rq->data));
+	struct log_c *lc = get_log(rq->uuid);
 
 	if (!lc)
 		return -EINVAL;
 
 	*rtn = log_test_bit(lc->clean_bits, region);
-	tfr->data_size = sizeof(*rtn);
+	rq->data_size = sizeof(*rtn);
 
 	return 0;
 }
 
 /*
  * clog_in_sync
- * @tfr
+ * @rq
  *
  * We ignore any request for non-block.  That
  * should be handled elsewhere.  (If the request
@@ -948,11 +966,11 @@
  *
  * Returns: 1 if in-sync, 0 otherwise
  */
-static int clog_in_sync(struct clog_tfr *tfr)
+static int clog_in_sync(struct dm_ulog_request *rq)
 {
-	int *rtn = (int *)tfr->data;
-	uint64_t region = *((uint64_t *)(tfr->data));
-	struct log_c *lc = get_log(tfr->uuid);
+	int64_t *rtn = (int64_t *)rq->data;
+	uint64_t region = *((uint64_t *)(rq->data));
+	struct log_c *lc = get_log(rq->uuid);
 
 	if (!lc)
 		return -EINVAL;
@@ -968,20 +986,20 @@
 		LOG_DBG("[%s] Region is not in-sync: %llu",
 			SHORT_UUID(lc->uuid), (unsigned long long)region);
 
-	tfr->data_size = sizeof(*rtn);
+	rq->data_size = sizeof(*rtn);
 
 	return 0;
 }
 
 /*
  * clog_flush
- * @tfr
+ * @rq
  *
  */
-static int clog_flush(struct clog_tfr *tfr, int server)
+static int clog_flush(struct dm_ulog_request *rq, int server)
 {
 	int r = 0;
-	struct log_c *lc = get_log(tfr->uuid);
+	struct log_c *lc = get_log(rq->uuid);
 	
 	if (!lc)
 		return -EINVAL;
@@ -994,7 +1012,7 @@
 	 * if we are the server.
 	 */
 	if (server && (lc->disk_fd >= 0)) {
-		r = tfr->error = write_log(lc);
+		r = rq->error = write_log(lc);
 		if (r)
 			LOG_ERROR("[%s] Error writing to disk log",
 				  SHORT_UUID(lc->uuid));
@@ -1057,38 +1075,38 @@
 
 /*
  * clog_mark_region
- * @tfr
+ * @rq
  *
- * tfr may contain more than one mark request.  We
+ * rq may contain more than one mark request.  We
  * can determine the number from the 'data_size' field.
  *
  * Returns: 0 on success, -EXXX on failure
  */
-static int clog_mark_region(struct clog_tfr *tfr)
+static int clog_mark_region(struct dm_ulog_request *rq, uint32_t originator)
 {
 	int r;
 	int count;
 	uint64_t *region;
-	struct log_c *lc = get_log(tfr->uuid);
+	struct log_c *lc = get_log(rq->uuid);
 
 	if (!lc)
 		return -EINVAL;
 
-	if (tfr->data_size % sizeof(uint64_t)) {
+	if (rq->data_size % sizeof(uint64_t)) {
 		LOG_ERROR("Bad data size given for mark_region request");
 		return -EINVAL;
 	}
 
-	count = tfr->data_size / sizeof(uint64_t);
-	region = (uint64_t *)&tfr->data;
+	count = rq->data_size / sizeof(uint64_t);
+	region = (uint64_t *)&rq->data;
 
 	for (; count > 0; count--, region++) {
-		r = mark_region(lc, *region, tfr->originator);
+		r = mark_region(lc, *region, originator);
 		if (r)
 			return r;
 	}
 
-	tfr->data_size = 0;
+	rq->data_size = 0;
 
 	return 0;
 }
@@ -1124,60 +1142,59 @@
 
 /*
  * clog_clear_region
- * @tfr
+ * @rq
  *
- * tfr may contain more than one clear request.  We
+ * rq may contain more than one clear request.  We
  * can determine the number from the 'data_size' field.
  *
  * Returns: 0 on success, -EXXX on failure
  */
-static int clog_clear_region(struct clog_tfr *tfr)
+static int clog_clear_region(struct dm_ulog_request *rq, uint32_t originator)
 {
 	int r;
 	int count;
 	uint64_t *region;
-	struct log_c *lc = get_log(tfr->uuid);
+	struct log_c *lc = get_log(rq->uuid);
 
 	if (!lc)
 		return -EINVAL;
 
-	if (tfr->data_size % sizeof(uint64_t)) {
+	if (rq->data_size % sizeof(uint64_t)) {
 		LOG_ERROR("Bad data size given for clear_region request");
 		return -EINVAL;
 	}
 
-	count = tfr->data_size / sizeof(uint64_t);
-	region = (uint64_t *)&tfr->data;
+	count = rq->data_size / sizeof(uint64_t);
+	region = (uint64_t *)&rq->data;
 
 	for (; count > 0; count--, region++) {
-		r = clear_region(lc, *region, tfr->originator);
+		r = clear_region(lc, *region, originator);
 		if (r)
 			return r;
 	}
 
-	tfr->data_size = 0;
+	rq->data_size = 0;
 
 	return 0;
 }
 
 /*
  * clog_get_resync_work
- * @tfr
+ * @rq
  *
  */
-static int clog_get_resync_work(struct clog_tfr *tfr)
+static int clog_get_resync_work(struct dm_ulog_request *rq, uint32_t originator)
 {
 	struct {
-		int32_t i;
-		uint32_t arch_padding;
+		int64_t i;
 		uint64_t r;
-	} *pkg = (void *)tfr->data;
-	struct log_c *lc = get_log(tfr->uuid);
+	} *pkg = (void *)rq->data;
+	struct log_c *lc = get_log(rq->uuid);
 
 	if (!lc)
 		return -EINVAL;
 
-	tfr->data_size = sizeof(*pkg);
+	rq->data_size = sizeof(*pkg);
 	pkg->i = 0;
 
 	if (lc->sync_search >= lc->region_count) {
@@ -1187,15 +1204,15 @@
 		 */
 		LOG_SPRINT(lc, "GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
 			   "Recovery finished",
-			   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator);
+			   rq->seq, SHORT_UUID(lc->uuid), originator);
 		return 0;
 	}
 
 	if (lc->recovering_region != (uint64_t)-1) {
-		if (lc->recoverer == tfr->originator) {
+		if (lc->recoverer == originator) {
 			LOG_SPRINT(lc, "GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
 				   "Re-requesting work (%llu)",
-				   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator,
+				   rq->seq, SHORT_UUID(lc->uuid), originator,
 				   (unsigned long long)lc->recovering_region);
 			pkg->r = lc->recovering_region;
 			pkg->i = 1;
@@ -1203,7 +1220,7 @@
 		} else {
 			LOG_SPRINT(lc, "GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
 				   "Someone already recovering (%llu)",
-				   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator,
+				   rq->seq, SHORT_UUID(lc->uuid), originator,
 				   (unsigned long long)lc->recovering_region);
 		}
 
@@ -1222,11 +1239,11 @@
 		if (!log_test_bit(lc->sync_bits, pkg->r)) {
 			LOG_SPRINT(lc, "GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
 				   "Assigning priority resync work (%llu)",
-				   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator,
+				   rq->seq, SHORT_UUID(lc->uuid), originator,
 				   (unsigned long long)pkg->r);
 			pkg->i = 1;
 			lc->recovering_region = pkg->r;
-			lc->recoverer = tfr->originator;
+			lc->recoverer = originator;
 			return 0;
 		}
 	}
@@ -1238,7 +1255,7 @@
 	if (pkg->r >= lc->region_count) {
 		LOG_SPRINT(lc, "GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
 			   "Resync work complete.",
-			   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator);
+			   rq->seq, SHORT_UUID(lc->uuid), originator);
 		return 0;
 	}
 
@@ -1246,27 +1263,26 @@
 
 	LOG_SPRINT(lc, "GET - SEQ#=%u, UUID=%s, nodeid = %u:: "
 		   "Assigning resync work (%llu)",
-		   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator,
+		   rq->seq, SHORT_UUID(lc->uuid), originator,
 		   (unsigned long long)pkg->r);
 	pkg->i = 1;
 	lc->recovering_region = pkg->r;
-	lc->recoverer = tfr->originator;
+	lc->recoverer = originator;
 
 	return 0;
 }
 
 /*
  * clog_set_region_sync
- * @tfr
+ * @rq
  */
-static int clog_set_region_sync(struct clog_tfr *tfr)
+static int clog_set_region_sync(struct dm_ulog_request *rq, uint32_t originator)
 {
 	struct {
 		uint64_t region;
-		uint32_t arch_padding;
-		int32_t in_sync;
-	} *pkg = (void *)tfr->data;
-	struct log_c *lc = get_log(tfr->uuid);
+		int64_t in_sync;
+	} *pkg = (void *)rq->data;
+	struct log_c *lc = get_log(rq->uuid);
 
 	if (!lc)
 		return -EINVAL;
@@ -1277,7 +1293,7 @@
 		if (log_test_bit(lc->sync_bits, pkg->region)) {
 			LOG_SPRINT(lc, "SET - SEQ#=%u, UUID=%s, nodeid = %u:: "
 				   "Region already set (%llu)",
-				   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator,
+				   rq->seq, SHORT_UUID(lc->uuid), originator,
 				   (unsigned long long)pkg->region);
 		} else {
 			log_set_bit(lc, lc->sync_bits, pkg->region);
@@ -1286,7 +1302,7 @@
 			/* The rest of this section is all for debugging */
 			LOG_SPRINT(lc, "SET - SEQ#=%u, UUID=%s, nodeid = %u:: "
 				   "Setting region (%llu)",
-				   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator,
+				   rq->seq, SHORT_UUID(lc->uuid), originator,
 				   (unsigned long long)pkg->region);
 			if (pkg->region == lc->skip_bit_warning)
 				lc->skip_bit_warning = lc->region_count;
@@ -1312,7 +1328,7 @@
 		log_clear_bit(lc, lc->sync_bits, pkg->region);
 		LOG_SPRINT(lc, "SET - SEQ#=%u, UUID=%s, nodeid = %u:: "
 			   "Unsetting region (%llu)",
-			   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator,
+			   rq->seq, SHORT_UUID(lc->uuid), originator,
 			   (unsigned long long)pkg->region);
 	}
 
@@ -1321,7 +1337,7 @@
 
 		LOG_SPRINT(lc, "SET - SEQ#=%u, UUID=%s, nodeid = %u:: "
 			   "sync_count(%llu) != bitmap count(%llu)",
-			   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator,
+			   rq->seq, SHORT_UUID(lc->uuid), originator,
 			   (unsigned long long)lc->sync_count, reset);
 #ifdef DEBUG
 		kill(getpid(), SIGUSR1);
@@ -1332,20 +1348,20 @@
 	if (lc->sync_count > lc->region_count)
 		LOG_SPRINT(lc, "SET - SEQ#=%u, UUID=%s, nodeid = %u:: "
 			   "(lc->sync_count > lc->region_count) - this is bad",
-			   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator);
+			   rq->seq, SHORT_UUID(lc->uuid), originator);
 
-	tfr->data_size = 0;
+	rq->data_size = 0;
 	return 0;
 }
 
 /*
  * clog_get_sync_count
- * @tfr
+ * @rq
  */
-static int clog_get_sync_count(struct clog_tfr *tfr)
+static int clog_get_sync_count(struct dm_ulog_request *rq, uint32_t originator)
 {
-	uint64_t *sync_count = (uint64_t *)tfr->data;
-	struct log_c *lc = get_log(tfr->uuid);
+	uint64_t *sync_count = (uint64_t *)rq->data;
+	struct log_c *lc = get_log(rq->uuid);
 
 	/*
 	 * FIXME: Mirror requires us to be able to ask for
@@ -1354,21 +1370,21 @@
 	 * the stored value may not be accurate.
 	 */
 	if (!lc)
-		lc = get_pending_log(tfr->uuid);
+		lc = get_pending_log(rq->uuid);
 
 	if (!lc)
 		return -EINVAL;
 
 	*sync_count = lc->sync_count;
 
-	tfr->data_size = sizeof(*sync_count);
+	rq->data_size = sizeof(*sync_count);
 
 	if (lc->sync_count != count_bits32(lc->sync_bits, lc->bitset_uint32_count)) {
 		unsigned long long reset = count_bits32(lc->sync_bits, lc->bitset_uint32_count);
 
 		LOG_SPRINT(lc, "get_sync_count - SEQ#=%u, UUID=%s, nodeid = %u:: "
 			   "sync_count(%llu) != bitmap count(%llu)",
-			   tfr->seq, SHORT_UUID(lc->uuid), tfr->originator,
+			   rq->seq, SHORT_UUID(lc->uuid), originator,
 			   (unsigned long long)lc->sync_count, reset);
 #ifdef DEBUG
 		kill(getpid(), SIGUSR1);
@@ -1379,129 +1395,124 @@
 	return 0;
 }
 
-static int core_status_info(struct log_c *lc, struct clog_tfr *tfr)
+static int core_status_info(struct log_c *lc, struct dm_ulog_request *rq)
 {
-	char *data = (char *)tfr->data;
+	char *data = (char *)rq->data;
 
-	tfr->data_size = sprintf(data, "1 clustered_core");
+	rq->data_size = sprintf(data, "1 clustered_core");
 
 	return 0;
 }
 
-static int disk_status_info(struct log_c *lc, struct clog_tfr *tfr)
+static int disk_status_info(struct log_c *lc, struct dm_ulog_request *rq)
 {
-	char *data = (char *)tfr->data;
+	char *data = (char *)rq->data;
 	struct stat statbuf;
 
 	if(fstat(lc->disk_fd, &statbuf)) {
-		tfr->error = -errno;
+		rq->error = -errno;
 		return -errno;
 	}
 
-	tfr->data_size = sprintf(data, "3 clustered_disk %d:%d %c",
-				 major(statbuf.st_rdev), minor(statbuf.st_rdev),
-				 (lc->log_dev_failed) ? 'D' : 'A');
+	rq->data_size = sprintf(data, "3 clustered_disk %d:%d %c",
+				major(statbuf.st_rdev), minor(statbuf.st_rdev),
+				(lc->log_dev_failed) ? 'D' : 'A');
 
 	return 0;
 }
 
 /*
  * clog_status_info
- * @tfr
+ * @rq
  *
  */
-static int clog_status_info(struct clog_tfr *tfr)
+static int clog_status_info(struct dm_ulog_request *rq)
 {
 	int r;
-	struct log_c *lc = get_log(tfr->uuid);
+	struct log_c *lc = get_log(rq->uuid);
 
 	if (!lc)
-		lc = get_pending_log(tfr->uuid);
+		lc = get_pending_log(rq->uuid);
 
 	if (!lc)
 		return -EINVAL;
 
 	if (lc->disk_fd == -1)
-		r = core_status_info(lc, tfr);
+		r = core_status_info(lc, rq);
 	else
-		r = disk_status_info(lc, tfr);
+		r = disk_status_info(lc, rq);
 
 	return r;
 }
 
-static int core_status_table(struct log_c *lc, struct clog_tfr *tfr)
+static int core_status_table(struct log_c *lc, struct dm_ulog_request *rq)
 {
-	int params;
-	char *data = (char *)tfr->data;
+	char *data = (char *)rq->data;
 
-	params = (lc->sync == DEFAULTSYNC) ? 3 : 4;
-	tfr->data_size = sprintf(data, "clustered_core %d %u %s %s%s ",
-				 params, lc->region_size, lc->uuid,
-				 (lc->sync == DEFAULTSYNC) ? "" :
-				 (lc->sync == NOSYNC) ? "nosync " : "sync ",
-				 (lc->block_on_error) ? "block_on_error" : "");
+	rq->data_size = sprintf(data, "clustered_core %u %s%s ",
+				lc->region_size,
+				(lc->sync == DEFAULTSYNC) ? "" :
+				(lc->sync == NOSYNC) ? "nosync " : "sync ",
+				(lc->block_on_error) ? "block_on_error" : "");
 	return 0;
 }
 
-static int disk_status_table(struct log_c *lc, struct clog_tfr *tfr)
+static int disk_status_table(struct log_c *lc, struct dm_ulog_request *rq)
 {
-	int params;
-	char *data = (char *)tfr->data;
+	char *data = (char *)rq->data;
 	struct stat statbuf;
 
 	if(fstat(lc->disk_fd, &statbuf)) {
-		tfr->error = -errno;
+		rq->error = -errno;
 		return -errno;
 	}
 
-	params = (lc->sync == DEFAULTSYNC) ? 4 : 5;
-	tfr->data_size = sprintf(data, "clustered_disk %d %d:%d %u %s %s%s ",
-				 params, major(statbuf.st_rdev), minor(statbuf.st_rdev),
-				 lc->region_size, lc->uuid,
-				 (lc->sync == DEFAULTSYNC) ? "" :
-				 (lc->sync == NOSYNC) ? "nosync " : "sync ",
-				 (lc->block_on_error) ? "block_on_error" : "");
+	rq->data_size = sprintf(data, "clustered_disk %d:%d %u %s%s ",
+				major(statbuf.st_rdev), minor(statbuf.st_rdev),
+				lc->region_size,
+				(lc->sync == DEFAULTSYNC) ? "" :
+				(lc->sync == NOSYNC) ? "nosync " : "sync ",
+				(lc->block_on_error) ? "block_on_error" : "");
 	return 0;
 }
 
 /*
  * clog_status_table
- * @tfr
+ * @rq
  *
  */
-static int clog_status_table(struct clog_tfr *tfr)
+static int clog_status_table(struct dm_ulog_request *rq)
 {
 	int r;
-	struct log_c *lc = get_log(tfr->uuid);
+	struct log_c *lc = get_log(rq->uuid);
 
 	if (!lc)
-		lc = get_pending_log(tfr->uuid);
+		lc = get_pending_log(rq->uuid);
 
 	if (!lc)
 		return -EINVAL;
 
 	if (lc->disk_fd == -1)
-		r = core_status_table(lc, tfr);
+		r = core_status_table(lc, rq);
 	else
-		r = disk_status_table(lc, tfr);
+		r = disk_status_table(lc, rq);
 
 	return r;
 }
 
 /*
  * clog_is_remote_recovering
- * @tfr
+ * @rq
  *
  */
-static int clog_is_remote_recovering(struct clog_tfr *tfr)
+static int clog_is_remote_recovering(struct dm_ulog_request *rq)
 {
-	uint64_t region = *((uint64_t *)(tfr->data));
+	uint64_t region = *((uint64_t *)(rq->data));
 	struct {
-		int32_t is_recovering;
-		uint32_t arch_padding;
+		int64_t is_recovering;
 		uint64_t in_sync_hint;
-	} *pkg = (void *)tfr->data;
-	struct log_c *lc = get_log(tfr->uuid);
+	} *pkg = (void *)rq->data;
+	struct log_c *lc = get_log(rq->uuid);
 
 	if (!lc)
 		return -EINVAL;
@@ -1554,7 +1565,7 @@
 
 out:
 
-	tfr->data_size = sizeof(*pkg);
+	rq->data_size = sizeof(*pkg);
 
 	return 0;	
 }
@@ -1562,92 +1573,92 @@
 
 /*
  * do_request
- * @tfr: the request
+ * @rq: the request
  * @server: is this request performed by the server
  *
  * An inability to perform this function will return an error
  * from this function.  However, an inability to successfully
- * perform the request will fill in the 'tfr->error' field.
+ * perform the request will fill in the 'rq->error' field.
  *
  * Returns: 0 on success, -EXXX on error
  */
-int do_request(struct clog_tfr *tfr, int server)
+int do_request(struct clog_request *rq, int server)
 {
 	int r;
 
-	if (!tfr)
+	if (!rq)
 		return 0;
 
-	if (tfr->error)
-		LOG_DBG("Programmer error: tfr struct has error set");
+	if (rq->u_rq.error)
+		LOG_DBG("Programmer error: rq struct has error set");
 
-	switch (tfr->request_type) {
-	case DM_CLOG_CTR:
-		r = clog_ctr(tfr);
+	switch (rq->u_rq.request_type) {
+	case DM_ULOG_CTR:
+		r = clog_ctr(&rq->u_rq);
 		break;
-	case DM_CLOG_DTR:
-		r = clog_dtr(tfr);
+	case DM_ULOG_DTR:
+		r = clog_dtr(&rq->u_rq);
 		break;
-	case DM_CLOG_PRESUSPEND:
-		r = clog_presuspend(tfr);
+	case DM_ULOG_PRESUSPEND:
+		r = clog_presuspend(&rq->u_rq);
 		break;
-	case DM_CLOG_POSTSUSPEND:
-		r = clog_postsuspend(tfr);
+	case DM_ULOG_POSTSUSPEND:
+		r = clog_postsuspend(&rq->u_rq);
 		break;
-	case DM_CLOG_RESUME:
-		r = clog_resume(tfr);
+	case DM_ULOG_RESUME:
+		r = clog_resume(&rq->u_rq);
 		break;
-	case DM_CLOG_GET_REGION_SIZE:
-		r = clog_get_region_size(tfr);
+	case DM_ULOG_GET_REGION_SIZE:
+		r = clog_get_region_size(&rq->u_rq);
 		break;
-	case DM_CLOG_IS_CLEAN:
-		r = clog_is_clean(tfr);
+	case DM_ULOG_IS_CLEAN:
+		r = clog_is_clean(&rq->u_rq);
 		break;
-	case DM_CLOG_IN_SYNC:
-		r = clog_in_sync(tfr);
+	case DM_ULOG_IN_SYNC:
+		r = clog_in_sync(&rq->u_rq);
 		break;
-	case DM_CLOG_FLUSH:
-		r = clog_flush(tfr, server);
+	case DM_ULOG_FLUSH:
+		r = clog_flush(&rq->u_rq, server);
 		break;
-	case DM_CLOG_MARK_REGION:
-		r = clog_mark_region(tfr);
+	case DM_ULOG_MARK_REGION:
+		r = clog_mark_region(&rq->u_rq, rq->originator);
 		break;
-	case DM_CLOG_CLEAR_REGION:
-		r = clog_clear_region(tfr);
+	case DM_ULOG_CLEAR_REGION:
+		r = clog_clear_region(&rq->u_rq, rq->originator);
 		break;
-	case DM_CLOG_GET_RESYNC_WORK:
-		r = clog_get_resync_work(tfr);
+	case DM_ULOG_GET_RESYNC_WORK:
+		r = clog_get_resync_work(&rq->u_rq, rq->originator);
 		break;
-	case DM_CLOG_SET_REGION_SYNC:
-		r = clog_set_region_sync(tfr);
+	case DM_ULOG_SET_REGION_SYNC:
+		r = clog_set_region_sync(&rq->u_rq, rq->originator);
 		break;
-	case DM_CLOG_GET_SYNC_COUNT:
-		r = clog_get_sync_count(tfr);
+	case DM_ULOG_GET_SYNC_COUNT:
+		r = clog_get_sync_count(&rq->u_rq, rq->originator);
 		break;
-	case DM_CLOG_STATUS_INFO:
-		r = clog_status_info(tfr);
+	case DM_ULOG_STATUS_INFO:
+		r = clog_status_info(&rq->u_rq);
 		break;
-	case DM_CLOG_STATUS_TABLE:
-		r = clog_status_table(tfr);
+	case DM_ULOG_STATUS_TABLE:
+		r = clog_status_table(&rq->u_rq);
 		break;
-	case DM_CLOG_IS_REMOTE_RECOVERING:
-		r = clog_is_remote_recovering(tfr);
+	case DM_ULOG_IS_REMOTE_RECOVERING:
+		r = clog_is_remote_recovering(&rq->u_rq);
 		break;
 	default:
 		LOG_ERROR("Unknown request");
-		r = tfr->error = -EINVAL;
+		r = rq->u_rq.error = -EINVAL;
 		break;
 	}
 
-	if (r && !tfr->error)
-		tfr->error = r;
-	else if (r != tfr->error)
-		LOG_DBG("Warning:  error from function != tfr->error");
+	if (r && !rq->u_rq.error)
+		rq->u_rq.error = r;
+	else if (r != rq->u_rq.error)
+		LOG_DBG("Warning:  error from function != rq->u_rq.error");
 
-	if (tfr->error && tfr->data_size) {
+	if (rq->u_rq.error && rq->u_rq.data_size) {
 		/* Make sure I'm handling errors correctly above */
-		LOG_DBG("Programmer error: tfr->error && tfr->data_size");
-		tfr->data_size = 0;
+		LOG_DBG("Programmer error: rq->u_rq.error && rq->u_rq.data_size");
+		rq->u_rq.data_size = 0;
 	}
 
 	return 0;
@@ -1784,11 +1795,11 @@
 	return 0;
 }
 
-int log_get_state(struct clog_tfr *tfr)
+int log_get_state(struct dm_ulog_request *rq)
 {
 	struct log_c *lc;
 
-	lc = get_log(tfr->uuid);
+	lc = get_log(rq->uuid);
 	if (!lc)
 		return -EINVAL;
 
--- LVM2/daemons/clogd/functions.h	2009/04/21 19:16:22	1.2
+++ LVM2/daemons/clogd/functions.h	2009/07/21 15:34:53	1.3
@@ -1,19 +1,21 @@
 #ifndef __CLOG_FUNCTIONS_DOT_H__
 #define __CLOG_FUNCTIONS_DOT_H__
 
-#include <linux/dm-clog-tfr.h>
+#include <linux/dm-log-userspace.h>
+#include "cluster.h"
 
 #define LOG_RESUMED   1
 #define LOG_SUSPENDED 2
 
-int local_resume(struct clog_tfr *tfr);
+int local_resume(struct dm_ulog_request *rq);
 int cluster_postsuspend(char *);
 
-int do_request(struct clog_tfr *tfr, int server);
-int push_state(const char *uuid, const char *which, char **buf, uint32_t debug_who);
+int do_request(struct clog_request *rq, int server);
+int push_state(const char *uuid, const char *which,
+	       char **buf, uint32_t debug_who);
 int pull_state(const char *uuid, const char *which, char *buf, int size);
 
-int log_get_state(struct clog_tfr *tfr);
+int log_get_state(struct dm_ulog_request *rq);
 int log_status(void);
 void log_debug(void);
 
--- LVM2/daemons/clogd/local.c	2009/07/21 15:32:13	1.2
+++ LVM2/daemons/clogd/local.c	2009/07/21 15:34:53	1.3
@@ -8,7 +8,7 @@
 #include <linux/connector.h>
 #include <linux/netlink.h>
 
-#include "linux/dm-clog-tfr.h"
+#include "linux/dm-log-userspace.h"
 #include "functions.h"
 #include "cluster.h"
 #include "common.h"
@@ -18,14 +18,14 @@
 
 static int cn_fd;  /* Connector (netlink) socket fd */
 static char recv_buf[2048];
+static char send_buf[2048];
 
 
 /* FIXME: merge this function with kernel_send_helper */
 static int kernel_ack(uint32_t seq, int error)
 {
 	int r;
-	unsigned char buf[sizeof(struct nlmsghdr) + sizeof(struct cn_msg)];
-	struct nlmsghdr *nlh = (struct nlmsghdr *)buf;
+	struct nlmsghdr *nlh = (struct nlmsghdr *)send_buf;
 	struct cn_msg *msg = NLMSG_DATA(nlh);
 
 	if (error < 0) {
@@ -33,7 +33,7 @@
 		return -EINVAL;
 	}
 
-	memset(buf, 0, sizeof(buf));
+	memset(send_buf, 0, sizeof(send_buf));
 
 	nlh->nlmsg_seq = 0;
 	nlh->nlmsg_pid = getpid();
@@ -42,8 +42,8 @@
 	nlh->nlmsg_flags = 0;
 
 	msg->len = 0;
-	msg->id.idx = 0x4;
-	msg->id.val = 0x1;
+	msg->id.idx = CN_IDX_DM;
+	msg->id.val = CN_VAL_DM_USERSPACE_LOG;
 	msg->seq = seq;
 	msg->ack = error;
 
@@ -58,23 +58,24 @@
 
 /*
  * kernel_recv
- * @tfr: the newly allocated request from kernel
+ * @rq: the newly allocated request from kernel
  *
  * Read requests from the kernel and allocate space for the new request.
- * If there is no request from the kernel, *tfr is NULL.
+ * If there is no request from the kernel, *rq is NULL.
  *
  * This function is not thread safe due to returned stack pointer.  In fact,
  * the returned pointer must not be in-use when this function is called again.
  *
  * Returns: 0 on success, -EXXX on error
  */
-static int kernel_recv(struct clog_tfr **tfr)
+static int kernel_recv(struct clog_request **rq)
 {
 	int r = 0;
 	int len;
 	struct cn_msg *msg;
+	struct dm_ulog_request *u_rq;
 
-	*tfr = NULL;
+	*rq = NULL;
 	memset(recv_buf, 0, sizeof(recv_buf));
 
 	len = recv(cn_fd, recv_buf, sizeof(recv_buf), 0);
@@ -99,9 +100,9 @@
 			goto fail;
 		}
 
-		if (msg->len > DM_CLOG_TFR_SIZE) {
+		if (msg->len > DM_ULOG_REQUEST_SIZE) {
 			LOG_ERROR("Not enough space to receive kernel request (%d/%d)",
-				  msg->len, DM_CLOG_TFR_SIZE);
+				  msg->len, DM_ULOG_REQUEST_SIZE);
 			r = -EBADE;
 			goto fail;
 		}
@@ -115,10 +116,11 @@
 			LOG_ERROR("len = %d, msg->len = %d", len, msg->len);
 
 		msg->data[msg->len] = '\0'; /* Cleaner way to ensure this? */
-		*tfr = (struct clog_tfr *)msg->data;
+		u_rq = (struct dm_ulog_request *)msg->data;
 
-		if (!(*tfr)->request_type) {
-			LOG_DBG("Bad transmission, requesting resend [%u]", msg->seq);
+		if (!u_rq->request_type) {
+			LOG_DBG("Bad transmission, requesting resend [%u]",
+				msg->seq);
 			r = -EAGAIN;
 
 			if (kernel_ack(msg->seq, EAGAIN)) {
@@ -127,6 +129,25 @@
 				r = -EBADE;
 			}
 		}
+
+		/*
+		 * Now we've got sizeof(struct cn_msg) + sizeof(struct nlmsghdr)
+		 * worth of space that precede the request structure from the
+		 * kernel.  Since that space isn't going to be used again, we
+		 * can take it for our purposes; rather than allocating a whole
+		 * new structure and doing a memcpy.
+		 *
+		 * We should really make sure 'clog_request' doesn't grow
+		 * beyond what is available to us, but we need only check it
+		 * once... perhaps at compile time?
+		 */
+//		*rq = container_of(u_rq, struct clog_request, u_rq);
+		*rq = (void *)u_rq -
+			(sizeof(struct clog_request) -
+			 sizeof(struct dm_ulog_request));
+
+		/* Clear the wrapper container fields */
+		memset(*rq, 0, (void *)u_rq - (void *)(*rq));
 		break;
 	default:
 		LOG_ERROR("Unknown nlmsg_type");
@@ -135,7 +156,7 @@
 
 fail:
 	if (r)
-		*tfr = NULL;
+		*rq = NULL;
 
 	return (r == -EAGAIN) ? 0 : r;
 }
@@ -145,11 +166,10 @@
 	int r;
 	struct nlmsghdr *nlh;
 	struct cn_msg *msg;
-	unsigned char buf[2048];
 
-	memset(buf, 0, sizeof(buf));
+	memset(send_buf, 0, sizeof(send_buf));
 
-	nlh = (struct nlmsghdr *)buf;
+	nlh = (struct nlmsghdr *)send_buf;
 	nlh->nlmsg_seq = 0;  /* FIXME: Is this used? */
 	nlh->nlmsg_pid = getpid();
 	nlh->nlmsg_type = NLMSG_DONE;
@@ -159,8 +179,8 @@
 	msg = NLMSG_DATA(nlh);
 	memcpy(msg->data, data, out_size);
 	msg->len = out_size;
-	msg->id.idx = 0x4;
-	msg->id.val = 0x1;
+	msg->id.idx = CN_IDX_DM;
+	msg->id.val = CN_VAL_DM_USERSPACE_LOG;
 	msg->seq = 0;
 
 	r = send(cn_fd, nlh, NLMSG_LENGTH(out_size + sizeof(struct cn_msg)), 0);
@@ -174,7 +194,7 @@
 /*
  * do_local_work
  *
- * Any processing errors are placed in the 'tfr'
+ * Any processing errors are placed in the 'rq'
  * structure to be reported back to the kernel.
  * It may be pointless for this function to
  * return an int.
@@ -184,73 +204,76 @@
 static int do_local_work(void *data)
 {
 	int r;
-	struct clog_tfr *tfr = NULL;
+	struct clog_request *rq;
+	struct dm_ulog_request *u_rq = NULL;
 
-	r = kernel_recv(&tfr);
+	r = kernel_recv(&rq);
 	if (r)
 		return r;
 
-	if (!tfr)
+	if (!rq)
 		return 0;
 
+	u_rq = &rq->u_rq;
 	LOG_DBG("[%s]  Request from kernel received: [%s/%u]",
-		SHORT_UUID(tfr->uuid), RQ_TYPE(tfr->request_type),
-		tfr->seq);
-	switch (tfr->request_type) {
-	case DM_CLOG_CTR:
-	case DM_CLOG_DTR:
-	case DM_CLOG_IN_SYNC:
-	case DM_CLOG_GET_SYNC_COUNT:
-	case DM_CLOG_STATUS_INFO:
-	case DM_CLOG_STATUS_TABLE:
-	case DM_CLOG_PRESUSPEND:
+		SHORT_UUID(u_rq->uuid), RQ_TYPE(u_rq->request_type),
+		u_rq->seq);
+	switch (u_rq->request_type) {
+	case DM_ULOG_CTR:
+	case DM_ULOG_DTR:
+	case DM_ULOG_GET_REGION_SIZE:
+	case DM_ULOG_IN_SYNC:
+	case DM_ULOG_GET_SYNC_COUNT:
+	case DM_ULOG_STATUS_INFO:
+	case DM_ULOG_STATUS_TABLE:
+	case DM_ULOG_PRESUSPEND:
 		/* We do not specify ourselves as server here */
-		r = do_request(tfr, 0);
+		r = do_request(rq, 0);
 		if (r)
 			LOG_DBG("Returning failed request to kernel [%s]",
-				RQ_TYPE(tfr->request_type));
-		r = kernel_send(tfr);
+				RQ_TYPE(u_rq->request_type));
+		r = kernel_send(u_rq);
 		if (r)
 			LOG_ERROR("Failed to respond to kernel [%s]",
-				  RQ_TYPE(tfr->request_type));
+				  RQ_TYPE(u_rq->request_type));
 			
 		break;
-	case DM_CLOG_RESUME:
+	case DM_ULOG_RESUME:
 		/*
 		 * Resume is a special case that requires a local
 		 * component to join the CPG, and a cluster component
 		 * to handle the request.
 		 */
-		r = local_resume(tfr);
+		r = local_resume(u_rq);
 		if (r) {
 			LOG_DBG("Returning failed request to kernel [%s]",
-				RQ_TYPE(tfr->request_type));
-			r = kernel_send(tfr);
+				RQ_TYPE(u_rq->request_type));
+			r = kernel_send(u_rq);
 			if (r)
 				LOG_ERROR("Failed to respond to kernel [%s]",
-					  RQ_TYPE(tfr->request_type));
+					  RQ_TYPE(u_rq->request_type));
 			break;
 		}
 		/* ELSE, fall through */
-	case DM_CLOG_IS_CLEAN:
-	case DM_CLOG_FLUSH:
-	case DM_CLOG_MARK_REGION:
-	case DM_CLOG_GET_RESYNC_WORK:
-	case DM_CLOG_SET_REGION_SYNC:
-	case DM_CLOG_IS_REMOTE_RECOVERING:
-	case DM_CLOG_POSTSUSPEND:
-		r = cluster_send(tfr);
+	case DM_ULOG_IS_CLEAN:
+	case DM_ULOG_FLUSH:
+	case DM_ULOG_MARK_REGION:
+	case DM_ULOG_GET_RESYNC_WORK:
+	case DM_ULOG_SET_REGION_SYNC:
+	case DM_ULOG_IS_REMOTE_RECOVERING:
+	case DM_ULOG_POSTSUSPEND:
+		r = cluster_send(rq);
 		if (r) {
-			tfr->data_size = 0;
-			tfr->error = r;
-			kernel_send(tfr);
+			u_rq->data_size = 0;
+			u_rq->error = r;
+			kernel_send(u_rq);
 		}
 
 		break;
-	case DM_CLOG_CLEAR_REGION:
-		r = kernel_ack(tfr->seq, 0);
+	case DM_ULOG_CLEAR_REGION:
+		r = kernel_ack(u_rq->seq, 0);
 
-		r = cluster_send(tfr);
+		r = cluster_send(rq);
 		if (r) {
 			/*
 			 * FIXME: store error for delivery on flush
@@ -260,24 +283,24 @@
 		}
 
 		break;
-	case DM_CLOG_GET_REGION_SIZE:
 	default:
-		LOG_ERROR("Invalid log request received, ignoring.");
+		LOG_ERROR("Invalid log request received (%u), ignoring.",
+			  u_rq->request_type);
 
 		return 0;
 	}
 
-	if (r && !tfr->error)
-		tfr->error = r;
+	if (r && !u_rq->error)
+		u_rq->error = r;
 
 	return r;
 }
 
 /*
  * kernel_send
- * @tfr: result to pass back to kernel
+ * @u_rq: result to pass back to kernel
  *
- * This function returns the tfr structure
+ * This function returns the u_rq structure
  * (containing the results) to the kernel.
  * It then frees the structure.
  *
@@ -288,21 +311,21 @@
  *
  * Returns: 0 on success, -EXXX on failure
  */
-int kernel_send(struct clog_tfr *tfr)
+int kernel_send(struct dm_ulog_request *u_rq)
 {
 	int r;
 	int size;
 
-	if (!tfr)
+	if (!u_rq)
 		return -EINVAL;
 
-	size = sizeof(struct clog_tfr) + tfr->data_size;
+	size = sizeof(struct dm_ulog_request) + u_rq->data_size;
 
-	if (!tfr->data_size && !tfr->error) {
+	if (!u_rq->data_size && !u_rq->error) {
 		/* An ACK is all that is needed */
 
 		/* FIXME: add ACK code */
-	} else if (size > DM_CLOG_TFR_SIZE) {
+	} else if (size > DM_ULOG_REQUEST_SIZE) {
 		/*
 		 * If we gotten here, we've already overrun
 		 * our allotted space somewhere.
@@ -311,11 +334,11 @@
 		 * is waiting for a response.
 		 */
 		LOG_ERROR("Not enough space to respond to server");
-		tfr->error = -ENOSPC;
-		size = sizeof(struct clog_tfr);
+		u_rq->error = -ENOSPC;
+		size = sizeof(struct dm_ulog_request);
 	}
 
-	r = kernel_send_helper(tfr, size);
+	r = kernel_send_helper(u_rq, size);
 	if (r)
 		LOG_ERROR("Failed to send msg to kernel.");
 
@@ -337,26 +360,26 @@
 
 	cn_fd = socket(PF_NETLINK, SOCK_DGRAM, NETLINK_CONNECTOR);
 	if (cn_fd < 0)
-		return EXIT_KERNEL_TFR_SOCKET;
+		return EXIT_KERNEL_SOCKET;
 
 	/* memset to fix valgrind complaint */
 	memset(&addr, 0, sizeof(struct sockaddr_nl));
 
 	addr.nl_family = AF_NETLINK;
-	addr.nl_groups = 0x4;
+	addr.nl_groups = CN_IDX_DM;
 	addr.nl_pid = 0;
 
 	r = bind(cn_fd, (struct sockaddr *) &addr, sizeof(addr));
 	if (r < 0) {
 		close(cn_fd);
-		return EXIT_KERNEL_TFR_BIND;
+		return EXIT_KERNEL_BIND;
 	}
 
 	opt = addr.nl_groups;
 	r = setsockopt(cn_fd, 270, NETLINK_ADD_MEMBERSHIP, &opt, sizeof(opt));
 	if (r) {
 		close(cn_fd);
-		return EXIT_KERNEL_TFR_SETSOCKOPT;
+		return EXIT_KERNEL_SETSOCKOPT;
 	}
 
 	/*
--- LVM2/daemons/clogd/local.h	2009/01/08 17:12:33	1.1
+++ LVM2/daemons/clogd/local.h	2009/07/21 15:34:53	1.2
@@ -4,6 +4,6 @@
 int init_local(void);
 void cleanup_local(void);
 
-int kernel_send(struct clog_tfr *tfr);
+int kernel_send(struct dm_ulog_request *rq);
 
 #endif /* __CLUSTER_LOG_LOCAL_DOT_H__ */
--- LVM2/daemons/clogd/logging.c	2009/01/08 17:12:33	1.1
+++ LVM2/daemons/clogd/logging.c	2009/07/21 15:34:53	1.2
@@ -1,5 +1,27 @@
+#include <stdio.h>
 #include <syslog.h>
 
+char *__rq_types_off_by_one[] = {
+	"DM_ULOG_CTR",
+	"DM_ULOG_DTR",
+	"DM_ULOG_PRESUSPEND",
+	"DM_ULOG_POSTSUSPEND",
+	"DM_ULOG_RESUME",
+	"DM_ULOG_GET_REGION_SIZE",
+	"DM_ULOG_IS_CLEAN",
+	"DM_ULOG_IN_SYNC",
+	"DM_ULOG_FLUSH",
+	"DM_ULOG_MARK_REGION",
+	"DM_ULOG_CLEAR_REGION",
+	"DM_ULOG_GET_RESYNC_WORK",
+	"DM_ULOG_SET_REGION_SYNC",
+	"DM_ULOG_GET_SYNC_COUNT",
+	"DM_ULOG_STATUS_INFO",
+	"DM_ULOG_STATUS_TABLE",
+	"DM_ULOG_IS_REMOTE_RECOVERING",
+	NULL
+};
+
 int log_tabbing = 0;
 int log_is_open = 0;
 
--- LVM2/daemons/clogd/logging.h	2009/01/08 17:12:33	1.1
+++ LVM2/daemons/clogd/logging.h	2009/07/21 15:34:53	1.2
@@ -31,6 +31,9 @@
 /* SHORT_UUID - print last 8 chars of a string */
 #define SHORT_UUID(x) (strlen(x) > 8) ? ((x) + (strlen(x) - 8)) : (x)
 
+extern char *__rq_types_off_by_one[];
+#define RQ_TYPE(x) __rq_types_off_by_one[(x) - 1]
+
 extern int log_tabbing;
 extern int log_is_open;
 extern int log_membership_change;


