From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 24 Jun 2020 11:58:11 +0000 (GMT)
Subject: stable-2.02 - lv{resize, extend, reduce}: reject size change on 2-legged raid5*
Message-ID: <20200624115811.83899388C00B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d17780c6b85a0f136e0ed395d5722d82bd8c7464
Commit:        d17780c6b85a0f136e0ed395d5722d82bd8c7464
Parent:        1fb7a9d9e53cbde38250bb9ece72a25191899b78
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Jun 24 13:52:53 2020 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Jun 24 13:57:13 2020 +0200

lv{resize,extend,reduce}: reject size change on 2-legged raid5*

Reject size changing request in to avoid 'Bus error' and
display hint to convert to more stripes.

Resolves: https://bugzilla.redhat.com/show_bug.cgi?id=1784351
---
 lib/metadata/lv_manip.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c8acb6ce8..d35eb5e0a 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4773,6 +4773,7 @@ static int _lvresize_check(struct logical_volume *lv,
 			   struct lvresize_params *lp)
 {
 	struct volume_group *vg = lv->vg;
+	struct lv_segment *seg = first_seg(lv);
 
 	if (lv_is_external_origin(lv)) {
 		/*
@@ -4796,6 +4797,12 @@ static int _lvresize_check(struct logical_volume *lv,
 		return 0;
 	}
 
+	if (seg && seg_is_any_raid5(seg) && seg->area_count < 3) {
+		log_error("Cannot resize %s LV %s. Convert to more stripes first.",
+			  lvseg_name(seg), display_lvname(lv));
+		return 0;
+	}
+
 	if (lv_is_raid(lv) &&
 	    lp->resize == LV_REDUCE) {
 		unsigned attrs;


