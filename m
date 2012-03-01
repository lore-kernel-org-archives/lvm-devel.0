From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2012 21:56:45 -0000
Subject: LVM2 ./WHATS_NEW_DM tools/dmsetup.c
Message-ID: <20120301215645.19897.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-01 21:56:44

Modified files:
	.              : WHATS_NEW_DM 
	tools          : dmsetup.c 

Log message:
	Add some more pointer validation
	
	Ensure _display_name() and _add_dep() would not deref NULL names.
	Switch to use internal dm_basename().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.578&r2=1.579
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.184&r2=1.185

--- LVM2/WHATS_NEW_DM	2012/03/01 10:07:38	1.578
+++ LVM2/WHATS_NEW_DM	2012/03/01 21:56:44	1.579
@@ -1,5 +1,6 @@
 Version 1.02.73 - 
 ====================================
+  Add few pointer validation in dmsetup.
   Support dm_task_get_driver_version() query without version string.
   Log failure of pthread_join when cleaning unused threads in dmeventd.
   Fix empty string warning logic in _find_config_str. (1.02.68)
--- LVM2/tools/dmsetup.c	2012/03/01 21:50:35	1.184
+++ LVM2/tools/dmsetup.c	2012/03/01 21:56:44	1.185
@@ -1869,6 +1869,9 @@
 {
 	char dev_name[PATH_MAX];
 
+	if (!names)
+		return 1;
+
 	if ((_dev_name_type == DN_BLK || _dev_name_type == DN_MAP) &&
 	    dm_device_get_name((int) MAJOR(names->dev), (int) MINOR(names->dev),
 			       _dev_name_type == DN_BLK, dev_name, PATH_MAX))
@@ -2203,7 +2206,8 @@
 
 static int _add_dep(CMD_ARGS)
 {
-	if (!dm_tree_add_dev(_dtree, (unsigned) MAJOR(names->dev), (unsigned) MINOR(names->dev)))
+	if (names &&
+	    !dm_tree_add_dev(_dtree, (unsigned) MAJOR(names->dev), (unsigned) MINOR(names->dev)))
 		return 0;
 
 	return 1;
@@ -3417,7 +3421,8 @@
 
 static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 {
-	char *base, *namebase, *s;
+	const char *base;
+	char *namebase, *s;
 	static int ind;
 	int c, r;
 
@@ -3482,7 +3487,7 @@
 		fprintf(stderr, "Failed to duplicate name.\n");
 		return 0;
 	}
-	base = basename(namebase);
+	base = dm_basename(namebase);
 
 	if (!strcmp(base, "devmap_name")) {
 		free(namebase);


