From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Mar 2021 10:14:13 +0000 (GMT)
Subject: main - lvremove: use to_remove for snapshot removal
Message-ID: <20210315101413.C03C43858039@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5edb353062b26bbe93002717d77aa5d1707f1f70
Commit:        5edb353062b26bbe93002717d77aa5d1707f1f70
Parent:        0a2d7c57a1120045e1a93a63bc568dc1e3dbb734
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 14 13:18:45 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 15 11:11:35 2021 +0100

lvremove: use to_remove for snapshot removal

Reuse similar 'acceleration' as used for dependent volumes also
for snapshot  - so when origin is being removed with all thick
snapshots, don't bother with individual 'COW' detachments
and write&commits, and when possible handle this all within
a single commit.
---
 lib/metadata/lv_manip.c       | 15 ++++++++-------
 lib/metadata/snapshot_manip.c | 10 ++++++++++
 2 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1d341eea2..6fc7afbac 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6823,13 +6823,10 @@ static int _lv_remove_segs_using_this_lv(struct cmd_context *cmd, struct logical
 	    yes_no_prompt("Removing %s \"%s\" will remove %u dependent volume(s). "
 			  "Proceed? [y/n]: ", lv_type, lv->name,
 			  dm_list_size(&lv->segs_using_this_lv)) == 'n') {
-			log_error("Logical volume \"%s\" not removed.", lv->name);
-			return 0;
-		}
-
-	/* Make aware users of this LV, it's going to be removed, so they
-	 * can skip any updates of itself */
-	lv->to_remove = 1;
+		lv->to_remove = 0;
+		log_error("Logical volume \"%s\" not removed.", lv->name);
+		return 0;
+	}
 
 	/*
 	 * Not using _safe iterator here - since we may delete whole subtree
@@ -6859,6 +6856,10 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 	struct lv_list *lvl;
 	struct logical_volume *origin;
 
+	/* Make aware users of this LV, it's going to be removed, so they
+	 * can skip any updates of itself */
+	lv->to_remove = 1;
+
 	if (!level && lv_is_cow(lv)) {
 		/*
 		 * A merging snapshot cannot be removed directly unless
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 3ee5f4a86..463bb291b 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -325,6 +325,16 @@ int vg_remove_snapshot(struct logical_volume *cow)
 	cow->snapshot = NULL;
 	lv_set_visible(cow);
 
+	/* When origin with all its snapshots is going to be remove
+	 * don't bother with individual manipulation with COWs
+	 * Note: removal proceeds only when origin is inactive */
+	if (is_origin_active && origin->to_remove) {
+		origin->vg->needs_write_and_commit = 1;
+		log_debug_metadata("Postponing write and commit for remove of snapshot %s.",
+				   display_lvname(cow));
+		return 1;
+	}
+
 	if (!vg_write(origin->vg))
 		return_0;
 


