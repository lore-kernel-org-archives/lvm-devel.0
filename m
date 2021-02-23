From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 23 Feb 2021 14:04:20 +0000 (GMT)
Subject: main - cleanup: comment typo
Message-ID: <20210223140420.F1000393A413@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5d820b02012bbadb07990ee20034145ab8e2fb0e
Commit:        5d820b02012bbadb07990ee20034145ab8e2fb0e
Parent:        0c842ee8adc4f5566e49b59abee5d43a15b85f0c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 20 23:50:25 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 14:56:48 2021 +0100

cleanup: comment typo

---
 lib/metadata/cache_manip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index f29442358..3eac736dd 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -656,7 +656,7 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	if (!remove_layer_from_lv(cache_lv, corigin_lv))
 		return_0;
 
-	/* Preserve currently imortant data from original cache segment.
+	/* Preserve currently important data from original cache segment.
 	 * TODO: can it be done without this ? */
 	data_id = cache_seg->data_id;
 	data_len = cache_seg->data_len;


