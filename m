From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 16 Dec 2010 11:36:22 +0100
Subject: [PATCH 14/20] Remove dead store in _clog_ctr
In-Reply-To: <cover.1292495195.git.zkabelac@redhat.com>
References: <cover.1292495195.git.zkabelac@redhat.com>
Message-ID: <61fcd5f680d68f17d7465707d8e231da71218e6b.1292495195.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Remove unused 'duplicate' pointer.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/cmirrord/functions.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/daemons/cmirrord/functions.c b/daemons/cmirrord/functions.c
index d773c42..de80793 100644
--- a/daemons/cmirrord/functions.c
+++ b/daemons/cmirrord/functions.c
@@ -366,7 +366,6 @@ static int _clog_ctr(char *uuid, uint64_t luid,
 	uint64_t region_size;
 	uint64_t region_count;
 	struct log_c *lc = NULL;
-	struct log_c *duplicate;
 	enum sync log_sync = DEFAULTSYNC;
 	uint32_t block_on_error = 0;
 
@@ -448,8 +447,8 @@ static int _clog_ctr(char *uuid, uint64_t luid,
 	strncpy(lc->uuid, uuid, DM_UUID_LEN);
 	lc->luid = luid;
 
-	if ((duplicate = get_log(lc->uuid, lc->luid)) ||
-	    (duplicate = get_pending_log(lc->uuid, lc->luid))) {
+	if (get_log(lc->uuid, lc->luid) ||
+	    get_pending_log(lc->uuid, lc->luid)) {
 		LOG_ERROR("[%s/%" PRIu64 "u] Log already exists, unable to create.",
 			  SHORT_UUID(lc->uuid), lc->luid);
 		dm_free(lc);
-- 
1.7.3.3


