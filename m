From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Feb 2012 11:13:45 -0000
Subject: LVM2 tools/dmsetup.c ./WHATS_NEW_DM
Message-ID: <20120213111345.15070.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-13 11:13:44

Modified files:
	tools          : dmsetup.c 
	.              : WHATS_NEW_DM 

Log message:
	Add few missing allocation failures tests

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.174&r2=1.175
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.552&r2=1.553

--- LVM2/tools/dmsetup.c	2012/02/08 11:05:05	1.174
+++ LVM2/tools/dmsetup.c	2012/02/13 11:13:44	1.175
@@ -422,16 +422,24 @@
 	obj.split_name = NULL;
 
 	if (_report_type & DR_TREE)
-		obj.tree_node = dm_tree_find_node(_dtree, info->major, info->minor);
+		if (!(obj.tree_node = dm_tree_find_node(_dtree, info->major, info->minor))) {
+			log_error("Cannot find node %d:%d.", info->major, info->minor);
+			goto out;
+		}
 
 	if (_report_type & DR_DEPS)
-		obj.deps_task = _get_deps_task(info->major, info->minor);
+		if (!(obj.deps_task = _get_deps_task(info->major, info->minor))) {
+			log_error("Cannot get deps for %d:%d.", info->major, info->minor);
+			goto out;
+		}
 
 	if (_report_type & DR_NAME)
-		obj.split_name = _get_split_name(dm_task_get_uuid(dmt), dm_task_get_name(dmt), '-');
+		if (!(obj.split_name = _get_split_name(dm_task_get_uuid(dmt),
+						       dm_task_get_name(dmt), '-')))
+			goto_out;
 
 	if (!dm_report_object(_report, &obj))
-		goto out;
+		goto_out;
 
 	r = 1;
 
@@ -865,8 +873,9 @@
 	obj.info = NULL;
 	obj.deps_task = NULL;
 	obj.tree_node = NULL;
-	obj.split_name = _get_split_name((argc == 3) ? argv[2] : "LVM",
-					 argv[1], '\0');
+	if (!(obj.split_name = _get_split_name((argc == 3) ? argv[2] : "LVM",
+					       argv[1], '\0')))
+                return_0;
 
 	r = dm_report_object(_report, &obj);
 	_destroy_split_name(obj.split_name);
@@ -3234,9 +3243,9 @@
 		return 0;
 	}
 
-	/* FIXME Missing free */
 	_table = dm_malloc(LOOP_TABLE_SIZE);
-	if (!_loop_table(_table, (size_t) LOOP_TABLE_SIZE, loop_file, device_name, offset)) {
+	if (!_table ||
+	    !_loop_table(_table, (size_t) LOOP_TABLE_SIZE, loop_file, device_name, offset)) {
 		fprintf(stderr, "Could not build device-mapper table for %s\n", (*argv)[0]);
 		dm_free(device_name);
 		return 0;
@@ -3355,7 +3364,10 @@
 	memset(&_int_args, 0, sizeof(_int_args));
 	_read_ahead_flags = 0;
 
-	namebase = strdup((*argv)[0]);
+	if (!(namebase = strdup((*argv)[0]))) {
+		fprintf(stderr, "Failed to duplicate name.\n");
+		return 0;
+	}
 	base = basename(namebase);
 
 	if (!strcmp(base, "devmap_name")) {
@@ -3646,5 +3658,7 @@
 	if (_dtree)
 		dm_tree_free(_dtree);
 
+	dm_free(_table);
+
 	return r;
 }
--- LVM2/WHATS_NEW_DM	2012/02/13 10:49:28	1.552
+++ LVM2/WHATS_NEW_DM	2012/02/13 11:13:44	1.553
@@ -1,5 +1,6 @@
 Version 1.02.71 - 
 ====================================
+  Add few missing allocation failures tests in dmsetup.
   Fix potential risk of writing in front of buffer in _sysfs_get_dm_name().
 
 Version 1.02.70 - 12th February 2012


