From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 19 Dec 2008 15:23:04 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20081219152304.12928.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-12-19 15:23:03

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Fail add tree node when requested major/minor is used.
	
	Check for major/minor collision is added in _add_dev_to_dtree()
	where we already read info by uuid,
	so in the case of requesting major/minor it queries device-mapper
	by major/minor for device availability.
	
	Fixes https://bugzilla.redhat.com/show_bug.cgi?id=204992

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1011&r2=1.1012
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.143&r2=1.144

--- LVM2/WHATS_NEW	2008/12/19 14:43:02	1.1011
+++ LVM2/WHATS_NEW	2008/12/19 15:23:03	1.1012
@@ -1,5 +1,6 @@
 Version 2.02.44 - 
 ====================================
+  Check if requested major/minor pair is already used.
   Fix incorrect return value in help function.
   Fix vgrename using UUID in case there are VGs with the same name.
   Fix segfault when invalid field given in reporting commands.
--- LVM2/lib/activate/dev_manager.c	2008/12/19 14:22:48	1.143
+++ LVM2/lib/activate/dev_manager.c	2008/12/19 15:23:03	1.144
@@ -93,7 +93,8 @@
  * Low level device-layer operations.
  */
 static struct dm_task *_setup_task(const char *name, const char *uuid,
-				   uint32_t *event_nr, int task)
+				   uint32_t *event_nr, int task,
+				   uint32_t major, uint32_t minor)
 {
 	struct dm_task *dmt;
 
@@ -109,12 +110,17 @@
 	if (event_nr)
 		dm_task_set_event_nr(dmt, *event_nr);
 
+	if (major) {
+		dm_task_set_major(dmt, major);
+		dm_task_set_minor(dmt, minor);
+	}
+
 	return dmt;
 }
 
 static int _info_run(const char *name, const char *dlid, struct dm_info *info,
 		     uint32_t *read_ahead, int mknodes, int with_open_count,
-		     int with_read_ahead)
+		     int with_read_ahead, uint32_t major, uint32_t minor)
 {
 	int r = 0;
 	struct dm_task *dmt;
@@ -122,7 +128,7 @@
 
 	dmtask = mknodes ? DM_DEVICE_MKNODES : DM_DEVICE_INFO;
 
-	if (!(dmt = _setup_task(name, dlid, 0, dmtask)))
+	if (!(dmt = _setup_task(name, dlid, 0, dmtask, major, minor)))
 		return_0;
 
 	if (!with_open_count)
@@ -206,23 +212,28 @@
 {
 	if (!mknodes && dlid && *dlid) {
 		if (_info_run(NULL, dlid, info, read_ahead, 0, with_open_count,
-			      with_read_ahead) &&
+			      with_read_ahead, 0, 0) &&
 	    	    info->exists)
 			return 1;
 		else if (_info_run(NULL, dlid + sizeof(UUID_PREFIX) - 1, info,
 				   read_ahead, 0, with_open_count,
-				   with_read_ahead) &&
+				   with_read_ahead, 0, 0) &&
 			 info->exists)
 			return 1;
 	}
 
 	if (name)
 		return _info_run(name, NULL, info, read_ahead, mknodes,
-				 with_open_count, with_read_ahead);
+				 with_open_count, with_read_ahead, 0, 0);
 
 	return 0;
 }
 
+static int _info_by_dev(uint32_t major, uint32_t minor, struct dm_info *info)
+{
+	return _info_run(NULL, NULL, info, NULL, 0, 0, 0, major, minor);
+}
+
 int dev_manager_info(struct dm_pool *mem, const char *name,
 		     const struct logical_volume *lv, int with_mknodes,
 		     int with_open_count, int with_read_ahead,
@@ -252,7 +263,7 @@
 	char *type = NULL;
 	char *params = NULL;
 
-	if (!(dmt = _setup_task(name, uuid, 0, DM_DEVICE_STATUS)))
+	if (!(dmt = _setup_task(name, uuid, 0, DM_DEVICE_STATUS, 0, 0)))
 		return_0;
 
 	if (!dm_task_no_open_count(dmt))
@@ -339,7 +350,7 @@
 	*percent = -1;
 
 	if (!(dmt = _setup_task(name, dlid, event_nr,
-				wait ? DM_DEVICE_WAITEVENT : DM_DEVICE_STATUS)))
+				wait ? DM_DEVICE_WAITEVENT : DM_DEVICE_STATUS, 0, 0)))
 		return_0;
 
 	if (!dm_task_no_open_count(dmt))
@@ -610,7 +621,7 @@
 			       struct logical_volume *lv, const char *layer)
 {
 	char *dlid, *name;
-	struct dm_info info;
+	struct dm_info info, info2;
 
 	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
@@ -624,6 +635,27 @@
 		return 0;
 	}
 
+	/*
+	 * For top level volumes verify that existing device match
+	 * requested major/minor and that major/minor pair is available for use
+	 */
+	if (!layer && lv->major != -1 && lv->minor != -1) {
+		if (info.exists && (info.major != lv->major || info.minor != lv->minor)) {
+			log_error("Volume %s (%" PRIu32 ":%" PRIu32")"
+				  " differs from already active device "
+				  "(%" PRIu32 ":%" PRIu32")",
+				  lv->name, lv->major, lv->minor, info.major, info.minor);
+			return 0;
+		}
+		if (!info.exists && _info_by_dev(lv->major, lv->minor, &info2) &&
+		    info2.exists) {
+			log_error("The requested major:minor pair "
+				  "(%" PRIu32 ":%" PRIu32") is already used",
+				  lv->major, lv->minor);
+			return 0;
+		}
+	}
+
 	if (info.exists && !dm_tree_add_dev(dtree, info.major, info.minor)) {
 		log_error("Failed to add device (%" PRIu32 ":%" PRIu32") to dtree",
 			  info.major, info.minor);


