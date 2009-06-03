From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Jun 2009 20:44:53 -0000
Subject: LVM2 ./WHATS_NEW_DM tools/dmsetup.c
Message-ID: <20090603204453.19665.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-06-03 20:44:50

Modified files:
	.              : WHATS_NEW_DM 
	tools          : dmsetup.c 

Log message:
	Add splitname.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.271&r2=1.272
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.115&r2=1.116

--- LVM2/WHATS_NEW_DM	2009/06/03 18:35:39	1.271
+++ LVM2/WHATS_NEW_DM	2009/06/03 20:44:42	1.272
@@ -1,5 +1,6 @@
 Version 1.02.33 - 
 ===============================
+  Add splitname command to dmsetup.
   Add subsystem, vg_name, lv_name, lv_layer fields to dmsetup reports.
   Make mempool optional in dm_split_lvm_name().
 
--- LVM2/tools/dmsetup.c	2009/06/03 18:35:39	1.115
+++ LVM2/tools/dmsetup.c	2009/06/03 20:44:49	1.116
@@ -303,14 +303,14 @@
 	return NULL;
 }
 
-static char *_extract_uuid_prefix(const char *uuid)
+static char *_extract_uuid_prefix(const char *uuid, const int separator)
 {
 	char *ptr = NULL;
 	char *uuid_prefix = NULL;
 	size_t len;
 
 	if (uuid)
-		ptr = strchr(uuid, '-');
+		ptr = strchr(uuid, separator);
 
 	len = ptr ? ptr - uuid : 0;
 	if (!(uuid_prefix = dm_malloc(len + 1))) {
@@ -324,7 +324,8 @@
 	return uuid_prefix;
 }
 
-static struct dm_split_name *_get_split_name(const char *uuid, const char *name)
+static struct dm_split_name *_get_split_name(const char *uuid, const char *name,
+					     int separator)
 {
 	struct dm_split_name *split_name;
 
@@ -334,7 +335,7 @@
 		return NULL;
 	}
 
-	split_name->subsystem = _extract_uuid_prefix(uuid);
+	split_name->subsystem = _extract_uuid_prefix(uuid, separator);
 	split_name->vg_name = split_name->lv_name =
 	    split_name->lv_layer = (char *) "";
 
@@ -383,7 +384,7 @@
 		obj.deps_task = _get_deps_task(info->major, info->minor);
 
 	if (_report_type & DR_NAME)
-		obj.split_name = _get_split_name(dm_task_get_uuid(dmt), dm_task_get_name(dmt));
+		obj.split_name = _get_split_name(dm_task_get_uuid(dmt), dm_task_get_name(dmt), '-');
 
 	if (!dm_report_object(_report, &obj))
 		goto out;
@@ -721,6 +722,24 @@
 	return r;
 }
 
+static int _splitname(int argc, char **argv, void *data __attribute((unused)))
+{
+	struct dmsetup_report_obj obj;
+	int r = 1;
+
+	obj.task = NULL;
+	obj.info = NULL;
+	obj.deps_task = NULL;
+	obj.tree_node = NULL;
+	obj.split_name = _get_split_name((argc == 3) ? argv[2] : "LVM",
+					 argv[1], '\0');
+
+	r = dm_report_object(_report, &obj);
+	_destroy_split_name(obj.split_name);
+
+	return r;
+}
+
 static int _version(int argc __attribute((unused)), char **argv __attribute((unused)), void *data __attribute((unused)))
 {
 	char version[80];
@@ -2090,6 +2109,7 @@
 #undef FIELD_F
 
 static const char *default_report_options = "name,major,minor,attr,open,segments,events,uuid";
+static const char *splitname_report_options = "vg_name,lv_name,lv_layer";
 
 static int _report_init(struct command *c)
 {
@@ -2102,6 +2122,9 @@
 	size_t len = 0;
 	int r = 0;
 
+	if (!strcmp(c->name, "splitname"))
+		options = (char *) splitname_report_options;
+
 	/* emulate old dmsetup behaviour */
 	if (_switches[NOHEADINGS_ARG]) {
 		separator = ":";
@@ -2241,6 +2264,7 @@
 	{"targets", "", 0, 0, _targets},
 	{"version", "", 0, 0, _version},
 	{"setgeometry", "<device> <cyl> <head> <sect> <start>", 5, 5, _setgeometry},
+	{"splitname", "<device> [<subsystem>]", 1, 2, _splitname},
 	{NULL, NULL, 0, 0, NULL}
 };
 
@@ -2858,6 +2882,9 @@
 		goto out;
 	}
 
+	if (!_switches[COLS_ARG] && !strcmp(c->name, "splitname"))
+		_switches[COLS_ARG]++;
+
 	if (_switches[COLS_ARG] && !_report_init(c))
 		goto out;
 


