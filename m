From: Dave Wysochanski <wysochanski@pobox.com>
Date: Thu, 11 Nov 2010 11:41:56 -0500
Subject: [PATCH 2/3] Add lvm_vg_set_property() function.
In-Reply-To: <1289493717-5790-1-git-send-email-wysochanski@pobox.com>
References: <1289493717-5790-1-git-send-email-wysochanski@pobox.com>
Message-ID: <1289493717-5790-3-git-send-email-wysochanski@pobox.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Implement lvm_vg_set_property() by calling internal 'set' property function.

Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
---
 liblvm/lvm2app.h  |   30 ++++++++++++++++++++++++++++++
 liblvm/lvm_misc.c |   30 ++++++++++++++++++++++++++++++
 liblvm/lvm_misc.h |    2 ++
 liblvm/lvm_vg.c   |    6 ++++++
 4 files changed, 68 insertions(+), 0 deletions(-)

diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index a5f65e9..a871df3 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -911,6 +911,36 @@ struct dm_list *lvm_vg_get_tags(const vg_t vg);
  */
 struct lvm_property_value lvm_vg_get_property(const vg_t vg, const char *name);
 
+/**
+ * Set the value of a VG property.  Note that the property must be
+ * a 'settable' property, as evidenced by the 'is_settable' flag
+ * when querying the property.
+ *
+ * \memberof vg_t
+ *
+ * The memory allocated for a string property value is tied to the vg_t
+ * handle and will be released when lvm_vg_close() is called.
+ *
+ * Example (integer):
+ *      lvm_property_value copies;
+ *
+ *      if (lvm_vg_get_property(vg, "vg_mda_copies", &copies) < 0) {
+ *              // Error - unable to query property
+ *      }
+ *      if (!copies.is_settable) {
+ *              // Error - property not settable
+ *      }
+ *      copies.value.integer = 2;
+ *      if (lvm_vg_set_property(vg, "vg_mda_copies", &copies) < 0) {
+ *              // handle error
+ *      }
+ *
+ * \return
+ * 0 (success) or -1 (failure).
+ */
+int lvm_vg_set_property(const vg_t vg, const char *name,
+			struct lvm_property_value *value);
+
 /************************** logical volume handling *************************/
 
 /**
diff --git a/liblvm/lvm_misc.c b/liblvm/lvm_misc.c
index adec2bc..30984e8 100644
--- a/liblvm/lvm_misc.c
+++ b/liblvm/lvm_misc.c
@@ -78,3 +78,33 @@ struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
 	v.is_valid = 1;
 	return v;
 }
+
+
+int set_property(const pv_t pv, const vg_t vg, const lv_t lv,
+		 const char *name, struct lvm_property_value *v)
+{
+	struct lvm_property_type prop;
+
+	prop.id = name;
+	if (v->is_string)
+		prop.value.string = v->value.string;
+	else
+		prop.value.integer = v->value.integer;
+	if (pv) {
+		if (!pv_set_property(pv, &prop)) {
+			v->is_valid = 0;
+			return -1;
+		}
+	} else if (vg) {
+		if (!vg_set_property(vg, &prop)) {
+			v->is_valid = 0;
+			return -1;
+		}
+	} else if (lv) {
+		if (!lv_set_property(lv, &prop)) {
+			v->is_valid = 0;
+			return -1;
+		}
+	}
+	return 0;
+}
diff --git a/liblvm/lvm_misc.h b/liblvm/lvm_misc.h
index b4e675e..710c98d 100644
--- a/liblvm/lvm_misc.h
+++ b/liblvm/lvm_misc.h
@@ -19,5 +19,7 @@
 struct dm_list *tag_list_copy(struct dm_pool *p, struct dm_list *tag_list);
 struct lvm_property_value get_property(const pv_t pv, const vg_t vg,
 				       const lv_t lv, const char *name);
+int set_property(const pv_t pv, const vg_t vg, const lv_t lv,
+		 const char *name, struct lvm_property_value *value);
 
 #endif
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index 6970910..e6644ae 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -341,6 +341,12 @@ struct lvm_property_value lvm_vg_get_property(const vg_t vg, const char *name)
 	return get_property(NULL, vg, NULL, name);
 }
 
+int lvm_vg_set_property(const vg_t vg, const char *name,
+			struct lvm_property_value *value)
+{
+	return set_property(NULL, vg, NULL, name, value);
+}
+
 struct dm_list *lvm_list_vg_names(lvm_t libh)
 {
 	return get_vgnames((struct cmd_context *)libh, 0);
-- 
1.7.2.2


