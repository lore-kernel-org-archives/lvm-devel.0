From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 23 May 2016 23:41:43 +0000 (UTC)
Subject: master - raid10: Fix new use of area multiple calc.
Message-ID: <20160523234143.E6A3C60F62@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=498da2414b90098eb78cdd8c87bda7b022240fda
Commit:        498da2414b90098eb78cdd8c87bda7b022240fda
Parent:        b896f7de1e6773ce6c17bf29a9123276695f4b60
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue May 24 00:41:09 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue May 24 00:41:09 2016 +0100

raid10: Fix new use of area multiple calc.

---
 lib/metadata/lv_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2e9a7a3..8a2c728 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3803,9 +3803,9 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 	 * 'stripes' and 'stripe_size' parameters meaningless.
 	 */
 	if (seg_is_raid(seg)) {
-		area_multiple = _calc_area_multiple(seg->segtype, seg->area_count, 0);
 		stripes = 1;
 		stripe_size = 0;
+		area_multiple = _calc_area_multiple(seg->segtype, seg->area_count, stripes);
 	}
 
 	for (fa = first_area, s = 0; s < seg->area_count; s++) {


