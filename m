From: Tony Asleson <tasleson@redhat.com>
Date: Fri, 27 Sep 2013 14:10:29 -0500
Subject: [PATCH 09/12] lvm2app: Add VG/LV name validation
In-Reply-To: <1380309032-12736-1-git-send-email-tasleson@redhat.com>
References: <1380309032-12736-1-git-send-email-tasleson@redhat.com>
Message-ID: <1380309032-12736-10-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

C library portion for
https://bugzilla.redhat.com/show_bug.cgi?id=883689

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/metadata/metadata-exported.h |  1 +
 lib/metadata/metadata.c          |  4 +--
 lib/misc/lvm-string.c            | 68 ++++++++++++++++++++++++++++++++--------
 lib/misc/lvm-string.h            |  1 +
 liblvm/lvm2app.h                 | 32 +++++++++++++++++++
 liblvm/lvm_base.c                |  1 +
 liblvm/lvm_vg.c                  | 21 +++++++++++++
 7 files changed, 113 insertions(+), 15 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 64bd650..5c00327 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -578,6 +578,7 @@ int pv_analyze(struct cmd_context *cmd, const char *pv_name,
 /* FIXME: move internal to library */
 uint32_t pv_list_extents_free(const struct dm_list *pvh);
 
+int validate_new_vg_name(struct cmd_context *cmd, const char *vg_name);
 int vg_validate(struct volume_group *vg);
 struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name);
 int vg_remove_mdas(struct volume_group *vg);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 1a212c3..2799b5f 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -429,11 +429,11 @@ int move_pvs_used_by_lv(struct volume_group *vg_from,
 	return 1;
 }
 
