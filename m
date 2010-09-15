From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 15 Sep 2010 11:35:59 -0400
Subject: [PATCH 07/19] Add pv_tags, vg_tags, lv_tags functions that call tags_format_and_copy.
In-Reply-To: <1284564971-26060-1-git-send-email-dwysocha@redhat.com>
References: <1284564971-26060-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1284564971-26060-8-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |   15 +++++++++++++++
 lib/metadata/metadata.h |    3 +++
 2 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 7e8d8f1..704e77b 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4775,6 +4775,21 @@ char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tags)
 	return dm_pool_end_object(mem);
 }
 
+char *pv_tags(const struct physical_volume *pv)
+{
+	return tags_format_and_copy(pv->vg->vgmem, &pv->tags);
+}
+
+char *vg_tags(const struct volume_group *vg)
+{
+	return tags_format_and_copy(vg->vgmem, &vg->tags);
+}
+
+char *lv_tags(const struct logical_volume *lv)
+{
+	return tags_format_and_copy(lv->vg->vgmem, &lv->tags);
+}
+
 uint64_t lv_size(const struct logical_volume *lv)
 {
 	return lv->size;
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 64da490..47fcd08 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -426,5 +426,8 @@ char *lv_uuid(const struct logical_volume *lv);
 char *vg_uuid(const struct volume_group *vg);
 char *pv_uuid(const struct physical_volume *pv);
 char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tags);
+char *pv_tags(const struct physical_volume *pv);
+char *vg_tags(const struct volume_group *vg);
+char *lv_tags(const struct logical_volume *lv);
 
 #endif
-- 
1.7.2.1


