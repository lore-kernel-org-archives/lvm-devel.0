From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  4 Jul 2014 00:21:07 +0000 (UTC)
Subject: master - vgsplit: Improve message when LV still active.
Message-ID: <20140704002107.643B261193@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ac60c876c43d0ebc7e642dcc92528b974bd7b9f5
Commit:        ac60c876c43d0ebc7e642dcc92528b974bd7b9f5
Parent:        137ed3081adca8ecec933bd5f5e34c1fa3e2ffef
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jul 4 01:13:51 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jul 4 01:13:51 2014 +0100

vgsplit: Improve message when LV still active.

Mention parent LV as well as the LV triggering the warning.

Still leaves some confusing cases but its not worth fixing them
at the moment.
(Thin pool inactive but a thin volume active => deactivate thin vol.
Inactive mirror/raid with pvmove in progress => complete pvmove and
active&deactivate mirror/raid.
If new VG already exists it requires some LVs to be inactive
unnecessarily.)
---
 lib/metadata/lv.c |   21 ++++++++++++++-------
 lib/metadata/lv.h |    1 +
 tools/vgsplit.c   |   12 ++++++++----
 3 files changed, 23 insertions(+), 11 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 18066f0..308b93d 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -231,22 +231,29 @@ char *lv_fullname_dup(struct dm_pool *mem, const struct logical_volume *lv)
         return dm_pool_strdup(mem, lvfullname);
 }
 
-char *lv_parent_dup(struct dm_pool *mem, const struct logical_volume *lv)
+struct logical_volume *lv_parent(const struct logical_volume *lv)
 {
-	const char *parent = "";
+	struct logical_volume *parent_lv = NULL;
 
 	if (lv_is_visible(lv))
 		;
 	else if (lv_is_mirror_image(lv) || lv_is_mirror_log(lv))
-		parent = get_only_segment_using_this_lv(lv)->lv->name;
+		parent_lv = get_only_segment_using_this_lv(lv)->lv;
 	else if (lv_is_raid_image(lv) || lv_is_raid_metadata(lv))
-		parent = get_only_segment_using_this_lv(lv)->lv->name;
+		parent_lv = get_only_segment_using_this_lv(lv)->lv;
 	else if (lv_is_cache_pool_data(lv) || lv_is_cache_pool_metadata(lv))
-		parent = get_only_segment_using_this_lv(lv)->lv->name;
+		parent_lv = get_only_segment_using_this_lv(lv)->lv;
 	else if (lv_is_thin_pool_data(lv) || lv_is_thin_pool_metadata(lv))
-		parent = get_only_segment_using_this_lv(lv)->lv->name;
+		parent_lv = get_only_segment_using_this_lv(lv)->lv;
+
+	return parent_lv;
+}
+
+char *lv_parent_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	struct logical_volume *parent_lv = lv_parent(lv);
 
-	return dm_pool_strdup(mem, parent);
+	return dm_pool_strdup(mem, parent_lv ? parent_lv->name : "");
 }
 
 char *lv_modules_dup(struct dm_pool *mem, const struct logical_volume *lv)
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 47ade92..f298162 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -73,6 +73,7 @@ char *lv_pool_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_modules_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_name_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_fullname_dup(struct dm_pool *mem, const struct logical_volume *lv);
+struct logical_volume *lv_parent(const struct logical_volume *lv);
 char *lv_parent_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv);
 uint32_t lv_kernel_read_ahead(const struct logical_volume *lv);
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 9b0f616..5478e78 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -18,10 +18,10 @@
 
 static int _lv_is_in_vg(struct volume_group *vg, struct logical_volume *lv)
 {
-	if (lv->vg == vg)
-		return 1;
+	if (!lv || lv->vg != vg)
+		return 0;
 
-	return 0;
+	return 1;
 }
 
 static int _move_one_lv(struct volume_group *vg_from,
@@ -29,9 +29,13 @@ static int _move_one_lv(struct volume_group *vg_from,
 			 struct dm_list *lvh)
 {
 	struct logical_volume *lv = dm_list_item(lvh, struct lv_list)->lv;
+	struct logical_volume *parent_lv;
 
 	if (lv_is_active(lv)) {
-		log_error("Logical volume \"%s\" must be inactive", lv->name);
+		if ((parent_lv = lv_parent(lv)))
+			log_error("Logical volume %s (part of %s) must be inactive.", display_lvname(lv), parent_lv->name);
+		else
+			log_error("Logical volume %s must be inactive.", display_lvname(lv));
 		return 0;
 	}
 


