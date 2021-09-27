From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 27 Sep 2021 16:57:57 +0000 (GMT)
Subject: main - cleanup: use already known lv size
Message-ID: <20210927165757.C59363858408@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f74d30d411af0849e4c7f5ac6027899a32b48f52
Commit:        f74d30d411af0849e4c7f5ac6027899a32b48f52
Parent:        a8a958cc04da2c23e2a7a168ae19f05d4fcab1ae
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 27 11:00:53 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 27 18:56:14 2021 +0200

cleanup: use already known lv size

---
 lib/metadata/lv.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 475f21191..21aa3b422 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -951,7 +951,7 @@ uint64_t lv_origin_size(const struct logical_volume *lv)
 	struct lv_segment *seg;
 
 	if (lv_is_cow(lv))
-		return (uint64_t) find_snapshot(lv)->len * lv->vg->extent_size;
+		return find_snapshot(lv)->lv->size;
 
 	if (lv_is_thin_volume(lv) && (seg = first_seg(lv)) &&
 	    seg->external_lv)


