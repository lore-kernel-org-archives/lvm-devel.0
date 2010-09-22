From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Sep 2010 17:06:23 -0400
Subject: [PATCH 11/20] Make generic GET_*_PROPERTY_FN macros and define secondary macro for vg, pv, lv.
In-Reply-To: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
References: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1285189592-26525-12-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Will need similar macros for VG, PV and LV, so define a generic one, and just
pass in the struct name and variable name for the specific macro.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/properties.c |   25 +++++++++++++++++++++++--
 1 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/lib/report/properties.c b/lib/report/properties.c
index 9e3cad3..b39a979 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -20,14 +20,35 @@
 #include "lvm-types.h"
 #include "metadata.h"
 
-#define GET_NUM_PROPERTY_FN(NAME, VALUE) \
+#define GET_NUM_PROPERTY_FN(NAME, VALUE, STRUCT, VAR)			\
 static int _ ## NAME ## _get (void *obj, struct lvm_property_type *prop) \
 { \
-	struct volume_group *vg = (struct volume_group *)obj; \
+	struct STRUCT *VAR = (struct STRUCT *)obj; \
 \
 	prop->v.n_val = VALUE; \
 	return 1; \
 }
+#define GET_VG_NUM_PROPERTY_FN(NAME, VALUE) \
+	GET_NUM_PROPERTY_FN(NAME, VALUE, volume_group, vg)
+#define GET_PV_NUM_PROPERTY_FN(NAME, VALUE) \
+	GET_NUM_PROPERTY_FN(NAME, VALUE, physical_volume, pv)
+#define GET_LV_NUM_PROPERTY_FN(NAME, VALUE) \
+	GET_NUM_PROPERTY_FN(NAME, VALUE, logical_volume, lv)
+
+#define GET_STR_PROPERTY_FN(NAME, VALUE, STRUCT, VAR)			\
+static int _ ## NAME ## _get (void *obj, struct lvm_property_type *prop) \
+{ \
+	struct STRUCT *VAR = (struct STRUCT *)obj; \
+\
+	prop->v.s_val = (char *)VALUE;	\
+	return 1; \
+}
+#define GET_VG_STR_PROPERTY_FN(NAME, VALUE) \
+	GET_STR_PROPERTY_FN(NAME, VALUE, volume_group, vg)
+#define GET_PV_STR_PROPERTY_FN(NAME, VALUE) \
+	GET_STR_PROPERTY_FN(NAME, VALUE, physical_volume, pv)
+#define GET_LV_STR_PROPERTY_FN(NAME, VALUE) \
+	GET_STR_PROPERTY_FN(NAME, VALUE, logical_volume, lv)
 
 static int _not_implemented(void *obj, struct lvm_property_type *prop)
 {
-- 
1.7.2.2


