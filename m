From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 23 Apr 2009 15:06:57 +0200
Subject: [PATCH 1/5] Udev integration: add LVM fields support for dmsetup (updated)
Message-ID: <49F067F1.5070707@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I'm resending updated and cleaned up patches for udev integration...
(I'd better send all four of them + add one for lvmsplit command)

Peter


diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 93aecbb..ded0eaf 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -131,6 +131,13 @@ struct dm_versions {
 	char name[0];
 };
 
+struct dm_split_name {
+	char *subsystem;
+	char *vg;
+	char *lv;
+	char *lv_layer;
+};
+
 int dm_get_library_version(char *version, size_t size);
 int dm_task_get_driver_version(struct dm_task *dmt, char *version, size_t size);
 int dm_task_get_info(struct dm_task *dmt, struct dm_info *dmi);
diff --git a/libdm/libdm-string.c b/libdm/libdm-string.c
index 0e41f9d..c6f101b 100644
--- a/libdm/libdm-string.c
+++ b/libdm/libdm-string.c
@@ -93,7 +93,7 @@ static char *_unquote(char *component)
 int dm_split_lvm_name(struct dm_pool *mem, const char *dmname,
 		      char **vgname, char **lvname, char **layer)
 {
-	if (!(*vgname = dm_pool_strdup(mem, dmname)))
+	if (mem && !(*vgname = dm_pool_strdup(mem, dmname)))
 		return 0;
 
 	_unquote(*layer = _unquote(*lvname = _unquote(*vgname)));
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 0d6a371..f2397f6 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -141,7 +141,8 @@ typedef enum {
 	DR_TASK = 1,
 	DR_INFO = 2,
 	DR_DEPS = 4,
-	DR_TREE = 8	/* Complete dependency tree required */
+	DR_TREE = 8,	/* Complete dependency tree required */
+	DR_NAME = 16
 } report_type_t;
 
 static int _switches[NUM_SWITCHES];
@@ -261,6 +262,7 @@ struct dmsetup_report_obj {
 	struct dm_info *info;
 	struct dm_task *deps_task;
 	struct dm_tree_node *tree_node;
+	struct dm_split_name *split_name;
 };
 
 static struct dm_task *_get_deps_task(int major, int minor)
@@ -294,6 +296,60 @@ static struct dm_task *_get_deps_task(int major, int minor)
 	return NULL;
 }
 
+static char *_extract_uuid_prefix(const char *uuid)
+{
+	char *ptr = NULL;
+	size_t len;
+	char *str = NULL;
+
+	if (uuid)
+		ptr = strchr(uuid, '-');
+
+	len = ptr ? ptr - uuid : 0;
+	if (!(str = dm_malloc(len + 1)))
+		return NULL;
+
+	memcpy(str, uuid, len);
+	str[len] = '\0';
+
+	return str;
+}
+
+static struct dm_split_name *_get_split_name(const char *uuid, const char *name)
+{
+	struct dm_split_name *split_name;
+
+	if (!(split_name = dm_malloc(sizeof(struct dm_split_name))))
+		return NULL;
+
+	split_name->subsystem = _extract_uuid_prefix(uuid);
+
+	if (!(split_name->vg = dm_strdup(name)))
+		return split_name;
+
+	if (!strcmp(split_name->subsystem, "LVM"))
+		dm_split_lvm_name(NULL, NULL, &split_name->vg,
+				&split_name->lv, &split_name->lv_layer);
+	else
+		split_name->vg = split_name->lv = split_name->lv_layer = (char *) "";
+
+	return split_name;
+}
+
+static void _destroy_split_name(struct dm_split_name *split_name)
+{
+	if (*split_name->subsystem)
+		dm_free(split_name->subsystem);
+
+	/* vg, lv and lv_layer is under one allocated block of memory
+	 * starting at vg pointer and separated by \0 each, so by
+	 * freeing vg, we free memory for lv and lv_layer as well */
+	if (*split_name->vg)
+		dm_free(split_name->vg);
+
+	dm_free(split_name);
+}
+
 static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 {
 	struct dmsetup_report_obj obj;
@@ -307,6 +363,7 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 	obj.task = dmt;
 	obj.info = info;
 	obj.deps_task = NULL;
+	obj.split_name = NULL;
 
 	if (_report_type & DR_TREE)
 		obj.tree_node = dm_tree_find_node(_dtree, info->major, info->minor);
@@ -314,6 +371,9 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 	if (_report_type & DR_DEPS)
 		obj.deps_task = _get_deps_task(info->major, info->minor);
 
+	if (_report_type & DR_NAME)
+		obj.split_name = _get_split_name(dm_task_get_uuid(dmt), dm_task_get_name(dmt));
+
 	if (!dm_report_object(_report, &obj))
 		goto out;
 
@@ -322,6 +382,8 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
       out:
 	if (obj.deps_task)
 		dm_task_destroy(obj.deps_task);
+	if (obj.split_name)
+		_destroy_split_name(obj.split_name);
 	return r;
 }
 
@@ -1899,6 +1961,41 @@ static int _dm_deps_disp(struct dm_report *rh, struct dm_pool *mem,
 	return 0;
 }
 
+static int _dm_subsystem_disp(struct dm_report *rh,
+			 struct dm_pool *mem __attribute((unused)),
+			 struct dm_report_field *field, const void *data,
+			 void *private __attribute((unused)))
+{
+	return dm_report_field_string(rh, field, (const char **) data);
+}
+
+static int _dm_vg_name_disp(struct dm_report *rh,
+					struct dm_pool *mem __attribute((unused)),
+					struct dm_report_field *field, const void *data,
+					void *private __attribute((unused)))
+{
+
+	return dm_report_field_string(rh, field, (const char **) data);
+}
+
+static int _dm_lv_name_disp(struct dm_report *rh,
+					struct dm_pool *mem __attribute((unused)),
+					struct dm_report_field *field, const void *data,
+					void *private __attribute((unused)))
+
+{
+	return dm_report_field_string(rh, field, (const char **) data);
+}
+
+static int _dm_lv_layer_name_disp(struct dm_report *rh,
+					struct dm_pool *mem __attribute((unused)),
+					struct dm_report_field *field, const void *data,
+					void *private __attribute((unused)))
+
+{
+	return dm_report_field_string(rh, field, (const char **) data);
+}
+
 static void *_task_get_obj(void *obj)
 {
 	return ((struct dmsetup_report_obj *)obj)->task;
@@ -1919,11 +2016,17 @@ static void *_tree_get_obj(void *obj)
 	return ((struct dmsetup_report_obj *)obj)->tree_node;
 }
 
+static void *_split_name_get_obj(void *obj)
+{
+	return ((struct dmsetup_report_obj *)obj)->split_name;
+}
+
 static const struct dm_report_object_type _report_types[] = {
 	{ DR_TASK, "Mapped Device Name", "", _task_get_obj },
 	{ DR_INFO, "Mapped Device Information", "", _info_get_obj },
 	{ DR_DEPS, "Mapped Device Relationship Information", "", _deps_get_obj },
 	{ DR_TREE, "Mapped Device Relationship Information", "", _tree_get_obj },
+	{ DR_NAME, "Mapped Device LVM Name", "", _split_name_get_obj },
 	{ 0, "", "", NULL },
 };
 
@@ -1960,6 +2063,12 @@ FIELD_F(DEPS, STR, "DevNos", 6, dm_deps, "devnos_used", "List of device numbers
 FIELD_F(TREE, NUM, "#Refs", 5, dm_tree_parents_count, "device_ref_count", "Number of mapped devices referencing this one.")
 FIELD_F(TREE, STR, "RefNames", 8, dm_tree_parents_names, "names_using_dev", "List of names of mapped devices using this one.")
 FIELD_F(TREE, STR, "RefDevNos", 9, dm_tree_parents_devs, "devnos_using_dev", "List of device numbers of mapped devices using this one.")
+
+FIELD_O(NAME, dm_split_name, STR, "Subsystem", subsystem, 9, dm_subsystem, "subsystem", "DM subsystem.")
+FIELD_O(NAME, dm_split_name, STR, "VGName", vg, 6, dm_vg_name, "vg_name", "LVM volume group name.")
+FIELD_O(NAME, dm_split_name, STR, "LVName", lv, 6, dm_lv_name, "lv_name", "LVM logical volume name.")
+FIELD_O(NAME, dm_split_name, STR, "LVLayer", lv_layer, 7, dm_lv_layer_name, "lv_layer", "LVM layer.")
+
 {0, 0, 0, 0, "", "", NULL, NULL},
 /* *INDENT-ON* */
 };


