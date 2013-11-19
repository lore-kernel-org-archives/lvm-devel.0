From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 19 Nov 2013 20:56:41 +0000 (UTC)
Subject: master - lvm2app: Add VG/LV name validation
Message-ID: <20131119205641.A0BC860EA1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0dd247502ace2dd20763d1b664edc280a255de06
Commit:        0dd247502ace2dd20763d1b664edc280a255de06
Parent:        e54e70dc66a8be0dbc61e1dbc65310d86d35b086
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Sep 26 11:37:40 2013 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Nov 19 14:40:39 2013 -0600

lvm2app: Add VG/LV name validation

C library portion for
https://bugzilla.redhat.com/show_bug.cgi?id=883689

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/display/display.c            |   29 ++++++++++++++++++++++++++++
 lib/display/display.h            |    3 ++
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |   12 ++++++----
 lib/misc/lvm-string.c            |   39 +++++++++++++++++++++++++------------
 lib/misc/lvm-string.h            |    8 ++++++-
 liblvm/lvm2app.h                 |   32 +++++++++++++++++++++++++++++++
 liblvm/lvm_base.c                |    1 +
 liblvm/lvm_vg.c                  |   30 +++++++++++++++++++++++++++++
 9 files changed, 136 insertions(+), 19 deletions(-)

diff --git a/lib/display/display.c b/lib/display/display.c
index be56f12..2fd37a2 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -915,6 +915,35 @@ void display_segtypes(const struct cmd_context *cmd)
 	}
 }
 
+void display_name_error(name_error_t name_error)
+{
+	if (name_error != NAME_VALID) {
+		switch(name_error) {
+		case NAME_INVALID_EMPTY:
+			log_error("Name is zero length");
+			break;
+		case NAME_INVALID_HYPEN:
+			log_error("Name cannot start with hyphen");
+			break;
+		case NAME_INVALID_DOTS:
+			log_error("Name starts with . or .. and has no "
+						"following character(s)");
+			break;
+		case NAME_INVALID_CHARSET:
+			log_error("Name contains invalid character, valid set includes: "
+					"[a-zA-Z0-9.-_+]");
+			break;
+		case NAME_INVALID_LENGTH:
+			/* Report that name length -1 to accommodate nul*/
+			log_error("Name length exceeds maximum limit of %d", (NAME_LEN -1));
+			break;
+		default:
+			log_error("Unknown error %d on name validation", name_error);
+			break;
+		}
+	}
+}
+
 /*
  * Prompt for y or n from stdin.
  * Defaults to 'no' in silent mode.
diff --git a/lib/display/display.h b/lib/display/display.h
index 8462901..077fff4 100644
--- a/lib/display/display.h
+++ b/lib/display/display.h
@@ -18,6 +18,7 @@
 
 #include "metadata-exported.h"
 #include "locking.h"
+#include "lvm-string.h"
 
 #include <stdint.h>
 
@@ -53,6 +54,8 @@ void vgdisplay_short(const struct volume_group *vg);
 void display_formats(const struct cmd_context *cmd);
 void display_segtypes(const struct cmd_context *cmd);
 
+void display_name_error(name_error_t name_error);
+
 /*
  * Allocation policy display conversion routines.
  */
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 7429241..ed1ec8d 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -581,6 +581,7 @@ int pv_analyze(struct cmd_context *cmd, const char *pv_name,
 /* FIXME: move internal to library */
 uint32_t pv_list_extents_free(const struct dm_list *pvh);
 
+int validate_new_vg_name(struct cmd_context *cmd, const char *vg_name);
 int vg_validate(struct volume_group *vg);
 struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name);
 int vg_remove_mdas(struct volume_group *vg);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index d80958d..53d7e5e 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -435,13 +435,15 @@ int move_pvs_used_by_lv(struct volume_group *vg_from,
 	return 1;
 }
 
-static int validate_new_vg_name(struct cmd_context *cmd, const char *vg_name)
+int validate_new_vg_name(struct cmd_context *cmd, const char *vg_name)
 {
 	static char vg_path[PATH_MAX];
+	name_error_t name_error;
 
-	if (!validate_name(vg_name)) {
-		log_error("New volume group name \"%s\" is invalid.",
-			  vg_name);
+	name_error = validate_name_detailed(vg_name);
+	if (NAME_VALID != name_error) {
+		display_name_error(name_error);
+		log_error("New volume group name \"%s\" is invalid.", vg_name);
 		return 0;
 	}
 
@@ -4574,7 +4576,7 @@ void mda_set_ignored(struct metadata_area *mda, unsigned mda_ignored)
 	else
 		return;	/* No change */
 
-	log_debug_metadata("%s ignored flag for mda %s at offset %" PRIu64 ".", 
+	log_debug_metadata("%s ignored flag for mda %s at offset %" PRIu64 ".",
 			   mda_ignored ? "Setting" : "Clearing",
 			   mda->ops->mda_metadata_locn_name ? mda->ops->mda_metadata_locn_name(locn) : "",
 			   mda->ops->mda_metadata_locn_offset ? mda->ops->mda_metadata_locn_offset(locn) : UINT64_C(0));
diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index 8aa1f6c..380fe81 100644
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
@@ -136,6 +141,14 @@ int apply_lvname_restrictions(const char *name)
 	return 1;
 }
 
+/*
+ * Validates name and returns an emunerated reason for name validataion failure.
+ */
+name_error_t validate_name_detailed(const char *name)
+{
+	return _validate_name(name);
+}
+
 int is_reserved_lvname(const char *name)
 {
 	int rc, old_suppress;
diff --git a/lib/misc/lvm-string.h b/lib/misc/lvm-string.h
index 6be048d..13aacf8 100644
--- a/lib/misc/lvm-string.h
+++ b/lib/misc/lvm-string.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
  * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -24,6 +24,11 @@
 
 struct pool;
 
+typedef enum name_error { NAME_VALID = 0, NAME_INVALID_EMPTY = -1,
+					NAME_INVALID_HYPEN = -2, NAME_INVALID_DOTS = -3,
+					NAME_INVALID_CHARSET = -4, NAME_INVALID_LENGTH = -5}
+					name_error_t;
+
 int emit_to_buffer(char **buffer, size_t *size, const char *fmt, ...)
   __attribute__ ((format(printf, 3, 4)));
 
@@ -31,6 +36,7 @@ char *build_dm_uuid(struct dm_pool *mem, const char *lvid,
 		    const char *layer);
 
 int validate_name(const char *n);
+name_error_t validate_name_detailed(const char *n);
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
index 214f459..d3c8ae2 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -21,6 +21,7 @@
 #include "lvmetad.h"
 #include "lvm_misc.h"
 #include "lvm2app.h"
+#include "display.h"
 
 int lvm_vg_add_tag(vg_t vg, const char *tag)
 {
@@ -385,3 +386,32 @@ int lvm_scan(lvm_t libh)
 		return -1;
 	return 0;
 }
+
+int lvm_lv_name_validate(const vg_t vg, const char *name)
+{
+	name_error_t name_error;
+
+	name_error = validate_name_detailed(name);
+
+	if (NAME_VALID == name_error) {
+		if (apply_lvname_restrictions(name)) {
+			if (!find_lv_in_vg(vg, name)) {
+				return 0;
+			} else {
+				log_errno(EINVAL, "LV name exists in VG");
+			}
+		}
+	} else {
+		display_name_error(name_error);
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


