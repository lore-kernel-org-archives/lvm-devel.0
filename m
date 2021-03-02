From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Mar 2021 21:58:40 +0000 (GMT)
Subject: main - cleanup: free already checks for NULL
Message-ID: <20210302215840.7FBC03834402@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=eb3dcc72eb0e1f3922dafcc4d018db70aabc3bc9
Commit:        eb3dcc72eb0e1f3922dafcc4d018db70aabc3bc9
Parent:        0b7a4503e51d29454bdb8852dfd2a39276f828af
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 27 14:14:25 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 2 22:57:35 2021 +0100

cleanup: free already checks for NULL

---
 daemons/cmirrord/functions.c        |  3 +--
 daemons/lvmlockd/lvmlockd-dlm.c     |  3 +--
 daemons/lvmlockd/lvmlockd-sanlock.c |  6 ++---
 lib/cache/lvmcache.c                |  3 +--
 lib/device/device_id.c              | 54 +++++++++++++------------------------
 lib/format_text/format-text.c       |  7 ++---
 tools/pvchange.c                    |  3 +--
 7 files changed, 26 insertions(+), 53 deletions(-)

diff --git a/daemons/cmirrord/functions.c b/daemons/cmirrord/functions.c
index f10a8d5bb..23a17015a 100644
--- a/daemons/cmirrord/functions.c
+++ b/daemons/cmirrord/functions.c
@@ -658,8 +658,7 @@ static int clog_dtr(struct dm_ulog_request *rq)
 	if (lc->disk_fd != -1 && close(lc->disk_fd))
 		LOG_ERROR("Failed to close disk log: %s",
 			  strerror(errno));
-	if (lc->disk_buffer)
-		free(lc->disk_buffer);
+	free(lc->disk_buffer);
 	free(lc->clean_bits);
 	free(lc->sync_bits);
 	free(lc);
diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index 7915cc008..dc665e0a4 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -327,8 +327,7 @@ int lm_rem_resource_dlm(struct lockspace *ls, struct resource *r)
 		log_error("S %s R %s rem_resource_dlm unlock error %d", ls->name, r->name, rv);
 	}
  out:
-	if (rdd->vb)
-		free(rdd->vb);
+	free(rdd->vb);
 
 	memset(rdd, 0, sizeof(struct rd_dlm));
 	r->lm_init = 0;
diff --git a/daemons/lvmlockd/lvmlockd-sanlock.c b/daemons/lvmlockd/lvmlockd-sanlock.c
index 4bc6402cf..36d57767f 100644
--- a/daemons/lvmlockd/lvmlockd-sanlock.c
+++ b/daemons/lvmlockd/lvmlockd-sanlock.c
@@ -1503,8 +1503,7 @@ out:
 fail:
 	if (lms && lms->sock)
 		close(lms->sock);
-	if (lms)
-		free(lms);
+	free(lms);
 	return ret;
 }
 
@@ -1634,8 +1633,7 @@ int lm_rem_resource_sanlock(struct lockspace *ls, struct resource *r)
 
 	/* FIXME: assert r->mode == UN or unlock if it's not? */
 
-	if (rds->vb)
-		free(rds->vb);
+	free(rds->vb);
 
 	memset(rds, 0, sizeof(struct rd_sanlock));
 	r->lm_init = 0;
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 172c10f30..04f6fe0a5 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1406,8 +1406,7 @@ static void _free_vginfo(struct lvmcache_vginfo *vginfo)
 	free(vginfo->vgname);
 	free(vginfo->system_id);
 	free(vginfo->creation_host);
-	if (vginfo->lock_type)
-		free(vginfo->lock_type);
+	free(vginfo->lock_type);
 	free(vginfo);
 }
 
diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 698942bb1..4b7214b60 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -149,12 +149,9 @@ static int _searched_devnames_exists(struct cmd_context *cmd)
 
 void free_du(struct dev_use *du)
 {
-	if (du->idname)
-		free(du->idname);
-	if (du->devname)
-		free(du->devname);
-	if (du->pvid)
-		free(du->pvid);
+	free(du->idname);
+	free(du->devname);
+	free(du->pvid);
 	free(du);
 }
 
@@ -170,8 +167,7 @@ void free_dus(struct dm_list *dus)
 
 void free_did(struct dev_id *id)
 {
-	if (id->idname)
-		free(id->idname);
+	free(id->idname);
 	free(id);
 }
 
