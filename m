From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 15 Jan 2010 19:49:37 -0000
Subject: LVM2 ./WHATS_NEW daemons/cmirrord/Makefile.in ...
Message-ID: <20100115194937.5829.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-01-15 19:49:36

Modified files:
	.              : WHATS_NEW 
	daemons/cmirrord: Makefile.in cluster.c cluster.h common.h 
Added files:
	daemons/cmirrord: compat.c compat.h 

Log message:
	Make the intermachine communication structures architecture independant
	to allow for mixed architecture clusters.
	
	Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1391&r2=1.1392
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/compat.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/compat.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/Makefile.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/cluster.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/cluster.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/common.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/WHATS_NEW	2010/01/15 18:48:24	1.1391
+++ LVM2/WHATS_NEW	2010/01/15 19:49:35	1.1392
@@ -1,5 +1,6 @@
 Version 2.02.59 - 
 ===================================
+  Make cluster log communication structures architecture independant.
   Fix cluster log issues with in-memory bitmaps.
   Improve target type compatibility checking in _percent_run().
   Add 'target_status_compatible' method to 'struct segtype_handler'.
/cvs/lvm2/LVM2/daemons/cmirrord/compat.c,v  -->  standard output
revision 1.1
--- LVM2/daemons/cmirrord/compat.c
+++ -	2010-01-15 19:49:36.887660000 +0000
@@ -0,0 +1,214 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ */
+#include <stdlib.h>
+#include <errno.h>
+#include <stdint.h>
+#include <string.h>
+#include "dm-log-userspace.h"
+#include "logging.h"
+#include "cluster.h"
+#include "xlate.h"
+
+#include "compat.h"
+
+/*
+ * Older versions of the log daemon communicate with different
+ * versions of the inter-machine communication structure, which
+ * varies in size and fields.  The older versions append the
+ * standard upstream version of the structure to every request.
+ * COMPAT_OFFSET is where the upstream structure starts.
+ */
+#define COMPAT_OFFSET 256
+
+static void v5_data_endian_switch(struct clog_request *rq, int to_network)
+{
+	int i, end;
+	int64_t *pi64;
+	uint64_t *pu64;
+	uint32_t rq_type = rq->u_rq.request_type & ~DM_ULOG_RESPONSE;
+
+	if (rq->u_rq.request_type & DM_ULOG_RESPONSE) {
+		switch (rq_type) {
+		case DM_ULOG_CTR:
+		case DM_ULOG_DTR:
+			LOG_ERROR("Invalid response type in endian switch");
+			exit(EXIT_FAILURE);
+
+		case DM_ULOG_PRESUSPEND:
+		case DM_ULOG_POSTSUSPEND:
+		case DM_ULOG_RESUME:
+		case DM_ULOG_FLUSH:
+		case DM_ULOG_MARK_REGION:
+		case DM_ULOG_CLEAR_REGION:
+		case DM_ULOG_SET_REGION_SYNC:
+		case DM_ULOG_CHECKPOINT_READY:
+		case DM_ULOG_MEMBER_JOIN:
+		case DM_ULOG_STATUS_INFO:
+		case DM_ULOG_STATUS_TABLE:
+			/* No outbound data */
+			break;
+
+		case DM_ULOG_GET_REGION_SIZE:
+		case DM_ULOG_GET_SYNC_COUNT:
+			pu64 = (uint64_t *)rq->u_rq.data;
+			*pu64 = xlate64(*pu64);
+			break;
+		case DM_ULOG_IS_CLEAN:
+		case DM_ULOG_IN_SYNC:
+			pi64 = (int64_t *)rq->u_rq.data;
+			*pi64 = xlate64(*pi64);
+			break;
+		case DM_ULOG_GET_RESYNC_WORK:
+		case DM_ULOG_IS_REMOTE_RECOVERING:
+			pi64 = (int64_t *)rq->u_rq.data;
+			pu64 = ((uint64_t *)rq->u_rq.data) + 1;
+			*pi64 = xlate64(*pi64);
+			*pu64 = xlate64(*pu64);
+			break;
+		default:
+			LOG_ERROR("Unknown request type, %u", rq_type);
+			return;
+		}
+	} else {
+		switch (rq_type) {
+		case DM_ULOG_CTR:
+		case DM_ULOG_DTR:
+			LOG_ERROR("Invalid request type in endian switch");
+			exit(EXIT_FAILURE);
+
+		case DM_ULOG_PRESUSPEND:
+		case DM_ULOG_POSTSUSPEND:
+		case DM_ULOG_RESUME:
+		case DM_ULOG_GET_REGION_SIZE:
+		case DM_ULOG_FLUSH:
+		case DM_ULOG_GET_RESYNC_WORK:
+		case DM_ULOG_GET_SYNC_COUNT:
+		case DM_ULOG_STATUS_INFO:
+		case DM_ULOG_STATUS_TABLE:
+		case DM_ULOG_CHECKPOINT_READY:
+		case DM_ULOG_MEMBER_JOIN:
+			/* No incoming data */
+			break;
+		case DM_ULOG_IS_CLEAN:
+		case DM_ULOG_IN_SYNC:
+		case DM_ULOG_IS_REMOTE_RECOVERING:
+			pu64 = (uint64_t *)rq->u_rq.data;
+			*pu64 = xlate64(*pu64);
+			break;
+		case DM_ULOG_MARK_REGION:
+		case DM_ULOG_CLEAR_REGION:
+			end = rq->u_rq.data_size/sizeof(uint64_t);
+
+			pu64 = (uint64_t *)rq->u_rq.data;
+			for (i = 0; i < end; i++)
+				pu64[i] = xlate64(pu64[i]);
+			break;
+		case DM_ULOG_SET_REGION_SYNC:
+			pu64 = (uint64_t *)rq->u_rq.data;
+			pi64 = ((int64_t *)rq->u_rq.data) + 1;
+			*pu64 = xlate64(*pu64);
+			*pi64 = xlate64(*pi64);
+			break;
+		default:
+			LOG_ERROR("Unknown request type, %u", rq_type);
+			exit(EXIT_FAILURE);
+		}
+	}
+}
+
+static int v5_endian_to_network(struct clog_request *rq)
+{
+	int size;
+	struct dm_ulog_request *u_rq = &rq->u_rq;
+
+	size = sizeof(*rq) + u_rq->data_size;
+
+	u_rq->error = xlate32(u_rq->error);
+	u_rq->seq = xlate32(u_rq->seq);
+	u_rq->request_type = xlate32(u_rq->request_type);
+	u_rq->data_size = xlate64(u_rq->data_size);
+
+	rq->originator = xlate32(rq->originator);
+
+	v5_data_endian_switch(rq, 1);
+
+	return size;
+}
+
+int clog_request_to_network(struct clog_request *rq)
+{
+	int r;
+
+	/* FIXME: Remove this safety check */
+	if (rq->u.version[0] != xlate64(rq->u.version[1])) {
+		LOG_ERROR("Programmer error:  version[0] must be LE");
+		exit(EXIT_FAILURE);
+	}
+
+	/*
+	 * Are we already running in the endian mode we send
+	 * over the wire?
+	 */
+	if (rq->u.version[0] == rq->u.version[1])
+		return 0;
+
+	r = v5_endian_to_network(rq);
+	if (r < 0)
+		return r;
+	return 0;
+}
+
+static int v5_endian_from_network(struct clog_request *rq)
+{
+	int size;
+	struct dm_ulog_request *u_rq = &rq->u_rq;
+
+	u_rq->error = xlate32(u_rq->error);
+	u_rq->seq = xlate32(u_rq->seq);
+	u_rq->request_type = xlate32(u_rq->request_type);
+	u_rq->data_size = xlate64(u_rq->data_size);
+
+	rq->originator = xlate32(rq->originator);
+
+	size = sizeof(*rq) + u_rq->data_size;
+
+	v5_data_endian_switch(rq, 0);
+
+	return size;
+}
+
+int clog_request_from_network(void *data, size_t data_len)
+{
+	uint64_t *vp = data;
+	uint64_t version = xlate64(vp[0]);
+	uint64_t unconverted_version = vp[1];
+	struct clog_request *rq = data;
+
+	switch (version) {
+	case 5: /* Upstream */
+		if (version == unconverted_version)
+			return 0;
+		break;
+	case 4: /* RHEL 5.[45] */
+	case 3: /* RHEL 5.3 */
+	case 2: /* RHEL 5.2 */
+		/* FIXME: still need to account for payload */
+		if (data_len < (COMPAT_OFFSET + sizeof(*rq)))
+			return -ENOSPC;
+
+		rq = data + COMPAT_OFFSET;
+		break;
+	default:
+		LOG_ERROR("Unable to process cluster message: "
+			  "Incompatible version");
+		return -EINVAL;
+	}
+
+	v5_endian_from_network(rq);
+	return 0;
+}
/cvs/lvm2/LVM2/daemons/cmirrord/compat.h,v  -->  standard output
revision 1.1
--- LVM2/daemons/cmirrord/compat.h
+++ -	2010-01-15 19:49:36.972958000 +0000
@@ -0,0 +1,25 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ */
+#ifndef __COMPAT_DOT_H__
+#define __COMPAT_DOT_H__
+
+/*
+ * The intermachine communication structure version are:
+ *	0: Unused
+ *	1: Never in the wild
+ *	2: RHEL 5.2
+ *	3: RHEL 5.3
+ *	4: RHEL 5.4, RHEL 5.5
+ *	5: RHEL 6, Current Upstream Format
+ */
+#define CLOG_TFR_VERSION 5
+
+int clog_request_to_network(struct clog_request *rq);
+int clog_request_from_network(void *data, size_t data_len);
+
+#endif /* __COMPAT_DOT_H__ */
--- LVM2/daemons/cmirrord/Makefile.in	2009/10/05 13:46:01	1.5
+++ LVM2/daemons/cmirrord/Makefile.in	2010/01/15 19:49:36	1.6
@@ -21,7 +21,7 @@
 SACKPT_LIBS = @SACKPT_LIBS@
 SACKPT_CFLAGS = @SACKPT_CFLAGS@
 
