From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 08 Apr 2009 14:13:06 +0200
Subject: [PATCH 1/4] Udev integration: add LVM fields support for dmsetup
Message-ID: <49DC94D2.4010903@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi, 

this is the first patch of the whole udev integration patchset.
Udev integration patchset relies on "uevent cookie env var support"
DM patch, see dm-devel list.

This patch adds support for splitting given UUID and LVM name into
its subsystem (the UUID prefix), VG/LV/LV layer constituents. This
way we can import these values in udev rules and use its primary
use is to create the directories with symlinks under /dev dir.

Peter


diff --git a/libdm/.exported_symbols b/libdm/.exported_symbols
index a6e04f8..9f7e4af 100644
--- a/libdm/.exported_symbols
+++ b/libdm/.exported_symbols
@@ -116,6 +116,7 @@ dm_hash_get_first
 dm_hash_get_next
 dm_set_selinux_context
 dm_task_set_geometry
+dm_split_lvm_name_mem
 dm_split_lvm_name
 dm_split_words
 dm_snprintf
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 93aecbb..c1c6218 100644
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
@@ -819,6 +826,8 @@ int dm_set_selinux_context(const char *path, mode_t mode);
  * Break up the name of a mapped device into its constituent
  * Volume Group, Logical Volume and Layer (if present).
  */
+void dm_split_lvm_name_mem(char *mem, char **vgname, char **lvname, char **layer);
+
 int dm_split_lvm_name(struct dm_pool *mem, const char *dmname,
 		      char **vgname, char **lvname, char **layer);
 
diff --git a/libdm/libdm-string.c b/libdm/libdm-string.c
index 0e41f9d..ef06ea6 100644
--- a/libdm/libdm-string.c
+++ b/libdm/libdm-string.c
@@ -90,13 +90,19 @@ static char *_unquote(char *component)
 	return r;
 }
 
+void dm_split_lvm_name_mem(char *mem, char **vgname, char **lvname, char **layer)
+{
+	*vgname = mem;
+	_unquote(*layer = _unquote(*lvname = _unquote(*vgname)));
+}
+
 int dm_split_lvm_name(struct dm_pool *mem, const char *dmname,
 		      char **vgname, char **lvname, char **layer)
 {
 	if (!(*vgname = dm_pool_strdup(mem, dmname)))
 		return 0;
 
-	_unquote(*layer = _unquote(*lvname = _unquote(*vgname)));
+	dm_split_lvm_name_mem(*vgname, vgname, lvname, layer);
 
 	return 1;
 }
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 0d6a371..9a42c81 100644
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
@@ -294,6 +296,55 @@ static struct dm_task *_get_deps_task(int major, int minor)
 	return NULL;
 }
 
+static char *_get_uuid_prefix(const char *uuid)
+{
+	char *ptr;
+	int len;
+	char *str = NULL;
+
+	ptr = strchr(uuid, '-');
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
+	char *name_dup;
+
+	name_dup = dm_strdup(name);
+
+	if (!(split_name = dm_malloc(sizeof(struct dm_split_name))))
+		return NULL;
+
+	split_name->subsystem = _get_uuid_prefix(uuid);
+
+	if (!strcmp(split_name->subsystem, "LVM"))
+		dm_split_lvm_name_mem(name_dup, &split_name->vg, &split_name->lv, &split_name->lv_layer);
+	else
+		split_name->vg = split_name->lv = split_name->lv_layer = "";
+
+	return split_name;
+}
+
+static void _destroy_split_name(struct dm_split_name *split_name)
+{
+	dm_free(split_name->subsystem);
+	/* vg, lv and lv_layer is under one allocated block of memory
+	 * starting at vg pointer and separated by \0 each, so by
+	 * freeing vg, we free memory for lv and lv_layer as well */
+	if (*split_name->vg)
+		dm_free(split_name->vg);
+	dm_free(split_name);
+}
+
 static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 {
 	struct dmsetup_report_obj obj;
@@ -307,6 +358,7 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 	obj.task = dmt;
 	obj.info = info;
 	obj.deps_task = NULL;
+	obj.split_name = NULL;
 
 	if (_report_type & DR_TREE)
 		obj.tree_node = dm_tree_find_node(_dtree, info->major, info->minor);
@@ -314,6 +366,9 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 	if (_report_type & DR_DEPS)
 		obj.deps_task = _get_deps_task(info->major, info->minor);
 
+	if (_report_type & DR_NAME)
+		obj.split_name = _get_split_name(dm_task_get_uuid(dmt), dm_task_get_name(dmt));
+
 	if (!dm_report_object(_report, &obj))
 		goto out;
 
@@ -322,6 +377,8 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
       out:
 	if (obj.deps_task)
 		dm_task_destroy(obj.deps_task);
+	if (obj.split_name)
+		_destroy_split_name(obj.split_name);
 	return r;
 }
 
@@ -1899,6 +1956,41 @@ static int _dm_deps_disp(struct dm_report *rh, struct dm_pool *mem,
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
@@ -1919,11 +2011,17 @@ static void *_tree_get_obj(void *obj)
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
+	{ DR_NAME, "Mapped Device LVM Fields", "", _split_name_get_obj },
 	{ 0, "", "", NULL },
 };
 
@@ -1960,6 +2058,12 @@ FIELD_F(DEPS, STR, "DevNos", 6, dm_deps, "devnos_used", "List of device numbers
 FIELD_F(TREE, NUM, "#Refs", 5, dm_tree_parents_count, "device_ref_count", "Number of mapped devices referencing this one.")
 FIELD_F(TREE, STR, "RefNames", 8, dm_tree_parents_names, "names_using_dev", "List of names of mapped devices using this one.")
 FIELD_F(TREE, STR, "RefDevNos", 9, dm_tree_parents_devs, "devnos_using_dev", "List of device numbers of mapped devices using this one.")
+
+FIELD_O(NAME, dm_split_name, STR, "Subsystem", subsystem, 10, dm_subsystem, "subsystem", "DM subsystem.")
+FIELD_O(NAME, dm_split_name, STR, "VGName", vg, 10, dm_vg_name, "vg_name", "LVM volume group name.")
+FIELD_O(NAME, dm_split_name, STR, "LVName", lv, 10, dm_lv_name, "lv_name", "LVM logical volume name.")
+FIELD_O(NAME, dm_split_name, STR, "LVLayer", lv_layer, 10, dm_lv_layer_name, "lv_layer", "LVM layer.")
+
 {0, 0, 0, 0, "", "", NULL, NULL},
 /* *INDENT-ON* */
 };


