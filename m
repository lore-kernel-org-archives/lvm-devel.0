From: dongmao zhang <dmzhang@suse.com>
Date: Thu, 26 Sep 2013 18:53:28 +0800
Subject: [PATCH 1/4] cmirrord add support_delay_clear option
In-Reply-To: <cover.1380191958.git.dmzhang@suse.com>
References: <cover.1380191958.git.dmzhang@suse.com>
Message-ID: <0205207c0395ef443acfb94b2eb4a93ed68e5907.1380191958.git.dmzhang@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 daemons/cmirrord/functions.c |   20 +++++++++++++++-----
 1 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/daemons/cmirrord/functions.c b/daemons/cmirrord/functions.c
index f6e0918..17f588e 100644
--- a/daemons/cmirrord/functions.c
+++ b/daemons/cmirrord/functions.c
@@ -75,6 +75,7 @@ struct log_c {
                 FORCESYNC,      /* Force a sync to happen */
         } sync;
 
+	uint32_t support_delay_flush;
 	uint32_t state;         /* current operational state of the log */
 
 	struct dm_list mark_list;
@@ -362,7 +363,7 @@ static int find_disk_path(char *major_minor_str, char *path_rtn, int *unlink_pat
 	// return r ? -errno : 0;
 }
 
-static int _clog_ctr(char *uuid, uint64_t luid,
+static int _clog_ctr(char *uuid, uint64_t luid, uint32_t version,
 		     int argc, char **argv, uint64_t device_size)
 {
 	int i;
@@ -373,6 +374,7 @@ static int _clog_ctr(char *uuid, uint64_t luid,
 	struct log_c *lc = NULL;
 	enum sync log_sync = DEFAULTSYNC;
 	uint32_t block_on_error = 0;
+	uint32_t support_delay_flush = 0;
 
 	int disk_log;
 	char disk_path[128];
@@ -431,6 +433,8 @@ static int _clog_ctr(char *uuid, uint64_t luid,
 			log_sync = NOSYNC;
 		else if (!strcmp(argv[i], "block_on_error"))
 			block_on_error = 1;
+		else if (!strcmp(argv[i], "support_delay_flush") && version > 2)
+			support_delay_flush = 1;
 	}
 
 	lc = dm_zalloc(sizeof(*lc));
@@ -451,6 +455,7 @@ static int _clog_ctr(char *uuid, uint64_t luid,
 	lc->log_dev_failed = 0;
 	strncpy(lc->uuid, uuid, DM_UUID_LEN);
 	lc->luid = luid;
+	lc->support_delay_flush = support_delay_flush;
 
 	if (get_log(lc->uuid, lc->luid) ||
 	    get_pending_log(lc->uuid, lc->luid)) {
@@ -552,6 +557,8 @@ static int clog_ctr(struct dm_ulog_request *rq)
 	char *dev_size_str;
 	uint64_t device_size;
 
+	struct log_c *tmplc = NULL;
+
 	/* Sanity checks */
 	if (!rq->data_size) {
 		LOG_ERROR("Received constructor request with no data");
@@ -594,14 +601,17 @@ static int clog_ctr(struct dm_ulog_request *rq)
 		return -EINVAL;
 	}
 
-	r = _clog_ctr(rq->uuid, rq->luid, argc - 1, argv + 1, device_size);
+	r = _clog_ctr(rq->uuid, rq->luid, rq->version, argc - 1, argv + 1, device_size);
 
 	/* We join the CPG when we resume */
 
 	/* No returning data */
-	if ((rq->version > 1) && !strcmp(argv[0], "clustered-disk"))
-		rq->data_size = sprintf(rq->data, "%s", argv[1]) + 1;
-	else
+	if ((rq->version > 1) && !strcmp(argv[0], "clustered-disk")) {
+		rq->data_size = sprintf(rq->data, "%s", argv[1]);
+		tmplc = get_pending_log(rq->uuid, rq->luid);
+		if (tmplc && tmplc->support_delay_flush)
+			rq->data_size += sprintf(rq->data + rq->data_size, " %s", "support_delay_flush") + 1;
+	} else
 		rq->data_size = 0;
 
 	if (r) {
-- 
1.7.3.4