-SOURCES = clogd.c cluster.c functions.c link_mon.c local.c logging.c
+SOURCES = clogd.c cluster.c compat.c functions.c link_mon.c local.c logging.c
 
 TARGETS = cmirrord
 
--- LVM2/daemons/cmirrord/cluster.c	2009/09/14 22:57:46	1.9
+++ LVM2/daemons/cmirrord/cluster.c	2010/01/15 19:49:36	1.10
@@ -34,6 +34,8 @@
 #include "logging.h"
 #include "link_mon.h"
 #include "cluster.h"
+#include "compat.h"
+#include "xlate.h"
 
 /* Open AIS error codes */
 #define str_ais_error(x)						\
@@ -66,10 +68,6 @@
 	((x) == SA_AIS_ERR_NO_SECTIONS) ? "SA_AIS_ERR_NO_SECTIONS" :	\
 	"ais_error_unknown"
 
-#define DM_ULOG_RESPONSE 0x1000 /* in last byte of 32-bit value */
-#define DM_ULOG_CHECKPOINT_READY 21
-#define DM_ULOG_MEMBER_JOIN      22
-
 #define _RQ_TYPE(x)							\
 	((x) == DM_ULOG_CHECKPOINT_READY) ? "DM_ULOG_CHECKPOINT_READY": \
 	((x) == DM_ULOG_MEMBER_JOIN) ? "DM_ULOG_MEMBER_JOIN":		\
