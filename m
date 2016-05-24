From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 24 May 2016 13:29:24 +0000 (UTC)
Subject: master - raid: Revert _lv_extend_layered_lv non-raid0 area_multiple.
Message-ID: <20160524132924.C837A60DCF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7fffcce9247cba8ecb40a1c7b0c6d18a5cde2165
Commit:        7fffcce9247cba8ecb40a1c7b0c6d18a5cde2165
Parent:        adeb624c3bdfa5b444becb6918486b49a8d9ce4d
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue May 24 14:27:05 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue May 24 14:27:05 2016 +0100

raid: Revert _lv_extend_layered_lv non-raid0 area_multiple.

---
 lib/metadata/lv_manip.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 8a2c728..6c2d4e5 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3805,7 +3805,8 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 	if (seg_is_raid(seg)) {
 		stripes = 1;
 		stripe_size = 0;
-		area_multiple = _calc_area_multiple(seg->segtype, seg->area_count, stripes);
+		if (seg_is_raid0(seg))
+			area_multiple = seg->area_count;
 	}
 
 	for (fa = first_area, s = 0; s < seg->area_count; s++) {


