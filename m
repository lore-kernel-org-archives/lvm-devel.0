From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 11 Aug 2016 22:33:40 +0000 (UTC)
Subject: master - raid: Avoid double suffix on rmeta LV name paired with rimage LV.
Message-ID: <20160811223340.0D42460DF3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=93b61c07eb14f6185c708bd74f7e471b50cf251b
Commit:        93b61c07eb14f6185c708bd74f7e471b50cf251b
Parent:        e30fb19030823cd8bb181e2b494488c18c187850
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Aug 11 23:31:49 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Aug 11 23:31:49 2016 +0100

raid: Avoid double suffix on rmeta LV name paired with rimage LV.

---
 WHATS_NEW                 |    1 +
 lib/metadata/raid_manip.c |   23 +++++++++++++++++++----
 2 files changed, 20 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8f4fe9c..425729a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.164 -
 ===================================
+  Avoid double suffix when naming _rmeta LV paired with _rimage LV.
 
 Version 2.02.163 - 10th August 2016
 ===================================
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index c1cff33..ce560fe 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -108,6 +108,22 @@ static void _check_and_adjust_region_size(const struct logical_volume *lv)
 	return _ensure_min_region_size(lv);
 }
 
+/* Strip any raid suffix off LV name */
+static char *_top_level_raid_lv_name(struct logical_volume *lv)
+{
+	char *new_lv_name, *suffix;
+
+	if (!(new_lv_name = dm_pool_strdup(lv->vg->vgmem, lv->name))) {
+		log_error("Failed to allocate string for new LV name.");
+		return NULL;
+	}
+        
+	if ((suffix = first_substring(new_lv_name, "_rimage_", "_mimage_", NULL)))
+		*suffix = '\0';
+
+	return new_lv_name;
+}
+
 static int _lv_is_raid_with_tracking(const struct logical_volume *lv,
 				     struct logical_volume **tracking)
 {
@@ -679,7 +695,7 @@ static int _alloc_rmeta_for_lv(struct logical_volume *data_lv,
 	struct dm_list allocatable_pvs;
 	struct alloc_handle *ah;
 	struct lv_segment *seg = first_seg(data_lv);
-	char *p, base_name[NAME_LEN];
+	char *base_name;
 
 	dm_list_init(&allocatable_pvs);
 
@@ -699,9 +715,8 @@ static int _alloc_rmeta_for_lv(struct logical_volume *data_lv,
 		return 0;
 	}
 
-	(void) dm_strncpy(base_name, data_lv->name, sizeof(base_name));
-	if ((p = strstr(base_name, "_mimage_")))
-		*p = '\0';
+	if (!(base_name = _top_level_raid_lv_name(data_lv)))
+		return_0;
 
 	if (!(ah = allocate_extents(data_lv->vg, NULL, seg->segtype, 0, 1, 0,
 				    seg->region_size,


