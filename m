From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 21 Sep 2015 12:46:20 +0000 (UTC)
Subject: master - pv: add 'mem' arg for pv_uuid_dup and pv_name_dup
Message-ID: <20150921124620.DA9DA6112C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f01b7afa19433e4d428478fd0bb5e5a33d45685e
Commit:        f01b7afa19433e4d428478fd0bb5e5a33d45685e
Parent:        ffa7b37b281faaafaa5053d292502dafcdbf27f9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Sep 21 13:38:53 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Sep 21 14:21:42 2015 +0200

pv: add 'mem' arg for pv_uuid_dup and pv_name_dup

---
 lib/metadata/pv.c       |    8 ++++----
 lib/metadata/pv.h       |    4 ++--
 lib/report/properties.c |    4 ++--
 liblvm/lvm_pv.c         |    2 +-
 4 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
index 774cedb..ef95175 100644
--- a/lib/metadata/pv.c
+++ b/lib/metadata/pv.c
@@ -29,9 +29,9 @@ char *pv_fmt_dup(const struct physical_volume *pv)
 	return dm_pool_strdup(pv->vg->vgmem, pv->fmt->name);
 }
 
-char *pv_name_dup(const struct physical_volume *pv)
+char *pv_name_dup(struct dm_pool *mem, const struct physical_volume *pv)
 {
-	return dm_pool_strdup(pv->vg->vgmem, dev_name(pv->dev));
+	return dm_pool_strdup(mem ? mem : pv->vg->vgmem, dev_name(pv->dev));
 }
 
 /*
@@ -42,9 +42,9 @@ struct id pv_id(const struct physical_volume *pv)
 	return pv_field(pv, id);
 }
 
-char *pv_uuid_dup(const struct physical_volume *pv)
+char *pv_uuid_dup(struct dm_pool *mem, const struct physical_volume *pv)
 {
-	return id_format_and_copy(pv->vg->vgmem, &pv->id);
+	return id_format_and_copy(mem ? mem : pv->vg->vgmem, &pv->id);
 }
 
 char *pv_tags_dup(const struct physical_volume *pv)
diff --git a/lib/metadata/pv.h b/lib/metadata/pv.h
index 2d436cb..565d10e 100644
--- a/lib/metadata/pv.h
+++ b/lib/metadata/pv.h
@@ -68,12 +68,12 @@ struct physical_volume {
 };
 
 char *pv_fmt_dup(const struct physical_volume *pv);
-char *pv_name_dup(const struct physical_volume *pv);
+char *pv_name_dup(struct dm_pool *mem, const struct physical_volume *pv);
 struct device *pv_dev(const struct physical_volume *pv);
 const char *pv_vg_name(const struct physical_volume *pv);
 char *pv_attr_dup(struct dm_pool *mem, const struct physical_volume *pv);
 const char *pv_dev_name(const struct physical_volume *pv);
-char *pv_uuid_dup(const struct physical_volume *pv);
+char *pv_uuid_dup(struct dm_pool *mem, const struct physical_volume *pv);
 char *pv_tags_dup(const struct physical_volume *pv);
 uint64_t pv_size(const struct physical_volume *pv);
 uint64_t pv_size_field(const struct physical_volume *pv);
diff --git a/lib/report/properties.c b/lib/report/properties.c
index b151190..6f55a56 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -149,11 +149,11 @@ static dm_percent_t _metadata_percent(const struct logical_volume *lv)
 /* PV */
 GET_PV_STR_PROPERTY_FN(pv_fmt, pv_fmt_dup(pv))
 #define _pv_fmt_set prop_not_implemented_set
-GET_PV_STR_PROPERTY_FN(pv_uuid, pv_uuid_dup(pv))
+GET_PV_STR_PROPERTY_FN(pv_uuid, pv_uuid_dup(pv->vg->vgmem, pv))
 #define _pv_uuid_set prop_not_implemented_set
 GET_PV_NUM_PROPERTY_FN(dev_size, SECTOR_SIZE * pv_dev_size(pv))
 #define _dev_size_set prop_not_implemented_set
-GET_PV_STR_PROPERTY_FN(pv_name, pv_name_dup(pv))
+GET_PV_STR_PROPERTY_FN(pv_name, pv_name_dup(pv->vg->vgmem, pv))
 #define _pv_name_set prop_not_implemented_set
 GET_PV_NUM_PROPERTY_FN(pv_mda_free, SECTOR_SIZE * pv_mda_free(pv))
 #define _pv_mda_free_set prop_not_implemented_set
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index 5933e0a..fee1e8d 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -37,7 +37,7 @@ const char *lvm_pv_get_uuid(const pv_t pv)
 {
 	const char *rc;
 	struct saved_env e = store_user_env(pv->vg->cmd);
-	rc = pv_uuid_dup(pv);
+	rc = pv_uuid_dup(pv->vg->vgmem, pv);
 	restore_user_env(&e);
 	return rc;
 }


