From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 20 Nov 2009 17:35:49 -0500
Subject: [PATCH 09/15] lvm-merge-origin-report-progress
In-Reply-To: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
References: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
Message-ID: <1258756555-14486-10-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Mikulas Patocka <mpatocka@redhat.com>

When there is merging snapshot, report percentage on the origin LV.
Because the snapshot LV will be hidden this is needed so the user can
see merging progress with "lvs" command.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Reviewed-by: Mike Snitzer <snitzer@redhat.com>
---
 lib/report/report.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 9b3fd0d..b65b492 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1032,7 +1032,7 @@ static int _snpercent_disp(struct dm_report *rh __attribute((unused)), struct dm
 		return 0;
 	}
 
-	if (!lv_is_cow(lv) ||
+	if ((!lv_is_cow(lv) && !lv->merging_snapshot) ||
 	    (lv_info(lv->vg->cmd, lv, &info, 0, 0) && !info.exists)) {
 		*sortval = UINT64_C(0);
 		dm_report_field_set_value(field, "", sortval);
-- 
1.6.5.2


