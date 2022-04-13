From: David Teigland <teigland@sourceware.org>
Date: Wed, 13 Apr 2022 17:21:13 +0000 (GMT)
Subject: main - devices file: remove extraneous unlock in vgchange -u
Message-ID: <20220413172113.047FB3857C50@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bee575d678399a45db09ec8fcba79eae3890ec54
Commit:        bee575d678399a45db09ec8fcba79eae3890ec54
Parent:        d14245c72425b99c3bc33a533da46962d010871a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 13 12:16:57 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 13 12:19:04 2022 -0500

devices file: remove extraneous unlock in vgchange -u

vgchange -u exit path was unlocking the devices file in cases
when it wasn't needed, which produced an warning.
---
 lib/device/device_id.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 6c7136d5f..f1928347c 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -1298,15 +1298,15 @@ void device_id_update_vg_uuid(struct cmd_context *cmd, struct volume_group *vg,
 	int update = 0;
 
 	if (!cmd->enable_devices_file)
-		goto out;
+		return;
 
 	/* Without this setting there is no stacking LVs on PVs. */
 	if (!cmd->scan_lvs)
-		goto out;
+		return;
 
 	/* Check if any devices file entries are stacked on LVs. */
 	if (!_device_ids_use_lvmlv(cmd))
-		goto out;
+		return;
 
 	memcpy(old_vgid, old_vg_id, ID_LEN);
 	memcpy(new_vgid, &vg->id, ID_LEN);
@@ -1336,7 +1336,6 @@ void device_id_update_vg_uuid(struct cmd_context *cmd, struct volume_group *vg,
 	if (update &&
 	    !device_ids_write(cmd))
 		stack;
- out:
 	unlock_devices_file(cmd);
 }
 

