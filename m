From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 16 Dec 2010 11:36:21 +0100
Subject: [PATCH 13/20] Properly use dm_free
In-Reply-To: <cover.1292495195.git.zkabelac@redhat.com>
References: <cover.1292495195.git.zkabelac@redhat.com>
Message-ID: <89f2e9a3d250cd33752b150d17be7cb5d5fc1ace.1292495195.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use dm_zalloc to obtain zeroed memory block.
Use dm_free for dm_ allocated memory blocks.
Test close() for error.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/cmirrord/functions.c |   27 ++++++++++++---------------
 1 files changed, 12 insertions(+), 15 deletions(-)

diff --git a/daemons/cmirrord/functions.c b/daemons/cmirrord/functions.c
index 58e76ac..d773c42 100644
--- a/daemons/cmirrord/functions.c
+++ b/daemons/cmirrord/functions.c
@@ -429,13 +429,12 @@ static int _clog_ctr(char *uuid, uint64_t luid,
 			block_on_error = 1;
 	}
 
-	lc = malloc(sizeof(*lc));
+	lc = dm_zalloc(sizeof(*lc));
 	if (!lc) {
 		LOG_ERROR("Unable to allocate cluster log context");
 		r = -ENOMEM;
 		goto fail;
 	}
-	memset(lc, 0, sizeof(*lc));
 
 	lc->region_size = region_size;
 	lc->region_count = region_count;
@@ -453,7 +452,7 @@ static int _clog_ctr(char *uuid, uint64_t luid,
 	    (duplicate = get_pending_log(lc->uuid, lc->luid))) {
 		LOG_ERROR("[%s/%" PRIu64 "u] Log already exists, unable to create.",
 			  SHORT_UUID(lc->uuid), lc->luid);
-		free(lc);
+		dm_free(lc);
 		return -EINVAL;
 	}
 
@@ -511,15 +510,13 @@ static int _clog_ctr(char *uuid, uint64_t luid,
 	return 0;
 fail:
 	if (lc) {
-		if (lc->clean_bits)
-			free(lc->clean_bits);
-		if (lc->sync_bits)
-			free(lc->sync_bits);
-		if (lc->disk_buffer)
-			free(lc->disk_buffer);
-		if (lc->disk_fd >= 0)
-			close(lc->disk_fd);
-		free(lc);
+		if (lc->disk_fd >= 0 && close(lc->disk_fd))
+			LOG_ERROR("Close device error, %s: %s",
+				  disk_path, strerror(errno));
+		free(lc->disk_buffer);
+		dm_free(lc->sync_bits);
+		dm_free(lc->clean_bits);
+		dm_free(lc);
 	}
 	return r;
 }
@@ -634,9 +631,9 @@ static int clog_dtr(struct dm_ulog_request *rq)
 		close(lc->disk_fd);
 	if (lc->disk_buffer)
 		free(lc->disk_buffer);
-	free(lc->clean_bits);
-	free(lc->sync_bits);
-	free(lc);
+	dm_free(lc->clean_bits);
+	dm_free(lc->sync_bits);
+	dm_free(lc);
 
 	return 0;
 }
-- 
1.7.3.3