-static int validate_new_vg_name(struct cmd_context *cmd, const char *vg_name)
+int validate_new_vg_name(struct cmd_context *cmd, const char *vg_name)
 {
 	static char vg_path[PATH_MAX];
 
-	if (!validate_name(vg_name)) {
+	if (!validate_name_detailed(vg_name)) {
 		log_error("New volume group name \"%s\" is invalid.",
 			  vg_name);
 		return 0;
diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index 8aa1f6c..4351dfc 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -63,35 +63,40 @@ int validate_tag(const char *n)
 	return 1;
 }
 
-/*
- * Device layer names are all of the form <vg>-<lv>-<layer>, any
- * other hyphens that appear in these names are quoted with yet
- * another hyphen.  The top layer of any device has no layer
- * name.  eg, vg0-lvol0.
- */
-int validate_name(const char *n)
+static int _validate_name(const char *n)
 {
 	register char c;
 	register int len = 0;
 
 	if (!n || !*n)
-		return 0;
+		return -1;
 
 	/* Hyphen used as VG-LV separator - ambiguity if LV starts with it */
 	if (*n == '-')
-		return 0;
+		return -2;
 
 	if ((*n == '.') && (!n[1] || (n[1] == '.' && !n[2]))) /* ".", ".." */
-		return 0;
+		return -3;
 
 	while ((len++, c = *n++))
 		if (!isalnum(c) && c != '.' && c != '_' && c != '-' && c != '+')
-			return 0;
+			return -4;
 
 	if (len > NAME_LEN)
-		return 0;
+		return -5;
 
-	return 1;
+	return 0;
+}
+
+/*
+ * Device layer names are all of the form <vg>-<lv>-<layer>, any
+ * other hyphens that appear in these names are quoted with yet
+ * another hyphen.  The top layer of any device has no layer
+ * name.  eg, vg0-lvol0.
+ */
+int validate_name(const char *n)
+{
+	return (_validate_name(n) < 0 ? 0 : 1);
 }
 
 int apply_lvname_restrictions(const char *name)
@@ -136,6 +141,43 @@ int apply_lvname_restrictions(const char *name)
 	return 1;
 }
 
+/*
+ * Validates name and adds additional information to error messages.
+ */
+int validate_name_detailed(const char *name)
+{
+	int rc = 0;
+
+	rc = _validate_name(name);
+
+	if (rc) {
+		switch(rc) {
+		case -1:
+			log_error("Name is zero length");
+			break;
+		case -2:
+			log_error("Name cannot start with hyphen");
+			break;
+		case -3:
+			log_error("Name starts with . or .. and has no "
+						"following character(s)");
+			break;
+		case -4:
+			log_error("Name contains invalid character, valid set includes: "
+					"[a-zA-Z0-9.-_+]");
+			break;
+		case -5:
+			log_error("Name length exceeds maximum limit of %d", NAME_LEN);
+			break;
+		default:
+			log_error("Unknown error %d on name validation", rc);
+			break;
+		}
+	}
+
+	return (rc < 0) ? 0: 1;
+}
+
 int is_reserved_lvname(const char *name)
 {
 	int rc, old_suppress;
diff --git a/lib/misc/lvm-string.h b/lib/misc/lvm-string.h
index 6be048d..1e2ecc5 100644
--- a/lib/misc/lvm-string.h
+++ b/lib/misc/lvm-string.h
@@ -31,6 +31,7 @@ char *build_dm_uuid(struct dm_pool *mem, const char *lvid,
 		    const char *layer);
 
 int validate_name(const char *n);
+int validate_name_detailed(const char *n);
 int validate_tag(const char *n);
 
 int apply_lvname_restrictions(const char *name);
diff --git a/liblvm/lvm2app.h b/liblvm/lvm2app.h
index afc6793..0940b6f 100644
--- a/liblvm/lvm2app.h
+++ b/liblvm/lvm2app.h
@@ -510,6 +510,21 @@ vg_t lvm_vg_open(lvm_t libh, const char *vgname, const char *mode,
 		  uint32_t flags);
 
 /**
+ * Validate a name to be used for new VG construction.
+ *
+ * This function checks that the name has no invalid characters,
+ * the length doesn't exceed maximum and that the VG name isn't already in use
+ * and that the name adheres to any other limitations.
+ *
+ * \param libh
+ * Valid library handle
+ *
+ * \param name
+ * Name to validate for new VG create.
+ */
+int lvm_vg_name_validate(lvm_t libh, const char *vg_name);
+
+/**
  * Create a VG with default parameters.
  *
  * \memberof lvm_t
@@ -1554,6 +1569,23 @@ int lvm_lv_resize(const lv_t lv, uint64_t new_size);
 lv_t lvm_lv_snapshot(const lv_t lv, const char *snap_name, uint64_t max_snap_size);
 
 /**
+ * Validate a name to be used for LV creation.
+ *
+ * Validates that the name does not contain any invalid characters, max length
+ * and that the LV name doesn't already exist for this VG.
+ *
+ * Note: You can have the same LV name in different VGs, thus the reason this
+ * function requires that you specify a VG to check against.
+ *
+ * \param lv
+ * Volume group handle.
+ *
+ * \param name
+ * Name to validate
+ */
+int lvm_lv_name_validate(const vg_t vg, const char *lv_name);
+
+/**
  * Thin provisioning discard policies
  */
 typedef enum {
diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index b7603e3..139cc97 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -18,6 +18,7 @@
 #include "lvm-version.h"
 #include "metadata-exported.h"
 #include "lvm2app.h"
+#include "lvm-string.h"
 
 const char *lvm_library_get_version(void)
 {
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index 214f459..ee7aa18 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -385,3 +385,24 @@ int lvm_scan(lvm_t libh)
 		return -1;
 	return 0;
 }
+
+int lvm_lv_name_validate(const vg_t vg, const char *name)
+{
+	if (validate_name_detailed(name) && apply_lvname_restrictions(name)) {
+		if (!find_lv_in_vg(vg, name)) {
+			return 0;
+		} else {
+			log_errno(EINVAL, "LV name exists in VG");
+		}
+	}
+	return -1;
+}
+
+int lvm_vg_name_validate(lvm_t libh, const char *name)
+{
+	struct cmd_context *cmd = (struct cmd_context *)libh;
+
+	if (validate_new_vg_name(cmd, name))
+		return 0;
+	return -1;
+}
-- 
1.8.2.1


