From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 19 Jan 2016 13:46:19 +0000 (UTC)
Subject: master - report: fix off-by-one error when reporting LV segment's metadata device extent count
Message-ID: <20160119134619.7A924606DC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2a4ef78c4a7212b5f1416a0532fa83bbbe74561a
Commit:        2a4ef78c4a7212b5f1416a0532fa83bbbe74561a
Parent:        acf1e84e8c067de246fd83b05e723049c9f91407
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jan 19 14:42:51 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jan 19 14:44:06 2016 +0100

report: fix off-by-one error when reporting LV segment's metadata device extent count

Commit a3f484f812bfb89063fbc25e378f34cacd50bf7d used "-1" two times by
mistake for the extent count when reporting seg_metadata_le_ranges.
---
 lib/metadata/lv.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index b5c9852..4f25a59 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -55,7 +55,7 @@ static struct dm_list *_format_pvsegs(struct dm_pool *mem, const struct lv_segme
 		switch (metadata_areas_only ? seg_metatype(seg, s) : seg_type(seg, s)) {
 		case AREA_LV:
 			lv = metadata_areas_only ? seg_metalv(seg, s) : seg_lv(seg, s);
-			seg_len = metadata_areas_only ? seg_metalv(seg, s)->le_count - 1 : seg_lv(seg, s)->le_count;
+			seg_len = metadata_areas_only ? seg_metalv(seg, s)->le_count : seg_lv(seg, s)->le_count;
 			visible = lv_is_visible(lv);
 			name = lv->name;
 			extent = metadata_areas_only ? seg_le(seg, s) : 0;


