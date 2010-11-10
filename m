From: Dave Wysochanski <wysochanski@pobox.com>
Date: Wed, 10 Nov 2010 11:11:58 -0500
Subject: [PATCH 5/7] Add pvseg internal library 'get' functions.
In-Reply-To: <1289405520-19964-1-git-send-email-wysochanski@pobox.com>
References: <1289405520-19964-1-git-send-email-wysochanski@pobox.com>
Message-ID: <1289405520-19964-6-git-send-email-wysochanski@pobox.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add the macro and specific 'get' functions for pvsegs.

Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
---
 lib/report/properties.c |   14 ++++++++++++--
 lib/report/properties.h |    2 ++
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/lib/report/properties.c b/lib/report/properties.c
index cb0beec..71f54bf 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -36,6 +36,8 @@ static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
 	GET_NUM_PROPERTY_FN(NAME, VALUE, logical_volume, lv)
 #define GET_LVSEG_NUM_PROPERTY_FN(NAME, VALUE) \
 	GET_NUM_PROPERTY_FN(NAME, VALUE, lv_segment, lvseg)
+#define GET_PVSEG_NUM_PROPERTY_FN(NAME, VALUE) \
+	GET_NUM_PROPERTY_FN(NAME, VALUE, pv_segment, pvseg)
 
 #define GET_STR_PROPERTY_FN(NAME, VALUE, TYPE, VAR)			\
 static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
@@ -53,6 +55,8 @@ static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
 	GET_STR_PROPERTY_FN(NAME, VALUE, logical_volume, lv)
 #define GET_LVSEG_STR_PROPERTY_FN(NAME, VALUE) \
 	GET_STR_PROPERTY_FN(NAME, VALUE, lv_segment, lvseg)
+#define GET_PVSEG_STR_PROPERTY_FN(NAME, VALUE) \
+	GET_STR_PROPERTY_FN(NAME, VALUE, pv_segment, pvseg)
 
 static int _not_implemented_get(const void *obj, struct lvm_property_type *prop)
 {
@@ -222,9 +226,9 @@ GET_LVSEG_STR_PROPERTY_FN(seg_tags, lvseg_tags_dup(lvseg))
 
 
 /* PVSEG */
-#define _pvseg_start_get _not_implemented_get
+GET_PVSEG_NUM_PROPERTY_FN(pvseg_start, pvseg->pe)
 #define _pvseg_start_set _not_implemented_set
-#define _pvseg_size_get _not_implemented_get
+GET_PVSEG_NUM_PROPERTY_FN(pvseg_size, pvseg->len)
 #define _pvseg_size_set _not_implemented_set
 
 
@@ -289,6 +293,12 @@ int vg_get_property(const struct volume_group *vg,
 	return _get_property(vg, prop, VGS);
 }
 
+int pvseg_get_property(const struct pv_segment *pvseg,
+		       struct lvm_property_type *prop)
+{
+	return _get_property(pvseg, prop, PVSEGS);
+}
+
 int pv_get_property(const struct physical_volume *pv,
 		    struct lvm_property_type *prop)
 {
diff --git a/lib/report/properties.h b/lib/report/properties.h
index 361750f..20123b3 100644
--- a/lib/report/properties.h
+++ b/lib/report/properties.h
@@ -39,6 +39,8 @@ int lv_get_property(const struct logical_volume *lv,
 		    struct lvm_property_type *prop);
 int vg_get_property(const struct volume_group *vg,
 		    struct lvm_property_type *prop);
+int pvseg_get_property(const struct pv_segment *pvseg,
+		       struct lvm_property_type *prop);
 int pv_get_property(const struct physical_volume *pv,
 		    struct lvm_property_type *prop);
 
-- 
1.7.2.2


