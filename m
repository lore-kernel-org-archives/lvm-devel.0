From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 21 Sep 2015 12:46:08 +0000 (UTC)
Subject: master - lv: add 'mem' arg for lv_uuid_dup
Message-ID: <20150921124608.2B23E61059@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0e3042f488dd22b99b4ac0705a18bb03ee48a4d3
Commit:        0e3042f488dd22b99b4ac0705a18bb03ee48a4d3
Parent:        f644431346465389bf1aaab0e9880cf0b1751c5a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Sep 21 12:23:03 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Sep 21 12:25:31 2015 +0200

lv: add 'mem' arg for lv_uuid_dup

---
 lib/metadata/lv.c       |    4 ++--
 lib/metadata/lv.h       |    2 +-
 lib/report/properties.c |    2 +-
 liblvm/lvm_lv.c         |    2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index c775077..3009149 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -479,9 +479,9 @@ char *lv_dmpath_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	return repstr;
 }
 
-char *lv_uuid_dup(const struct logical_volume *lv)
+char *lv_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
-	return id_format_and_copy(lv->vg->vgmem, &lv->lvid.id[1]);
+	return id_format_and_copy(mem ? mem : lv->vg->vgmem, &lv->lvid.id[1]);
 }
 
 char *lv_tags_dup(const struct logical_volume *lv)
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index a2b0f6f..bc82d3e 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -62,7 +62,7 @@ uint64_t lv_size(const struct logical_volume *lv);
 uint64_t lv_metadata_size(const struct logical_volume *lv);
 char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_with_info_and_seg_status *lvdm);
 char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv);
-char *lv_uuid_dup(const struct logical_volume *lv);
+char *lv_uuid_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_tags_dup(const struct logical_volume *lv);
 char *lv_path_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_dmpath_dup(struct dm_pool *mem, const struct logical_volume *lv);
diff --git a/lib/report/properties.c b/lib/report/properties.c
index e38359b..4b2aff5 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -264,7 +264,7 @@ GET_PV_NUM_PROPERTY_FN(pv_ba_size, SECTOR_SIZE * pv->ba_size)
 #define _cache_write_misses_get prop_not_implemented_get
 
 /* LV */
-GET_LV_STR_PROPERTY_FN(lv_uuid, lv_uuid_dup(lv))
+GET_LV_STR_PROPERTY_FN(lv_uuid, lv_uuid_dup(lv->vg->vgmem, lv))
 #define _lv_uuid_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(lv_name, lv_name_dup(lv->vg->vgmem, lv))
 #define _lv_name_set prop_not_implemented_set
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 33af348..95d8492 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -56,7 +56,7 @@ const char *lvm_lv_get_uuid(const lv_t lv)
 {
 	const char *rc;
 	struct saved_env e = store_user_env(lv->vg->cmd);
-	rc = lv_uuid_dup(lv);
+	rc = lv_uuid_dup(lv->vg->vgmem, lv);
 	restore_user_env(&e);
 	return rc;
 }


