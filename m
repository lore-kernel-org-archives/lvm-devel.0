From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 31 Jul 2014 23:38:17 +0000 (UTC)
Subject: master - lvresize: Allow approximation with +%FREE.
Message-ID: <20140731233817.0C49760FC7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c7b9f0ab424136b686cd08ff7416078e7c3728c3
Commit:        c7b9f0ab424136b686cd08ff7416078e7c3728c3
Parent:        0dc3684b872fa1f225e06deeb0136d1ef66d4c1e
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Aug 1 00:35:43 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Aug 1 00:35:43 2014 +0100

lvresize: Allow approximation with +%FREE.

Make lvresize -l+%FREE support approximate allocation.

Move existing "Reducing/Extending' message to verbose level
and change it to say 'up to' if approximate allocation is being used.

Replace it with a new message that gives the actual old and new size or
says 'unchanged'.
---
 WHATS_NEW               |    2 ++
 lib/metadata/lv_manip.c |   22 ++++++++++++++++++----
 2 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 03cf668..a1099fe 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.109 - 
 =================================
+  Display actual size changed when resizing LV.
+  Allow approximate allocation with +%FREE in lvextend.
   Remove possible spurious "not found" message on PV create before wiping.
   Handle upgrade from 2.02.105 when an LV now gaining a uuid suffix is active.
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 0d39166..3e1f9e9 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4155,6 +4155,8 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 		if (lp->sign == SIGN_NONE && (lp->percent != PERCENT_LV && lp->percent != PERCENT_ORIGIN))
 			lp->approx_alloc = 1;
 		/* FIXME Adjust for parallel areas here before processing relative allocations */
+		if (lp->sign == SIGN_PLUS && lp->percent == PERCENT_FREE)
+			lp->approx_alloc = 1;
 	}
 
 	if (lp->sign == SIGN_PLUS) {
@@ -4456,6 +4458,7 @@ static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
 	struct volume_group *vg = lv->vg;
 	struct logical_volume *lock_lv = NULL;
 	struct lv_segment *seg = NULL;
+	uint32_t old_extents;
 	int status;
 	alloc_policy_t alloc;
 
@@ -4500,10 +4503,11 @@ static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
 	if (!archive(vg))
 		return_NULL;
 
-	log_print_unless_silent("%sing logical volume %s to %s",
-				(lp->resize == LV_REDUCE) ? "Reduc" : "Extend",
-				lv->name,
-				display_size(cmd, (uint64_t) lp->extents * vg->extent_size));
+	old_extents = lv->le_count;
+	log_verbose("%sing logical volume %s to %s%s",
+		    (lp->resize == LV_REDUCE) ? "Reduc" : "Extend",
+		    display_lvname(lv), lp->approx_alloc ? "up to " : "",
+		    display_size(cmd, (uint64_t) lp->extents * vg->extent_size));
 
 	if (lp->resize == LV_REDUCE) {
 		if (!lv_reduce(lv, lv->le_count - lp->extents))
@@ -4516,6 +4520,16 @@ static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
 			      pvh, alloc, lp->approx_alloc))
 		return_NULL;
 
+	if (old_extents == lv->le_count)
+		log_print_unless_silent("Size of logical volume %s unchanged from %s.",
+					display_lvname(lv),
+					display_size(cmd, (uint64_t) old_extents * vg->extent_size));
+	else
+		log_print_unless_silent("Size of logical volume %s changed from %s to %s.",
+					display_lvname(lv),
+					display_size(cmd, (uint64_t) old_extents * vg->extent_size),
+					display_size(cmd, (uint64_t) lv->le_count * vg->extent_size));
+
 	if (lock_lv) {
 		/* Update thin pool segment from the layered LV */
 		seg->area_len = lv->le_count;


