From: Milan Broz <mbroz@redhat.com>
Date: Sun, 10 May 2009 20:06:08 +0200
Subject: [PATCH] Fix first_seg() call for empty segment list.
Message-ID: <1241978772-6394-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The seg variable is temporary variable for list iterator,
code cannot expect that after iteration it remains NULL
(it contains non-NULL pointer here id list is empty).

Patch fixes first_seg function so it now correctly returns NULL
for empty segment list.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 WHATS_NEW               |    1 +
 lib/metadata/metadata.c |    6 +++---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8c465bd..e9e7446 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Fix first_seg() call for empty segment list.
   Fix PV datalignment for values starting prior to MDA area. (2.02.45)
   Add sparse devices: lvcreate -s --virtualoriginsize (hidden zero origin).
   Add lvs origin_size field.
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 13ab8f3..af4c69c 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1108,12 +1108,12 @@ struct lv_segment *find_seg_by_le(const struct logical_volume *lv, uint32_t le)
 
 struct lv_segment *first_seg(const struct logical_volume *lv)
 {
-	struct lv_segment *seg = NULL;
+	struct lv_segment *seg;
 
 	dm_list_iterate_items(seg, &lv->segments)
-		break;
+		return seg;
 
-	return seg;
+	return NULL;
 }
 
 /* Find segment at a given physical extent in a PV */
-- 
1.6.2.4


