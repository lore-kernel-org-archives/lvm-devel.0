From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Nov 2014 13:24:11 +0000 (UTC)
Subject: master - cleanup: use lv_is_pool
Message-ID: <20141103132411.E20C060E6E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6c32ced6572b857ca954601757268dc4bb688b2f
Commit:        6c32ced6572b857ca954601757268dc4bb688b2f
Parent:        0ba5571bab4ea0d9e1f30bd35033033bdb477417
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 2 19:43:35 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 3 14:19:34 2014 +0100

cleanup: use lv_is_pool

Use lv_is_pool() to detect both pool versions.
---
 lib/report/report.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index c74bbfa..4f505e7 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -447,7 +447,7 @@ static int _datalv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 			const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	const struct lv_segment *seg = (lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) ? first_seg(lv) : NULL;
+	const struct lv_segment *seg = (lv_is_pool(lv)) ? first_seg(lv) : NULL;
 
 	if (seg)
 		return _lvname_disp(rh, mem, field, seg_lv(seg, 0), private);
@@ -460,7 +460,7 @@ static int _metadatalv_disp(struct dm_report *rh, struct dm_pool *mem __attribut
 			    const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	const struct lv_segment *seg = (lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) ? first_seg(lv) : NULL;
+	const struct lv_segment *seg = (lv_is_pool(lv)) ? first_seg(lv) : NULL;
 
 	if (seg)
 		return _lvname_disp(rh, mem, field, seg->metadata_lv, private);


