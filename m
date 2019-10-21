From: David Teigland <teigland@sourceware.org>
Date: Mon, 21 Oct 2019 13:16:51 -0400
Subject: master - cachevol: use cachepool code for metadata size
Message-ID: <201910211716.x9LHGp2N031110@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c08704cee7e34a96fdaa453faf900683283e8691
Commit:        c08704cee7e34a96fdaa453faf900683283e8691
Parent:        018cf39316923f26e42c25fc6e885b0ca46c88ba
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Oct 21 12:13:33 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Oct 21 12:13:33 2019 -0500

cachevol: use cachepool code for metadata size

Based on a more detailed calculation, but because of
extent size rounding, the final result is about the
same.
---
 lib/metadata/cache_manip.c |   26 +-------------------------
 1 files changed, 1 insertions(+), 25 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index c20cc49..2f35d83 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -1092,32 +1092,8 @@ int cache_vol_set_params(struct cmd_context *cmd,
 		}
 	}
 
-	/*
-	 * cachevol size 8M to 16M  -> metadata size 4M
-	 *
-	 * cachevol size 16M to 4G  -> metadata size 8M
-	 *
-	 * cachevol size 4G to 16G  -> metadata size 16M
-	 *
-	 * cachevol size 16G to 32G -> metadata size 32M
-	 *
-	 * cachevol size 32G and up -> metadata size 64M
-	 */
 	if (!meta_size) {
-		if (pool_lv->size <= (16 * ONE_MB_IN_SECTORS))
-			meta_size = 4 * ONE_MB_IN_SECTORS;
-
-		else if (pool_lv->size <= (4 * ONE_GB_IN_SECTORS))
-			meta_size = 8 * ONE_MB_IN_SECTORS;
-
-		else if (pool_lv->size <= (16 * ONE_GB_IN_SECTORS))
-			meta_size = 16 * ONE_MB_IN_SECTORS;
-
-		else if (pool_lv->size <= (32 * ONE_GB_IN_SECTORS))
-			meta_size = 32 * ONE_MB_IN_SECTORS;
-
-		else
-			meta_size = 64 * ONE_MB_IN_SECTORS;
+		meta_size = _cache_min_metadata_size(pool_lv->size, chunk_size);
 
 		if (meta_size < min_meta_size)
 			meta_size = min_meta_size;


