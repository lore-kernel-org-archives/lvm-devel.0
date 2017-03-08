From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 8 Mar 2017 12:32:21 -0500
Subject: master - report: fix segfault
Message-ID: <201703081732.v28HWLpf022064@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7f25fbe1547f06f4de880fbf6d28b83cebc7e16d
Commit:        7f25fbe1547f06f4de880fbf6d28b83cebc7e16d
Parent:        11f1556d5dbfb843f894b64d1e0cd2ff6197851a
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Mar 8 18:31:20 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Mar 8 18:32:01 2017 +0100

report: fix segfault

Commit f4b30b0daef3 which was about displaying visible
LV size when reshape space is allocated did not account
for undefined first lv segment.
---
 lib/report/report.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 4204d47..b5791c6 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -2304,7 +2304,7 @@ static int _lv_size_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_segment *seg = first_seg(lv);
 	uint64_t size = lv->le_count;
 
-	if (!lv_is_raid_image(lv))
+	if (seg && !lv_is_raid_image(lv))
 		size -= seg->reshape_len * (seg->area_count > 2 ? seg->area_count : 1);
 
 	size *= lv->vg->extent_size;


