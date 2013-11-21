From: dongmao zhang <dmzhang@suse.com>
Date: Thu, 21 Nov 2013 16:18:13 +0800
Subject: [PATCH 1/1] add integrated_flush to cmirrord(improve the performance of dm-log-userspace)
Message-ID: <d582f9c96ab9cc348201c2bb2e9c73636f21796b.1385021027.git.dmzhang@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Brassow,
 I managed to change the previous patch. Please review that.


Dongmao Zhang

---
 daemons/cmirrord/cluster.c   |    4 +++
 daemons/cmirrord/functions.c |   56 +++++++++++++++++++++++++++--------------
 libdm/libdm-deptree.c        |    4 +++
 3 files changed, 45 insertions(+), 19 deletions(-)

diff --git a/daemons/cmirrord/cluster.c b/daemons/cmirrord/cluster.c
index fea739a..aa35f62 100644
--- a/daemons/cmirrord/cluster.c
+++ b/daemons/cmirrord/cluster.c
@@ -353,6 +353,10 @@ static int handle_cluster_response(struct clog_cpg *entry,
 	/* FIXME: Ensure memcpy cannot explode */
 	memcpy(orig_rq, rq, sizeof(*rq) + rq->u_rq.data_size);
 
+	/* make sure the response of DM_ULOG_FLUSH has no payload */
+	if (orig_rq->u_rq.request_type == DM_ULOG_FLUSH)
+		orig_rq->u_rq.data_size = 0;
+
 	r = kernel_send(&orig_rq->u_rq);
 	if (r)
 		LOG_ERROR("Failed to send response to kernel");
diff --git a/daemons/cmirrord/functions.c b/daemons/cmirrord/functions.c
index f6e0918..c1c3538 100644
--- a/daemons/cmirrord/functions.c
+++ b/daemons/cmirrord/functions.c
@@ -362,7 +362,7 @@ static int find_disk_path(char *major_minor_str, char *path_rtn, int *unlink_pat
 	// return r ? -errno : 0;
 }
 
-static int _clog_ctr(char *uuid, uint64_t luid,
+static int _clog_ctr(char *uuid, uint64_t luid, uint32_t version,
 		     int argc, char **argv, uint64_t device_size)
 {
 	int i;
@@ -431,6 +431,8 @@ static int _clog_ctr(char *uuid, uint64_t luid,
 			log_sync = NOSYNC;
 		else if (!strcmp(argv[i], "block_on_error"))
 			block_on_error = 1;
+		else if (!strcmp(argv[i], "integrated_flush") && version > 2)
+			LOG_PRINT("support integrated_flush");
 	}
 
 	lc = dm_zalloc(sizeof(*lc));
@@ -594,7 +596,7 @@ static int clog_ctr(struct dm_ulog_request *rq)
 		return -EINVAL;
 	}
 
-	r = _clog_ctr(rq->uuid, rq->luid, argc - 1, argv + 1, device_size);
+	r = _clog_ctr(rq->uuid, rq->luid, rq->version, argc - 1, argv + 1, device_size);
 
 	/* We join the CPG when we resume */
 
@@ -1026,12 +1028,14 @@ static int clog_in_sync(struct dm_ulog_request *rq)
 	return 0;
 }
 
+static int _clog_mark_region(struct log_c * lc, struct dm_ulog_request *rq, uint32_t originator);
+
 /*
  * clog_flush
  * @rq
  *
  */
-static int clog_flush(struct dm_ulog_request *rq, int server)
+static int clog_flush(struct dm_ulog_request *rq, uint32_t originator, int server)
 {
 	int r = 0;
 	struct log_c *lc = get_log(rq->uuid, rq->luid);
@@ -1042,6 +1046,15 @@ static int clog_flush(struct dm_ulog_request *rq, int server)
 	if (!lc->touched)
 		return 0;
 
+	/* flush has payload to mark region */
+	if(rq->data_size) {
+		r = _clog_mark_region(lc, rq, originator);
+		if (r) {
+			LOG_ERROR("mark region failed in integrated flush");
+			return r;
+		}
+	}
+
 	/*
 	 * Do the actual flushing of the log only
 	 * if we are the server.
@@ -1104,25 +1117,11 @@ static int mark_region(struct log_c *lc, uint64_t region, uint32_t who)
 	return 0;
 }
 
-/*
- * clog_mark_region
- * @rq
- *
- * rq may contain more than one mark request.  We
- * can determine the number from the 'data_size' field.
- *
- * Returns: 0 on success, -EXXX on failure
- */
-static int clog_mark_region(struct dm_ulog_request *rq, uint32_t originator)
+static int _clog_mark_region(struct log_c * lc, struct dm_ulog_request *rq, uint32_t originator)
 {
 	int r;
 	int count;
 	uint64_t *region;
-	struct log_c *lc = get_log(rq->uuid, rq->luid);
-
-	if (!lc)
-		return -EINVAL;
-
 	if (rq->data_size % sizeof(uint64_t)) {
 		LOG_ERROR("Bad data size given for mark_region request");
 		return -EINVAL;
@@ -1142,6 +1141,25 @@ static int clog_mark_region(struct dm_ulog_request *rq, uint32_t originator)
 	return 0;
 }
 
+/*
+ * clog_mark_region
+ * @rq
+ *
+ * rq may contain more than one mark request.  We
+ * can determine the number from the 'data_size' field.
+ *
+ * Returns: 0 on success, -EXXX on failure
+ */
+static int clog_mark_region(struct dm_ulog_request *rq, uint32_t originator)
+{
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
+
+	if (!lc)
+		return -EINVAL;
+
+	return _clog_mark_region(lc, rq, originator);
+}
+
 static int clear_region(struct log_c *lc, uint64_t region, uint32_t who)
 {
 	int other_matches = 0;
@@ -1673,7 +1691,7 @@ int do_request(struct clog_request *rq, int server)
 		r = clog_in_sync(&rq->u_rq);
 		break;
 	case DM_ULOG_FLUSH:
-		r = clog_flush(&rq->u_rq, server);
+		r = clog_flush(&rq->u_rq, rq->originator, server);
 		break;
 	case DM_ULOG_MARK_REGION:
 		r = clog_mark_region(&rq->u_rq, rq->originator);
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 752a44b..fb78cb6 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2164,6 +2164,10 @@ static int _mirror_emit_segment_line(struct dm_task *dmt, struct load_segment *s
 	if (block_on_error)
 		EMIT_PARAMS(pos, " block_on_error");
 
+	/* for cluster raid1, use integrated flush to improve performance */
+	if (dm_log_userspace)
+		EMIT_PARAMS(pos, " integrated_flush");
+
 	EMIT_PARAMS(pos, " %u ", seg->mirror_area_count);
 
 	if (_emit_areas_line(dmt, seg, params, paramsize, &pos) <= 0)
-- 
1.7.3.4


