From: Milan Broz <mbroz@redhat.com>
Date: Thu, 17 Sep 2009 17:25:43 +0200
Subject: [PATCH 2/3] Fix possible lost of temporary devices in pvmove.
Message-ID: <4AB254F7.5050509@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix possible lost of temporary devices in pvmove.

If some process locks temporary pvmove device (udev scan etc),
the code do not detect that device remains in kernel.
Because device is removed from lvm metadata, subsequent
pvmove will crash leaving suspended devices.

Fix consists from these steps:
 - with previous patch we can detect that lv_deactivate failed.
 
 - instead of creating empty pvmove layer in remove_layers_for_segments_all
 replace this device with error target.
 (which btw means that number of segments for active kernel device is still
 the same as size in metadata - now we have activated mirror and zero size
 LV in metadata)
 
 - if pvmove fails, try to sleep some time and retry. Usually device is locked
 by scan from wrong udev rule and remapping to error target causes all scanning
 programs to quickly fail.
 (This is real hack, but it was proved in cryptsetup in similar situation
 that it helps.)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/lv_manip.c |    2 +-
 tools/pvmove.c          |   27 ++++++++++++++++++++++-----
 2 files changed, 23 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 70d9da2..33be952 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2351,7 +2351,7 @@ int remove_layers_for_segments_all(struct cmd_context *cmd,
 			return_0;
 	}
 
-	if (!lv_empty(layer_lv))
+	if (!replace_lv_with_error_segment(layer_lv))
 		return_0;
 
 	return 1;
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 2490863..364b084 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -456,6 +456,26 @@ out:
 	return r;
 }
 
+#define TEMP_DEVICE_REMOVAL_RETRIES 3
+static int retry_deactivate_lv(struct cmd_context *cmd,
+				struct logical_volume *lv_mirr)
+{
+	int retries = 0;
+
+	while (!deactivate_lv(cmd, lv_mirr)) {
+		log_debug("Temporary pvmove volume %s locked, retrying...",
+			  lv_mirr->name);
+		sleep(1);
+		if (++retries > TEMP_DEVICE_REMOVAL_RETRIES) {
+			log_error("ABORTING: Unable to deactivate temporary logical "
+			"volume %s", lv_mirr->name);
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
 static int _finish_pvmove(struct cmd_context *cmd, struct volume_group *vg,
 			  struct logical_volume *lv_mirr,
 			  struct dm_list *lvs_changed)
@@ -517,11 +537,8 @@ static int _finish_pvmove(struct cmd_context *cmd, struct volume_group *vg,
 	resume_lvs(cmd, lvs_changed);
 
 	/* Deactivate mirror LV */
-	if (!deactivate_lv(cmd, lv_mirr)) {
-		log_error("ABORTING: Unable to deactivate temporary logical "
-			  "volume \"%s\"", lv_mirr->name);
-		r = 0;
-	}
+	if (!retry_deactivate_lv(cmd, lv_mirr))
+		return 0;
 
 	log_verbose("Removing temporary pvmove LV");
 	if (!lv_remove(lv_mirr)) {



