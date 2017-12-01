From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 1 Dec 2017 06:20:27 -0500
Subject: master - activation: extend resume validation
Message-ID: <201712011120.vB1BKRjT029446@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e4db42e4769823aceb59698cef9811c11e330b7b
Commit:        e4db42e4769823aceb59698cef9811c11e330b7b
Parent:        c086dfadc389551b9a2d7b4c26931e5e74ada8d6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 28 23:11:20 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 1 12:19:09 2017 +0100

activation: extend resume validation

Check also all snapshosts when resume is requested,
the origin volume is already resume, but possibly
some subLV or snapshot LV could be suspended if
we are still in critical_section.
---
 lib/activate/activate.c |   21 +++++++++++++++------
 1 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 17bbe15..eacf638 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2311,6 +2311,11 @@ static int _check_suspended_lv(struct logical_volume *lv, void *data)
 		return 0; /* There is suspended subLV in the tree */
 	}
 
+	if (lv_layer(lv) && lv_info(lv->vg->cmd, lv, 1, &info, 0, 0) && info.exists && info.suspended) {
+		log_debug("Found suspended layered LV %s in critical section().", display_lvname(lv));
+		return 0; /* There is suspended subLV in the tree */
+	}
+
 	return 1;
 }
 
@@ -2319,6 +2324,7 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 	              const struct logical_volume *lv)
 {
 	const struct logical_volume *lv_to_free = NULL;
+	struct dm_list *snh;
 	struct lvinfo info;
 	int r = 0;
 
@@ -2360,18 +2366,21 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 			critical_section_dec(cmd, "resumed");
 
 		if (!info.suspended && critical_section()) {
-			/* check if any subLV is suspended */
-			if ((r = for_each_sub_lv((struct logical_volume *)lv, &_check_suspended_lv, NULL))) {
-				/* Everything seems resumed */
-				log_debug_activation("LV %s not suspended.", display_lvname(lv));
-				goto out;
+			/* Validation check if any subLV is suspended */
+			if (!laopts->origin_only && lv_is_origin(lv)) {
+				/* Check all snapshots for this origin LV */
+				dm_list_iterate(snh, &lv->snapshot_segs)
+					if (!_check_suspended_lv(dm_list_struct_base(snh, struct lv_segment, origin_list)->cow, NULL))
+						goto needs_resume; /* Found suspended snapshot */
 			}
+			if ((r = for_each_sub_lv((struct logical_volume *)lv, &_check_suspended_lv, NULL)))
+				goto out; /* Nothing was found suspended */
 		} else {
 			r = 1;
 			goto out;
 		}
 	}
-
+needs_resume:
 	laopts->read_only = _passes_readonly_filter(cmd, lv);
 	laopts->resuming = 1;
 


