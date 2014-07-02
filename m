From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  2 Jul 2014 16:25:46 +0000 (UTC)
Subject: master - report: Add lv_dm_path and lv_full_name fields.
Message-ID: <20140702162546.15A5560994@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=64ce3a8066ead3bc2ee16e9cc286d68057bbe956
Commit:        64ce3a8066ead3bc2ee16e9cc286d68057bbe956
Parent:        5bfa2ec21d79b090276676076917808207ad4dd1
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jul 2 17:24:05 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jul 2 17:24:05 2014 +0100

report: Add lv_dm_path and lv_full_name fields.

---
 WHATS_NEW               |    1 +
 lib/display/display.c   |    7 ++-----
 lib/metadata/lv.c       |   45 +++++++++++++++++++++++++++++++++++++++++++--
 lib/metadata/lv.h       |    2 ++
 lib/report/columns.h    |    4 +++-
 lib/report/properties.c |    4 ++++
 lib/report/report.c     |   26 ++++++++++++++++++++++++++
 7 files changed, 81 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c55b3fb..625d58f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.108 -
 =================================
+  Add lv_full_name and lv_dm_path fields to reports.
   Change lv_path field to suppress devices that never appear in /dev/vg.
   Postpone thin pool lvconvert prompts (2.02.107).
   Require --yes option to skip prompt to lvconvert thin pool chunksize.
diff --git a/lib/display/display.c b/lib/display/display.c
index fd785ed..cd204a0 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -95,11 +95,8 @@ const char *get_percent_string(percent_type_t def)
 
 const char *display_lvname(const struct logical_volume *lv)
 {
-	char buf[NAME_LEN * 2 + 2];
-
-	(void) snprintf(buf, sizeof(buf), "%s/%s", lv->vg->name, lv->name);
-
-	return dm_pool_strdup(lv->vg->cmd->mem, buf) ? : lv->name; /* at least LV name... */
+	/* On allocation failure, just return the LV name. */
+	return lv_fullname_dup(lv->vg->cmd->mem, lv) ? : lv->name;
 }
 
 #define BASE_UNKNOWN 0
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 55395ce..c38cbe3 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -219,6 +219,18 @@ char *lv_name_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	return dm_pool_strdup(mem, lv->name);
 }
 
+char *lv_fullname_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+        char lvfullname[NAME_LEN * 2 + 2];
+
+        if (dm_snprintf(lvfullname, sizeof(lvfullname), "%s/%s", lv->vg->name, lv->name) < 0) {
+                log_error("lvfullname snprintf failed");
+                return NULL;
+        }
+
+        return dm_pool_strdup(mem, lvfullname);
+}
+
 char *lv_modules_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
 	struct dm_list *modules;
@@ -379,13 +391,42 @@ char *lv_path_dup(struct dm_pool *mem, const struct logical_volume *lv)
 
 	if (!(repstr = dm_pool_zalloc(mem, len))) {
 		log_error("dm_pool_alloc failed");
-		return 0;
+		return NULL;
 	}
 
 	if (dm_snprintf(repstr, len, "%s%s/%s",
 			lv->vg->cmd->dev_dir, lv->vg->name, lv->name) < 0) {
 		log_error("lvpath snprintf failed");
-		return 0;
+		return NULL;
+	}
+
+	return repstr;
+}
+
+char *lv_dmpath_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	char *name;
+	char *repstr;
+	size_t len;
+
+	if (!*lv->vg->name)
+		return dm_pool_strdup(mem, "");
+
+        if (!(name = dm_build_dm_name(mem, lv->vg->name, lv->name, NULL))) {
+		log_error("dm_build_dm_name failed");
+		return NULL;
+	}
+
+	len = strlen(dm_dir()) + strlen(name) + 2;
+
+	if (!(repstr = dm_pool_zalloc(mem, len))) {
+		log_error("dm_pool_alloc failed");
+		return NULL;
+	}
+
+	if (dm_snprintf(repstr, len, "%s/%s", dm_dir(), name) < 0) {
+		log_error("lv_dmpath snprintf failed");
+		return NULL;
 	}
 
 	return repstr;
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 51920b0..86db501 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -60,6 +60,7 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_uuid_dup(const struct logical_volume *lv);
 char *lv_tags_dup(const struct logical_volume *lv);
 char *lv_path_dup(struct dm_pool *mem, const struct logical_volume *lv);