@@ -1213,8 +1209,7 @@ id_done:
 		du_devname->devname = NULL;
 	}
 
-	if (check_idname)
-		free((void *)check_idname);
+	free((void *)check_idname);
 
 	if (!update_du) {
 		log_debug("Adding new entry to devices file for %s PVID %s %s %s.",
@@ -1227,12 +1222,9 @@ id_done:
 			  dev_name(dev), update_matching_kind, update_matching_name);
 	}
 
-	if (du->idname)
-		free(du->idname);
-	if (du->devname)
-		free(du->devname);
-	if (du->pvid)
-		free(du->pvid);
+	free(du->idname);
+	free(du->devname);
+	free(du->pvid);
 
 	du->idtype = id->idtype;
 	du->idname = strdup(id->idname);
@@ -1604,8 +1596,7 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 					 dev_name(dev), dev->pvid, du->pvid ?: "none");
 				if (!(tmpdup = strdup(dev->pvid)))
 					continue;
-				if (du->pvid)
-					free(du->pvid);
+				free(du->pvid);
 				du->pvid = tmpdup;
 				update_file = 1;
 				*device_ids_invalid = 1;
@@ -1614,8 +1605,7 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 			if (du->pvid && (du->pvid[0] != '.')) {
 				log_warn("Device %s has no PVID (devices file %s)",
 					 dev_name(dev), du->pvid);
-				if (du->pvid)
-					free(du->pvid);
+				free(du->pvid);
 				du->pvid = NULL;
 				update_file = 1;
 				*device_ids_invalid = 1;
@@ -1627,8 +1617,7 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 				 dev_name(du->dev), du->devname ?: "none");
 			if (!(tmpdup = strdup(dev_name(du->dev))))
 				continue;
-			if (du->devname)
-				free(du->devname);
+			free(du->devname);
 			du->devname = tmpdup;
 			update_file = 1;
 			*device_ids_invalid = 1;
@@ -1686,8 +1675,7 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 					 devname, du->devname ?: "none");
 				if (!(tmpdup = strdup(devname)))
 					continue;
-				if (du->devname)
-					free(du->devname);
+				free(du->devname);
 				du->devname = tmpdup;
 				update_file = 1;
 				*device_ids_invalid = 1;
@@ -2029,24 +2017,18 @@ void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_l
 		dup_devname3 = strdup(devname);
 		id = zalloc(sizeof(struct dev_id));
 		if (!dup_devname1 || !dup_devname2 || !dup_devname3 || !id) {
-			if (dup_devname1)
-				free(dup_devname1);
-			if (dup_devname2)
-				free(dup_devname2);
-			if (dup_devname3)
-				free(dup_devname3);
-			if (id)
-				free(id);
+			free(dup_devname1);
+			free(dup_devname2);
+			free(dup_devname3);
+			free(id);
 			stack;
 			continue;
 		}
 
 		log_warn("Devices file PVID %s updating IDNAME to %s.", dev->pvid, devname);
 
-		if (du->idname)
-			free(du->idname);
-		if (du->devname)
-			free(du->devname);
+		free(du->idname);
+		free(du->devname);
 		free_dids(&dev->ids);
 
 		du->idname = dup_devname1;
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index e1142c07e..e8533d5dc 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -63,8 +63,7 @@ void free_text_fidtc(struct volume_group *vg)
 
 	fidtc->preserve = 0;
 
-	if (fidtc->write_buf)
-		free(fidtc->write_buf);
+	free(fidtc->write_buf);
 	fidtc->write_buf = NULL;
 	fidtc->write_buf_size = 0;
 	fidtc->new_metadata_size = 0;
@@ -2018,9 +2017,7 @@ static void _text_destroy(struct format_type *fmt)
 	if (fmt->orphan_vg)
 		free_orphan_vg(fmt->orphan_vg);
 
-	if (fmt->private)
-		free(fmt->private);
-
+	free(fmt->private);
 	free(fmt);
 }
 
diff --git a/tools/pvchange.c b/tools/pvchange.c
index 5e457a60b..b0bc83ed5 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -189,8 +189,7 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 	}
 
 	if (du) {
-		if (du->pvid)
-			free(du->pvid);
+		free(du->pvid);
 		if (!(du->pvid = strndup((char *)&pv->id, ID_LEN)))
 			log_error("Failed to set pvid for devices file.");
 		if (!device_ids_write(cmd))


