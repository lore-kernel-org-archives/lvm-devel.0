From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Sep 2010 17:06:21 -0400
Subject: [PATCH 09/20] Add pv_tags_dup, vg_tags_dup, lv_tags_dup functions that call tags_format_and_copy.
In-Reply-To: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
References: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1285189592-26525-10-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/lv.c |    5 +++++
 lib/metadata/lv.h |    1 +
 lib/metadata/pv.c |    5 +++++
 lib/metadata/pv.h |    1 +
 lib/metadata/vg.c |    5 +++++
 lib/metadata/vg.h |    1 +
 6 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 4604653..8ee7788 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -21,6 +21,11 @@ char *lv_uuid_dup(const struct logical_volume *lv)
 	return id_format_and_copy(lv->vg->vgmem, &lv->lvid.id[1]);
 }
 
+char *lv_tags_dup(const struct logical_volume *lv)
+{
+	return tags_format_and_copy(lv->vg->vgmem, &lv->tags);
+}
+
 uint64_t lv_size(const struct logical_volume *lv)
 {
 	return lv->size;
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 9e8dbe2..2694c52 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -50,5 +50,6 @@ struct logical_volume {
 uint64_t lv_size(const struct logical_volume *lv);
 char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_uuid_dup(const struct logical_volume *lv);
+char *lv_tags_dup(const struct logical_volume *lv);
 
 #endif
diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
index c60d825..5d29693 100644
--- a/lib/metadata/pv.c
+++ b/lib/metadata/pv.c
@@ -34,6 +34,11 @@ char *pv_uuid_dup(const struct physical_volume *pv)
 	return id_format_and_copy(pv->vg->vgmem, &pv->id);
 }
 
+char *pv_tags_dup(const struct physical_volume *pv)
+{
+	return tags_format_and_copy(pv->vg->vgmem, &pv->tags);
+}
+
 const struct format_type *pv_format_type(const struct physical_volume *pv)
 {
 	return pv_field(pv, fmt);
diff --git a/lib/metadata/pv.h b/lib/metadata/pv.h
index 1df4957..14133c7 100644
--- a/lib/metadata/pv.h
+++ b/lib/metadata/pv.h
@@ -57,6 +57,7 @@ const char *pv_vg_name(const struct physical_volume *pv);
 char *pv_attr_dup(struct dm_pool *mem, const struct physical_volume *pv);
 const char *pv_dev_name(const struct physical_volume *pv);
 char *pv_uuid_dup(const struct physical_volume *pv);
+char *pv_tags_dup(const struct physical_volume *pv);
 uint64_t pv_size(const struct physical_volume *pv);
 uint64_t pv_size_field(const struct physical_volume *pv);
 uint64_t pv_dev_size(const struct physical_volume *pv);
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index c82eaa4..c79f136 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -21,6 +21,11 @@ char *vg_uuid_dup(const struct volume_group *vg)
 	return id_format_and_copy(vg->vgmem, &vg->id);
 }
 
+char *vg_tags_dup(const struct volume_group *vg)
+{
+	return tags_format_and_copy(vg->vgmem, &vg->tags);
+}
+
 uint32_t vg_seqno(const struct volume_group *vg)
 {
 	return vg->seqno;
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index b090894..6071ccb 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -125,5 +125,6 @@ uint64_t vg_mda_size(const struct volume_group *vg);
 uint64_t vg_mda_free(const struct volume_group *vg);
 char *vg_attr_dup(struct dm_pool *mem, const struct volume_group *vg);
 char *vg_uuid_dup(const struct volume_group *vg);
+char *vg_tags_dup(const struct volume_group *vg);
 
 #endif
-- 
1.7.2.2