@@ -168,6 +166,14 @@
 	iov.iov_base = rq;
 	iov.iov_len = sizeof(struct clog_request) + rq->u_rq.data_size;
 
+	rq->u.version[0] = xlate64(CLOG_TFR_VERSION);
+	rq->u.version[1] = CLOG_TFR_VERSION;
+
+	r = clog_request_to_network(rq);
+	if (r < 0)
+		/* FIXME: Better error code for byteswap failure? */
+		return -EINVAL;
+
 	if (entry->cpg_state != VALID)
 		return -EINVAL;
 
@@ -211,9 +217,9 @@
 {
 	struct clog_request *match, *n;
 
-	dm_list_iterate_items_safe(match, n, l)
+	dm_list_iterate_items_gen_safe(match, n, l, u.list)
 		if (match->u_rq.seq == rq->u_rq.seq) {
-			dm_list_del(&match->list);
+			dm_list_del(&match->u.list);
 			return match;
 		}
 
@@ -298,7 +304,7 @@
 		if (dm_list_empty(&entry->working_list))
 			LOG_ERROR("   [none]");
 
-		dm_list_iterate_items(orig_rq, &entry->working_list)
+		dm_list_iterate_items_gen(orig_rq, &entry->working_list, u.list)
 			LOG_ERROR("   [%s]  %s:%u",
 				  SHORT_UUID(orig_rq->u_rq.uuid),
 				  _RQ_TYPE(orig_rq->u_rq.request_type),
@@ -578,7 +584,7 @@
 	}
 	memset(rq, 0, sizeof(*rq));
 
-	dm_list_init(&rq->list);
+	dm_list_init(&rq->u.list);
 	rq->u_rq.request_type = DM_ULOG_CHECKPOINT_READY;
 	rq->originator = cp->requester;  /* FIXME: hack to overload meaning of originator */
 	strncpy(rq->u_rq.uuid, cp->uuid, CPG_MAX_NAME_LENGTH);
@@ -803,8 +809,8 @@
 
 	entry->resend_requests = 0;
 
-	dm_list_iterate_items_safe(rq, n, &entry->working_list) {
-		dm_list_del(&rq->list);
+	dm_list_iterate_items_gen_safe(rq, n, &entry->working_list, u.list) {
+		dm_list_del(&rq->u.list);
 
 		if (strcmp(entry->name.value, rq->u_rq.uuid)) {
 			LOG_ERROR("[%s]  Stray request from another log (%s)",
@@ -890,8 +896,8 @@
 	struct clog_request *rq, *n;
 	struct checkpoint_data *new;
 
-	dm_list_iterate_items_safe(rq, n, &entry->startup_list) {
-		dm_list_del(&rq->list);
+	dm_list_iterate_items_gen_safe(rq, n, &entry->startup_list, u.list) {
+		dm_list_del(&rq->u.list);
 
 		if (rq->u_rq.request_type == DM_ULOG_MEMBER_JOIN) {
 			new = prepare_checkpoint(entry, rq->originator);
@@ -945,6 +951,10 @@
 	struct clog_request *tmp_rq;
 	struct clog_cpg *match;
 
+	if (clog_request_from_network(rq, msg_len) < 0)
+		/* Error message comes from 'clog_request_from_network' */
+		return;
+
 	match = find_clog_cpg(handle);
 	if (!match) {
 		LOG_ERROR("Unable to find clog_cpg for cluster message");
@@ -968,8 +978,8 @@
 			return;
 		}
 		memcpy(tmp_rq, rq, sizeof(*rq) + rq->u_rq.data_size);
-		dm_list_init(&tmp_rq->list);
-		dm_list_add( &match->working_list, &tmp_rq->list);
+		dm_list_init(&tmp_rq->u.list);
+		dm_list_add( &match->working_list, &tmp_rq->u.list);
 	}
 
 	if (rq->u_rq.request_type == DM_ULOG_POSTSUSPEND) {
@@ -990,7 +1000,7 @@
 						 SHORT_UUID(rq->u_rq.uuid), nodeid,
 						 (dm_list_empty(&match->working_list)) ? " -- working_list empty": "");
 
-					dm_list_iterate_items(tmp_rq, &match->working_list)
+					dm_list_iterate_items_gen(tmp_rq, &match->working_list, u.list)
 						LOG_COND(log_resend_requests,
 							 "[%s]                %s/%u",
 							 SHORT_UUID(tmp_rq->u_rq.uuid),
@@ -1075,8 +1085,8 @@
 
 			memcpy(tmp_rq, rq, sizeof(*rq) + rq->u_rq.data_size);
 			tmp_rq->pit_server = match->lowest_id;
-			dm_list_init(&tmp_rq->list);
-			dm_list_add(&match->startup_list, &tmp_rq->list);
+			dm_list_init(&tmp_rq->u.list);
+			dm_list_add(&match->startup_list, &tmp_rq->u.list);
 			goto out;
 		}
 
@@ -1206,8 +1216,8 @@
 	}
 	rq->u_rq.request_type = DM_ULOG_MEMBER_JOIN;
 	rq->originator = joined->nodeid;
-	dm_list_init(&rq->list);
-	dm_list_add(&match->startup_list, &rq->list);
+	dm_list_init(&rq->u.list);
+	dm_list_add(&match->startup_list, &rq->u.list);
 
 out:
 	/* Find the lowest_id, i.e. the server */
@@ -1256,8 +1266,8 @@
 
 		cluster_postsuspend(match->name.value, match->luid);
 
-		dm_list_iterate_items_safe(rq, n, &match->working_list) {
-			dm_list_del(&rq->list);
+		dm_list_iterate_items_gen_safe(rq, n, &match->working_list, u.list) {
+			dm_list_del(&rq->u.list);
 
 			if (rq->u_rq.request_type == DM_ULOG_POSTSUSPEND)
 				kernel_send(&rq->u_rq);
@@ -1286,13 +1296,13 @@
 			 SHORT_UUID(match->name.value), left->nodeid);
 		free_checkpoint(c_cp);
 	}
-	dm_list_iterate_items_safe(rq, n, &match->startup_list) {
+	dm_list_iterate_items_gen_safe(rq, n, &match->startup_list, u.list) {
 		if ((rq->u_rq.request_type == DM_ULOG_MEMBER_JOIN) &&
 		    (rq->originator == left->nodeid)) {
 			LOG_COND(log_checkpoint,
 				 "[%s] Removing pending ckpt from startup list (%u is leaving)",
 				 SHORT_UUID(match->name.value), left->nodeid);
-			dm_list_del(&rq->list);
+			dm_list_del(&rq->u.list);
 			free(rq);
 		}
 	}
@@ -1352,7 +1362,7 @@
 		 */
 
 		i = 1; /* We do not have a DM_ULOG_MEMBER_JOIN entry of our own */
-		dm_list_iterate_items(rq, &match->startup_list)
+		dm_list_iterate_items_gen(rq, &match->startup_list, u.list)
 			if (rq->u_rq.request_type == DM_ULOG_MEMBER_JOIN)
 				i++;
 
@@ -1526,8 +1536,8 @@
 	LOG_DBG("[%s]  CPG teardown before checkpoint received",
 		SHORT_UUID(del->name.value));
 
-	dm_list_iterate_items_safe(rq, n, &del->startup_list) {
-		dm_list_del(&rq->list);
+	dm_list_iterate_items_gen_safe(rq, n, &del->startup_list, u.list) {
+		dm_list_del(&rq->u.list);
 
 		LOG_DBG("[%s]  Ignoring request from %u: %s",
 			SHORT_UUID(del->name.value), rq->originator,
@@ -1640,12 +1650,12 @@
 				break;
 		LOG_ERROR("  CKPTs waiting     : %d", i);
 		LOG_ERROR("  Working list:");
-		dm_list_iterate_items(rq, &entry->working_list)
+		dm_list_iterate_items_gen(rq, &entry->working_list, u.list)
 			LOG_ERROR("  %s/%u", _RQ_TYPE(rq->u_rq.request_type),
 				  rq->u_rq.seq);
 
 		LOG_ERROR("  Startup list:");
-		dm_list_iterate_items(rq, &entry->startup_list)
+		dm_list_iterate_items_gen(rq, &entry->startup_list, u.list)
 			LOG_ERROR("  %s/%u", _RQ_TYPE(rq->u_rq.request_type),
 				  rq->u_rq.seq);
 
--- LVM2/daemons/cmirrord/cluster.h	2009/08/13 16:34:07	1.5
+++ LVM2/daemons/cmirrord/cluster.h	2010/01/15 19:49:36	1.6
@@ -15,6 +15,10 @@
 #include "libdevmapper.h"
 #include "dm-log-userspace.h"
 
+#define DM_ULOG_RESPONSE 0x1000 /* in last byte of 32-bit value */
+#define DM_ULOG_CHECKPOINT_READY 21
+#define DM_ULOG_MEMBER_JOIN      22
+
 /*
  * There is other information in addition to what can
  * be found in the dm_ulog_request structure that we
@@ -23,7 +27,22 @@
  * available.
  */
 struct clog_request {
-	struct dm_list list;
+	/*
+	 * If we don't use a union, the structure size will
+	 * vary between 32-bit and 64-bit machines.  So, we
+	 * pack two 64-bit version numbers in there to force
+	 * the size of the structure to be the same.
+	 *
+	 * The two version numbers also help us with endian
+	 * issues.  The first is always little endian, while
+	 * the second is in native format of the sending
+	 * machine.  If the two are equal, there is no need
+	 * to do endian conversions.
+	 */
+	union {
+		uint64_t version[2]; /* LE version and native version */
+		struct dm_list list;
+	} u;
 
 	/*
 	 * 'originator' is the machine from which the requests
--- LVM2/daemons/cmirrord/common.h	2009/08/13 16:34:07	1.3
+++ LVM2/daemons/cmirrord/common.h	2010/01/15 19:49:36	1.4
@@ -13,21 +13,21 @@
 #define __CLUSTER_LOG_COMMON_DOT_H__
 
 /*
-#define EXIT_SUCCESS 0
-#define EXIT_FAILURE 1
-*/
-
+ * If there are problems when forking off to become a daemon,
+ * the child will exist with one of these codes.  This allows
+ * the parent to know the reason for the failure and print it
+ * to the launching terminal.
+ *
+ * #define EXIT_SUCCESS 0 (from stdlib.h)
+ * #define EXIT_FAILURE 1 (from stdlib.h)
+ */
 #define EXIT_LOCKFILE              2
-
 #define EXIT_KERNEL_SOCKET         3 /* Failed netlink socket create */
 #define EXIT_KERNEL_BIND           4
 #define EXIT_KERNEL_SETSOCKOPT     5
-
 #define EXIT_CLUSTER_CKPT_INIT     6 /* Failed to init checkpoint */
-
 #define EXIT_QUEUE_NOMEM           7
 
-
 #define DM_ULOG_REQUEST_SIZE 1024
 
 #endif /* __CLUSTER_LOG_COMMON_DOT_H__ */


