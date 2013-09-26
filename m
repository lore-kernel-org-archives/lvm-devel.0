From: dongmao zhang <dmzhang@suse.com>
Date: Thu, 26 Sep 2013 18:53:29 +0800
Subject: [PATCH 2/4] cmirrord create new function _clog_flush
In-Reply-To: <cover.1380191958.git.dmzhang@suse.com>
References: <cover.1380191958.git.dmzhang@suse.com>
Message-ID: <1456e04aaa25c03cdcdc533c995375c35fa65f2f.1380191958.git.dmzhang@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

_clog_flush is used by both clog_mark_region and clog_flush
---
 daemons/cmirrord/functions.c |   40 ++++++++++++++++++++++++++++++++--------
 1 files changed, 32 insertions(+), 8 deletions(-)

diff --git a/daemons/cmirrord/functions.c b/daemons/cmirrord/functions.c
index 17f588e..33e909f 100644
--- a/daemons/cmirrord/functions.c
+++ b/daemons/cmirrord/functions.c
@@ -1037,14 +1037,17 @@ static int clog_in_sync(struct dm_ulog_request *rq)
 }
 
 /*
- * clog_flush
- * @rq
+ * _clog_flush
+ * @lc
+ * @server
  *
+ * real flush
+ *
+ * Returns: 0 on success, -EXXX on error
  */
-static int clog_flush(struct dm_ulog_request *rq, int server)
+static int _clog_flush(struct log_c *lc, int server)
 {
 	int r = 0;
-	struct log_c *lc = get_log(rq->uuid, rq->luid);
 
 	if (!lc)
 		return -EINVAL;
@@ -1057,10 +1060,10 @@ static int clog_flush(struct dm_ulog_request *rq, int server)
 	 * if we are the server.
 	 */
 	if (server && (lc->disk_fd >= 0)) {
-		r = rq->error = write_log(lc);
+		r = write_log(lc);
 		if (r)
 			LOG_ERROR("[%s] Error writing to disk log",
-				  SHORT_UUID(lc->uuid));
+				SHORT_UUID(lc->uuid));
 		else 
 			LOG_DBG("[%s] Disk log written", SHORT_UUID(lc->uuid));
 	}
@@ -1068,6 +1071,21 @@ static int clog_flush(struct dm_ulog_request *rq, int server)
 	lc->touched = 0;
 
 	return r;
+}
+
+
+/*
+ * clog_flush
+ * @rq
+ *
+ */
+static int clog_flush(struct dm_ulog_request *rq, int server)
+{
+	int r = 0;
+	struct log_c *lc = get_log(rq->uuid, rq->luid);
+
+	r = rq->error = _clog_flush(lc, server);
+	return r;
 
 }
 
@@ -1123,7 +1141,7 @@ static int mark_region(struct log_c *lc, uint64_t region, uint32_t who)
  *
  * Returns: 0 on success, -EXXX on failure
  */
-static int clog_mark_region(struct dm_ulog_request *rq, uint32_t originator)
+static int clog_mark_region(struct dm_ulog_request *rq, uint32_t originator, int server)
 {
 	int r;
 	int count;
@@ -1149,6 +1167,12 @@ static int clog_mark_region(struct dm_ulog_request *rq, uint32_t originator)
 
 	rq->data_size = 0;
 
+	/*if kernel support delay clear flush, cmirrord could
+	 *run flush immediatly after mark region*/
+
+	if(lc->support_delay_flush)
+		return _clog_flush(lc, server);
+
 	return 0;
 }
 
@@ -1686,7 +1710,7 @@ int do_request(struct clog_request *rq, int server)
 		r = clog_flush(&rq->u_rq, server);
 		break;
 	case DM_ULOG_MARK_REGION:
-		r = clog_mark_region(&rq->u_rq, rq->originator);
+		r = clog_mark_region(&rq->u_rq, rq->originator, server);
 		break;
 	case DM_ULOG_CLEAR_REGION:
 		r = clog_clear_region(&rq->u_rq, rq->originator);
-- 
1.7.3.4


