From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 18 Aug 2010 09:51:59 -0400
Subject: [PATCH 08/11] Add 'get' functions for various numeric vg fields.
In-Reply-To: <1282139522-31240-1-git-send-email-dwysocha@redhat.com>
References: <1282139522-31240-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1282139522-31240-9-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add 'get' functions for the following: _vg_extent_count_get,
_vg_free_count_get, _max_lv_get, _max_pv_get, _pv_count_get,
_lv_count_get, _snap_count_get, _vg_seqno_get, _vg_size_get,
_vg_free_get.

Multiply SECTOR_SIZE inside _vg_size_get and _vg_free_get to
return bytes instead of sectors.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/properties.c |   80 +++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 70 insertions(+), 10 deletions(-)

diff --git a/lib/report/properties.c b/lib/report/properties.c
index 879f849..d21c2b0 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -113,29 +113,89 @@ static int _not_implemented(void *obj, struct lvm_property_type *prop)
 #define _vg_name_set _not_implemented
 #define _vg_attr_get _not_implemented
 #define _vg_attr_set _not_implemented
-#define _vg_size_get _not_implemented
+static int _vg_size_get (void *obj, struct lvm_property_type *prop)
+{
+	struct volume_group *vg = (struct volume_group *)obj;
+
+	prop->v.n_val = SECTOR_SIZE * vg_size(vg);
+	return 1;
+}
 #define _vg_size_set _not_implemented
-#define _vg_free_get _not_implemented
+static int _vg_free_get (void *obj, struct lvm_property_type *prop)
+{
+	struct volume_group *vg = (struct volume_group *)obj;
+
+	prop->v.n_val = SECTOR_SIZE * vg_free(vg);
+	return 1;
+}
 #define _vg_free_set _not_implemented
 #define _vg_sysid_get _not_implemented
 #define _vg_sysid_set _not_implemented
 #define _vg_extent_size_get _not_implemented
 #define _vg_extent_size_set _not_implemented
-#define _vg_extent_count_get _not_implemented
+static int _vg_extent_count_get (void *obj, struct lvm_property_type *prop)
+{
+	struct volume_group *vg = (struct volume_group *)obj;
+
+	prop->v.n_val = vg->extent_count;
+	return 1;
+}
 #define _vg_extent_count_set _not_implemented
-#define _vg_free_count_get _not_implemented
+static int _vg_free_count_get (void *obj, struct lvm_property_type *prop)
+{
+	struct volume_group *vg = (struct volume_group *)obj;
+
+	prop->v.n_val = vg->free_count;
+	return 1;
+}
 #define _vg_free_count_set _not_implemented
-#define _max_lv_get _not_implemented
+static int _max_lv_get (void *obj, struct lvm_property_type *prop)
+{
+	struct volume_group *vg = (struct volume_group *)obj;
+
+	prop->v.n_val = vg->max_lv;
+	return 1;
+}
 #define _max_lv_set _not_implemented
-#define _max_pv_get _not_implemented
+static int _max_pv_get (void *obj, struct lvm_property_type *prop)
+{
+	struct volume_group *vg = (struct volume_group *)obj;
+
+	prop->v.n_val = vg->max_pv;
+	return 1;
+}
 #define _max_pv_set _not_implemented
-#define _pv_count_get _not_implemented
+static int _pv_count_get (void *obj, struct lvm_property_type *prop)
+{
+	struct volume_group *vg = (struct volume_group *)obj;
+
+	prop->v.n_val = vg->pv_count;
+	return 1;
+}
 #define _pv_count_set _not_implemented
-#define _lv_count_get _not_implemented
+static int _lv_count_get (void *obj, struct lvm_property_type *prop)
+{
+	struct volume_group *vg = (struct volume_group *)obj;
+
+	prop->v.n_val = vg_visible_lvs(vg);
+	return 1;
+}
 #define _lv_count_set _not_implemented
-#define _snap_count_get _not_implemented
+static int _snap_count_get (void *obj, struct lvm_property_type *prop)
+{
+	struct volume_group *vg = (struct volume_group *)obj;
+
+	prop->v.n_val = snapshot_count(vg);
+	return 1;
+}
 #define _snap_count_set _not_implemented
-#define _vg_seqno_get _not_implemented
+static int _vg_seqno_get (void *obj, struct lvm_property_type *prop)
+{
+	struct volume_group *vg = (struct volume_group *)obj;
+
+	prop->v.n_val = vg->seqno;
+	return 1;
+}
 #define _vg_seqno_set _not_implemented
 #define _vg_tags_get _not_implemented
 #define _vg_tags_set _not_implemented
-- 
1.7.2.1


