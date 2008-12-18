From: Milan Broz <mbroz@redhat.com>
Date: Thu, 18 Dec 2008 20:59:47 +0100
Subject: [LVM2 PATCH v2] libdm: Fail to add tree node when requested major/minor is used.
In-Reply-To: <494930F1.1030607@redhat.com>
References: <494930F1.1030607@redhat.com>
Message-ID: <494AABB3.8010300@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fail add tree node when requested major/minor is used.

After discussion with Alasdair I tried another approach,
check is added in _add_dev_to_dtree() where we already read info by uuid,
so in the case of requesting major/minor it queries device-mapper
by major/minor for device availability.

Fixes https://bugzilla.redhat.com/show_bug.cgi?id=204992

Signed-off-by: Milan Broz <mbroz@redhat.com>

---
 lib/activate/dev_manager.c |   51 +++++++++++++++++++++++++++++++++++++--------
 1 file changed, 42 insertions(+), 9 deletions(-)

Index: LVM2/lib/activate/dev_manager.c
===================================================================
--- LVM2.orig/lib/activate/dev_manager.c	2008-12-18 15:42:53.000000000 +0100
+++ LVM2/lib/activate/dev_manager.c	2008-12-18 19:03:45.000000000 +0100
@@ -93,7 +93,8 @@ static int _read_only_lv(struct logical_
  * Low level device-layer operations.
  */
 static struct dm_task *_setup_task(const char *name, const char *uuid,
-				   uint32_t *event_nr, int task)
+				   uint32_t *event_nr, int task,
+				   uint32_t major, uint32_t minor)
 {
 	struct dm_task *dmt;
 
@@ -109,12 +110,17 @@ static struct dm_task *_setup_task(const
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
@@ -122,7 +128,7 @@ static int _info_run(const char *name, c
 
 	dmtask = mknodes ? DM_DEVICE_MKNODES : DM_DEVICE_INFO;
 
-	if (!(dmt = _setup_task(name, dlid, 0, dmtask)))
+	if (!(dmt = _setup_task(name, dlid, 0, dmtask, major, minor)))
 		return_0;
 
 	if (!with_open_count)
@@ -206,23 +212,29 @@ static int _info(const char *name, const
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
 
+static int _info_by_dev(const char *name, uint32_t major, uint32_t minor,
+			struct dm_info *info)
+{
+	return _info_run(name, NULL, info, NULL, 0, 0, 0, major, minor);
+}
+
 int dev_manager_info(struct dm_pool *mem, const char *name,
 		     const struct logical_volume *lv, int with_mknodes,
 		     int with_open_count, int with_read_ahead,
@@ -252,7 +264,7 @@ static int _status_run(const char *name,
 	char *type = NULL;
 	char *params = NULL;
 
-	if (!(dmt = _setup_task(name, uuid, 0, DM_DEVICE_STATUS)))
+	if (!(dmt = _setup_task(name, uuid, 0, DM_DEVICE_STATUS, 0, 0)))
 		return_0;
 
 	if (!dm_task_no_open_count(dmt))
@@ -339,7 +351,7 @@ static int _percent_run(struct dev_manag
 	*percent = -1;
 
 	if (!(dmt = _setup_task(name, dlid, event_nr,
-				wait ? DM_DEVICE_WAITEVENT : DM_DEVICE_STATUS)))
+				wait ? DM_DEVICE_WAITEVENT : DM_DEVICE_STATUS, 0, 0)))
 		return_0;
 
 	if (!dm_task_no_open_count(dmt))
@@ -610,7 +622,7 @@ static int _add_dev_to_dtree(struct dev_
 			       struct logical_volume *lv, const char *layer)
 {
 	char *dlid, *name;
-	struct dm_info info;
+	struct dm_info info, info2;
 
 	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
@@ -624,6 +636,27 @@ static int _add_dev_to_dtree(struct dev_
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
+		if (!info.exists && _info_by_dev(NULL, lv->major, lv->minor, &info2) &&
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



