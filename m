From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu,  9 Sep 2010 16:13:06 -0400
Subject: [PATCH 09/12] Add 'get' functions for a few vg string fields, vg_name, vg_fmt, vg_sysid.
In-Reply-To: <1284063189-4908-1-git-send-email-dwysocha@redhat.com>
References: <1284063189-4908-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1284063189-4908-10-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add _vg_name_get, _vg_fmt_get, and _vg_sysid_get functions.
Place the static functions inside properties.c to avoid namespace conflict
with vg_name(), and as there are no other callers.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/properties.c |   23 ++++++++++++++++++++---
 1 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/lib/report/properties.c b/lib/report/properties.c
index 20119b3..ce7b85f 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -44,6 +44,23 @@ static int _not_implemented(void *obj, struct lvm_property_type *prop)
 	return 0;
 }
 
+static char *vg_fmt(const struct volume_group *vg)
+{
+	if (!vg->fid || !vg->fid->fmt)
+		return NULL;
+	return dm_pool_strdup(vg->vgmem, vg->fid->fmt->name);
+}
+
+static char *vg_name(const struct volume_group *vg)
+{
+	return dm_pool_strdup(vg->vgmem, vg->name);
+}
+
+static char *vg_system_id(const struct volume_group *vg)
+{
+	return dm_pool_strdup(vg->vgmem, vg->system_id);
+}
+
 /* PV */
 #define _pv_fmt_get _not_implemented
 #define _pv_fmt_set _not_implemented
@@ -123,11 +140,11 @@ static int _not_implemented(void *obj, struct lvm_property_type *prop)
 #define _modules_set _not_implemented
 
 /* VG */
-#define _vg_fmt_get _not_implemented
+GET_STR_PROPERTY_FN(vg_fmt, vg_fmt(vg))
 #define _vg_fmt_set _not_implemented
 #define _vg_uuid_get _not_implemented
 #define _vg_uuid_set _not_implemented
-#define _vg_name_get _not_implemented
+GET_STR_PROPERTY_FN(vg_name, vg_name(vg))
 #define _vg_name_set _not_implemented
 #define _vg_attr_get _not_implemented
 #define _vg_attr_set _not_implemented
@@ -135,7 +152,7 @@ GET_NUM_PROPERTY_FN(vg_size, (SECTOR_SIZE * vg_size(vg)))
 #define _vg_size_set _not_implemented
 GET_NUM_PROPERTY_FN(vg_free, (SECTOR_SIZE * vg_free(vg)))
 #define _vg_free_set _not_implemented
-#define _vg_sysid_get _not_implemented
+GET_STR_PROPERTY_FN(vg_sysid, vg_system_id(vg))
 #define _vg_sysid_set _not_implemented
 GET_NUM_PROPERTY_FN(vg_extent_size, vg->extent_size)
 #define _vg_extent_size_set _not_implemented
-- 
1.7.2.1


