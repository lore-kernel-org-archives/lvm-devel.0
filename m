From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Jun 2009 18:35:39 -0000
Subject: LVM2 ./WHATS_NEW_DM tools/dmsetup.c
Message-ID: <20090603183539.20648.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-06-03 18:35:39

Modified files:
	.              : WHATS_NEW_DM 
	tools          : dmsetup.c 

Log message:
	Add subsystem, vg_name, lv_name, lv_layer fields to dmsetup reports.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.270&r2=1.271
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.114&r2=1.115

--- LVM2/WHATS_NEW_DM	2009/06/03 11:40:23	1.270
+++ LVM2/WHATS_NEW_DM	2009/06/03 18:35:39	1.271
@@ -1,5 +1,6 @@
 Version 1.02.33 - 
 ===============================
+  Add subsystem, vg_name, lv_name, lv_layer fields to dmsetup reports.
   Make mempool optional in dm_split_lvm_name().
 
 Version 1.02.32 - 21st May 2009
--- LVM2/tools/dmsetup.c	2009/04/24 11:30:49	1.114
+++ LVM2/tools/dmsetup.c	2009/06/03 18:35:39	1.115
@@ -141,7 +141,8 @@
 	DR_TASK = 1,
 	DR_INFO = 2,
 	DR_DEPS = 4,
-	DR_TREE = 8	/* Complete dependency tree required */
+	DR_TREE = 8,	/* Complete dependency tree required */
+	DR_NAME = 16
 } report_type_t;
 
 static int _switches[NUM_SWITCHES];
@@ -256,11 +257,19 @@
 	return r;
 }
 
+struct dm_split_name {
+        char *subsystem;
+        char *vg_name;
+        char *lv_name;
+        char *lv_layer;
+};
+
 struct dmsetup_report_obj {
 	struct dm_task *task;
 	struct dm_info *info;
 	struct dm_task *deps_task;
 	struct dm_tree_node *tree_node;
+	struct dm_split_name *split_name;
 };
 
 static struct dm_task *_get_deps_task(int major, int minor)
@@ -294,6 +303,64 @@
 	return NULL;
 }
 
+static char *_extract_uuid_prefix(const char *uuid)
+{
+	char *ptr = NULL;
+	char *uuid_prefix = NULL;
+	size_t len;
+
+	if (uuid)
+		ptr = strchr(uuid, '-');
+
+	len = ptr ? ptr - uuid : 0;
+	if (!(uuid_prefix = dm_malloc(len + 1))) {
+		log_error("Failed to allocate memory to extract uuid prefix.");
+		return NULL;
+	}
+
+	memcpy(uuid_prefix, uuid, len);
+	uuid_prefix[len] = '\0';
+
+	return uuid_prefix;
+}
+
+static struct dm_split_name *_get_split_name(const char *uuid, const char *name)
+{
+	struct dm_split_name *split_name;
+
+	if (!(split_name = dm_malloc(sizeof(*split_name)))) {
+		log_error("Failed to allocate memory to split device name "
+			  "into components.");
+		return NULL;
+	}
+
+	split_name->subsystem = _extract_uuid_prefix(uuid);
+	split_name->vg_name = split_name->lv_name =
+	    split_name->lv_layer = (char *) "";
+
+	if (!strcmp(split_name->subsystem, "LVM") &&
+	    (!(split_name->vg_name = dm_strdup(name)) ||
+	     !dm_split_lvm_name(NULL, NULL, &split_name->vg_name,
+			        &split_name->lv_name, &split_name->lv_layer)))
+		log_error("Failed to allocate memory to split LVM name "
+			  "into components.");
+
+	return split_name;
+}
+
+static void _destroy_split_name(struct dm_split_name *split_name)
+{
+	/*
+	 * lv_name and lv_layer are allocated within the same block
+	 * of memory as vg_name so don't need to be freed separately.
+	 */
+	if (!strcmp(split_name->subsystem, "LVM"))
+		dm_free(split_name->vg_name);
+
+	dm_free(split_name->subsystem);
+	dm_free(split_name);
+}
+
 static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 {
 	struct dmsetup_report_obj obj;
@@ -307,6 +374,7 @@
 	obj.task = dmt;
 	obj.info = info;
 	obj.deps_task = NULL;
+	obj.split_name = NULL;
 
 	if (_report_type & DR_TREE)
 		obj.tree_node = dm_tree_find_node(_dtree, info->major, info->minor);
@@ -314,6 +382,9 @@
 	if (_report_type & DR_DEPS)
 		obj.deps_task = _get_deps_task(info->major, info->minor);
 
+	if (_report_type & DR_NAME)
+		obj.split_name = _get_split_name(dm_task_get_uuid(dmt), dm_task_get_name(dmt));
+
 	if (!dm_report_object(_report, &obj))
 		goto out;
 
@@ -322,6 +393,8 @@
       out:
 	if (obj.deps_task)
 		dm_task_destroy(obj.deps_task);
+	if (obj.split_name)
+		_destroy_split_name(obj.split_name);
 	return r;
 }
 
