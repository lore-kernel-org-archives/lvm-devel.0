From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 21 Dec 2010 16:41:35 +0100
Subject: [PATCH 03/23] Remove dead assigment of mirr_state
In-Reply-To: <cover.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
Message-ID: <4eb4464700b7063faa2d4f08c7f9bdc790263618.1292945707.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Variable 'mirr_state' is not used.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/mirror/mirrored.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 3d25d70..0bf3b3b 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -184,7 +184,6 @@ static int _mirrored_target_percent(void **target_state,
 				    uint64_t *total_numerator,
 				    uint64_t *total_denominator)
 {
-	struct mirror_state *mirr_state;
 	uint64_t numerator, denominator;
 	unsigned mirror_count, m;
 	int used;
@@ -193,8 +192,6 @@ static int _mirrored_target_percent(void **target_state,
 	if (!*target_state)
 		*target_state = _mirrored_init_target(mem, cmd);
 
-	mirr_state = *target_state;
-
 	/* Status line: <#mirrors> (maj:min)+ <synced>/<total_regions> */
 	log_debug("Mirror status: %s", params);
 
-- 
1.7.3.4


