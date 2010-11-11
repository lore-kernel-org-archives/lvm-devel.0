From: Dave Wysochanski <wysochanski@pobox.com>
Date: Thu, 11 Nov 2010 11:41:55 -0500
Subject: [PATCH 1/3] Add generic 'set' property function to internal library.
In-Reply-To: <1289493717-5790-1-git-send-email-wysochanski@pobox.com>
References: <1289493717-5790-1-git-send-email-wysochanski@pobox.com>
Message-ID: <1289493717-5790-2-git-send-email-wysochanski@pobox.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add generic infrastructure to internal library to 'set' a property.
Similar to 'get' property internal functions.
Add specific 'set' function for vg_mda_copies.

Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
---
 lib/report/columns.h    |    2 +-
 lib/report/properties.c |   71 ++++++++++++++++++++++++++++++++++++++++++++++-
 lib/report/properties.h |    6 ++++
 3 files changed, 77 insertions(+), 2 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 689f6a5..acc232f 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -121,7 +121,7 @@ FIELD(VGS, vg, NUM, "#VMda", cmd, 5, vgmdas, vg_mda_count, "Number of metadata a
 FIELD(VGS, vg, NUM, "#VMdaUse", cmd, 8, vgmdasused, vg_mda_used_count, "Number of metadata areas in use on this VG.", 0)
 FIELD(VGS, vg, NUM, "VMdaFree", cmd, 9, vgmdafree, vg_mda_free, "Free metadata area space for this VG in current units.", 0)
 FIELD(VGS, vg, NUM, "VMdaSize", cmd, 9, vgmdasize, vg_mda_size, "Size of smallest metadata area for this VG in current units.", 0)
-FIELD(VGS, vg, NUM, "#VMdaCps", cmd, 8, vgmdacopies, vg_mda_copies, "Target number of in use metadata areas in the VG.", 0)
+FIELD(VGS, vg, NUM, "#VMdaCps", cmd, 8, vgmdacopies, vg_mda_copies, "Target number of in use metadata areas in the VG.", 1)
 
 FIELD(SEGS, seg, STR, "Type", list, 4, segtype, segtype, "Type of LV segment.", 0)
 FIELD(SEGS, seg, NUM, "#Str", area_count, 4, uint32, stripes, "Number of stripes or mirror legs.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 339fd84..d814afe 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -35,6 +35,21 @@ static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
 #define GET_LV_NUM_PROPERTY_FN(NAME, VALUE) \
 	GET_NUM_PROPERTY_FN(NAME, VALUE, logical_volume, lv)
 
+#define SET_NUM_PROPERTY_FN(NAME, SETFN, TYPE, VAR)			\
+static int _ ## NAME ## _set (void *obj, struct lvm_property_type *prop) \
+{ \
+	struct TYPE *VAR = (struct TYPE *)obj; \
+\
+	SETFN(VAR, prop->value.integer);		\
+	return 1; \
+}
+#define SET_VG_NUM_PROPERTY_FN(NAME, SETFN) \
+	SET_NUM_PROPERTY_FN(NAME, SETFN, volume_group, vg)
+#define SET_PV_NUM_PROPERTY_FN(NAME, SETFN) \
+	SET_NUM_PROPERTY_FN(NAME, SETFN, physical_volume, pv)
+#define SET_LV_NUM_PROPERTY_FN(NAME, SETFN) \
+	SET_NUM_PROPERTY_FN(NAME, SETFN, logical_volume, lv)
+
 #define GET_STR_PROPERTY_FN(NAME, VALUE, TYPE, VAR)			\
 static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
 { \
@@ -184,7 +199,7 @@ GET_VG_NUM_PROPERTY_FN(vg_mda_free, (SECTOR_SIZE * vg_mda_free(vg)))
 GET_VG_NUM_PROPERTY_FN(vg_mda_size, (SECTOR_SIZE * vg_mda_size(vg)))
 #define _vg_mda_size_set _not_implemented_set
 GET_VG_NUM_PROPERTY_FN(vg_mda_copies, (vg_mda_copies(vg)))
-#define _vg_mda_copies_set _not_implemented_set
+SET_VG_NUM_PROPERTY_FN(vg_mda_copies, vg_set_mda_copies)
 
 /* LVSEG */
 #define _segtype_get _not_implemented_get
@@ -267,6 +282,42 @@ static int _get_property(const void *obj, struct lvm_property_type *prop,
 	return 1;
 }
 
+static int _set_property(void *obj, struct lvm_property_type *prop,
+			 report_type_t type)
+{
+	struct lvm_property_type *p;
+
+	p = _properties;
+	while (p->id[0]) {
+		if (!strcmp(p->id, prop->id))
+			break;
+		p++;
+	}
+	if (!p->id[0]) {
+		log_errno(EINVAL, "Invalid property name %s", prop->id);
+		return 0;
+	}
+	if (!p->is_settable) {
+		log_errno(EINVAL, "Unable to set read-only property %s",
+			  prop->id);
+		return 0;
+	}
+	if (!(p->type & type)) {
+		log_errno(EINVAL, "Property name %s does not match type %d",
+			  prop->id, p->type);
+		return 0;
+	}
+
+	if (p->is_string)
+		p->value.string = prop->value.string;
+	else
+		p->value.integer = prop->value.integer;
+	if (!p->set(obj, p)) {
+		return 0;
+	}
+	return 1;
+}
+
 int lv_get_property(const struct logical_volume *lv,
 		    struct lvm_property_type *prop)
 {
@@ -284,3 +335,21 @@ int pv_get_property(const struct physical_volume *pv,
 {
 	return _get_property(pv, prop, PVS | LABEL);
 }
+
+int lv_set_property(struct logical_volume *lv,
+		    struct lvm_property_type *prop)
+{
+	return _set_property(lv, prop, LVS);
+}
+
+int vg_set_property(struct volume_group *vg,
+		    struct lvm_property_type *prop)
+{
+	return _set_property(vg, prop, VGS);
+}
+
+int pv_set_property(struct physical_volume *pv,
+		    struct lvm_property_type *prop)
+{
+	return _set_property(pv, prop, PVS | LABEL);
+}
diff --git a/lib/report/properties.h b/lib/report/properties.h
index 054f400..7756cbe 100644
--- a/lib/report/properties.h
+++ b/lib/report/properties.h
@@ -39,5 +39,11 @@ int vg_get_property(const struct volume_group *vg,
 		    struct lvm_property_type *prop);
 int pv_get_property(const struct physical_volume *pv,
 		    struct lvm_property_type *prop);
+int lv_set_property(struct logical_volume *lv,
+		    struct lvm_property_type *prop);
+int vg_set_property(struct volume_group *vg,
+		    struct lvm_property_type *prop);
+int pv_set_property(struct physical_volume *pv,
+		    struct lvm_property_type *prop);
 
 #endif
-- 
1.7.2.2


