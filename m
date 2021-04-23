From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:05:44 +0000 (GMT)
Subject: main - cov: add checks to prevent NULL dereference
Message-ID: <20210423210544.C5EBF394480D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d7237ca63a1497fc06a975639331ea7869b02c1a
Commit:        d7237ca63a1497fc06a975639331ea7869b02c1a
Parent:        3d96203e21be7fcea783afaa94e10295696a4533
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 22 15:08:04 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 23:00:55 2021 +0200

cov: add checks to prevent NULL dereference

---
 lib/device/device_id.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 1a9705f04..9fd22692c 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -523,7 +523,7 @@ int device_ids_read(struct cmd_context *cmd)
 			_copy_idline_str(line, _devices_file_systemid, sizeof(_devices_file_systemid));
 			log_debug("read devices file systemid %s", _devices_file_systemid);
 			if ((!cmd->system_id && _devices_file_systemid[0]) ||
-			    strcmp(cmd->system_id, _devices_file_systemid)) {
+			    (cmd->system_id && strcmp(cmd->system_id, _devices_file_systemid))) {
 				log_warn("WARNING: ignoring devices file with wrong system id %s vs local %s.",
 					  _devices_file_systemid[0] ? _devices_file_systemid : "none", cmd->system_id ?: "none");
 				free_dus(&cmd->use_devices);
@@ -1077,7 +1077,8 @@ id_done:
 		if (du_devid && (du_devid != du_dev)) {
 			log_warn("WARNING: device %s (%s) and %s (%s) have duplicate device ID.",
 				 dev_name(dev), id->idname,
-				 du_pvid->dev ? dev_name(du_pvid->dev) : "none", du_pvid->idname);
+				 (du_pvid && du_pvid->dev) ? dev_name(du_pvid->dev) : "none",
+				 du_pvid ? du_pvid->idname : "");
 		}
 
 		if (du_pvid && (du_pvid != du_dev)) {


