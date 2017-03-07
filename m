From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 7 Mar 2017 16:37:09 -0500
Subject: master - report: correct lv_size for 2-legged raid5
Message-ID: <201703072137.v27Lb6br001578@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=aedac100f9474bb9b5184f9c6efbc25d49eb742a
Commit:        aedac100f9474bb9b5184f9c6efbc25d49eb742a
Parent:        18bbeec8257f2806770601db9483309c35cb5225
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Mar 7 22:36:50 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Mar 7 22:36:50 2017 +0100

report: correct lv_size for 2-legged raid5

Reshaping a raid5 LV to one stripe aiming to convert it to
raid1 (and optionally to linear) reports the wrong LV size
when still having reshape space allocated.
---
 lib/report/report.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index e426371..4204d47 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -2305,7 +2305,7 @@ static int _lv_size_disp(struct dm_report *rh, struct dm_pool *mem,
 	uint64_t size = lv->le_count;
 
 	if (!lv_is_raid_image(lv))
-		size -= seg->reshape_len * seg->area_count;
+		size -= seg->reshape_len * (seg->area_count > 2 ? seg->area_count : 1);
 
 	size *= lv->vg->extent_size;
 