@@ -1899,6 +1972,41 @@
 	return 0;
 }
 
+static int _dm_subsystem_disp(struct dm_report *rh,
+			       struct dm_pool *mem __attribute((unused)),
+			       struct dm_report_field *field, const void *data,
+			       void *private __attribute((unused)))
+{
+	return dm_report_field_string(rh, field, (const char **) data);
+}
+
+static int _dm_vg_name_disp(struct dm_report *rh,
+			     struct dm_pool *mem __attribute((unused)),
+			     struct dm_report_field *field, const void *data,
+			     void *private __attribute((unused)))
+{
+
+	return dm_report_field_string(rh, field, (const char **) data);
+}
+
+static int _dm_lv_name_disp(struct dm_report *rh,
+			     struct dm_pool *mem __attribute((unused)),
+			     struct dm_report_field *field, const void *data,
+			     void *private __attribute((unused)))
+
+{
+	return dm_report_field_string(rh, field, (const char **) data);
+}
+
+static int _dm_lv_layer_name_disp(struct dm_report *rh,
+				   struct dm_pool *mem __attribute((unused)),
+				   struct dm_report_field *field, const void *data,
+				   void *private __attribute((unused)))
+
+{
+	return dm_report_field_string(rh, field, (const char **) data);
+}
+
 static void *_task_get_obj(void *obj)
 {
 	return ((struct dmsetup_report_obj *)obj)->task;
@@ -1919,11 +2027,17 @@
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
+	{ DR_NAME, "Mapped Device Name Components", "", _split_name_get_obj },
 	{ 0, "", "", NULL },
 };
 
@@ -1960,6 +2074,12 @@
 FIELD_F(TREE, NUM, "#Refs", 5, dm_tree_parents_count, "device_ref_count", "Number of mapped devices referencing this one.")
 FIELD_F(TREE, STR, "RefNames", 8, dm_tree_parents_names, "names_using_dev", "List of names of mapped devices using this one.")
 FIELD_F(TREE, STR, "RefDevNos", 9, dm_tree_parents_devs, "devnos_using_dev", "List of device numbers of mapped devices using this one.")
+
+FIELD_O(NAME, dm_split_name, STR, "Subsys", subsystem, 6, dm_subsystem, "subsystem", "Userspace subsystem responsible for this device.")
+FIELD_O(NAME, dm_split_name, STR, "VG", vg_name, 4, dm_vg_name, "vg_name", "LVM Volume Group name.")
+FIELD_O(NAME, dm_split_name, STR, "LV", lv_name, 4, dm_lv_name, "lv_name", "LVM Logical Volume name.")
+FIELD_O(NAME, dm_split_name, STR, "LVLayer", lv_layer, 7, dm_lv_layer_name, "lv_layer", "LVM device layer.")
+
 {0, 0, 0, 0, "", "", NULL, NULL},
 /* *INDENT-ON* */
 };