+char *lv_dmpath_dup(struct dm_pool *mem, const struct logical_volume *lv);
 uint64_t lv_origin_size(const struct logical_volume *lv);
 char *lv_move_pv_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
@@ -71,6 +72,7 @@ char *lv_metadata_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_pool_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_modules_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_name_dup(struct dm_pool *mem, const struct logical_volume *lv);
+char *lv_fullname_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv);
 uint32_t lv_kernel_read_ahead(const struct logical_volume *lv);
 uint64_t lvseg_start(const struct lv_segment *seg);
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 70a3b65..418e67a 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -30,7 +30,9 @@
 /* *INDENT-OFF* */
 FIELD(LVS, lv, STR, "LV UUID", lvid.id[1], 38, uuid, lv_uuid, "Unique identifier.", 0)
 FIELD(LVS, lv, STR, "LV", lvid, 4, lvname, lv_name, "Name.  LVs created for internal use are enclosed in brackets.", 0)
-FIELD(LVS, lv, STR, "Path", lvid, 4, lvpath, lv_path, "Full pathname for LV.", 0)
+FIELD(LVS, lv, STR, "LV", lvid, 4, lvfullname, lv_full_name, "Full name of LV including its VG, namely VG/LV.", 0)
+FIELD(LVS, lv, STR, "Path", lvid, 4, lvpath, lv_path, "Full pathname for LV. Blank for internal LVs.", 0)
+FIELD(LVS, lv, STR, "DMPath", lvid, 6, lvdmpath, lv_dm_path, "Internal device-mapper pathname for LV (in /dev/mapper directory).", 0)
 FIELD(LVS, lv, STR, "Attr", lvid, 4, lvstatus, lv_attr, "Various attributes - see man page.", 0)
 FIELD(LVS, lv, STR, "Active", lvid, 6, lvactive, lv_active, "Active state of the LV.", 0)
 FIELD(LVS, lv, NUM, "Maj", major, 3, int32, lv_major, "Persistent major number or -1 if not persistent.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index ce3ed53..9692de8 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -164,8 +164,12 @@ GET_LV_STR_PROPERTY_FN(lv_uuid, lv_uuid_dup(lv))
 #define _lv_uuid_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(lv_name, lv_name_dup(lv->vg->vgmem, lv))
 #define _lv_name_set prop_not_implemented_set
+GET_LV_STR_PROPERTY_FN(lv_full_name, lv_fullname_dup(lv->vg->vgmem, lv))
+#define _lv_full_name_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(lv_path, lv_path_dup(lv->vg->vgmem, lv))
 #define _lv_path_set prop_not_implemented_set
+GET_LV_STR_PROPERTY_FN(lv_dm_path, lv_dmpath_dup(lv->vg->vgmem, lv))
+#define _lv_dm_path_set prop_not_implemented_set
 GET_LV_STR_PROPERTY_FN(lv_attr, lv_attr_dup(lv->vg->vgmem, lv))
 #define _lv_attr_set prop_not_implemented_set
 GET_LV_NUM_PROPERTY_FN(lv_major, lv->major)
diff --git a/lib/report/report.c b/lib/report/report.c
index 34b7b07..fca1133 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -311,6 +311,19 @@ static int _lvname_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _field_set_value(field, repstr, lvname);
 }
 
+static int _lvfullname_disp(struct dm_report *rh, struct dm_pool *mem,
+			    struct dm_report_field *field,
+			    const void *data, void *private __attribute__((unused)))
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	char *repstr;
+
+	if (!(repstr = lv_fullname_dup(mem, lv)))
+		return_0;
+
+	return _field_set_value(field, repstr, NULL);
+}
+
 static int _datalv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
 			struct dm_report_field *field,
 			const void *data, void *private __attribute__((unused)))
@@ -364,6 +377,19 @@ static int _lvpath_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _field_set_value(field, repstr, NULL);
 }
 
+static int _lvdmpath_disp(struct dm_report *rh, struct dm_pool *mem,
+			  struct dm_report_field *field,
+			  const void *data, void *private __attribute__((unused)))
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	char *repstr;
+
+	if (!(repstr = lv_dmpath_dup(mem, lv)))
+		return_0;
+
+	return _field_set_value(field, repstr, NULL);
+}
+
 static int _origin_disp(struct dm_report *rh, struct dm_pool *mem,
 			struct dm_report_field *field,
 			const void *data, void *private)


