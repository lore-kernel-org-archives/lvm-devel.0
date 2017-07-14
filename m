From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 14 Jul 2017 09:53:53 -0400
Subject: master - report: fix data_offset/new_data_offset reporting
Message-ID: <201707141353.v6EDrrVb025127@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1c4b7a3c2d2691f6f0accf04af2e31e4379b3baf
Commit:        1c4b7a3c2d2691f6f0accf04af2e31e4379b3baf
Parent:        6685460f5a918393edcde50d11f5cefb3a259df8
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Jul 13 18:27:38 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Jul 14 15:53:23 2017 +0200

report: fix data_offset/new_data_offset reporting

---
 lib/report/report.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index f61776e..de8c06a 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -2578,10 +2578,10 @@ static int _segdata_offset(struct dm_report *rh, struct dm_pool *mem,
 	struct logical_volume *lv;
 
 	if ((lv = _lv_for_raid_image_seg(seg, mem))) {
-		uint64_t data_offset;
+		uint64_t data_offset = 0;
 
 		if (lv_raid_data_offset(lv, &data_offset)) {
-			if (new_data_offset && !lv_raid_image_in_sync(seg->lv))
+			if (new_data_offset && lv_is_raid_image(lv) && !lv_raid_image_in_sync(lv))
 				data_offset = data_offset ? 0 : (uint64_t) seg->reshape_len * lv->vg->extent_size;
 
 			return dm_report_field_uint64(rh, field, &data_offset);


